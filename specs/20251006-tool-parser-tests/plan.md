
# Implementation Plan: Comprehensive Unit Tests for All vLLM Tool Call Parsers

**Branch**: `20251006-tool-parser-tests` | **Date**: 2025-10-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Volumes/SourceCode/vllm/trees/20251006-tool-parser-tests/specs/20251006-tool-parser-tests/spec.md`

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
Create comprehensive unit tests for all 23 tool call parsers in vLLM, ensuring consistent test coverage across standard patterns (empty calls, single calls, parallel calls, whitespace handling, malformed input, etc.) while allowing parser-specific extensions for model-specific edge cases. Tests will cover both streaming and non-streaming modes, use pytest xfail markers for known failures, and follow a hybrid test infrastructure approach with shared utilities but parser-specific fixtures and test data.

## Technical Context
**Language/Version**: Python 3.9-3.13 (vLLM supports Python >=3.9,<3.14)
**Primary Dependencies**: pytest (testing framework), vLLM entrypoints.openai.protocol (OpenAI-compatible data structures), transformers (tokenizer access)
**Storage**: N/A (unit tests only, no persistent storage)
**Testing**: pytest with markers (slow_test, distributed, core_model), xfail for known failures
**Target Platform**: All platforms vLLM supports (Linux, macOS, Windows with various GPU/CPU backends)
**Project Type**: Single-project structure (vLLM monorepo)
**Performance Goals**: Fast test execution for CI/CD (<2min per parser for standard tests, slow tests marked separately)
**Constraints**: Test isolation (fresh parser instances), no external dependencies (mocked tokenizers acceptable), deterministic results
**Scale/Scope**: 23 tool parsers, ~10-15 standard test cases per parser, ~200-400 total test cases

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Performance First (Principle I)
- [x] Performance impact evaluated and documented - Tests only, no production code changes. Fast test execution required for CI/CD (<2min per parser). Slow tests will be marked with `slow_test` marker.
- [x] Benchmarks planned for performance-sensitive code paths - N/A, this feature adds tests for existing parsers, not new performance-sensitive code
- [x] No known regressions without justification - No production code changes, zero performance regression risk

### Hardware Diversity (Principle II)
- [x] Feature works across supported platforms OR explicitly scoped to specific hardware - Tests run on all platforms (pytest is cross-platform)
- [x] No breaking changes to existing hardware support - No production code changes
- [x] Hardware-specific features have appropriate test markers - N/A, tool parsers are hardware-agnostic (CPU-bound text processing)

### Comprehensive Testing (Principle III)
- [x] Test strategy defined (unit/integration/e2e appropriate for change) - Unit tests for each tool parser, testing both streaming and non-streaming extraction
- [x] Performance-sensitive code includes benchmark tests - N/A, adding tests not new performance code
- [x] Appropriate pytest markers planned (`core_model`, `slow_test`, `distributed`, etc.) - Using `slow_test` for extensive streaming tests, `xfail` for known parser bugs

### Modular Architecture (Principle IV)
- [x] Feature fits within existing `/vllm/` and `/tests/` structure - Tests go in `tests/entrypoints/openai/tool_parsers/test_*_tool_parser.py`, following existing convention
- [x] New modules justified with architectural reasoning - No new modules, only test files following established pattern
- [x] Clear separation of concerns maintained - Test utilities in `utils.py`, parser-specific tests in separate files

### Backward Compatibility (Principle V)
- [x] Public API changes maintain compatibility OR follow deprecation policy - No API changes, tests only
- [x] Breaking changes documented with migration guide - N/A, no breaking changes
- [x] Release notes plan includes compatibility notes - Tests enhance quality but don't affect user-facing behavior

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
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
The /tasks command will create tasks.md by processing:
1. Research findings from research.md (23 parsers, existing test patterns)
2. Data model from data-model.md (10 standard test patterns per parser)
3. Test interface contract from contracts/test_interface.md

**Task Categories**:

1. **Setup Tasks** (1-2 tasks):
   - Verify shared test utilities in `utils.py` are sufficient
   - Create shared fixtures in `conftest.py` if needed

2. **Parser Research Tasks** (18 tasks, one per parser without tests) [P]:
   - For each parser without existing tests:
     - Research model output format (web + code analysis per FR-014)
     - Document format in task notes
     - Create example model outputs for standard test patterns
   - Parsers: deepseekv31, deepseekv3, glm4_moe, granite, granite_20b_fc, internlm2, jamba, kimi_k2, llama, longcat, minimax, mistral, openai, phi4mini, qwen3coder, qwen3xml, seed_oss, step3, xlam

3. **New Test File Creation Tasks** (18 tasks, one per parser without tests) [P]:
   - Create test file `test_{parser}_tool_parser.py`
   - Implement module structure (docstring, imports, fixtures)
   - Implement all 10 standard test functions per contract
   - Add parser-specific tests as needed
   - Mark failing tests with xfail markers

4. **Existing Test Extension Tasks** (5 tasks, one per parser with tests) [P]:
   - Extend existing test files to ensure all 10 standard patterns covered
   - Add missing test scenarios based on contract review
   - Ensure consistent use of shared utilities
   - Verify streaming/non-streaming parametrization
   - Parsers: hermes, hunyuan_a13b, llama3_json, llama4_pythonic, pythonic

5. **Validation Tasks** (2-3 tasks):
   - Run full test suite: `pytest tests/entrypoints/openai/tool_parsers/ -v`
   - Document xfail tests and create bug tracking issues
   - Verify test performance (<2min per parser, slow tests marked)

**Ordering Strategy**:
1. Setup tasks first (shared infrastructure)
2. Research tasks in parallel [P] (independent web/code research)
3. Test creation/extension tasks after research [P] (can run in parallel)
4. Validation tasks last (require all tests complete)

**Dependency Rules**:
- Setup → Research (shared utilities must exist before writing tests)
- Research (parser X) → Test Creation (parser X) (need format examples before writing tests)
- All Test Creation/Extension → Validation (need all tests before running full suite)

**Parallelization Markers**:
- [P] on research tasks: Each parser research is independent
- [P] on test file tasks: Each test file is independent Python module
- Sequential for setup and validation tasks

**Estimated Output**:
- ~44 total tasks (2 setup + 18 research + 18 new tests + 5 extend tests + 3 validation)
- ~23 tasks can run in parallel (research + test creation)
- Expected completion: 200-400 test cases across 23 parsers

**Test Metrics per Parser**:
- Minimum 10 standard tests (from contract)
- ~2-5 parser-specific tests (discovered during research)
- Both streaming and non-streaming modes
- Total: ~15-20 test functions per parser → ~300-460 total test cases

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

No constitutional violations. This feature adds test coverage only, following established vLLM testing patterns and organizational structure.


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) - research.md created
- [x] Phase 1: Design complete (/plan command) - data-model.md, contracts/, quickstart.md, CLAUDE.md created
- [x] Phase 2: Task planning complete (/plan command - describe approach only) - Task generation strategy documented
- [x] Phase 3: Tasks generated (/tasks command) - tasks.md created with 46 tasks
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS - No violations, tests only
- [x] Post-Design Constitution Check: PASS - Design maintains constitutional compliance
- [x] All NEEDS CLARIFICATION resolved - No NEEDS CLARIFICATION markers in Technical Context
- [x] Complexity deviations documented - No deviations

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
