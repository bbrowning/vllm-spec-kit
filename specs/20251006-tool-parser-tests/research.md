# Phase 0: Research & Analysis

## Overview
Research findings for implementing comprehensive unit tests across all 23 vLLM tool call parsers.

## Tool Parser Analysis

### Parser Inventory
Confirmed 23 tool parsers requiring test coverage:
1. deepseekv31
2. deepseekv3
3. glm4_moe
4. granite
5. granite_20b_fc
6. hermes
7. hunyuan_a13b
8. internlm2
9. jamba
10. kimi_k2
11. llama
12. llama4_pythonic
13. longcat
14. minimax
15. mistral
16. openai
17. phi4mini
18. pythonic
19. qwen3coder
20. qwen3xml
21. seed_oss
22. step3
23. xlam

### Existing Test Coverage
**Files with existing tests** (5 parsers):
- `test_hermes_tool_parser.py` - Hermes parser with streaming/non-streaming tests
- `test_hunyuan_a13b_tool_parser.py` - Hunyuan A13B parser tests
- `test_llama3_json_tool_parser.py` - Llama3 JSON format tests
- `test_llama4_pythonic_tool_parser.py` - Llama4 pythonic parser tests
- `test_pythonic_tool_parser.py` - Generic pythonic parser tests

**Files needing new tests** (18 parsers):
deepseekv31, deepseekv3, glm4_moe, granite, granite_20b_fc, internlm2, jamba, kimi_k2, llama, longcat, minimax, mistral, openai, phi4mini, qwen3coder, qwen3xml, seed_oss, step3, xlam

## Common Test Patterns

### Pattern Analysis from Existing Tests

**1. Test Structure Pattern** (from `test_pythonic_tool_parser.py`)
- Parameterized tests using `@pytest.mark.parametrize` for streaming/non-streaming
- Fixture-based parser instantiation
- Mock tokenizers for test isolation
- Helper utilities in `utils.py` for tool extraction

**2. Standard Test Scenarios**
From analyzing existing tests, every parser should test:

a. **No Tool Calls** (FR-002)
   - Model output with plain text, no tool call syntax
   - Expected: `tools_called=False`, `content=original_text`, `tool_calls=[]`

b. **Single Tool Call** (FR-003)
   - Model output with one valid tool call
   - Simple arguments (strings, numbers)
   - Expected: One `ToolCall` with correct name and arguments

c. **Multiple Parallel Tool Calls** (FR-004)
   - Model output with 2+ tool calls
   - Expected: Multiple `ToolCall` objects with proper indexing

d. **Various Data Types** (FR-005)
   - Arguments containing: strings, integers, booleans, null, nested objects, arrays
   - Expected: Correct JSON serialization of all types

e. **Empty/Parameterless Tool Calls** (FR-006)
   - Tool calls with `()` or `{}` arguments
   - Expected: `arguments="{}"` or `arguments=""`

f. **Surrounding Text/Whitespace** (FR-007)
   - Tool calls with leading/trailing text or whitespace
   - Expected: Correct extraction of tool call portion only

g. **Escaped Strings/Special Characters** (FR-008)
   - Arguments with escaped quotes, backslashes, unicode
   - Expected: Proper handling and JSON encoding

h. **Malformed Input** (FR-009)
   - Invalid JSON, incomplete syntax, mismatched brackets
   - Expected: Graceful degradation (treat as text or return empty tool_calls)

i. **Streaming Mode** (FR-010, FR-011, FR-012)
   - Incremental deltas that reconstruct full tool calls
   - Tool calls split across multiple tokens
   - Expected: Correct reconstruction via `DeltaMessage` stream

### Test Infrastructure Patterns

**Shared Utilities** (`tests/entrypoints/openai/tool_parsers/utils.py`):
- `StreamingToolReconstructor`: Accumulates deltas into complete tool calls
- `run_tool_extraction()`: Unified interface for streaming/non-streaming tests
- `run_tool_extraction_streaming()`: Simulates streaming with token-by-token iteration
- `run_tool_extraction_nonstreaming()`: Direct parser call for complete output

