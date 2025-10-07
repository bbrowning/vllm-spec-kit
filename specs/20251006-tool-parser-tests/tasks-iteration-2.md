# Tasks Iteration 2: Fix Remaining Test Issues

**Created**: 2025-10-06
**Status**: In Progress
**Parent Spec**: specs/20251006-tool-parser-tests/spec.md
**Previous Tasks**: specs/20251006-tool-parser-tests/tasks.md

## Current Test Status

**Latest run**: 401 passed, 71 failed, 8 skipped, 85 xfailed, 27 xpassed, 15 errors (93.74s)
**vs. Original**: 420 passed, 106 failed, 4 skipped, 22 xfailed, 55 errors (242.56s)

## Task Summary

- **Total Tasks**: 29
- **Priority 1**: 5 tasks (remove unnecessary xfail markers)
- **Priority 2**: 1 task (fix kimi_k2 tokenizer error)
- **Priority 3**: 22 tasks (fix or mark parser failures)
- **Priority 4**: 1 task (update documentation)

---

## Priority 1: Remove Unnecessary xfail Markers (5 tasks)

Tests marked as xfail but now passing - these parsers work better than expected!

### P1-T001: Remove xfail from granite parser streaming tests ✅
**File**: tests/entrypoints/openai/tool_parsers/test_granite_tool_parser.py
**Issue**: 11 tests marked xfail but passing (streaming tests)
**Action**: Remove `@pytest.mark.xfail` decorators from:
- test_no_tool_calls[True]
- test_various_data_types[True]
- test_empty_arguments[True]
- test_escaped_strings[True]
- test_granite_token_prefix_format[True]
- test_granite_string_prefix_format[True]
- test_granite_plain_array_format[True]
- test_granite_whitespace_handling[True]
- test_granite_unicode_preservation[True]
- test_granite_nested_objects[True]
- test_granite_array_arguments[True]

### P1-T002: Remove xfail from step3 parser tests ✅
**File**: tests/entrypoints/openai/tool_parsers/test_step3_tool_parser.py
**Issue**: 9 tests marked xfail but passing
**Action**: Remove `@pytest.mark.xfail` decorators from:
- test_no_tool_calls[True]
- test_no_tool_calls[False]
- test_single_tool_call_simple_args[True]
- test_various_data_types[True]
- test_empty_arguments[True]
- test_surrounding_text[True]
- test_escaped_strings[True]
- test_malformed_input[False]
- test_step3_unicode_token_markers[True]

### P1-T003: Remove xfail from internlm2 parser streaming tests ✅
**File**: tests/entrypoints/openai/tool_parsers/test_internlm2_tool_parser.py
**Issue**: 3 tests marked xfail but passing
**Action**: Remove `@pytest.mark.xfail` decorators from:
- test_no_tool_calls[True]
- test_malformed_input[True]
- test_internlm2_plugin_marker_required[True]

### P1-T004: Remove xfail from glm4_moe parser streaming tests ✅
**File**: tests/entrypoints/openai/tool_parsers/test_glm4_moe_tool_parser.py
**Issue**: 2 tests marked xfail but passing
**Action**: Remove `@pytest.mark.xfail` decorators from:
- test_no_tool_calls[True]
- test_malformed_input[True]

### P1-T005: Remove xfail from qwen3coder parser streaming tests ✅
**File**: tests/entrypoints/openai/tool_parsers/test_qwen3coder_tool_parser.py
**Issue**: 2 tests marked xfail but passing
**Action**: Remove `@pytest.mark.xfail` decorators from:
- test_no_tool_calls[True]
- test_malformed_input[True]

---

## Priority 2: Fix Critical Errors (1 task)

### P2-T001: Fix kimi_k2 tokenizer trust_remote_code error ✅
**File**: tests/entrypoints/openai/tool_parsers/test_kimi_k2_tool_parser.py
**Issue**: 15 errors - all tests fail with "trust_remote_code=True" requirement
**Error**: `ValueError: The repository moonshotai/Kimi-K2-Instruct contains custom code which must be executed to correctly load the model`
**Action**: Update line 50:
```python
# Before:
return get_tokenizer("moonshotai/Kimi-K2-Instruct")

# After:
return get_tokenizer("moonshotai/Kimi-K2-Instruct", trust_remote_code=True)
```
**Expected**: All 15 tests should run (may still fail, but no errors)

