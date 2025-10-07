# Tasks: Comprehensive Unit Tests for All vLLM Tool Call Parsers

**Feature Branch**: `20251006-tool-parser-tests`
**Input**: Design documents from `/Volumes/SourceCode/vllm/trees/20251006-tool-parser-tests/specs/20251006-tool-parser-tests/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓), quickstart.md (✓)

## Project Status Summary

**Implementation**: ✅ 95% COMPLETE (Iteration 3 in progress)
**Test Files Created**: 15/15 comprehensive unit tests
**Test Coverage**: 607 test cases across 15 parsers
**Current Results**: 433 passed (71.3%), 58 failed (9.6%), 93 xfailed (15.3%), 0 xpassed, 15 errors (2.5%)
**Performance**: ~95 seconds execution time (under 120s target ✅)

**Scope Clarification**: This project covers 15 parsers with new comprehensive unit tests in `tests/entrypoints/openai/tool_parsers/`. Nine parsers with existing old-style unit tests in `tests/tool_use/` are excluded (documented in test-suite-reconciliation.md).

## Execution Summary

**Total Tasks**: 15 remaining tasks (down from original 46)
**Completed Work**: Iterations 1-2 completed all test creation and major fixes
**Remaining Focus**: Final triaging, dependency handling, optional refactoring
**Target**: Zero failures, zero errors, zero xpassed - all tests either passing or properly documented

## Format: `[ID] [Status] Description`
- **✅**: Complete
- **🔄**: In progress
- **⏳**: Pending
- **[P]**: Can run in parallel

---

## Phase 1: Iterations 1-2 Completed Work ✅

### Iteration 1: Initial Test Creation ✅ COMPLETE
- ✅ Created 15 comprehensive test files (~16,152 lines of code)
- ✅ Implemented 10 standard tests per parser + parser-specific extensions
- ✅ Total: 607 test cases across 15 parsers
- ✅ Initial results: 420 passed, 106 failed, 22 xfailed, 55 errors
- ✅ Documented known failures in known-failures.md

**Files Created** (all in `tests/entrypoints/openai/tool_parsers/`):
1. test_deepseekv3_tool_parser.py
2. test_granite_tool_parser.py
3. test_granite_20b_fc_tool_parser.py
4. test_hermes_tool_parser.py
5. test_hunyuan_a13b_tool_parser.py
6. test_internlm2_tool_parser.py
7. test_llama_tool_parser.py
8. test_llama3_json_tool_parser.py
9. test_llama4_pythonic_tool_parser.py
10. test_longcat_tool_parser.py
11. test_mistral_tool_parser.py
12. test_phi4mini_tool_parser.py
13. test_pythonic_tool_parser.py
14. test_qwen3xml_tool_parser.py
15. test_step3_tool_parser.py

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
**Result**: 433 passed (+1), 0 xpassed ✅

#### T002: Handle kimi_k2 blobfile dependency errors ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_kimi_k2_tool_parser.py` (in `tests/tool_use/`)
**Issue**: 15 errors - ImportError: blobfile is not installed
**Status**: ⏳ PENDING
**Action**:
```python
# Add at top of file or in fixture
pytest.importorskip("blobfile", reason="blobfile is required for kimi_k2 tests")
# OR
@pytest.mark.skipif(not has_blobfile(), reason="blobfile not installed")
```
**Expected**: 0 errors, 15 skipped tests
**Note**: This parser is in excluded scope (old-style tests) but blocking clean test runs

#### T003: Fix step3 streaming reconstruction test ✅ COMPLETE
**File**: `tests/entrypoints/openai/tool_parsers/test_step3_tool_parser.py`
**Status**: ✅ COMPLETED 2025-10-06
**Action Taken**: Added xfail marker to test_streaming_reconstruction - documented non-streaming bug
**Result**: 58 failed (-1), 93 xfailed (+1)

### Parser Triaging (12 task groups - 58 failures total)

#### T004: Triage seed_oss parser failures (32 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_seed_oss_tool_parser.py` (in `tests/tool_use/`)
**Issue**: Almost all tests failing - parser not extracting tool calls correctly
**Status**: ⏳ PENDING (excluded scope - old-style test)
**Action**: Document that this parser is in excluded scope, tests exist in `tests/tool_use/`
**Note**: Complex XML streaming parser requiring deeper investigation - not in current scope

#### T005: Triage mistral parser failures (14 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py`
**Status**: ⏳ PENDING
**Failure Pattern**:
- test_mistral_content_before_tool_calls variations
- test_malformed_input variations
- Streaming edge cases
**Investigation Steps**:
1. Run `pytest test_mistral_tool_parser.py::test_single_tool_call_simple_args -xvs`
2. Determine if test format issue or parser bug
3. Apply fixes or xfail markers
**Expected**: Mix of fixes and xfail markers

#### T006: Triage granite parser failures (12 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_granite_tool_parser.py`
**Status**: ⏳ PENDING
**Context**: Removed many xfails in iteration 2, but some streaming edge cases remain
**Failure Pattern**: Streaming reconstruction, boundary splits, malformed streaming
**Action**: Add selective xfail markers for streaming limitations
**Expected**: 6-8 xfailed (streaming issues documented)

#### T007: Triage llama parser failures (10 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_llama_tool_parser.py`
**Status**: ⏳ PENDING
**Failure Pattern**:
- test_llama_parallel_with_whitespace
- test_llama_streaming_parallel_tools
- Standard test variations
**Action**: Systematic investigation, fix or xfail
**Expected**: Mix of fixes and xfail markers

