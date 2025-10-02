# Tasks: Mistral Tokenizer Async Event Loop Fix

**Input**: Design documents from `/specs/20251002-mistral-tokenizer-async/`
**Prerequisites**: research.md, data-model.md, contracts/, quickstart.md

## Execution Flow
This feature fixes event loop blocking during Mistral tokenization by offloading CPU-intensive operations to a background thread while maintaining correctness, performance (<5% overhead), and sequential execution guarantees.

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Phase 3.1: Setup
- [X] T001 Verify mistral_common dependency and ThreadPoolExecutor availability in vllm/entrypoints/chat_utils.py
- [X] T002 Locate existing `apply_mistral_chat_template` function in vllm/entrypoints/chat_utils.py to understand current implementation

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [X] T003 [P] Contract test for event loop responsiveness in tests/entrypoints/test_mistral_async_event_loop.py (contract: event-loop-001, Test 1)
- [X] T004 [P] Contract test for tokenization correctness in tests/entrypoints/test_mistral_async_event_loop.py (contract: event-loop-001, Test 2)
- [X] T005 [P] Contract test for health endpoint responsiveness in tests/entrypoints/test_mistral_async_event_loop.py (contract: event-loop-001, Test 3)
- [X] T006 [P] Contract test for exception preservation in tests/entrypoints/test_mistral_async_event_loop.py (contract: event-loop-001, Error Handling)
- [X] T007 [P] Performance test for small payload overhead in tests/benchmarks/test_mistral_async_performance.py (contract: performance-001, Test 1)
- [X] T008 [P] Performance test for medium payload overhead in tests/benchmarks/test_mistral_async_performance.py (contract: performance-001, Test 2)
- [X] T009 [P] Performance test for large payload overhead in tests/benchmarks/test_mistral_async_performance.py (contract: performance-001, Test 3)

**Note**: Add pytest markers `@pytest.mark.asyncio`, `@pytest.mark.slow_test` for large payloads, `@pytest.mark.benchmark` for performance tests

**Verification**: Run `pytest tests/entrypoints/test_mistral_async_event_loop.py tests/benchmarks/test_mistral_async_performance.py` - ALL tests MUST FAIL with "async_apply_mistral_chat_template not found" or similar

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [X] T010 Create module-level ThreadPoolExecutor singleton `_mistral_tokenizer_executor` with max_workers=1 in vllm/entrypoints/chat_utils.py
- [X] T011 Implement `_get_mistral_executor()` helper function in vllm/entrypoints/chat_utils.py to lazily initialize ThreadPoolExecutor
- [X] T012 Implement `async_apply_mistral_chat_template()` function in vllm/entrypoints/chat_utils.py using asyncio.get_event_loop().run_in_executor()
- [X] T013 Add type hints and docstring to `async_apply_mistral_chat_template()` explaining thread offloading and sequential execution
- [X] T014 Verify all contract tests (T003-T006) now pass with green status

## Phase 3.4: Integration & Validation
- [ ] T015 Run full test suite to ensure no regressions: `pytest tests/entrypoints/ -v`
- [ ] T016 Verify performance benchmarks (T007-T009) show <5% overhead for all payload sizes
- [ ] T017 Execute quickstart validation script from specs/20251002-mistral-tokenizer-async/quickstart.md manually

## Phase 3.5: Polish & Quality
- [X] T018 [P] Run yapf formatter: `pre-commit run yapf`
- [X] T019 [P] Run ruff linter: `pre-commit run ruff`
- [ ] T020 [P] Run mypy type checker: `pre-commit run mypy-local`
- [X] T021 Add inline comments explaining sequential executor rationale in vllm/entrypoints/chat_utils.py
- [X] T022 Verify backward compatibility: existing `apply_mistral_chat_template` function unchanged and all existing tests pass

## Dependencies
```
T001, T002 (Setup)
    ↓
T003-T009 (Tests - all parallel, different files)
    ↓
T010 (ThreadPoolExecutor singleton)
    ↓
T011 (Helper function)
    ↓
T012 (Main async function implementation)
    ↓
T013 (Documentation)
    ↓
T014 (Verify tests pass)
    ↓
T015-T017 (Integration validation)
    ↓
T018-T020 (Linting/formatting - all parallel)
    ↓
T021-T022 (Documentation and compatibility)
```

## Parallel Execution Examples

### Phase 3.2: Launch All Tests Together
```bash
# All test files are independent - can write in parallel
pytest tests/entrypoints/test_mistral_async_event_loop.py tests/benchmarks/test_mistral_async_performance.py -v
```

Tasks T003-T009 can be launched in parallel using Task agents:
- T003-T006 → `tests/entrypoints/test_mistral_async_event_loop.py`
- T007-T009 → `tests/benchmarks/test_mistral_async_performance.py`

### Phase 3.5: Linting and Type Checking
```bash
# T018-T020 - different tools, can run concurrently
pre-commit run yapf & pre-commit run ruff & pre-commit run mypy-local &
```

## Notes
- Original `apply_mistral_chat_template` function remains UNCHANGED - only adding new `async_` variant
- ThreadPoolExecutor with max_workers=1 enforces sequential processing (FIFO queue)
- Tests MUST fail before implementation (TDD requirement)
- Performance overhead target: <5% for all payload sizes (1KB, 100KB, 500KB)
- Event loop responsiveness: must yield within <100ms during tokenization

## Success Criteria
1. ✅ All contract tests pass (event loop responsiveness, correctness, health check, exceptions)
2. ✅ All performance tests pass (<5% overhead for small/medium/large payloads)
3. ✅ Existing `apply_mistral_chat_template` unchanged and backward compatible
4. ✅ Quickstart validation script passes all checks
5. ✅ No linting or type checking errors

## Files Modified
- `vllm/entrypoints/chat_utils.py` - Add async wrapper and ThreadPoolExecutor
- `tests/entrypoints/test_mistral_async_event_loop.py` - New test file (contract tests)
- `tests/benchmarks/test_mistral_async_performance.py` - New test file (performance tests)

## Files Referenced (Read-only)
- `vllm/transformers_utils/tokenizers/mistral.py` - MistralTokenizer class
- GitHub Issue: https://github.com/vllm-project/vllm/issues/24910
