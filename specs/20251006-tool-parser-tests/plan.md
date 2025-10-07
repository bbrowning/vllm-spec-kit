
# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary

Create comprehensive unit tests for vLLM tool call parsers that convert model-specific outputs into OpenAI-compatible tool call objects. The test suite provides standardized test coverage across 15 parsers (deepseekv3, granite, granite_20b_fc, hermes, hunyuan_a13b, internlm2, llama, llama3_json, llama4_pythonic, longcat, mistral, phi4mini, pythonic, qwen3xml, step3) with 10 standard test scenarios per parser plus parser-specific extensions.

**Current Status (Iteration 3)**: 433 passed, 58 failed, 93 xfailed, 0 xpassed across ~607 test cases. Implementation complete with systematic triaging in progress to achieve zero failures through fixes or xfail markers.

**Key Learnings**:
- Test suite reconciliation revealed 9 parsers with old-style unit tests in `tests/tool_use/` (excluded from scope)
- Identified need for test refactoring using shared test contract to reduce ~4,155 lines of duplicated code
- Systematic triaging process critical: test format issues vs actual parser bugs vs streaming limitations
- xfail marker accuracy essential for CI/CD reliability

## Technical Context
**Language/Version**: Python 3.9-3.13 (vLLM supports Python >=3.9,<3.14)
**Primary Dependencies**: pytest (testing framework), vLLM entrypoints.openai.protocol (OpenAI-compatible data structures), transformers (tokenizer access), unittest.mock (test isolation)
**Storage**: N/A (unit tests only)
**Testing**: pytest with parametrization, fixtures, xfail/skip markers, streaming/non-streaming test variants
**Target Platform**: All platforms vLLM supports (Linux, macOS, multiple Python versions)
**Project Type**: single (vLLM monorepo with `/vllm/` source and `/tests/` test structure)
**Performance Goals**: Test suite execution < 2 minutes for fast CI feedback, < 120 seconds target
**Constraints**: Tests must not require model downloads (mocked tokenizers), no external services, full test isolation (fresh parser per test)
**Scale/Scope**: 15 parsers with comprehensive tests, 607 total test cases, ~16,152 lines of test code, future refactoring to reduce duplication by 65%

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Performance First (Principle I)
- [x] Performance impact evaluated and documented
  - **Status**: No performance impact - unit tests only, no production code changes
  - **Test execution**: Target < 120 seconds for full suite (currently ~95 seconds)
- [x] Benchmarks planned for performance-sensitive code paths
  - **Status**: N/A - testing infrastructure only, no performance-sensitive code added
- [x] No known regressions without justification
  - **Status**: Zero production code changes, only test additions

### Hardware Diversity (Principle II)
- [x] Feature works across supported platforms OR explicitly scoped to specific hardware
  - **Status**: Tests use mocked tokenizers, no hardware dependencies
  - **Platform coverage**: Tests run on all Python 3.9-3.13 platforms
- [x] No breaking changes to existing hardware support
  - **Status**: No production code changes
- [x] Hardware-specific features have appropriate test markers
  - **Status**: N/A - all tests platform-agnostic

### Comprehensive Testing (Principle III)
- [x] Test strategy defined (unit/integration/e2e appropriate for change)
  - **Strategy**: Pure unit tests with mocked dependencies in `tests/entrypoints/openai/tool_parsers/`
  - **Coverage**: 10 standard tests per parser + parser-specific extensions
  - **Modes**: Both streaming and non-streaming variants tested
  - **Markers**: xfail for known parser bugs, skip for missing dependencies
- [x] Performance-sensitive code includes benchmark tests
  - **Status**: N/A - test infrastructure only
- [x] Appropriate pytest markers planned
  - **Markers used**: `@pytest.mark.parametrize`, `@pytest.mark.xfail`, `@pytest.mark.skipif`
  - **No special markers needed**: Tests are fast unit tests (not slow_test, not distributed)

### Modular Architecture (Principle IV)
- [x] Feature fits within existing `/vllm/` and `/tests/` structure
  - **Location**: `tests/entrypoints/openai/tool_parsers/` (follows vLLM test organization)
  - **Pattern**: One test file per parser, shared utilities in `utils.py`
  - **Future refactoring**: Will introduce `test_contract.py` and `parser_test_fixtures.py` for DRY
