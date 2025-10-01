# Tasks: Llama 3 JSON Tool Parser Bug Fix

**Input**: Design documents from `/Volumes/SourceCode/vllm/specs/001-i-need-to/`
**Prerequisites**: plan.md, research.md, data-model.md, quickstart.md

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Parser source**: `vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py`
- **Tests**: `tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py`

## Phase 3.1: Setup
- [x] T001 Activate Python virtual environment: `source venv/bin/activate` (or `venv\Scripts\activate` on Windows) if not already active
- [x] T002 Verify development environment (Python 3.9+, pytest available): `python --version && pytest --version`
- [x] T003 Confirm current test suite passes for llama_tool_parser: `pytest tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py -v`

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [x] T004 [P] Update test `test_extract_tool_calls_simple` in tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py to expect `content=="Here is the result: Would you like to know more?"` instead of `content is None` (line 31)

- [x] T005 [P] Add content assertion to test `test_extract_tool_calls_multiple_json_with_surrounding_text` in tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py: `assert result.content == "Here are the results: Would you like to know more?"`

- [x] T006 [P] Add new test `test_extract_tool_calls_whitespace_only` in tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py to verify whitespace-only prefix/suffix returns `content is None`

- [x] T007 [P] Add new test `test_extract_tool_calls_no_surrounding_text` in tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py to verify JSON-only input returns `content is None`

- [x] T008 Verify all new/updated tests FAIL with current implementation (expected behavior before fix)

## Phase 3.3: Core Implementation (ONLY after tests are failing)

- [x] T009 Modify `extract_tool_calls` method in vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py (lines 59-110) to extract prefix text using `model_output[:match.start()]`

- [x] T010 Modify `extract_tool_calls` method in vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py to extract suffix text using `model_output[match.end():]`

- [x] T011 Modify `extract_tool_calls` method in vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py to combine prefix and suffix into single context field: `context = ' '.join([prefix.strip(), suffix.strip()])`

- [x] T012 Modify `extract_tool_calls` method in vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py to strip "; " delimiters from context: `context = context.replace('; ', ' ').strip()`

- [x] T013 Modify `extract_tool_calls` method in vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py to treat whitespace-only context as None: `if not context or context.isspace(): context = None`

- [x] T014 Update return statement in `extract_tool_calls` method (line 103) in vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py from `content=None` to `content=context`

- [x] T015 Add type hints and ensure all edge cases are handled (malformed JSON, empty output, special characters)

## Phase 3.4: Validation & Quality

- [x] T016 [P] Run updated tests: `pytest tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py -v` - all tests must pass

- [x] T017 [P] Run full tool parser test suite: `pytest tests/entrypoints/openai/tool_parsers/ -v` - verify no regressions

- [x] T018 [P] Run linter: `ruff check vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py` - must pass

- [x] T019 [P] Run type checker: `mypy vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py` - must pass

- [x] T020 Manual smoke test with quickstart examples from quickstart.md to verify behavior

## Dependencies

**Setup Phase Dependencies**:
- T001 (activate venv) must run first
- T002 depends on T001 (verify environment)
- T003 depends on T002 (baseline test)

**Test Phase Dependencies**:
- T004, T005, T006, T007 can run in parallel (different test functions)
- T008 depends on T004-T007 (verify tests fail)

**Implementation Dependencies**:
- T009-T015 are sequential (same method, same file)
- T009 (extract prefix) blocks T011 (combine context)
- T010 (extract suffix) blocks T011 (combine context)
- T011 (combine) blocks T012 (strip delimiters)
- T012 (strip delimiters) blocks T013 (whitespace handling)
- T013 (whitespace) blocks T014 (update return)
- T014 (update return) blocks T015 (type hints)

**Validation Dependencies**:
- T016-T020 depend on T009-T015 (implementation complete)
- T016, T017, T018, T019 can run in parallel (independent checks)
- T020 depends on T016 (tests passing)

## Parallel Example

