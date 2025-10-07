# Tasks: Comprehensive Unit Tests for All vLLM Tool Call Parsers

**Input**: Design documents from `/Volumes/SourceCode/vllm/trees/20251006-tool-parser-tests/specs/20251006-tool-parser-tests/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓), quickstart.md (✓)

## Execution Summary

**Total Tasks**: 46 tasks across 5 phases
**Parallel Tasks**: 41 tasks can run in parallel (marked [P])
**Expected Output**: ~300-460 test cases across 23 tool parsers
**Target Performance**: <2min per parser for standard tests

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

---

## Phase 1: Setup & Infrastructure (2 tasks)

### T001: Verify shared test utilities are sufficient ✅
**File**: `tests/entrypoints/openai/tool_parsers/utils.py`
**Action**: Read existing utilities and verify they support all required test patterns
**Verify**:
- `StreamingToolReconstructor` class exists
- `run_tool_extraction()` function exists with streaming parameter
- `run_tool_extraction_streaming()` function exists
- `run_tool_extraction_nonstreaming()` function exists
- All utilities support fresh parser instances per test
**If insufficient**: Document missing utilities needed

### T002: Create shared fixtures if needed ✅
**File**: `tests/entrypoints/openai/tool_parsers/conftest.py` (create if doesn't exist)
**Action**: Create pytest conftest.py with shared fixtures if needed after reviewing existing test files
**Include**:
- Mock tokenizer fixture if commonly used across parsers
- Shared ChatCompletionRequest fixture
- Any other common fixtures discovered during T001
**Note**: Only create if actual shared fixtures are identified; many parsers may use parser-specific fixtures

---

## Phase 2: Parser Research (18 tasks) - ALL [P]

### T003 [P]: Research deepseekv31 tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/deepseekv31_tool_parser.py`
**Action**:
1. Search web for "DeepSeek v3.1 tool calling format examples" and review official documentation
2. Read parser implementation code to understand expected format
3. Identify start/end tokens, JSON structure, special handling
4. Create example model outputs for all 10 standard test patterns
5. Document format in task notes for T021
**Output**: Format documentation and example outputs ready for test creation

### T004 [P]: Research deepseekv3 tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/deepseekv3_tool_parser.py`
**Action**: Same as T003 but for DeepSeek v3
**Search**: "DeepSeek v3 tool calling format examples"

### T005 [P]: Research glm4_moe tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/glm4_moe_tool_parser.py`
**Action**: Same as T003 but for GLM-4 MoE
**Search**: "GLM-4 MoE tool calling format examples"

### T006 [P]: Research granite tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/granite_tool_parser.py`
**Action**: Same as T003 but for Granite
**Search**: "IBM Granite tool calling format examples"

### T007 [P]: Research granite_20b_fc tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/granite_20b_fc_tool_parser.py`
**Action**: Same as T003 but for Granite 20B FC
**Search**: "IBM Granite 20B function calling format examples"

### T008 [P]: Research internlm2 tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/internlm2_tool_parser.py`
**Action**: Same as T003 but for InternLM2
**Search**: "InternLM2 tool calling format examples"

### T009 [P]: Research jamba tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/jamba_tool_parser.py`
**Action**: Same as T003 but for Jamba
**Search**: "AI21 Jamba tool calling format examples"

### T010 [P]: Research kimi_k2 tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/kimi_k2_tool_parser.py`
**Action**: Same as T003 but for Kimi K2
**Search**: "Kimi K2 tool calling format examples"

### T011 [P]: Research llama tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/llama_tool_parser.py`
**Action**: Same as T003 but for Llama (base)
**Search**: "Llama tool calling format examples"
**Note**: Different from llama4_pythonic which already has tests

### T012 [P]: Research longcat tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/longcat_tool_parser.py`
**Action**: Same as T003 but for LongCat
**Search**: "LongCat tool calling format examples"

### T013 [P]: Research minimax tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/minimax_tool_parser.py`
**Action**: Same as T003 but for MiniMax
**Search**: "MiniMax tool calling format examples"

### T014 [P]: Research mistral tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/mistral_tool_parser.py`
**Action**: Same as T003 but for Mistral
**Search**: "Mistral tool calling format examples"
**Note**: Pay attention to [TOOL_CALLS] token and 9-character alphanumeric ID format

### T015 [P]: Research openai tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/openai_tool_parser.py`
**Action**: Same as T003 but for OpenAI format
**Search**: "OpenAI Harmony encoding tool calling format"
**Note**: Check if test file already exists at tests/tool_use/test_openai_tool_parser.py

### T016 [P]: Research phi4mini tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/phi4mini_tool_parser.py`
**Action**: Same as T003 but for Phi-4 Mini
**Search**: "Phi-4 Mini tool calling format examples"

