# Quickstart: Running Tool Parser Tests

## Prerequisites

1. vLLM development environment set up
2. pytest installed (should be in requirements-dev.txt)
3. Working directory: repository root

## Running All Tool Parser Tests

### Run all tool parser tests
```bash
pytest tests/entrypoints/openai/tool_parsers/ -v
```

### Run tests for a specific parser
```bash
pytest tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py -v
```

### Run specific test pattern across all parsers
```bash
pytest tests/entrypoints/openai/tool_parsers/ -k "test_single_tool_call" -v
```

### Run only streaming tests
```bash
pytest tests/entrypoints/openai/tool_parsers/ -k "streaming" -v
```

### Run only non-streaming tests
```bash
pytest tests/entrypoints/openai/tool_parsers/ -k "nonstreaming" -v
```

### Exclude slow tests (for fast CI feedback)
```bash
pytest tests/entrypoints/openai/tool_parsers/ -m "not slow_test" -v
```

### Run only slow tests
```bash
pytest tests/entrypoints/openai/tool_parsers/ -m "slow_test" -v
```

### Show expected failures (xfail tests)
```bash
pytest tests/entrypoints/openai/tool_parsers/ -v -rx
```

## Example Test Run

### Successful test output
```
tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_no_tool_calls[True] PASSED
tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_no_tool_calls[False] PASSED
tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_single_tool_call_simple_args[True] PASSED
tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_single_tool_call_simple_args[False] PASSED
```

### Expected failure (xfail) output
```
tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py::test_nested_arrays XFAIL (Parser bug: does not handle deeply nested arrays)
```

### Failure output
```
tests/entrypoints/openai/tool_parsers/test_pythonic_tool_parser.py::test_parallel_tool_calls[True] FAILED

Expected 2 tool calls, got 1
AssertionError: Expected 2 tool calls, got 1
```

## Writing a New Test

### Step 1: Create test file
```bash
touch tests/entrypoints/openai/tool_parsers/test_newparser_tool_parser.py
```

### Step 2: Add module structure
```python
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright contributors to the vLLM project

"""
Tests for NewParser tool parser.

Parser format: [describe format]
Models: [list models]
Special handling: [note any quirks]
"""

import pytest
from tests.entrypoints.openai.tool_parsers.utils import run_tool_extraction
from vllm.entrypoints.openai.tool_parsers import ToolParserManager
from vllm.transformers_utils.tokenizer import get_tokenizer

MODEL = "model-identifier"

@pytest.fixture(scope="module")
def newparser_tokenizer():
    return get_tokenizer(MODEL)

@pytest.fixture
def newparser_parser(newparser_tokenizer):
    return ToolParserManager.get_tool_parser("newparser")(newparser_tokenizer)
```

### Step 3: Add test constants
```python
# Example model outputs
SIMPLE_TOOL_OUTPUT = "[tool_syntax_here]"
PARALLEL_TOOLS_OUTPUT = "[multiple_tools_syntax]"
MALFORMED_OUTPUT = "[invalid_syntax]"
```

### Step 4: Implement standard tests
```python
@pytest.mark.parametrize("streaming", [True, False])
def test_no_tool_calls(newparser_parser, streaming):
    model_output = "Just plain text"
    content, tool_calls = run_tool_extraction(
        newparser_parser, model_output, streaming=streaming
    )
    assert content == model_output
    assert len(tool_calls) == 0

@pytest.mark.parametrize("streaming", [True, False])
def test_single_tool_call_simple_args(newparser_parser, streaming):
    model_output = SIMPLE_TOOL_OUTPUT
    content, tool_calls = run_tool_extraction(
        newparser_parser, model_output, streaming=streaming
    )
    assert content is None
    assert len(tool_calls) == 1
    assert tool_calls[0].function.name == "expected_name"
    # ... more assertions

# ... implement remaining standard tests
```

### Step 5: Run the tests
```bash
pytest tests/entrypoints/openai/tool_parsers/test_newparser_tool_parser.py -v
```