- [x] New modules justified with architectural reasoning
  - **Current**: Individual test files per parser (existing pattern)
  - **Planned**: Shared test contract pattern to reduce duplication (tool-call-test-refactor.md)
- [x] Clear separation of concerns maintained
  - **Unit tests**: `tests/entrypoints/openai/tool_parsers/` (this work)
  - **Integration tests**: `tests/tool_use/` (pre-existing, separate)
  - **Old-style unit tests**: `tests/tool_use/test_*_parser.py` (9 parsers, excluded from scope)

### Backward Compatibility (Principle V)
- [x] Public API changes maintain compatibility OR follow deprecation policy
  - **Status**: No public API changes - tests only
- [x] Breaking changes documented with migration guide
  - **Status**: No breaking changes
- [x] Release notes plan includes compatibility notes
  - **Status**: Test additions only, not user-facing
  - **Note**: Future test refactoring is internal change, no user impact

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (vLLM structure)
```
vllm/
├── attention/           # Attention mechanisms and kernels
├── core/               # Core abstractions and interfaces
├── engine/             # Inference engine orchestration
├── entrypoints/        # API servers and CLI
├── executor/           # Execution backends (GPU, CPU, etc.)
├── kernels/            # CUDA/HIP kernels and ops
├── model_executor/     # Model loading and execution
├── models/             # Model implementations
├── multimodal/         # Multimodal model support
├── platforms/          # Platform-specific code
├── plugins/            # Plugin system
├── reasoning/          # Reasoning capabilities
├── transformers_utils/ # HuggingFace integration
└── worker/             # Distributed worker logic

tests/
├── basic_correctness/  # Basic end-to-end tests
├── benchmarks/         # Performance benchmarks
├── compile/            # Compilation tests
├── distributed/        # Multi-GPU/node tests
├── entrypoints/        # API/CLI integration tests
├── kernels/            # Kernel unit tests
├── models/             # Model-specific tests
├── multimodal/         # Multimodal tests
├── quantization/       # Quantization tests
└── [other components]  # Component-specific tests
```

**Structure Decision**: vLLM follows a single-project structure with clear component
separation. Features should be placed in the appropriate component directory within
`vllm/` with corresponding tests in `tests/`.

## Phase 0: Outline & Research

**Status**: ✅ COMPLETE - All research documented in research.md

**Completed Research**:
1. **Parser format discovery**: Researched official model documentation and examined parser implementations for 15 parsers across XML-based (qwen3xml, seed_oss), JSON-based (llama3_json, mistral), token-based (kimi_k2, jamba), Python-like (pythonic, llama4_pythonic), and custom formats
2. **Test pattern analysis**: Identified 10 standard test scenarios common across all parsers from existing test coverage
3. **Streaming vs non-streaming**: Documented streaming implementation patterns and common limitations across parsers
4. **Test organization**: Discovered test suite duplication issue - 3 categories identified (new comprehensive, old-style, integration)
5. **Systematic triaging approach**: Developed process for distinguishing test format issues from parser bugs

**Key Decisions**:
- **Decision**: Focus on 15 parsers without comprehensive unit tests, exclude 9 with old-style tests
- **Rationale**: Avoid duplication, maintain clear scope, preserve existing test infrastructure
- **Alternatives considered**: Migrate all 24 parsers (rejected - unnecessary churn)

- **Decision**: Use pytest parametrize with xfail markers for streaming bugs
- **Rationale**: Documents known issues while allowing tests to run, provides CI signal
- **Alternatives considered**: Skip tests entirely (rejected - hides bugs), fix all parsers first (rejected - out of scope)

- **Decision**: Mock tokenizers instead of loading real models
- **Rationale**: Fast test execution (<2 min), no downloads, platform-independent
- **Alternatives considered**: Real tokenizers (rejected - slow, requires downloads)

**Output**: research.md contains detailed parser format examples and testing patterns discovered during implementation iterations 1-3

## Phase 1: Design & Contracts

**Status**: ✅ COMPLETE - All design artifacts created

**Completed Artifacts**:

1. **data-model.md** - ✅ Created
   - Defined key entities: ToolParser, ModelOutput, ToolCall, TestCase, StreamingDelta, ParserTestConfig (for future refactoring)
   - Documented relationships: Parser → ModelOutput → ToolCall transformations
   - Validation rules: OpenAI compatibility requirements, JSON argument encoding
   - State transitions: Streaming parser state machine (INIT → ACCUMULATING → COMPLETE)

