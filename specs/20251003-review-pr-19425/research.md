# Research: PR #19425 - Mistral Tool Parser Streaming Refactor

**Date**: 2025-10-03
**Branch**: mistral-tool-parser-streaming-update
**PR**: https://github.com/vllm-project/vllm/pull/19425

## Decision

Replace the `partial_json_parser`-based streaming implementation with two custom stateful parsers:

1. **Pre-v11 tokenizers**: Uses `ijson` (incremental JSON parser) with coroutine-based event handling for format `[TOOL_CALLS][{"name": "add", "arguments":{"a": 3.5, "b": 4}}]`
2. **v11+ tokenizers**: Uses custom regex + state machine for format `[TOOL_CALLS]add{"a": 3.5, "b": 4}`

## Rationale

**Fixes Three Critical Bugs**:
- **Issue #13622**: Integer arguments dropped during streaming (pre-v11)
- **Issue #17585**: Corrupt tool_calls with missing punctuation and duplicate final deltas
- **Issue #20028**: Complete streaming failure with JSONDecodeError for Mistral Small 3.2

**Root Cause**: The old `partial_json_parser` implementation:
- Auto-completed incomplete JSON unpredictably
- Lost characters when comparing partial states (line 314 in old code)
- Failed to handle different tokenizer version formats

**Benefits of New Approach**:
- Fine-grained control over what gets streamed and when
- Proper handling of both old and new Mistral tokenizer formats
- Deterministic streaming without character loss
- Follows proven pattern from PR #16096 (Hermes tool parser)

## Alternatives Considered

1. **Continue using partial_json_parser**: Rejected - was root cause of corruption
2. **Single unified parser**: Not viable due to fundamental format differences between tokenizer versions
3. **Regex-only solution**: Insufficient for pre-v11 nested JSON structures

---

## PR Context (from gh pr view 19425)

### Issues Fixed
1. **#13622** - Integer parsing failure in streaming for Mistral-7B-Instruct-v0.3
2. **#17585** - Corrupt tool calls with missing characters for Ministral/Mistral-Large
3. **#20028** - Complete streaming failure for Mistral-Small-3.2

### Changed Files
- `.buildkite/test-pipeline.yaml` - Increased GPU allocation for tool use tests
- `requirements/common.txt` - Added ijson dependency
- `tests/tool_use/test_mistral_tool_parser.py` - 751 lines comprehensive test suite
- `tests/tool_use/utils.py` - Test utilities
- `vllm/entrypoints/openai/tool_parsers/mistral_tool_parser.py` - 571 lines core implementation

### Reviewer Concerns & Resolutions
1. **Bot token assertions** (gemini-code-assist) - RESOLVED in commit 0e0077a
2. **Code complexity** (gemini-code-assist) - ACKNOWLEDGED, inherent to stateful parsing
3. **Function name streaming** (sfbemerk) - FIXED in commit a338dc1, now sends complete name
4. **Finish reason not sent** (DarkLight1337) - FIXED, returns empty DeltaMessage()
5. **Merge conflicts** (mergify) - REQUIRES REBASE

---

## Test Coverage Analysis

### Test File: tests/tool_use/test_mistral_tool_parser.py

**Size**: 751 lines comprehensive coverage

**Fixtures**:
- `mistral_pre_v11_tokenizer`: mistralai/Mistral-7B-Instruct-v0.3
- `mistral_tokenizer`: mistralai/Mistral-Small-3.2-24B-Instruct-2506
- `mistral_pre_v11_tool_parser`: Parser for old format
- `mistral_tool_parser`: Parser for new format

### Coverage by Category

**Non-Streaming (Pre-v11)**:
- ✅ No tools (text-only)
- ✅ Single tool with integers
- ✅ Single tool with strings
- ✅ Arguments before name in JSON
- ✅ Name key collision edge case

**Non-Streaming (v11+)**:
- ✅ Single tool with integers
- ✅ Single tool with strings
- ✅ Multiple parallel tools

**Streaming (Pre-v11)** - 7 parametrized cases:
- ✅ No tools, single tool (ints/strings), complex arguments
- ✅ Arguments before name, name collision, multiple tools
- ✅ One-chunk delivery

**Streaming (v11+)** - 6 parametrized cases:
- ✅ Single/multiple tools, content before tools
- ✅ One-chunk delivery

### Test Utilities

**stream_delta_message_generator** (lines 70-131):
- Simulates incremental streaming with detokenize_incrementally()
- Validates: role never streamed, one diff per delta, complete function names

**assert_tool_calls** (lines 44-67):
- Validates tool call structure and 9-char alphanumeric IDs

### Coverage Gaps Identified
1. No explicit v13 tokenizer tests
2. No extremely nested argument object tests
3. No malformed JSON recovery tests
4. No partial state persistence tests
5. No tool ID collision tests

---

## Subsystem Architecture

### Core Files
- `vllm/entrypoints/openai/tool_parsers/mistral_tool_parser.py:1-571` - Implementation
- `vllm/entrypoints/openai/tool_parsers/abstract_tool_parser.py` - Base class
- `vllm/entrypoints/openai/serving_chat.py:1000-1027` - Integration (inspects prev_tool_call_arr)

### Dependencies
- `ijson` - Added to requirements/common.txt:50 for pre-v11 streaming
- `mistral_common >= 1.8.2` - Tokenizer support
- `partial-json-parser` - Used in serving_chat.py autocompletion

### Integration Pattern

**HACK** (lines 268-275, 504-510):
```python
# serving_chat.py inspects internal state for finish_reason
# Sets dummy prev_tool_call_arr value to trigger finish_reason
if delta_tool_calls and not self.prev_tool_call_arr:
    self.prev_tool_call_arr = [{"arguments": {}}]
```