### Step 6: Mark failing tests with xfail
```python
@pytest.mark.xfail(reason="Parser bug: incorrectly handles escaped quotes")
@pytest.mark.parametrize("streaming", [True, False])
def test_escaped_strings(newparser_parser, streaming):
    # Test that currently fails due to parser bug
    ...
```

## Debugging Failed Tests

### Run with verbose output
```bash
pytest tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_single_tool_call_simple_args -vv
```

### Run with pdb debugger on failure
```bash
pytest tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_single_tool_call_simple_args --pdb
```

### Show local variables on failure
```bash
pytest tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py::test_single_tool_call_simple_args -l
```

### Capture and show print statements
```bash
pytest tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py -s
```

## Test Coverage

### Generate coverage report
```bash
pytest tests/entrypoints/openai/tool_parsers/ --cov=vllm.entrypoints.openai.tool_parsers --cov-report=html
```

### View coverage report
```bash
open htmlcov/index.html
```

## Common Issues

### Issue: Tokenizer not found
**Error:** `KeyError: 'model-name'`
**Solution:** Use a mock tokenizer or verify model name is correct
```python
from unittest.mock import MagicMock

@pytest.fixture
def mock_tokenizer():
    tokenizer = MagicMock()
    tokenizer.get_vocab.return_value = {}
    return tokenizer
```

### Issue: Test times out
**Error:** Test takes >60s to run
**Solution:** Mark test as slow
```python
@pytest.mark.slow_test
def test_extensive_streaming(...):
    ...
```

### Issue: Streaming test fails but non-streaming passes
**Symptom:** `test_foo[False]` passes, `test_foo[True]` fails
**Debug:** Check delta reconstruction logic
```python
# Add debug output
from tests.entrypoints.openai.tool_parsers.utils import run_tool_extraction_streaming

reconstructor = run_tool_extraction_streaming(parser, model_output)
print(f"Tool calls: {reconstructor.tool_calls}")
print(f"Content: {reconstructor.other_content}")
```

### Issue: Parser raises exception
**Symptom:** Test crashes instead of asserting failure
**Solution:** Verify test expects exception or parser needs fixing
```python
# If exception is expected (malformed input test):
with pytest.raises(ExpectedException):
    run_tool_extraction(parser, malformed_output)

# If exception is a bug, mark xfail:
@pytest.mark.xfail(reason="Parser crashes on empty input")
def test_empty_input(...):
    ...
```

## CI/CD Integration

### Fast feedback loop (pre-commit)
```bash
# Run only unmarked tests (should complete in <30s)
pytest tests/entrypoints/openai/tool_parsers/ -m "not slow_test" --tb=short
```

### Full test suite (CI)
```bash
# Run all tests including slow ones
pytest tests/entrypoints/openai/tool_parsers/ -v --tb=short
```

### Parallel execution
```bash
# Install pytest-xdist
pip install pytest-xdist

# Run tests in parallel
pytest tests/entrypoints/openai/tool_parsers/ -n auto
```

## Validation Checklist

Before considering a parser's tests complete, verify:

- [ ] All 10 standard test functions implemented
- [ ] Both streaming and non-streaming modes tested
- [ ] Parser-specific edge cases covered
- [ ] Fixtures properly scoped (module for tokenizer, function for parser)
- [ ] Test constants defined for model outputs
- [ ] Failing tests marked with xfail and documented
- [ ] Module docstring describes parser format
- [ ] Tests run in <2min (or marked slow_test)
- [ ] All assertions include descriptive messages
- [ ] Tests use shared utilities from utils.py

## Success Criteria

A parser's test suite is complete when:

1. All required tests pass or are marked xfail with justification
2. Test file follows contract in `contracts/test_interface.md`
3. Tests execute quickly enough for CI/CD (<2min unmarked, slow tests separated)
4. Known parser bugs are documented via xfail markers
5. Both streaming and non-streaming modes produce consistent results
6. Edge cases specific to the parser's format are covered

## Next Steps

After completing tests for all 23 parsers:

1. Review xfail markers and create issues for parser bugs
2. Analyze test coverage gaps
3. Consider additional integration tests if needed
4. Document any patterns discovered during testing
5. Update this quickstart with lessons learned