### T017 [P]: Research qwen3coder tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/qwen3coder_tool_parser.py`
**Action**: Same as T003 but for Qwen3 Coder
**Search**: "Qwen3 Coder tool calling format examples"

### T018 [P]: Research qwen3xml tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/qwen3xml_tool_parser.py`
**Action**: Same as T003 but for Qwen3 XML
**Search**: "Qwen3 XML tool calling format examples"

### T019 [P]: Research seed_oss tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/seed_oss_tool_parser.py`
**Action**: Same as T003 but for SEED OSS
**Search**: "SEED OSS tool calling format examples"

### T020 [P]: Research step3 tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/step3_tool_parser.py`
**Action**: Same as T003 but for Step-3
**Search**: "Step-3 tool calling format examples"

### T021 [P]: Research xlam tool parser format ✅
**File**: `vllm/entrypoints/openai/tool_parsers/xlam_tool_parser.py`
**Action**: Same as T003 but for xLAM
**Search**: "xLAM tool calling format examples"

---

## Phase 3: New Test File Creation (18 tasks) - ALL [P]
**Dependencies**: Each T0XX task depends on corresponding research task T00(X-18)

### T022 [P]: Create test_deepseekv31_tool_parser.py
**Depends on**: T003
**File**: `tests/entrypoints/openai/tool_parsers/test_deepseekv31_tool_parser.py`
**Action**: Create complete test file with:
1. Module docstring describing parser format and models
2. Imports from utils, protocol, ToolParserManager
3. Test constants with example model outputs (from T003)
4. Module-scoped tokenizer fixture
5. Function-scoped parser fixture
6. All 10 standard test functions:
   - `test_no_tool_calls` [streaming, non-streaming]
   - `test_single_tool_call_simple_args` [streaming, non-streaming]
   - `test_parallel_tool_calls` [streaming, non-streaming]
   - `test_various_data_types` [streaming, non-streaming]
   - `test_empty_arguments` [streaming, non-streaming]
   - `test_surrounding_text` [streaming, non-streaming]
   - `test_escaped_strings` [streaming, non-streaming]
   - `test_malformed_input` [streaming, non-streaming]
   - `test_streaming_reconstruction`
   - `test_streaming_boundary_splits`
7. Parser-specific tests as discovered during research
8. Mark failing tests with `@pytest.mark.xfail(reason="...")`
9. Use `run_tool_extraction()` utility for all tests
10. Include descriptive assertion messages
**Contract**: Follow `contracts/test_interface.md`

### T023 [P]: Create test_deepseekv3_tool_parser.py
**Depends on**: T004
**File**: `tests/entrypoints/openai/tool_parsers/test_deepseekv3_tool_parser.py`
**Action**: Same as T022 but for deepseekv3 parser

### T024 [P]: Create test_glm4_moe_tool_parser.py
**Depends on**: T005
**File**: `tests/entrypoints/openai/tool_parsers/test_glm4_moe_tool_parser.py`
**Action**: Same as T022 but for glm4_moe parser

### T025 [P]: Create test_granite_tool_parser.py
**Depends on**: T006
**File**: `tests/entrypoints/openai/tool_parsers/test_granite_tool_parser.py`
**Action**: Same as T022 but for granite parser

### T026 [P]: Create test_granite_20b_fc_tool_parser.py
**Depends on**: T007
**File**: `tests/entrypoints/openai/tool_parsers/test_granite_20b_fc_tool_parser.py`
**Action**: Same as T022 but for granite_20b_fc parser

### T027 [P]: Create test_internlm2_tool_parser.py
**Depends on**: T008
**File**: `tests/entrypoints/openai/tool_parsers/test_internlm2_tool_parser.py`
**Action**: Same as T022 but for internlm2 parser

### T028 [P]: Create test_jamba_tool_parser.py
**Depends on**: T009
**File**: `tests/entrypoints/openai/tool_parsers/test_jamba_tool_parser.py`
**Action**: Same as T022 but for jamba parser

### T029 [P]: Create test_kimi_k2_tool_parser.py
**Depends on**: T010
**File**: `tests/entrypoints/openai/tool_parsers/test_kimi_k2_tool_parser.py`
**Action**: Same as T022 but for kimi_k2 parser

### T030 [P]: Create test_llama_tool_parser.py
**Depends on**: T011
**File**: `tests/entrypoints/openai/tool_parsers/test_llama_tool_parser.py`
**Action**: Same as T022 but for llama parser

### T031 [P]: Create test_longcat_tool_parser.py
**Depends on**: T012
**File**: `tests/entrypoints/openai/tool_parsers/test_longcat_tool_parser.py`
**Action**: Same as T022 but for longcat parser