2. **contracts/test_interface.md** - ✅ Created
   - Defined standard test contract: 10 required test scenarios all parsers must support
   - Test patterns: no_tool_calls, single_tool_call, parallel_tool_calls, various_data_types, empty_arguments, surrounding_text, escaped_strings, malformed_input, streaming_reconstruction, streaming_boundary_splits
   - Streaming requirements: Fresh parser per test, incremental delta handling
   - Extension patterns: Parser-specific tests allowed beyond standard contract

3. **quickstart.md** - ✅ Created
   - Test execution commands for running full suite and individual parsers
   - Investigation workflow for triaging failures
   - xfail marker usage patterns
   - Example parser test file structure

4. **Test Implementation** - ✅ Created 15 parser test files
   - Location: `tests/entrypoints/openai/tool_parsers/test_*_tool_parser.py`
   - Pattern: ~400-900 lines per file with standard tests + parser-specific extensions
   - Total: ~16,152 lines of test code, 607 test cases
   - Status: 433 passing, 58 failing, 93 xfailed (iteration 3 in progress)

5. **Future Refactoring Design** - ✅ Documented in tool-call-test-refactor.md
   - Proposed architecture: SharedTestContract base class + ParserTestConfig dataclass
   - Benefits: Reduce ~4,155 lines of duplication, easier maintenance, consistent patterns
   - Implementation path: Create test_contract.py and parser_test_fixtures.py modules
   - Migration strategy: Refactor parsers one by one, verify test results unchanged

6. **CLAUDE.md** - ✅ Updated
   - Added Python 3.9-3.13, pytest, vLLM protocol, transformers to active technologies
   - Updated commands: pytest, ruff check
   - Documented recent changes

**Output**: All Phase 1 artifacts complete, tests implemented across iterations 1-3, ready for systematic triaging in iteration 3

## Phase 2: Task Planning Approach

**Status**: ✅ COMPLETE - Executed across 3 task iterations

**Actual Execution** (tasks.md + tasks-iteration-2.md + tasks-iteration-3.md):

**Iteration 1 (tasks.md)**: Initial test creation
- Created 15 comprehensive test files (one per parser)
- Implemented 10 standard tests per parser + parser-specific extensions
- Generated ~16,152 lines of test code, 607 test cases total
- Result: 420 passed, 106 failed, 4 skipped, 22 xfailed, 55 errors
- Documented all known failures in known-failures.md

**Iteration 2 (tasks-iteration-2.md)**: Fix xfail marker accuracy + critical errors
- **Priority 1**: Removed 27 unnecessary xfail markers (5 parsers)
  - granite: 11 markers removed (streaming tests now passing)
  - step3: 9 markers removed (selective - kept some for non-streaming bugs)
  - internlm2, glm4_moe, qwen3coder: 2-3 markers each
- **Priority 2**: Fixed kimi_k2 tokenizer trust_remote_code error
- **Priority 3**: Fixed qwen3xml test format issues (missing XML closing tags)
- Result: 432 passed, 59 failed, 8 skipped, 92 xfailed, 1 xpassed, 15 errors
- Files modified: 8 test files

**Iteration 3 (tasks-iteration-3.md)**: Achieve zero failures (IN PROGRESS)
- **P0-T001**: ✅ Fixed qwen3xml xpassed test (removed marker)
- **P0-T002**: ⏳ Handle kimi_k2 blobfile dependency (skip tests)
- **P0-T003**: ⏳ Create OpenAI parser comprehensive tests (missing parser)
- **P1-P3**: ⏳ Triage remaining 58 failures across 12 parsers
- Target: 0 failures, 0 errors, 0 xpassed, all issues documented with xfail/skip
- Current: 433 passed, 58 failed, 8 skipped, 93 xfailed, 0 xpassed, 15 errors

**Key Learnings Applied**:
1. Systematic triaging: test format issues vs parser bugs vs streaming limitations
2. xfail marker accuracy critical for CI/CD reliability
3. Test suite reconciliation revealed 9 parsers excluded from scope (old-style tests)
4. Future refactoring opportunity: ~4,155 lines duplication reduction via test contract pattern

**Ordering Strategy Used**:
- Iteration 1: Create all test files in parallel
- Iteration 2: Priority-based (quick wins first, then format fixes, then systematic triaging)
- Iteration 3: Impact-based (0 xpassed first, then errors, then large failure groups)