**Fixture Patterns**:
- Module-scoped tokenizer fixtures (avoid repeated initialization)
- Function-scoped parser fixtures (fresh instance per test for isolation)
- Request fixtures for `ChatCompletionRequest` objects

**Assertion Patterns**:
- Verify `tools_called` boolean matches presence of tool calls
- Check tool call IDs are generated (non-empty strings, length > 16)
- Validate `type == "function"`
- Compare `FunctionCall` objects for exact name/arguments match
- Assert content is `None` when tools are called (unless mixed mode)

## Parser-Specific Format Research

### Format Categories

**1. XML-Based Parsers** (Hermes, possibly others)
- Format: `<tool_call>{"name": "...", "arguments": {...}}</tool_call>`
- Research approach: Read parser regex patterns, examine existing tests

**2. JSON Array Parsers** (Mistral, possibly others)
- Format: `[TOOL_CALLS][{"name": "...", "arguments": {...}}]`
- Research approach: Examine parser token detection and JSON parsing logic

**3. Pythonic Call Parsers** (Pythonic, Llama4 Pythonic)
- Format: `[func_name(arg1=val1, arg2=val2)]`
- Research approach: AST parsing code in parser, existing test examples

**4. Other Custom Formats** (DeepSeek, Granite, Qwen, etc.)
- Research approach for each:
  1. Search web for official model documentation/examples
  2. Read parser implementation to understand expected format
  3. Combine findings to create realistic test inputs

### Example Model Output Research Strategy

For parsers without existing tests:

**Step 1: Web Research**
- Query: "[Model Name] tool calling format examples"
- Sources: Official model cards, HuggingFace docs, GitHub repos, blog posts
- Extract: Example outputs showing tool call syntax

**Step 2: Code Analysis**
- Read parser's `extract_tool_calls()` implementation
- Identify regex patterns, start/end tokens, JSON expectations
- Note any special handling (escaping, prefixes, etc.)

**Step 3: Synthesize Test Data**
- Combine web examples with code understanding
- Create realistic model outputs covering all standard patterns
- Document any parser-specific quirks discovered

## Test Execution Strategy

### Performance Considerations (Constitution Principle I)
**Decision**: Mark extensive streaming tests with `@pytest.mark.slow_test`
**Rationale**: Fast CI/CD feedback requires quick core tests. Slow tests run separately.
**Constraints**: Target <2min per parser for unmarked tests

### Test Isolation (FR-011)
**Decision**: Each test creates fresh parser instance via function-scoped fixture
**Rationale**: Prevents state pollution between tests, ensures deterministic results
**Implementation**:
```python
@pytest.fixture
def parser_name(tokenizer_fixture):
    return ParserClass(tokenizer_fixture)
```

### Streaming Test Approach
**Decision**: Use `run_tool_extraction_streaming()` utility with character-by-character deltas
**Rationale**: Simulates realistic streaming without requiring live model
**Edge cases to test**:
- Tool call split mid-name
- Tool call split mid-arguments
- Multiple tools across delta boundaries
- Whitespace and formatting tokens

### Known Failures Handling (FR-021)
**Decision**: Mark failing tests with `@pytest.mark.xfail(reason="Parser bug: description")`
**Rationale**: Documents bugs without blocking test suite, provides TODO list for fixes
**Documentation**: Each xfail marker includes specific bug description

## Test Organization

### File Structure
```
tests/entrypoints/openai/tool_parsers/
├── utils.py                          # Shared utilities (existing)
├── conftest.py                       # Shared fixtures (if needed)
├── test_deepseekv31_tool_parser.py  # New
├── test_deepseekv3_tool_parser.py   # New
├── test_glm4_moe_tool_parser.py     # New
├── test_granite_tool_parser.py      # New
├── test_granite_20b_fc_tool_parser.py # New
├── test_hermes_tool_parser.py       # Extend existing
├── test_hunyuan_a13b_tool_parser.py # Extend existing
├── test_internlm2_tool_parser.py    # New
├── test_jamba_tool_parser.py        # New
├── test_kimi_k2_tool_parser.py      # New
├── test_llama_tool_parser.py        # New
├── test_llama3_json_tool_parser.py  # Extend existing
├── test_llama4_pythonic_tool_parser.py # Extend existing
├── test_longcat_tool_parser.py      # New
├── test_minimax_tool_parser.py      # New
├── test_mistral_tool_parser.py      # New
├── test_openai_tool_parser.py       # New or extend if exists
├── test_phi4mini_tool_parser.py     # New
├── test_pythonic_tool_parser.py     # Extend existing
├── test_qwen3coder_tool_parser.py   # New
├── test_qwen3xml_tool_parser.py     # New
├── test_seed_oss_tool_parser.py     # New
├── test_step3_tool_parser.py        # New
└── test_xlam_tool_parser.py         # New
```