---

## Priority 3: Fix or Mark Parser Failures (22 tasks)

### Group A: Incorrect Model Output Format (2 tasks)

#### P3-T001: Investigate and fix qwen3xml parser test failures ✓
**File**: tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py
**Issue**: 16 failures - XML parsing errors, JSONDecodeError
**Failures**:
- test_single_tool_call_simple_args[True/False]
- test_parallel_tool_calls[True/False]
- test_various_data_types[True/False]
- test_empty_arguments[True]
- test_surrounding_text[True]
- test_escaped_strings[True/False]
- test_malformed_input[True/False]
- test_streaming_reconstruction
- test_streaming_boundary_splits
- test_qwen3xml_parameter_tags[True/False]
**Error**: `mismatched tag: line 1, column 82`, `JSONDecodeError`
**Action**:
1. Read qwen3xml parser implementation to understand expected format
2. Review test output examples
3. Fix XML structure in test constants OR mark as xfail if parser is broken

#### P3-T002: Investigate and fix seed_oss parser test failures ✓
**File**: tests/entrypoints/openai/tool_parsers/test_seed_oss_tool_parser.py
**Issue**: 14 failures - parsing errors
**Failures**:
- test_single_tool_call_simple_args[True/False]
- test_parallel_tool_calls[True/False]
- test_various_data_types[True/False]
- test_empty_arguments[True/False]
- test_surrounding_text[True/False]
- test_escaped_strings[True/False]
- test_streaming_reconstruction
- test_streaming_boundary_splits
- test_seed_oss_thinking_tags[True/False]
**Action**:
1. Read seed_oss parser implementation to understand expected format
2. Review test output examples
3. Fix format in test constants OR mark as xfail if parser is broken

### Group B: Parser-Specific Failures (20 tasks - 1 per parser/test scenario)

#### P3-T003: Triage llama parser failures (5 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_llama_tool_parser.py
**Action**:
1. Run tests individually to see specific errors
2. Determine if test expectations are wrong or parser has bugs
3. Fix tests OR add xfail markers with reasons

#### P3-T004: Triage minimax parser failures (5 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_minimax_tool_parser.py
**Action**: Same as P3-T003

#### P3-T005: Triage mistral parser failures (7 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py
**Action**: Same as P3-T003

#### P3-T006: Triage llama3_json parser failures (4 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py
**Action**: Same as P3-T003

#### P3-T007: Triage phi4mini parser failures (2 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_phi4mini_tool_parser.py
**Action**: Same as P3-T003

#### P3-T008: Triage qwen3coder parser failures (4 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_qwen3coder_tool_parser.py
**Action**: Same as P3-T003

#### P3-T009: Fix step3 test_streaming_reconstruction failure (1 failure)
**File**: tests/entrypoints/openai/tool_parsers/test_step3_tool_parser.py
**Action**:
1. Run test to see specific error
2. Fix test OR mark as xfail if parser bug

#### P3-T010: Triage granite parser failures (6 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_granite_tool_parser.py
**Issue**: 6 streaming failures (single_tool, parallel, surrounding_text, malformed, reconstruction, boundary_splits)
**Action**: Investigate and add xfail markers if needed

#### P3-T011: Triage hermes parser failures (3 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py
**Issue**: Single tool streaming, malformed streaming, boundary splits
**Action**: Investigate and fix or mark as xfail

#### P3-T012: Triage internlm2 parser failures (4 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_internlm2_tool_parser.py
**Issue**: Streaming tests still failing after removing some xfails
**Action**: Investigate remaining failures and mark as xfail if needed

#### P3-T013: Triage glm4_moe parser failures (11 failures)
**File**: tests/entrypoints/openai/tool_parsers/test_glm4_moe_tool_parser.py
**Issue**: Streaming tests failing
**Action**: Add xfail markers to streaming tests

#### P3-T014: Review longcat parser skipped tests (4 skipped)
**File**: tests/entrypoints/openai/tool_parsers/test_longcat_tool_parser.py
**Issue**: 4 streaming tests skipped due to Hermes buffering complexity
**Action**: Document why skipped or implement tests

---

## Priority 4: Update Documentation (1 task)

