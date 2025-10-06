# Test Interface Contract

## Overview
Defines the standard interface that all tool parser tests must implement.

## Standard Test Functions

Every tool parser test file (`test_*_tool_parser.py`) MUST implement these test functions:

### 1. test_no_tool_calls
**Purpose:** Verify parser handles plain text without tool syntax
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_no_tool_calls(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Model output with no tool call syntax (plain text)

**Expected Behavior:**
- Returns `ExtractedToolCallInformation(tools_called=False, tool_calls=[], content=model_output)`
- Streaming mode returns same final result

**Assertions:**
```python
assert not extracted.tools_called
assert extracted.tool_calls == []
assert extracted.content == model_output
```

---

### 2. test_single_tool_call_simple_args
**Purpose:** Verify parser extracts one tool with basic arguments
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_single_tool_call_simple_args(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Model output with one tool call
- Arguments: simple types (string, number)

**Expected Behavior:**
- Returns `ExtractedToolCallInformation(tools_called=True, tool_calls=[...], content=None)`
- Tool call has correct name and JSON arguments

**Assertions:**
```python
assert extracted.tools_called
assert len(extracted.tool_calls) == 1
assert extracted.tool_calls[0].type == "function"
assert extracted.tool_calls[0].function.name == expected_name
assert json.loads(extracted.tool_calls[0].function.arguments) == expected_args_dict
assert extracted.content is None  # or expected content if mixed mode
```

---

### 3. test_parallel_tool_calls
**Purpose:** Verify parser handles multiple tools in one response
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_parallel_tool_calls(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Model output with 2+ tool calls

**Expected Behavior:**
- Returns all tool calls with proper indexing
- Each tool call has unique ID

**Assertions:**
```python
assert extracted.tools_called
assert len(extracted.tool_calls) == expected_count
for i, tool_call in enumerate(extracted.tool_calls):
    assert tool_call.id  # Non-empty
    assert tool_call.type == "function"
    # For streaming, verify index matches position
```

---

### 4. test_various_data_types
**Purpose:** Verify parser handles all JSON types in arguments
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_various_data_types(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Model output with tool call containing:
  - String, integer, float, boolean, null, array, nested object

**Expected Behavior:**
- All types correctly parsed and preserved

**Assertions:**
```python
args = json.loads(extracted.tool_calls[0].function.arguments)
assert isinstance(args["string_field"], str)
assert isinstance(args["int_field"], int)
assert isinstance(args["bool_field"], bool)
assert args["null_field"] is None
assert isinstance(args["array_field"], list)
assert isinstance(args["object_field"], dict)
```

---

### 5. test_empty_arguments
**Purpose:** Verify parser handles parameterless tool calls
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_empty_arguments(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Model output with tool call with no parameters

**Expected Behavior:**
- Returns tool call with `arguments="{}"` or `arguments=""`

**Assertions:**
```python
assert extracted.tools_called
args = extracted.tool_calls[0].function.arguments
assert args in ["{}", ""]
```

---

### 6. test_surrounding_text
**Purpose:** Verify parser extracts tools from mixed content
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_surrounding_text(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Model output with text before/after tool calls
- May include whitespace

**Expected Behavior:**
- Tool calls extracted correctly
- Surrounding text handling is parser-specific

**Assertions:**
```python
assert extracted.tools_called
assert len(extracted.tool_calls) >= 1
# Content handling varies by parser - document expected behavior
```

---

### 7. test_escaped_strings
**Purpose:** Verify parser handles escaped characters in arguments
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_escaped_strings(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Arguments with quotes, backslashes, newlines, unicode

**Expected Behavior:**
- Escaping preserved in JSON arguments

**Assertions:**
```python
args = json.loads(extracted.tool_calls[0].function.arguments)
assert args["quoted"] == 'He said "hello"'
assert args["path"] == "C:\\Users\\file"
```

---

### 8. test_malformed_input
**Purpose:** Verify parser gracefully handles invalid syntax
**Modes:** Both streaming and non-streaming
**Signature:**
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_malformed_input(parser_fixture, streaming: bool):
    ...
```

**Input:**
- Incomplete JSON, mismatched brackets, invalid syntax

**Expected Behavior:**
- No exceptions raised
- Treats as regular text (tools_called=False)

**Assertions:**
```python
# Should not raise exception
assert not extracted.tools_called
assert extracted.tool_calls == []
assert extracted.content == model_output
```

---

### 9. test_streaming_reconstruction
**Purpose:** Verify streaming produces same result as non-streaming
**Modes:** Streaming only
**Signature:**
```python
def test_streaming_reconstruction(parser_fixture):
    ...
```

**Input:**
- Model output split into realistic token deltas

**Expected Behavior:**
- Final reconstructed tool calls match non-streaming result

**Assertions:**
```python
# Run both streaming and non-streaming
streaming_result = run_tool_extraction(parser, output, streaming=True)
nonstreaming_result = run_tool_extraction(parser, output, streaming=False)
assert streaming_result == nonstreaming_result
```

---

### 10. test_streaming_boundary_splits
**Purpose:** Verify streaming handles splits at critical points
**Modes:** Streaming only
**Signature:**
```python
def test_streaming_boundary_splits(parser_fixture):
    ...
```

**Input:**
- Deltas split mid-name, mid-arguments, between tools

**Expected Behavior:**
- Correct reconstruction regardless of split point

**Assertions:**
```python
# Test multiple split strategies
for delta_sequence in split_strategies:
    result = run_tool_extraction_streaming(parser, delta_sequence)
    assert len(result.tool_calls) == expected_count
    # Verify tool calls match expected
```

---

## Fixtures Contract

Every test file MUST provide:

### 1. Parser Fixture
**Name:** `{parser_name}_parser` (e.g., `hermes_parser`, `pythonic_parser`)
**Scope:** Function (fresh instance per test)
**Returns:** Configured parser instance

```python
@pytest.fixture
def hermes_parser(tokenizer_fixture):
    return Hermes2ProToolParser(tokenizer_fixture)
```

### 2. Tokenizer Fixture
**Name:** `{parser_name}_tokenizer` or shared `mock_tokenizer`
**Scope:** Module (reused across tests)
**Returns:** Tokenizer instance (real or mocked)

```python
@pytest.fixture(scope="module")
def hermes_tokenizer():
    return get_tokenizer("model-name")
```

---

## Utilities Contract

All test files MUST use utilities from `tests/entrypoints/openai/tool_parsers/utils.py`:

### run_tool_extraction
```python
def run_tool_extraction(
    tool_parser: ToolParser,
    model_output: str,
    request: ChatCompletionRequest | None = None,
    streaming: bool = False,
    assert_one_tool_per_delta: bool = True,
) -> tuple[str | None, list[ToolCall]]:
    """
    Unified interface for running extraction in streaming or non-streaming mode.
    Returns: (content, tool_calls)
    """
```

### run_tool_extraction_streaming
```python
def run_tool_extraction_streaming(
    tool_parser: ToolParser,
    model_deltas: Iterable[str],
    request: ChatCompletionRequest | None = None,
    assert_one_tool_per_delta: bool = True,
) -> StreamingToolReconstructor:
    """
    Simulates streaming by processing deltas sequentially.
    Returns: Reconstructor with accumulated tool_calls and content
    """
```

---

## Marker Contract

Tests MUST use appropriate pytest markers:

### @pytest.mark.slow_test
For extensive streaming tests or large test matrices that take >5 seconds:
```python
@pytest.mark.slow_test
def test_extensive_streaming_scenarios(parser_fixture):
    ...
```

### @pytest.mark.xfail
For tests that expose known parser bugs:
```python
@pytest.mark.xfail(reason="Parser bug: does not handle nested arrays correctly")
def test_nested_arrays(parser_fixture):
    ...
```

---

## Documentation Contract

Each test file MUST include:

1. **Module docstring** explaining parser format and models it supports
2. **Test constants** defining example model outputs at module level
3. **Comments** for parser-specific edge cases

Example:
```python
"""
Tests for Hermes 2 Pro tool parser.

Parser format: XML-based with <tool_call>...</tool_call> tags
Models: Hermes 2 Pro, Hermes 2 Pro Mistral
Special handling: Scratch pad tags, token buffering
"""

# Example outputs
SIMPLE_TOOL_OUTPUT = '<tool_call>{"name": "get_weather", "arguments": {"city": "Tokyo"}}</tool_call>'
PARALLEL_TOOLS_OUTPUT = '<tool_call>...</tool_call><tool_call>...</tool_call>'
```

---

## Failure Message Contract

Assertions MUST include descriptive messages:

```python
# Good
assert len(tool_calls) == 2, f"Expected 2 tool calls, got {len(tool_calls)}"

# Bad
assert len(tool_calls) == 2
```

---

## Parser-Specific Extensions Contract

Parsers MAY include additional tests beyond the standard 10:

```python
# Standard tests (required)
def test_no_tool_calls(...): ...
def test_single_tool_call_simple_args(...): ...
# ... (8 more standard tests)

# Parser-specific extensions (optional)
def test_hermes_scratch_pad_handling(...): ...
def test_mistral_alphanumeric_id_format(...): ...
```

Extensions MUST be clearly documented and named `test_{parser_name}_{specific_feature}`.
