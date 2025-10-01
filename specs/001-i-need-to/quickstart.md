# Quickstart Test Plan: Llama 3 JSON Tool Parser Bug Fix

## Purpose
Validate that the Llama 3 JSON tool parser correctly extracts and preserves plain-text content surrounding tool calls in non-streaming mode.

## Prerequisites
- vLLM development environment set up
- pytest installed
- Changes applied to:
  - `/vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py`
  - `/tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py`

## Test Execution

### Run Unit Tests
```bash
# From repository root
cd /Volumes/SourceCode/vllm

# Run the specific test file
pytest tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py -v

# Expected: All tests pass
```

### Verify Test Coverage

#### Test 1: Single Tool Call with Prefix and Suffix
**Purpose**: Verify text before and after JSON is preserved

**Test**: `test_extract_tool_calls_simple`

**Expected Result**:
- ✅ `tools_called=True`
- ✅ `len(tool_calls)==1`
- ✅ `content=="Here is the result: Would you like to know more?"`

#### Test 2: Multiple Tool Calls with Surrounding Text
**Purpose**: Verify "; " delimiter is stripped and surrounding text preserved

**Test**: `test_extract_tool_calls_multiple_json_with_surrounding_text`

**Expected Result**:
- ✅ `tools_called=True`
- ✅ `len(tool_calls)==3`
- ✅ `content=="Here are the results: Would you like to know more?"`
- ✅ `"; "` delimiters NOT present in content

#### Test 3: Tool Call Without Surrounding Text
**Purpose**: Verify empty context returns None

**Test**: `test_extract_tool_calls_with_arguments`

**Expected Result**:
- ✅ `tools_called=True`
- ✅ `content is None` (no surrounding text)

#### Test 4: Whitespace-Only Surrounding Text
**Purpose**: Verify whitespace-only is treated as empty

**Test**: New test `test_extract_tool_calls_whitespace_only`

**Expected Result**:
- ✅ `tools_called=True`
- ✅ `content is None` (whitespace-only treated as empty)

#### Test 5: No Tool Calls
**Purpose**: Verify non-tool-call text is unchanged

**Test**: `test_extract_tool_calls_no_json`

**Expected Result**:
- ✅ `tools_called=False`
- ✅ `content==model_output` (entire output preserved)

#### Test 6: Malformed JSON
**Purpose**: Verify error handling preserves original text

**Test**: `test_extract_tool_calls_invalid_json`

**Expected Result**:
- ✅ `tools_called=False`
- ✅ `content==model_output` (malformed JSON treated as plain text)

## Manual Validation

### Interactive Test
```python
from transformers import AutoTokenizer
from vllm.entrypoints.openai.tool_parsers.llama_tool_parser import Llama3JsonToolParser

# Setup
tokenizer = AutoTokenizer.from_pretrained("gpt2")
parser = Llama3JsonToolParser(tokenizer)

# Test Case 1: Prefix + Suffix
output1 = 'Let me search for that: {"name": "search", "parameters": {"q": "test"}} Done!'
result1 = parser.extract_tool_calls(output1, None)
print(f"Tools called: {result1.tools_called}")
print(f"Content: {result1.content}")
# Expected: Content = "Let me search for that: Done!"

# Test Case 2: Multiple with delimiter
output2 = '{"name": "a", "parameters": {}}; {"name": "b", "parameters": {}}'
result2 = parser.extract_tool_calls(output2, None)
print(f"Tools: {len(result2.tool_calls)}")
print(f"Content: {result2.content}")
# Expected: 2 tools, Content = None (no text outside JSON)

# Test Case 3: Text between calls (edge case)
output3 = 'Start {"name": "a", "parameters": {}}; {"name": "b", "parameters": {}} End'
result3 = parser.extract_tool_calls(output3, None)
print(f"Content: {result3.content}")
# Expected: "Start End" (delimiter stripped)
```

## Success Criteria

### All Tests Pass
✅ pytest run completes with 0 failures

### Code Changes Minimal
✅ Only `extract_tool_calls` method modified
✅ No changes to streaming method
✅ No new dependencies

### Behavior Correct
✅ Prefix text preserved
✅ Suffix text preserved
✅ "; " delimiters stripped
✅ Whitespace-only → None
✅ No surrounding text → None
✅ Special characters preserved as-is
✅ Backward compatibility maintained

## Regression Testing

### Run Related Tests
```bash
# Run all tool parser tests
pytest tests/entrypoints/openai/tool_parsers/ -v

# Run OpenAI entrypoint tests
pytest tests/entrypoints/openai/ -k "tool" -v
```

**Expected**: All existing tests continue to pass

## Performance Check

### Quick Benchmark (Optional)
```python
import time
from transformers import AutoTokenizer
from vllm.entrypoints.openai/tool_parsers.llama_tool_parser import Llama3JsonToolParser

tokenizer = AutoTokenizer.from_pretrained("gpt2")
parser = Llama3JsonToolParser(tokenizer)

test_output = 'Here is the result: {"name": "search", "parameters": {"query": "test"}} Done!'

# Warm-up
for _ in range(100):
    parser.extract_tool_calls(test_output, None)

# Benchmark
start = time.time()
for _ in range(10000):
    parser.extract_tool_calls(test_output, None)
end = time.time()

print(f"Time per call: {(end - start) / 10000 * 1000:.3f}ms")
# Expected: < 0.1ms (negligible overhead)
```

## Troubleshooting

### Test Failures

**Symptom**: `test_extract_tool_calls_simple` fails with `content is None`
**Cause**: Fix not applied correctly
**Solution**: Verify changes to `extract_tool_calls` method around line 103

**Symptom**: Content includes "; " delimiter
**Cause**: Delimiter stripping not implemented
**Solution**: Verify `context.replace('; ', ' ')` in fix

**Symptom**: Whitespace-only test fails
**Cause**: Whitespace not treated as empty
**Solution**: Verify `if not context or context.isspace(): context = None`

### Import Errors

**Symptom**: `ModuleNotFoundError`
**Cause**: Not running from repository root
**Solution**: `cd /Volumes/SourceCode/vllm` before running tests

## Cleanup

### After Testing
```bash
# Ensure all tests pass
pytest tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py -v

# Run linter
ruff check vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py

# Run type checker
mypy vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py
```

## Next Steps

After all tests pass:
1. Run full test suite: `pytest tests/entrypoints/openai/`
2. Verify no regressions in related functionality
3. Ready for code review and merge

## Summary

This quickstart validates:
✅ Bug fix works correctly
✅ All acceptance scenarios pass
✅ Edge cases handled
✅ No regressions introduced
✅ Performance impact negligible
✅ Code quality maintained (linting, typing)