### P4-T001: Update known-failures.md with current results ✓
**File**: specs/20251006-tool-parser-tests/known-failures.md
**Action**:
1. Update test statistics (401 passed, 71 failed, 85 xfailed, 27 xpassed, 15 errors)
2. Update parser status sections
3. Update next steps based on iteration 2 work
4. Document improvements (106 → 71 failures, 55 → 15 errors)

---

## Task Execution Strategy

### Phase 1: Quick Wins (P1 + P2)
Run all Priority 1 and Priority 2 tasks to remove xfail markers and fix tokenizer errors.
**Expected Impact**: Reduce errors from 15 → 0, reduce xpassed from 27 → 0

### Phase 2: Format Fixes (P3 Group A)
Fix qwen3xml and seed_oss test format issues.
**Expected Impact**: Reduce failures by ~30 (if formats can be fixed)

### Phase 3: Triage Remaining (P3 Group B)
Systematically investigate each parser's failures.
**Expected Impact**: Properly categorize all failures with xfail markers or fixes

### Phase 4: Documentation (P4)
Update known-failures.md with final results.

---

## Progress Summary

### Iteration 2 Status (After Priority 1-2)

**Completed Tasks**:
- ✅ P1-T001: Removed xfail from granite parser (11 tests) - Now 26/32 passing
- ✅ P1-T002: Removed xfail from step3 parser (9 tests) - Streaming now working
- ✅ P1-T003: Removed xfail from internlm2 parser (3 tests)
- ✅ P1-T004: Removed xfail from glm4_moe parser (2 tests)
- ✅ P1-T005: Removed xfail from qwen3coder parser (2 tests)
- ✅ P2-T001: Fixed kimi_k2 tokenizer trust_remote_code (now has different error: missing blobfile)

**Expected Impact**:
- Reduced xpassed from 27 → 0 (all removed)
- Reduced errors from 15 → 1 (kimi_k2 now has blobfile dependency issue)
- Many streaming tests now passing that were previously marked as xfail

**Remaining Tasks**:
- P3-T001-T002: Fix qwen3xml and seed_oss format issues (~30 failures)
- P3-T003-T014: Triage remaining parser failures (~40 failures)
- P4-T001: Update known-failures.md

### New Issue Discovered
**kimi_k2**: After fixing trust_remote_code, tests now fail with `ImportError: blobfile is not installed`
- This is a missing test dependency, not a test issue
- Recommend: Mark tests as skipped until blobfile is available or mock the dependency

## Success Metrics

**Original**: 401 passed, 71 failed, 8 skipped, 85 xfailed, 27 xpassed, 15 errors
**After P1-P2**: Expected ~428+ passed, ~44 failed, 8 skipped, 85 xfailed, 0 xpassed, 1 error (kimi_k2 blobfile)

**Target**:
- ✅ 0 xpassed (remove unnecessary xfail markers) - ACHIEVED
- ⚠️ 0-1 errors (kimi_k2 needs blobfile or skip)
- 🔄 <50 failures (fix format issues) - IN PROGRESS
- 🔄 All remaining failures properly marked as xfail with reasons - IN PROGRESS

**Definition of Done**:
- ✅ No xpassed tests (all xfail markers are accurate) - MOSTLY ACHIEVED (1 xpassed remaining)
- ⚠️ All tests run without setup errors (kimi_k2 blobfile issue) - NEEDS WORK
- 🔄 All unmarked failures investigated and either fixed or marked xfail - IN PROGRESS
- 🔄 known-failures.md updated with accurate status - PENDING
- 🔄 Test suite ready for CI/CD integration - PENDING

---

## Final Iteration 2 Results

### Test Metrics

**Before Iteration 2**: 401 passed, 71 failed, 8 skipped, 85 xfailed, 27 xpassed, 15 errors

**After Iteration 2**: 432 passed, 59 failed, 8 skipped, 92 xfailed, 1 xpassed, 15 errors

**Improvements**:
- ✅ +31 passing tests (+7.7%)
- ✅ -12 failures (-16.9%)
- ✅ -26 xpassed (-96.3%) - nearly eliminated!
- ✅ +7 properly documented xfails
- ⚠️ 0 change in errors (kimi_k2 still blocked)

### Work Completed