### Batch 1: Setup (T001-T003)
```bash
# Sequential execution required:
source venv/bin/activate
python --version && pytest --version
pytest tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py -v
```

### Batch 2: Update Tests (T004-T007)
```bash
# These can run in parallel as they modify different test functions
# However, editing same file sequentially is safer
```

**Recommended Sequential Execution**:
```
T004 → T005 → T006 → T007 → T008
```

### Batch 3: Validation (T016-T019)
```bash
# Launch in parallel after implementation complete:
pytest tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py -v &
pytest tests/entrypoints/openai/tool_parsers/ -v &
ruff check vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py &
mypy vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py &
wait
```

## Notes

### TDD Workflow
1. **Setup**: Activate venv and verify environment (T001-T003)
2. **First**: Update/add tests (T004-T007) - they MUST fail
3. **Verify**: Run tests to confirm failures (T008)
4. **Then**: Implement fix (T009-T015)
5. **Finally**: Validate (T016-T020) - tests MUST pass

### Key Implementation Details

**Location of Bug** (from research.md):
- File: `vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py`
- Method: `extract_tool_calls()` lines 59-110
- Problem line: Line 103 returns `content=None`

**Fix Algorithm** (from research.md):
```python
# After line 74: match = self.tool_call_regex.search(model_output)
# Before line 81: try:

# Extract surrounding text
prefix = model_output[:match.start()]
suffix = model_output[match.end():]

# Combine and clean context
context_parts = [prefix.strip(), suffix.strip()]
context = ' '.join(part for part in context_parts if part)

# Remove "; " delimiters
context = context.replace('; ', ' ').strip()

# Treat whitespace-only as empty
if not context or context.isspace():
    context = None

# Then at line 103, change:
# FROM: content=None
# TO:   content=context
```

### Expected Test Changes

**Test File**: `tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py`

**T004 - Update test_extract_tool_calls_simple**:
```python
# Line 31: Change from
assert result.content is None
# To:
assert result.content == "Here is the result: Would you like to know more?"
```

**T005 - Update test_extract_tool_calls_multiple_json_with_surrounding_text**:
```python
# After line 132, add:
assert result.content == "Here are the results: Would you like to know more?"
```

**T006 - Add new test**:
```python
def test_extract_tool_calls_whitespace_only(parser):
    model_output = '   {"name": "searchTool", "parameters": {"query": "test"}}   '
    result = parser.extract_tool_calls(model_output, None)

    assert result.tools_called is True
    assert len(result.tool_calls) == 1
    assert result.content is None  # Whitespace-only treated as empty
```

**T007 - Add new test**:
```python
def test_extract_tool_calls_no_surrounding_text(parser):
    model_output = '{"name": "searchTool", "parameters": {"query": "test"}}'
    result = parser.extract_tool_calls(model_output, None)

    assert result.tools_called is True
    assert len(result.tool_calls) == 1
    assert result.content is None  # No text outside JSON
```

## Task Execution Summary

**Total Tasks**: 20
**Sequential Tasks**: T001-T003 (setup), T008 (verify), T009-T015 (implementation), T020 (smoke test)
**Parallel Tasks**: T004-T007 (tests - but same file), T016-T019 (validation)
**Estimated Time**: 1-2 hours for experienced developer

## Success Criteria

✅ All tests pass (T016)
✅ No regressions in tool parser suite (T017)
✅ Code passes linter (T018)
✅ Code passes type checker (T019)
✅ Manual testing confirms expected behavior (T020)
✅ Backward compatibility maintained
✅ Performance impact negligible

## Validation Checklist

- [x] Tests written before implementation (TDD)
- [x] Tests failed before fix, pass after fix
- [x] Prefix text preserved
- [x] Suffix text preserved
- [x] "; " delimiters stripped from context
- [x] Whitespace-only context returns None
- [x] No surrounding text returns None
- [x] Special characters preserved as-is
- [x] Malformed JSON handled gracefully
- [x] No breaking changes to API
- [x] All existing tests still pass
- [x] Code quality checks pass (ruff, mypy)