### T032 [P]: Create test_minimax_tool_parser.py
**Depends on**: T013
**File**: `tests/entrypoints/openai/tool_parsers/test_minimax_tool_parser.py`
**Action**: Same as T022 but for minimax parser

### T033 [P]: Create test_mistral_tool_parser.py
**Depends on**: T014
**File**: `tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py`
**Action**: Same as T022 but for mistral parser
**Special**: Verify MistralToolCall ID format (9-char alphanumeric), test [TOOL_CALLS] token

### T034 [P]: Create or extend test_openai_tool_parser.py
**Depends on**: T015
**File**: `tests/entrypoints/openai/tool_parsers/test_openai_tool_parser.py` OR `tests/tool_use/test_openai_tool_parser.py`
**Action**:
1. Check if test file already exists in either location
2. If exists: Review and extend with missing standard patterns
3. If not: Create new file same as T022 but for openai parser
**Special**: Handle Harmony encoding format, channel-based routing, content-type

### T035 [P]: Create test_phi4mini_tool_parser.py
**Depends on**: T016
**File**: `tests/entrypoints/openai/tool_parsers/test_phi4mini_tool_parser.py`
**Action**: Same as T022 but for phi4mini parser

### T036 [P]: Create test_qwen3coder_tool_parser.py
**Depends on**: T017
**File**: `tests/entrypoints/openai/tool_parsers/test_qwen3coder_tool_parser.py`
**Action**: Same as T022 but for qwen3coder parser

### T037 [P]: Create test_qwen3xml_tool_parser.py
**Depends on**: T018
**File**: `tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py`
**Action**: Same as T022 but for qwen3xml parser

### T038 [P]: Create test_seed_oss_tool_parser.py
**Depends on**: T019
**File**: `tests/entrypoints/openai/tool_parsers/test_seed_oss_tool_parser.py`
**Action**: Same as T022 but for seed_oss parser

### T039 [P]: Create test_step3_tool_parser.py
**Depends on**: T020
**File**: `tests/entrypoints/openai/tool_parsers/test_step3_tool_parser.py`
**Action**: Same as T022 but for step3 parser

### T040 [P]: Create test_xlam_tool_parser.py
**Depends on**: T021
**File**: `tests/entrypoints/openai/tool_parsers/test_xlam_tool_parser.py`
**Action**: Same as T022 but for xlam parser

---

## Phase 4: Extend Existing Test Files (5 tasks) - ALL [P]

### T041 [P]: Extend test_hermes_tool_parser.py
**File**: `tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py`
**Action**:
1. Read existing test file and compare against `contracts/test_interface.md`
2. Identify missing standard test patterns from the 10 required
3. Add missing tests using existing test patterns as examples
4. Ensure all tests use `run_tool_extraction()` utility
5. Verify streaming/non-streaming parametrization is consistent
6. Add any additional parser-specific tests for scratch pad handling or token buffering
7. Mark any failing tests with `@pytest.mark.xfail(reason="...")`
**Preserve**: Existing working tests, don't break current functionality

### T042 [P]: Extend test_hunyuan_a13b_tool_parser.py
**File**: `tests/entrypoints/openai/tool_parsers/test_hunyuan_a13b_tool_parser.py`
**Action**: Same as T041 but for hunyuan_a13b parser

### T043 [P]: Extend test_llama3_json_tool_parser.py
**File**: `tests/entrypoints/openai/tool_parsers/test_llama3_json_tool_parser.py`
**Action**: Same as T041 but for llama3_json parser

### T044 [P]: Extend test_llama4_pythonic_tool_parser.py
**File**: `tests/entrypoints/openai/tool_parsers/test_llama4_pythonic_tool_parser.py`
**Action**: Same as T041 but for llama4_pythonic parser
**Special**: Verify regex timeout handling tests exist (from existing pattern)

### T045 [P]: Extend test_pythonic_tool_parser.py
**File**: `tests/entrypoints/openai/tool_parsers/test_pythonic_tool_parser.py`
**Action**: Same as T041 but for pythonic parser
**Note**: This file already has comprehensive tests; focus on any gaps vs contract

---

## Phase 5: Validation & Documentation (3 tasks)

### T046: Run complete test suite and collect results
**Dependencies**: All test creation/extension tasks (T022-T045)
**Action**:
1. Run: `pytest tests/entrypoints/openai/tool_parsers/ -v --tb=short`
2. Collect results: passing, failing, xfail counts per parser
3. Verify performance: Each parser's tests complete in <2min (excluding slow_test marked)
4. Generate summary report with:
   - Total test count
   - Pass/fail/xfail breakdown per parser
   - Any parsers missing tests
   - Performance outliers (tests taking >2min)