### Related Parsers
- `hermes_tool_parser.py` - PR #16096 inspiration
- `llama4_pythonic_tool_parser.py` - finish_reason pattern
- 20+ tool parsers total in vllm/entrypoints/openai/tool_parsers/

---

## ijson & Parsing Strategy

### ijson Usage (Pre-v11 Only)

**Initialization** (lines 91-93):
```python
if _is_pre_v11_tokeniser(self.model_tokenizer):
    self.parse_coro = ijson.parse_coro(
        self.update_stream_state_pre_v11_tokenizer())
```

**Event Handling** (lines 334-358):
| Event | Prefix | Value | State Transition |
|-------|--------|-------|------------------|
| start_map | "item" | - | WAITING_FOR_TOOL_KEY |
| map_key | "item" | "name" | PARSING_NAME |
| string | "item.name" | fn_name | PARSING_NAME_COMPLETED |
| map_key | "item" | "arguments" | WAITING_FOR_ARGUMENTS_START |
| start_map | "item.arguments" | - | PARSING_ARGUMENTS |
| end_map | "item.arguments" | - | PARSING_ARGUMENTS_COMPLETED |
| end_map | "item" | - | TOOL_COMPLETE |
| end_array | "" | - | ALL_TOOLS_COMPLETE |

**_split_delta Strategy** (lines 525-570):
- Splits delta text at strategic points to trigger specific ijson events
- State-dependent: splits after `{`, `:`, `,`, `}`, `]` based on current state
- Key insight: ijson doesn't provide text index, so manual splitting is required

### Stateful Parser (v11+)

**State Machine** (lines 30-42):
```python
class StreamingState(Enum):
    WAITING_FOR_TOOL_START = auto()
    WAITING_FOR_TOOL_KEY = auto()
    PARSING_NAME = auto()
    PARSING_NAME_COMPLETED = auto()
    WAITING_FOR_ARGUMENTS_START = auto()
    PARSING_ARGUMENTS = auto()
    PARSING_ARGUMENTS_COMPLETED = auto()
    TOOL_COMPLETE = auto()
    ALL_TOOLS_COMPLETE = auto()
```

**Logic Flow** (_generate_delta_tool_call, lines 277-332):
1. Detect tool start via `[TOOL_CALLS]` token
2. Accumulate function name until `{`
3. Stream argument chunks incrementally
4. Recursively process multiple tools

**Edge Cases**:
- Content before tool calls - extracted and returned
- Multiple tools - recursive processing
- Empty deltas - return None (incomplete name) or DeltaMessage() (complete)

---

## Tokenizer Version Support

### Detection (lines 59-61)
```python
def _is_pre_v11_tokeniser(model_tokenizer: AnyTokenizer) -> bool:
    return not (isinstance(model_tokenizer, MistralTokenizer) \
        and model_tokenizer.version >= 11)
```

### Format Differences

**Pre-v11** (`< v11`):
- Format: `[TOOL_CALLS][{"name": "add", "arguments":{"a": 3, "b": 4}}]`
- JSON array of objects
- Arguments can appear before name
- Example: mistralai/Mistral-7B-Instruct-v0.3
- Parser: ijson incremental

**v11+** (`>= v11`):
- Format: `[TOOL_CALLS]function_name{"a": 3, "b": 4}`
- Function name outside JSON
- More compact representation
- Multiple: `[TOOL_CALLS]add{"a": 3}[TOOL_CALLS]multiply{"x": 2}`
- Example: mistralai/Mistral-Small-3.2-24B-Instruct-2506
- Parser: Custom state machine

**v13+**:
- No format changes from v11
- Compatibility confirmed in PR discussions

### Regex Patterns

**Pre-v11** (line 97):
```python
self.tool_call_regex = re.compile(r"\[{.*}\]", re.DOTALL)
```

**v11+** (lines 99-100):
```python
self.fn_name_regex = re.compile(
    r'([a-zA-Z0-9_-]+)(\{[\s\S]*?\})(?=\s*$|,|\s)', re.DOTALL)
```

---

## Critical Code References

**State Management**:
- Lines 30-42: StreamingState enum
- Lines 83-93: Initialization, ijson setup

**Pre-v11 Streaming**:
- Lines 334-358: ijson event handler
- Lines 360-523: Main extraction logic
- Lines 525-570: _split_delta utility

**v11+ Streaming**:
- Lines 226-275: Entry point
- Lines 277-332: State machine

**Non-Streaming**:
- Lines 122-199: Unified extraction

**Integration Hacks**:
- Lines 268-274: serving_chat.py v11+ compat
- Lines 504-510: serving_chat.py pre-v11 compat

---

## Review Recommendations

### Verify Issue Coverage
- ✅ Issue #13622 (integer args) - Covered in tests
- ⚠️ Issue #17585 (corrupt completions) - Indirectly tested
- ⚠️ Issue #20028 (JSONDecodeError) - Indirectly prevented

### PR Comment Resolutions
- ✅ Bot token assertions - Fixed
- ✅ Function name chunking - Fixed (single chunk)
- ✅ Finish reason - Fixed (empty DeltaMessage)
- ⚠️ Complexity - Acknowledged, not simplified

### Streaming Logic Analysis Needed
- ijson _split_delta logic review
- v11+ _generate_delta_tool_call recursion
- Error recovery in extract_tool_calls_streaming

### Integration Validation
- serving_chat.py HACK necessity
- prev_tool_call_arr dummy value side effects

### Test Coverage Recommendations
- Add explicit v13 tokenizer fixture
- Add malformed JSON recovery tests
- Add issue reproduction tests
- Add nested object stress tests

**Phase 0 Complete**: All technical unknowns resolved, ready for Phase 1