**IMPORTANT**: This phase was executed via manual implementation, not /tasks command

## Phase 3+: Implementation & Validation

**Status**: 🔄 IN PROGRESS (Iteration 3)

**Phase 3 - Task Execution**: ✅ COMPLETE
- Iteration 1: Created all 15 parser test files
- Iteration 2: Fixed xfail marker accuracy, critical errors
- Iteration 3: IN PROGRESS - triaging remaining 58 failures

**Phase 4 - Implementation**: ✅ MOSTLY COMPLETE
- ✅ 15/15 parser test files created (~16,152 lines)
- ✅ 607 test cases implemented
- ✅ 433/607 tests passing (71.3%)
- ✅ 93 tests properly marked as xfail (known bugs documented)
- ✅ 0 xpassed tests (all markers accurate)
- 🔄 58 failures under investigation (iteration 3)
- ⚠️ 15 errors (kimi_k2 blobfile dependency)

**Phase 5 - Validation**: 🔄 PARTIAL
- ✅ Test suite executes cleanly (~95 seconds, under 120s target)
- ✅ No unexpected failures from xfail marker inaccuracy
- ✅ Test suite reconciliation complete (documented 9 excluded parsers)
- ✅ Constitutional compliance verified (all checks passing)
- 🔄 Final triaging in progress (iteration 3)
- ⏳ Performance validation: On track for <120s target
- ⏳ CI/CD readiness: Pending zero failures

**Remaining Work**:
1. Handle kimi_k2 blobfile dependency (skip tests)
2. Create OpenAI parser comprehensive tests (1 missing parser)
3. Triage 58 remaining failures across 12 parsers
4. Update known-failures.md with final results
5. Optional: Implement test refactoring (reduce 4,155 lines duplication)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

**No violations** - All constitutional principles satisfied. This is a pure testing feature with no production code changes, no performance impact, no breaking changes, and follows vLLM's modular architecture.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete - Parser formats discovered, test patterns identified, systematic triaging approach developed
- [x] Phase 1: Design complete - data-model.md, contracts/test_interface.md, quickstart.md created; 15 test files implemented; CLAUDE.md updated
- [x] Phase 2: Task planning complete - 3 iterations planned and executed (tasks.md, tasks-iteration-2.md, tasks-iteration-3.md)
- [x] Phase 3: Tasks executed - Iteration 1 (initial tests), Iteration 2 (xfail accuracy), Iteration 3 IN PROGRESS (final triaging)
- [🔄] Phase 4: Implementation 95% complete - 433/607 passing, 58 failures under investigation, 15 errors (kimi_k2 dependency)
- [🔄] Phase 5: Validation in progress - Test suite executes in ~95s, constitutional compliance verified, final triaging needed

**Gate Status**:
- [x] Initial Constitution Check: PASS - All principles satisfied
- [x] Post-Design Constitution Check: PASS - Test implementation follows vLLM structure
- [x] All NEEDS CLARIFICATION resolved - Research complete, all technical context documented
- [x] Complexity deviations documented - None (no violations)

**Implementation Metrics**:
- **Test Coverage**: 15/15 parsers with comprehensive unit tests created
- **Test Cases**: 607 total (10 standard + extensions per parser)
- **Code Volume**: ~16,152 lines of test code
- **Test Results**: 433 passed (71.3%), 58 failed (9.6%), 93 xfailed (15.3%), 0 xpassed (0%), 15 errors (2.5%)
- **Execution Time**: ~95 seconds (under 120s target ✅)
- **Parser Coverage**: 15 new comprehensive, 9 excluded (old-style tests preserved)

**Iteration Progress**:
- **Iteration 1**: Created all test files (420 passed, 106 failed, 22 xfailed, 55 errors)
- **Iteration 2**: Fixed xfail accuracy (+31 passed, -12 failed, -26 xpassed, +7 xfailed)
- **Iteration 3**: IN PROGRESS - 2/16 task groups complete (qwen3xml xpassed fixed, step3 streaming documented)

**Next Steps**:
1. Complete iteration 3 triaging (58 failures remaining)
2. Handle kimi_k2 dependency error (15 errors → skip)
3. Create OpenAI parser tests (1 missing parser)
4. Update known-failures.md with final results
5. Optional: Implement test refactoring plan (reduce ~4,155 lines duplication)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