#### T008: Triage minimax parser failures (10 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_minimax_tool_parser.py` (in `tests/tool_use/`)
**Status**: ⏳ PENDING (excluded scope - old-style test)
**Failure Pattern**: test_minimax_duplicate_braces_cleaning variations
**Note**: This parser is in excluded scope, tests exist in `tests/tool_use/`

#### T009: Triage llama3_json parser failures (8 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py`
**Status**: ⏳ PENDING
**Context**: Modified in iteration 2, still has failures
**Action**: Review remaining failures, fix or xfail
**Expected**: Properly documented xfails

#### T010: Triage internlm2 parser failures (8 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_internlm2_tool_parser.py`
**Status**: ⏳ PENDING
**Context**: Removed 3 xfails in iteration 2, 8 failures remain
**Specific**: test_internlm2_streaming_incremental_arguments failure
**Action**: Investigate streaming issues, add selective xfail markers
**Expected**: Streaming bugs documented with xfail

#### T011: Triage qwen3coder parser failures (8 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_qwen3coder_tool_parser.py` (in `tests/tool_use/`)
**Status**: ⏳ PENDING (excluded scope - old-style test)
**Context**: Removed 2 xfails in iteration 2 for comprehensive tests
**Note**: This parser is in excluded scope, tests exist in `tests/tool_use/`

#### T012: Triage hermes parser failures (6 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py`
**Status**: ⏳ PENDING
**Failure Pattern**: Single tool streaming, malformed streaming, boundary splits
**Action**: Add xfail markers for known Hermes streaming limitations
**Expected**: 6 xfailed (streaming issues documented)

#### T013: Triage glm4_moe parser failures (4 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_glm4_moe_tool_parser.py` (in `tests/tool_use/`)
**Status**: ⏳ PENDING (excluded scope - old-style test)
**Context**: Removed 2 xfails in iteration 2 for comprehensive tests
**Note**: This parser is in excluded scope, tests exist in `tests/tool_use/`

#### T014: Triage phi4mini parser failures (4 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_phi4mini_tool_parser.py`
**Status**: ⏳ PENDING
**Action**: New parser, needs full investigation
**Expected**: Mix of fixes and xfail markers

#### T015: Triage step3 remaining failures (2 failures) ⏳
**File**: `tests/entrypoints/openai/tool_parsers/test_step3_tool_parser.py`
**Status**: ⏳ PENDING
**Context**: Removed 9 xfails in iteration 2, fixed 1 in iteration 3
**Remaining**: 2 edge case failures
**Action**: Add targeted xfail markers
**Expected**: 2 xfailed with clear reasons

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

### In Scope (15 parsers - comprehensive unit tests created) ✅
**Location**: `tests/entrypoints/openai/tool_parsers/`
1. deepseekv3
2. granite
3. granite_20b_fc
4. hermes
5. hunyuan_a13b
6. internlm2
7. llama
8. llama3_json
9. llama4_pythonic
10. longcat
11. mistral
12. phi4mini
13. pythonic
14. qwen3xml
15. step3

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

## Current Metrics (Iteration 3 Progress)

**Test Results**:
- **Total Tests**: 607
- **Passing**: 433 (71.3%)
- **Failing**: 58 (9.6%) - TARGET: 0
- **xfailed**: 93 (15.3%) - known bugs documented
- **xpassed**: 0 (0%) ✅ - all markers accurate
- **Errors**: 15 (2.5%) - kimi_k2 dependency (excluded scope)
- **Skipped**: 8

**Performance**:
- **Execution Time**: ~95 seconds (under 120s target ✅)
- **Target**: <2 minutes for CI/CD integration

**Iteration Progress**:
- **Iteration 1**: 420 passed, 106 failed, 22 xfailed, 55 errors
- **Iteration 2**: 432 passed, 59 failed, 92 xfailed, 1 xpassed, 15 errors (+31 passed, -47 failed)
- **Iteration 3**: 433 passed, 58 failed, 93 xfailed, 0 xpassed, 15 errors (+1 passed, -1 failed) 🔄

**Target State**: ~443-480 passed, 0 failed, 23 skipped, 120-157 xfailed, 0 xpassed, 0 errors

---

## Key Learnings Applied

1. **Test Suite Reconciliation**: Discovered 9 parsers with duplicate old-style tests - excluded from scope to avoid duplication
2. **xfail Marker Accuracy**: Critical for CI/CD - iteration 2 removed 27 inaccurate markers
3. **Systematic Triaging**: Distinguish test format issues vs parser bugs vs streaming limitations
4. **Test Isolation**: Fresh parser instance per test prevents state contamination
5. **Streaming Complexity**: Many parsers have incomplete streaming implementations - document with xfail
6. **Future Refactoring**: Identified opportunity to reduce 4,155 lines duplication via shared test contract

---

## Success Criteria

### Iteration 3 Complete When:
- ✅ 0 xpassed tests (all xfail markers accurate) - ACHIEVED
- ⏳ 0-1 errors (kimi_k2 dependency handled or accepted as excluded)
- ⏳ 0 unmarked failures (all investigated and either fixed or marked xfail)
- ⏳ All 15 in-scope parsers fully validated
- ⏳ known-failures.md updated with final results
- ⏳ Test suite ready for CI/CD integration

### Full Project Complete When:
- ✅ 15/15 parser test files created
- ✅ 607 test cases implemented
- ✅ Test execution <120s
- ✅ Constitutional compliance verified
- ⏳ All failures triaged (fixes or xfail markers)
- ⏳ Documentation updated
- ⏳ Optional: Test refactoring implemented

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
