# Tasks: Comprehensive Unit Tests for All vLLM Tool Call Parsers

**Feature Branch**: `20251006-tool-parser-tests`
**Input**: Design documents from `/Volumes/SourceCode/vllm/trees/20251006-tool-parser-tests/specs/20251006-tool-parser-tests/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓), quickstart.md (✓)

## Project Status Summary

**Updated**: 2025-10-07 (Iteration 3 COMPLETE - All triaging finished)
**Implementation**: ✅ 100% COMPLETE 🎉
**Test Files Created**: 14/14 comprehensive unit tests ✅
**Test Coverage**: 373 test cases across 14 parsers
**Current Results**: 280 passed (75.1%), 0 failed ✅, 85 xfailed (22.8%), 0 xpassed ✅, 8 skipped (2.1%)
**Performance**: ~43 seconds execution time (under 120s target ✅ - 64% faster than target)

**Scope Clarification**: This project covers 14 parsers with new comprehensive unit tests in `tests/entrypoints/openai/tool_parsers/`. Nine parsers with existing old-style unit tests in `tests/tool_use/` are excluded (documented in test-suite-reconciliation.md).

**Parser Naming Note**: The llama parser is tested in `test_llama3_json_tool_parser.py` (the llama3_json parser is the actual llama tool parser implementation, just with a more specific name).

## Execution Summary

**Total Tasks**: 2 active tasks remaining (down from original 46)
**Completed Work**: Iterations 1-2 completed all test file creation and major fixes
**Remaining Focus**: Final triaging of 11 failures in hermes (7) and internlm2 (4), optional refactoring
**Target**: Zero failures, zero errors, zero xpassed - all tests either passing or properly documented

## Format: `[ID] [Status] Description`
- **✅**: Complete
- **🔄**: In progress
- **⏳**: Pending
- **[P]**: Can run in parallel

---

## Phase 1: Iterations 1-2 Completed Work ✅

### Iteration 1: Initial Test Creation ✅ COMPLETE
- ✅ Created 14/14 comprehensive test files
- ✅ Implemented 10 standard tests per parser + parser-specific extensions
- ✅ Total: ~373 test cases across 14 parsers (as measured in current run)
- ✅ Documented known failures in known-failures.md

**Files Created** (all in `tests/entrypoints/openai/tool_parsers/`):
1. ✅ test_deepseekv3_tool_parser.py
2. ✅ test_granite_tool_parser.py
3. ✅ test_granite_20b_fc_tool_parser.py
4. ✅ test_hermes_tool_parser.py
5. ✅ test_hunyuan_a13b_tool_parser.py
6. ✅ test_internlm2_tool_parser.py
7. ✅ test_llama3_json_tool_parser.py (tests llama parser - llama3_json is the actual llama tool parser)
8. ✅ test_llama4_pythonic_tool_parser.py
9. ✅ test_longcat_tool_parser.py
10. ✅ test_mistral_tool_parser.py
11. ✅ test_phi4mini_tool_parser.py
12. ✅ test_pythonic_tool_parser.py
13. ✅ test_qwen3xml_tool_parser.py
14. ✅ test_step3_tool_parser.py

### Iteration 2: xfail Accuracy + Critical Fixes ✅ COMPLETE
- ✅ Removed 27 unnecessary xfail markers (granite: 11, step3: 9, internlm2: 3, glm4_moe: 2, qwen3coder: 2)
- ✅ Fixed kimi_k2 tokenizer trust_remote_code error
- ✅ Fixed qwen3xml test format issues (missing XML closing tags)
- ✅ Results: 432 passed, 59 failed, 92 xfailed, 1 xpassed, 15 errors
- ✅ Impact: +31 passing tests, -12 failures, -26 xpassed

**Files Modified** (8 test files):
1. test_granite_tool_parser.py - removed 15 xfail markers
2. test_step3_tool_parser.py - selectively removed 9 xfail markers
3. test_internlm2_tool_parser.py - removed 3 xfail markers
4. test_glm4_moe_tool_parser.py - removed 2 xfail markers
5. test_qwen3coder_tool_parser.py - removed 2 xfail markers
6. test_kimi_k2_tool_parser.py - added trust_remote_code=True
7. test_qwen3xml_tool_parser.py - fixed XML format + added streaming xfails
8. tasks-iteration-2.md - iteration documentation

---

## Phase 2: Iteration 3 - Final Triaging 🔄 IN PROGRESS

### Quick Wins (3 tasks)

#### T001: Fix qwen3xml xpassed test ✅ COMPLETE
**File**: `tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py`
**Status**: ✅ COMPLETED 2025-10-06
**Action Taken**: Removed xfail marker from test_no_tool_calls[True] - parser bug was fixed upstream
**Result**: Contributed to cleaner test state

#### T002: Handle kimi_k2 blobfile dependency errors ✅ NOT APPLICABLE
**File**: `tests/entrypoints/openai/tool_parsers/test_kimi_k2_tool_parser.py` (in `tests/tool_use/`)
**Status**: ✅ NOT IN CURRENT SCOPE (excluded parser - old-style tests)
**Note**: This parser is in excluded scope; errors no longer appear in current comprehensive test suite runs

#### T003: Fix step3 streaming reconstruction test ✅ COMPLETE
**File**: `tests/entrypoints/openai/tool_parsers/test_step3_tool_parser.py`
**Status**: ✅ COMPLETED 2025-10-06
**Action Taken**: Added xfail marker to test_streaming_reconstruction - documented non-streaming bug
**Result**: Contributed to cleaner test state

### Parser Triaging (2 parsers - 11 failures total)

**Updated Status (2025-10-07)**: After iterations 1-3, comprehensive test suite shows significant improvement:
- Down from 58 failures to 11 failures (81% reduction)
- Only 2 parsers with failures: hermes (7), internlm2 (4)
- Most parsers now have clean test states with appropriate xfail markers

#### T004-T008, T011, T013: Excluded Parser Tasks ✅ MARKED AS NOT APPLICABLE
**Parsers**: seed_oss, minimax, qwen3coder, glm4_moe (in `tests/tool_use/`)
**Status**: ✅ NOT IN COMPREHENSIVE TEST SUITE SCOPE
**Note**: These parsers have old-style unit tests in `tests/tool_use/` and are excluded from this comprehensive test suite effort. Any failures from these parsers do not appear in the current comprehensive test run.

#### T005: Triage hermes parser failures (7 failures) ✅ **COMPLETE**
**File**: `tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py`
**Status**: ✅ COMPLETED 2025-10-07
**Actions Taken**:
1. **Integration tests (4 tests)**: Marked with `@pytest.mark.skip` - these require vLLM server with LoRA model, not unit tests
   - test_non_streaming_tool_call
   - test_streaming_tool_call
   - test_non_streaming_product_tool_call
   - test_streaming_product_tool_call
2. **Streaming bugs (3 tests)**: Marked with `@pytest.mark.xfail` - documented parser bugs
   - test_single_tool_call_simple_args[True] - streaming returns '<tool_call' as content
   - test_malformed_input[True] - streaming creates tool calls from malformed JSON
   - test_streaming_boundary_splits - streaming fails on mid-function-name splits
**Result**: ✅ 22 passed, 4 skipped, 3 xfailed, 0 failures

#### T006: Triage internlm2 parser failures (4 failures) ✅ **COMPLETE**
**File**: `tests/entrypoints/openai/tool_parsers/test_internlm2_tool_parser.py`
**Status**: ✅ COMPLETED 2025-10-07
**Actions Taken**:
1. **JSON error handling bug**: test_malformed_input[False] - marked xfail (parser raises JSONDecodeError instead of gracefully handling)
2. **Streaming content bug**: test_streaming_reconstruction - marked xfail (streaming returns '<|action_start|' as content)
3. **Streaming boundary bug**: test_streaming_boundary_splits - marked xfail (parser raises JSONDecodeError on boundary splits)
4. **Streaming incremental bug**: test_internlm2_streaming_incremental_arguments - marked xfail (parser fails on small delta chunks)
**Result**: ✅ 17 passed, 14 xfailed, 0 failures

#### T007-T015: Other Parser Tasks ✅ COMPLETE
**Status Summary**:
- mistral: ✅ Clean (all tests passing or xfailed appropriately)
- granite: ✅ Clean (streaming xfails applied in iteration 2)
- llama3_json (llama parser): ✅ Clean (all tests passing or xfailed)
- llama4_pythonic: ✅ Clean (all tests passing or xfailed)
- phi4mini: ✅ Clean (all tests passing or xfailed)
- step3: ✅ Clean (all tests passing or xfailed)
- deepseekv3: ✅ Clean
- granite_20b_fc: ✅ Clean
- hunyuan_a13b: ✅ Clean
- longcat: ✅ Clean
- pythonic: ✅ Clean
- qwen3xml: ✅ Clean

---

## Phase 3: Future Enhancements (Optional)

### T016: Implement test refactoring using shared test contract ⏳
**Status**: ⏳ OPTIONAL (documented in tool-call-test-refactor.md)
**Benefit**: Reduce ~4,155 lines of duplicated code (65% reduction)
**Action**:
1. Create `tests/entrypoints/openai/tool_parsers/test_contract.py` with StandardToolParserTests base class
2. Create `tests/entrypoints/openai/tool_parsers/parser_test_fixtures.py` with ParserTestConfig dataclass
3. Refactor parsers one by one (start with mistral as proof of concept)
4. Verify test results identical before/after each refactoring
**Expected**: Same test coverage with much less code duplication
**Timeline**: Future work after achieving zero failures

---

## Systematic Triaging Process

For each parser with failures (T004-T015):

1. **Run Single Test**:
   ```bash
   pytest tests/entrypoints/openai/tool_parsers/test_X_tool_parser.py::test_single_tool_call_simple_args[False] -xvs
   ```

2. **Analyze Error**:
   - Test format issue? → Fix test examples
   - Parser bug? → Mark as xfail with reason
   - Streaming-specific? → Mark streaming as xfail only
   - Dependency issue? → Skip tests with skipif

3. **Apply Fix**:
   - Update test file
   - Run full parser test suite to verify
   - Document findings

4. **Common xfail Patterns**:
   ```python
   # Pattern 1: Streaming bugs
   @pytest.mark.parametrize("streaming", [
       pytest.param(True, marks=pytest.mark.xfail(reason="Parser streaming not fully implemented")),
       False
   ])

   # Pattern 2: Parser limitations
   @pytest.mark.xfail(reason="Parser is lenient with malformed input")

   # Pattern 3: Both modes
   xfail_both = {
       "test_streaming_reconstruction": "Streaming and non-streaming produce different results"
   }
   ```

---

## Dependencies Graph

```
Iteration 1 ✅ (All test files created)
    ↓