### Test Naming Convention
Pattern: `test_{scenario}_{streaming_mode}`
Examples:
- `test_no_tool_calls_nonstreaming()`
- `test_single_tool_call_streaming()`
- `test_parallel_tool_calls_nonstreaming()`
- `test_malformed_input_streaming()`

### Parameterization Strategy
**Decision**: Use `@pytest.mark.parametrize("streaming", [True, False])` for standard tests
**Rationale**: DRY principle, ensures both modes tested consistently
**Example**:
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_single_tool_call(parser, streaming):
    content, tool_calls = run_tool_extraction(parser, model_output, streaming=streaming)
    # assertions
```

## Technology Choices

### Testing Framework
**Decision**: pytest (existing)
**Rationale**: Already used by vLLM, feature-rich (parametrization, fixtures, markers)
**Alternatives considered**: unittest (less expressive), nose (deprecated)

### Mock Strategy
**Decision**: Mock tokenizers for most tests
**Rationale**: Tokenizers not core to parsing logic, mocking improves test speed
**When to use real tokenizers**: Parser-specific tests where tokenization affects parsing

### Assertion Style
**Decision**: Direct assertions with descriptive messages
**Rationale**: pytest provides excellent failure output, custom messages clarify intent
**Example**:
```python
assert len(tool_calls) == 2, f"Expected 2 tool calls, got {len(tool_calls)}"
assert tool_calls[0].function.name == "get_weather", "First tool name mismatch"
```

## Dependencies

### Existing Infrastructure
- `vllm.entrypoints.openai.protocol`: `ToolCall`, `FunctionCall`, `ExtractedToolCallInformation`
- `vllm.entrypoints.openai.tool_parsers`: Parser implementations and `ToolParserManager`
- `tests/entrypoints/openai/tool_parsers/utils.py`: Shared test utilities
- `vllm.transformers_utils.tokenizer`: Tokenizer access

### No New Dependencies
All required testing infrastructure exists. No new packages needed.

## Risk Analysis

### Potential Issues

**1. Parser Bugs Blocking Test Creation**
- **Risk**: Some parsers may be so broken tests are hard to write
- **Mitigation**: Use xfail markers, document bugs, write tests for expected behavior anyway

**2. Model Output Format Ambiguity**
- **Risk**: For parsers without docs, format may be unclear
- **Mitigation**: Examine parser code carefully, create best-effort examples, mark uncertain tests

**3. Test Suite Runtime**
- **Risk**: 23 parsers × 10-15 tests = 200-400 tests could be slow
- **Mitigation**: Use mocked tokenizers, mark slow streaming tests, parallelize test execution

**4. Streaming Test Complexity**
- **Risk**: Streaming edge cases may be hard to reproduce
- **Mitigation**: Use existing `utils.py` infrastructure, study existing streaming tests as templates

## Success Criteria

From spec FR-021 and clarifications:
1. ✅ All 23 parsers have test files created
2. ✅ Each parser has tests for all standard patterns (FR-002 through FR-020)
3. ✅ Tests use hybrid infrastructure (shared utilities, parser-specific fixtures)
4. ✅ Failing tests marked with xfail and documented
5. ✅ Both streaming and non-streaming modes tested
6. ✅ Test isolation maintained (fresh parser instances)

## Next Steps (Phase 1)
1. Create data model for test cases (model output, expected tool calls, metadata)
2. Generate contracts defining test interfaces
3. Create quickstart.md with example test execution
4. Update CLAUDE.md with project context