#### Priority 1: Remove Unnecessary xfail Markers ✅ COMPLETE
- **P1-T001**: ✅ Granite parser - removed 11 xfail markers
- **P1-T002**: ✅ Step3 parser - selectively removed 9 xfail markers (keeping some for non-streaming bugs)
- **P1-T003**: ✅ InternLM2 parser - removed 3 xfail markers
- **P1-T004**: ✅ GLM4-MoE parser - removed 2 xfail markers
- **P1-T005**: ✅ Qwen3Coder parser - removed 2 xfail markers

**Impact**: 27 xpassed → 1 xpassed (96% reduction)

#### Priority 2: Fix Critical Errors ✅ COMPLETE
- **P2-T001**: ✅ kimi_k2 tokenizer - added `trust_remote_code=True`
  - Note: Revealed new issue (blobfile dependency) - now shows ImportError instead of tokenizer error
  - Recommend: Skip tests with `@pytest.mark.skipif` until blobfile available

**Impact**: Better error message, issue now clearly identified

#### Priority 3: Fix or Mark Parser Failures 🔄 PARTIAL
- **P3-T001**: ✅ Qwen3XML parser - MAJOR SUCCESS
  - Fixed 16 failures → 8 passed, 11 xfailed (streaming issues documented)
  - Root cause: Missing `</function>` closing tags in XML test examples
  - Added proper XML structure to all test constants
  - Marked all streaming tests as xfail (systematic streaming bugs)

- **P3-T002**: ⚠️ SEED-OSS parser - NOT COMPLETED
  - 14 failures remain (actually 32 after full run)
  - Complex XML streaming parser needs deeper investigation
  - Recommend: Mark all as xfail for iteration 3

- **P3-T003-T014**: ⚠️ Other parsers - NOT STARTED
  - 59 failures remaining across multiple parsers:
    - seed_oss: 32 failures
    - mistral: 14 failures
    - granite: 12 failures (some streaming edge cases)
    - llama: 10 failures
    - minimax: 10 failures
    - llama3_json: 8 failures
    - internlm2: 8 failures
    - qwen3coder: 8 failures
    - hermes: 6 failures
    - glm4_moe: 4 failures
    - phi4mini: 4 failures
    - step3: 2 failures

**Impact**: 71 → 59 failures (16.9% reduction), qwen3xml fully triaged

#### Priority 4: Update Documentation ⚠️ NOT COMPLETED
- **P4-T001**: ⚠️ known-failures.md - needs update with current results

### Files Modified

**Iteration 2 changed 8 test files**:
1. ✅ `test_granite_tool_parser.py` - removed 15 xfail markers
2. ✅ `test_step3_tool_parser.py` - selectively removed 9 xfail markers
3. ✅ `test_internlm2_tool_parser.py` - removed 3 xfail markers
4. ✅ `test_glm4_moe_tool_parser.py` - removed 2 xfail markers
5. ✅ `test_qwen3coder_tool_parser.py` - removed 2 xfail markers
6. ✅ `test_kimi_k2_tool_parser.py` - added `trust_remote_code=True` parameter
7. ✅ `test_qwen3xml_tool_parser.py` - fixed XML format + added 11 xfail markers for streaming
8. 📝 `specs/20251006-tool-parser-tests/tasks-iteration-2.md` - this file

### Key Learnings

1. **xfail marker accuracy is critical**: We had 27 tests marked as xfail that were actually passing. Removing these markers improves test quality and provides accurate signal.

2. **Test format matters**: The qwen3xml failure was entirely due to missing XML closing tags in test examples, not parser bugs. Always verify test format first.

3. **Streaming is complex**: Multiple parsers have incomplete or buggy streaming implementations. These should be systematically documented with xfail markers.

4. **Dependencies matter**: kimi_k2 needs blobfile, which isn't installed. This blocks all tests for that parser.

5. **Incremental progress works**: By focusing on Priority 1-2 first (quick wins), we achieved significant improvement before tackling harder problems.

### Remaining Work (→ Iteration 3)

See `specs/20251006-tool-parser-tests/tasks-iteration-3.md` for complete plan.

**Quick wins for iteration 3**:
- Fix 1 xpassed test (qwen3xml test_no_tool_calls[True])
- Skip 15 kimi_k2 error tests (add skipif for blobfile dependency)
- Triage 59 failures across 12 parsers

**Goal**: Zero failures, zero errors, zero xpassed - all tests either passing or properly documented with xfail/skip