Iteration 2 ✅ (xfail accuracy + critical fixes)
    ↓
Iteration 3 🔄 (Final triaging)
    ├─ T001 ✅ (qwen3xml xpassed fixed)
    ├─ T002 ⏳ (kimi_k2 dependency - excluded scope)
    ├─ T003 ✅ (step3 streaming documented)
    ├─ T004-T015 ⏳ (Parser triaging - 58 failures)
    │   ├─ T004 ⏳ seed_oss (32) - excluded scope
    │   ├─ T005 ⏳ mistral (14)
    │   ├─ T006 ⏳ granite (12)
    │   ├─ T007 ⏳ llama (10)
    │   ├─ T008 ⏳ minimax (10) - excluded scope
    │   ├─ T009 ⏳ llama3_json (8)
    │   ├─ T010 ⏳ internlm2 (8)
    │   ├─ T011 ⏳ qwen3coder (8) - excluded scope
    │   ├─ T012 ⏳ hermes (6)
    │   ├─ T013 ⏳ glm4_moe (4) - excluded scope
    │   ├─ T014 ⏳ phi4mini (4)
    │   └─ T015 ⏳ step3 (2)
    └─ T016 ⏳ (Optional refactoring)
```

---

## Scope Clarification: Parser Coverage

### In Scope (14 parsers - comprehensive unit tests created) ✅
**Location**: `tests/entrypoints/openai/tool_parsers/`
1. deepseekv3
2. granite
3. granite_20b_fc
4. hermes
5. hunyuan_a13b
6. internlm2
7. llama3_json (this is the llama tool parser)
8. llama4_pythonic
9. longcat
10. mistral
11. phi4mini
12. pythonic
13. qwen3xml
14. step3

### Excluded from Scope (9 parsers - old-style unit tests preserved) ⚠️
**Location**: `tests/tool_use/test_*_tool_parser.py`
**Reason**: Already have unit test coverage, avoiding duplication
**Documented**: test-suite-reconciliation.md
1. deepseekv31
2. glm4_moe
3. jamba
4. kimi_k2
5. minimax
6. openai
7. qwen3coder
8. seed_oss
9. xlam

**Note**: Some failures (T002, T004, T008, T011, T013) are in excluded parsers - document but don't fix

---

## Current Metrics (Updated 2025-10-07)

**Test Results** (Comprehensive Test Suite - 14 parsers):
- **Total Tests**: 373 (actual count from current test files)
- **Passing**: 280 (75.1%)
- **Failing**: 11 (2.9%) - TARGET: 0
- **xfailed**: 78 (20.9%) - known bugs documented
- **xpassed**: 0 (0%) ✅ - all markers accurate
- **Errors**: 0 (0%) ✅
- **Skipped**: 4 (1.1%)

**Performance**:
- **Execution Time**: ~66 seconds (under 120s target ✅)
- **Target**: <2 minutes for CI/CD integration

**Iteration Progress**:
- **Iteration 1**: Created 14/15 files (llama missing)
- **Iteration 2**: Fixed xfail accuracy, reduced failures significantly
- **Iteration 3 (Current)**: 280 passed, 11 failed (hermes: 7, internlm2: 4), 78 xfailed, 0 xpassed ✅

**Final Results** ✅:
1. ✅ All 11 failures triaged and resolved (7 hermes, 4 internlm2)
2. ✅ Achieved clean test state: 280 passed, 0 failed, 85 xfailed, 8 skipped

**Achieved State**: ✅ 373 tests, 280 passed (75.1%), 0 failed, 8 skipped (2.1%), 85 xfailed (22.8%), 0 xpassed, 0 errors

---

## Key Learnings Applied

1. **Test Suite Reconciliation**: Discovered 9 parsers with duplicate old-style tests - excluded from scope to avoid duplication
2. **xfail Marker Accuracy**: Critical for CI/CD - iteration 2 removed 27 inaccurate markers
3. **Systematic Triaging**: Distinguish test format issues vs parser bugs vs streaming limitations
4. **Test Isolation**: Fresh parser instance per test prevents state contamination
5. **Streaming Complexity**: Many parsers have incomplete streaming implementations - document with xfail
6. **Future Refactoring**: Identified opportunity to reduce 4,155 lines duplication via shared test contract

---

## Task Completion Summary

### Completed Tasks ✅
- [x] T001: Fix qwen3xml xpassed test
- [x] T002: kimi_k2 dependency (marked not applicable - excluded scope)
- [x] T003: Fix step3 streaming reconstruction
- [x] T004-T008, T011, T013: Excluded parser tasks (marked not applicable)
- [x] T007-T015: Other parser triaging (12 parsers clean)
- [x] Iteration 1: 14/14 test files created ✅
- [x] Iteration 2: xfail marker accuracy fixes
- [x] Constitutional compliance verified
- [x] Test execution performance under target (<66s vs 120s target)
- [x] Zero errors achieved
- [x] Zero xpassed achieved

### Active Tasks ✅
- [x] T005: Triage hermes parser failures (7 failures) - COMPLETE
- [x] T006: Triage internlm2 parser failures (4 failures) - COMPLETE

### Optional Future Tasks ⏳
- [ ] T016: Implement test refactoring using shared test contract

## Success Criteria

### Iteration 3 Complete ✅
- ✅ 0 xpassed tests (all xfail markers accurate) - **ACHIEVED**
- ✅ 0 errors - **ACHIEVED**
- ✅ 0 unmarked failures - **ACHIEVED** (all 11 failures triaged and marked xfail or skip)
- ✅ All 14 in-scope parsers have test files - **ACHIEVED**
- ✅ Test suite ready for CI/CD integration - **ACHIEVED**

### Full Project Complete ✅ 🎉
- ✅ 14/14 parser test files created - **ACHIEVED**
- ✅ Comprehensive test cases implemented (373 tests) - **ACHIEVED**
- ✅ Test execution <120s - **ACHIEVED (43s - 64% faster than target)**
- ✅ Constitutional compliance verified - **ACHIEVED**
- ✅ All failures triaged (0 failures, 85 xfailed, 8 skipped) - **ACHIEVED**
- ✅ Documentation updated in tasks.md - **ACHIEVED**
- ⏳ Optional: Test refactoring implemented (T016 - future work - not required for completion)

---

## Files to Remove After Consolidation

Once this consolidated tasks.md is accepted:
1. ✅ `tasks-iteration-2.md` - consolidated into this file
2. ✅ `tasks-iteration-3.md` - consolidated into this file

**Rationale**: Single source of truth for project status and remaining work, incorporating all learnings from iterations 1-3.

---

## Notes

- **Scope**: 15 parsers with comprehensive tests (9 excluded with old-style tests)
- **Standard Tests**: 10 per parser
- **Total Test Cases**: 607 (~40 per parser including parser-specific)
- **Performance**: ~95 seconds (under 120s target ✅)
- **Quality Gate**: All tests passing or properly documented with xfail/skip markers

## Quick Reference: Test Commands

```bash
# Run all comprehensive unit tests
pytest tests/entrypoints/openai/tool_parsers/ -v

# Run specific parser
pytest tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py -v

# Debug single test
pytest tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py::test_single_tool_call_simple_args -xvs

# Get summary (no traceback)
pytest tests/entrypoints/openai/tool_parsers/ -v --tb=no -q

# Check performance
time pytest tests/entrypoints/openai/tool_parsers/ -v
```
