# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Source code**: `vllm/<component>/` (e.g., `vllm/models/`, `vllm/kernels/`, `vllm/entrypoints/`)
- **Tests**: `tests/<component>/` mirroring source structure (e.g., `tests/models/`, `tests/kernels/`)
- **Special test categories**: `tests/basic_correctness/`, `tests/benchmarks/`, `tests/distributed/`
- Use appropriate pytest markers: `@pytest.mark.core_model`, `@pytest.mark.slow_test`, `@pytest.mark.distributed`, etc.

## Phase 3.1: Setup
- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T004 [P] Unit test for [component] in tests/[component]/test_[feature].py
- [ ] T005 [P] Integration test in tests/entrypoints/test_[feature].py (if API change)
- [ ] T006 [P] Basic correctness test in tests/basic_correctness/ (if end-to-end feature)
- [ ] T007 [P] Benchmark test in tests/benchmarks/ (if performance-sensitive)
- [ ] T008 [P] Model test in tests/models/ (if new model or model change)

**Note**: Add appropriate pytest markers (`@pytest.mark.core_model`, `@pytest.mark.slow_test`, etc.)

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T009 [P] Core logic in vllm/[component]/[feature].py
- [ ] T010 [P] Model changes in vllm/models/ (if applicable)
- [ ] T011 [P] Kernel implementation in vllm/kernels/ (if performance-critical)
- [ ] T012 Engine integration in vllm/engine/ (if orchestration change)
- [ ] T013 API endpoint in vllm/entrypoints/ (if API change)
- [ ] T014 Error handling and validation
- [ ] T015 Type hints and docstrings

## Phase 3.4: Integration & Platform Support
- [ ] T016 Hardware compatibility verification (NVIDIA/AMD/Intel/etc.)
- [ ] T017 Distributed execution testing (if multi-GPU feature)
- [ ] T018 Quantization support (if applicable)
- [ ] T019 Plugin integration (if extensibility point)

## Phase 3.5: Polish & Quality
- [ ] T020 [P] Code passes `ruff` linter
- [ ] T021 [P] Type checking with `mypy` passes
- [ ] T022 [P] Performance benchmarks meet targets
- [ ] T023 Update external docs reference (https://docs.vllm.ai/en/latest/contributing/)
- [ ] T024 Verify backward compatibility
- [ ] T025 Remove duplication and refactor

## Dependencies
- Tests (T004-T008) before implementation (T009-T015)
- Core implementation before integration (T016-T019)
- Integration before polish (T020-T025)
- Hardware-specific tests depend on core implementation
- Benchmark tests require working implementation

## Parallel Example
```
# Launch T004-T008 together (different test files):
Task: "Unit test in tests/kernels/test_new_kernel.py"
Task: "Integration test in tests/entrypoints/test_api.py"
Task: "Basic correctness test in tests/basic_correctness/test_feature.py"
Task: "Benchmark test in tests/benchmarks/test_feature_perf.py"
Task: "Model test in tests/models/test_new_model.py"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task