5. If slow tests found, mark them with `@pytest.mark.slow_test`
**Output**: Test results summary for documentation

### T047: Document known failures and create bug tracking
**Dependencies**: T046
**Action**:
1. Review all `@pytest.mark.xfail` markers across test files
2. Create comprehensive list of parser bugs exposed by tests
3. For each xfail test, document:
   - Parser name
   - Test scenario that fails
   - Reason from xfail marker
   - Example model output that triggers bug
4. Create reference document: `specs/20251006-tool-parser-tests/known-failures.md`
5. Optionally: Create GitHub issues for each bug (if authorized)
**Output**: Bug tracking document for future parser fixes

### T048: Final validation and quickstart verification
**Dependencies**: T046, T047
**Action**:
1. Verify all 23 parsers have test files
2. Run quickstart.md examples to ensure they work
3. Test parallel execution: `pytest tests/entrypoints/openai/tool_parsers/ -n auto`
4. Verify test markers are correct (slow_test, xfail)
5. Check test coverage: `pytest tests/entrypoints/openai/tool_parsers/ --cov=vllm.entrypoints.openai.tool_parsers`
6. Update quickstart.md with any lessons learned
7. Verify constitutional compliance:
   - Tests only, no production changes ✓
   - Fast execution (<2min per parser) ✓
   - Cross-platform compatible ✓
   - Follows vLLM test structure ✓
**Success Criteria**: All validation checklist items pass

---

## Dependencies Graph

```
T001, T002 (Setup)
    ↓
T003-T021 (Research) [ALL PARALLEL]
    ↓
T022-T040 (New Tests) [ALL PARALLEL, each depends on corresponding research]
T041-T045 (Extend Tests) [ALL PARALLEL, no research dependency]
    ↓
T046 (Run Tests)
    ↓
T047 (Document Failures)
    ↓
T048 (Final Validation)
```

## Parallel Execution Examples

### Phase 2: Launch all research tasks in parallel
```bash
# All 18 research tasks can run simultaneously (T003-T021)
# Each researches a different parser independently
```

### Phase 3: Launch all test creation tasks in parallel
```bash
# All 18 new test files can be created simultaneously (T022-T040)
# All 5 test extensions can run simultaneously (T041-T045)
# Total: 23 parallel test file tasks
```

### Example: Running 5 test creation tasks together
```python
# These all modify different files, can run in parallel:
# T022: tests/entrypoints/openai/tool_parsers/test_deepseekv31_tool_parser.py
# T023: tests/entrypoints/openai/tool_parsers/test_deepseekv3_tool_parser.py
# T024: tests/entrypoints/openai/tool_parsers/test_glm4_moe_tool_parser.py
# T025: tests/entrypoints/openai/tool_parsers/test_granite_tool_parser.py
# T026: tests/entrypoints/openai/tool_parsers/test_granite_20b_fc_tool_parser.py
```

## Task Execution Checklist

Before starting implementation:
- [ ] All design documents reviewed (plan.md, research.md, data-model.md, contracts/, quickstart.md)
- [ ] Understand 10 standard test patterns from contract
- [ ] Understand shared utilities in utils.py
- [ ] Ready to search web + read parser code for format research

During implementation:
- [ ] Follow TDD: Research → Write Tests → Tests Should Fail/Pass (xfail if bugs)
- [ ] Use fresh parser instances (function-scoped fixtures)
- [ ] Mark slow tests with `@pytest.mark.slow_test`
- [ ] Mark known failures with `@pytest.mark.xfail(reason="...")`
- [ ] Include descriptive assertion messages

After implementation:
- [ ] All 23 parsers have test coverage
- [ ] Tests run in <2min per parser (excluding slow_test)
- [ ] Known failures documented
- [ ] Quickstart.md examples verified working
- [ ] Test coverage meets requirements

## Notes

- **Total Test Files**: 23 (18 new + 5 extended)
- **Standard Tests per Parser**: 10 required test functions
- **Expected Test Cases**: ~300-460 total (15-20 per parser including parser-specific)
- **Parallelization**: 41 of 46 tasks can run in parallel
- **Performance Target**: <2min per parser for standard tests
- **Quality Gate**: Tests validate parsers, xfail markers document bugs

## Success Criteria

✓ All 23 tool parsers have comprehensive test coverage
✓ All tests follow contracts/test_interface.md
✓ Both streaming and non-streaming modes tested
✓ Test isolation maintained (fresh parser instances)
✓ Known failures documented with xfail markers
✓ Tests execute quickly for CI/CD (<2min per parser)
✓ Shared utilities used consistently
✓ Parser-specific edge cases covered
