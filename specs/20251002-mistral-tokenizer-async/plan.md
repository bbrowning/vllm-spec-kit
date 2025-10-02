
# Implementation Plan: Mistral Tokenizer Async Event Loop Fix

**Branch**: `20251002-mistral-tokenizer-async` | **Date**: 2025-10-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Volumes/SourceCode/vllm/trees/20251002-mistral-tokenizer-async/specs/20251002-mistral-tokenizer-async/spec.md`

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
Fix event loop blocking in vLLM when processing large payloads with Mistral tokenizers. Currently, calling `apply_mistral_chat_template` (which uses Mistral tokenizer's `apply_chat_template` and `encode_chat_completion`) executes synchronously on the async event loop, causing health endpoints to become unresponsive (439KB request blocks for 53s). The fix will add a new `async_apply_mistral_chat_template` wrapper function in `chat_utils.py` that offloads the blocking `apply_mistral_chat_template` call to a thread pool executor with sequential queuing, ensuring health checks remain responsive (<2s) while maintaining identical tokenization results and <5% performance overhead.

## Technical Context
**Language/Version**: Python 3.9+ (vLLM supports Python 3.9-3.12)
**Primary Dependencies**: asyncio (stdlib), mistral_common (Mistral tokenizer library), pytest (testing)
**Storage**: N/A (in-memory tokenization operations)
**Testing**: pytest with async support, pytest markers (`slow_test` for event loop blocking tests)
**Target Platform**: Linux server (vLLM inference server)
**Project Type**: single (vLLM monorepo)
**Performance Goals**: Health endpoint <2s response during tokenization, tokenization overhead <5% vs current implementation
**Constraints**: Must maintain identical tokenization results, sequential processing for large payloads (400KB+), no changes to HuggingFace tokenizer path
**Scale/Scope**: Add new async wrapper in `vllm/entrypoints/chat_utils.py` as `async_apply_mistral_chat_template`, leaves existing `apply_mistral_chat_template` unchanged

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Performance First (Principle I)
- [x] Performance impact evaluated and documented - <5% overhead target, health endpoint must stay <2s responsive
- [x] Benchmarks planned for performance-sensitive code paths - Will measure tokenization timing before/after, event loop blocking detection
- [x] No known regressions without justification - Sequential queueing may add latency for concurrent large requests, but this is intentional to prevent resource exhaustion

### Hardware Diversity (Principle II)
- [x] Feature works across supported platforms OR explicitly scoped to specific hardware - Tokenization is CPU-bound, works across all platforms
- [x] No breaking changes to existing hardware support - No hardware-specific code changes
- [x] Hardware-specific features have appropriate test markers - N/A, not hardware-specific

### Comprehensive Testing (Principle III)
- [x] Test strategy defined (unit/integration/e2e appropriate for change) - Unit test for event loop blocking detection, integration test for health endpoint responsiveness
- [x] Performance-sensitive code includes benchmark tests - Will measure tokenization performance regression
- [x] Appropriate pytest markers planned (`core_model`, `slow_test`, `distributed`, etc.) - Use `slow_test` marker for event loop blocking test

### Modular Architecture (Principle IV)
- [x] Feature fits within existing `/vllm/` and `/tests/` structure - New async function in `vllm/entrypoints/chat_utils.py`, tests in `tests/entrypoints/`
- [x] New modules justified with architectural reasoning - No new modules, adding async variant alongside existing function
- [x] Clear separation of concerns maintained - Async wrapper isolated in chat_utils, original Mistral tokenizer unchanged

### Backward Compatibility (Principle V)
- [x] Public API changes maintain compatibility OR follow deprecation policy - New async function added, existing `apply_mistral_chat_template` unchanged
- [x] Breaking changes documented with migration guide - No breaking changes, additive only
- [x] Release notes plan includes compatibility notes - Will note new async variant for event loop blocking fix

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
Following TDD (Test-Driven Development) approach per user requirements:
1. **Failing Test Tasks** - Create tests comparing original vs new async function (will fail before implementation)
   - Event loop responsiveness test using `async_apply_mistral_chat_template` (from contracts/event-loop-responsiveness.md)
   - Tokenization correctness test comparing `apply_mistral_chat_template` vs `async_apply_mistral_chat_template` (from contracts/event-loop-responsiveness.md)
   - Performance overhead tests comparing both functions (from contracts/performance-overhead.md)
   - Mark with `@pytest.mark.slow_test` and `@pytest.mark.asyncio`

2. **Implementation Tasks** - Add new async wrapper function
   - Add module-level ThreadPoolExecutor helper `_get_mistral_executor()` to chat_utils.py
   - Add `async_apply_mistral_chat_template()` function that wraps existing `apply_mistral_chat_template`
   - Use `asyncio.get_event_loop().run_in_executor()` to offload to thread
   - Ensure sequential execution via ThreadPoolExecutor max_workers=1
   - Preserve error handling (exceptions propagate naturally from executor)

3. **Verification Tasks** - Confirm tests now pass
   - Run event loop blocking test → should pass
   - Run correctness tests → should pass (identical tokens)
   - Run performance benchmarks → overhead <5%
   - Update quickstart.md with actual results

**Ordering Strategy**:
- **Test-First**: All test tasks before any implementation (TDD requirement)
- **Sequential Dependencies**:
  1. Create failing event loop blocking test [blocks: implementation]
  2. Create tokenization correctness test [blocks: implementation]
  3. Create performance overhead test [blocks: implementation]
  4. Implement ThreadPoolExecutor helper in chat_utils.py [depends: tests exist]
  5. Implement async_apply_mistral_chat_template wrapper [depends: executor helper]
  6. Verify all tests pass [depends: implementation complete]
  7. Run quickstart validation [depends: tests passing]
- **No Parallel Tasks** - Sequential execution ensures test failures are visible before implementation

**Estimated Output**: 10-12 numbered, ordered tasks in tasks.md

**Focus Areas** (from user input):
- Primary: Fix Mistral tokenizer preprocessing blocking async event loop
- Testing: Write failing test first, then fix, then verify test passes
- Scope: Add new async wrapper in chat_utils.py, leave original `apply_mistral_chat_template` unchanged
- Approach: New `async_apply_mistral_chat_template` wraps existing function via ThreadPoolExecutor

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) - research.md created
- [x] Phase 1: Design complete (/plan command) - data-model.md, contracts/, quickstart.md, CLAUDE.md created
- [x] Phase 2: Task planning complete (/plan command - describe approach only) - TDD strategy defined
- [ ] Phase 3: Tasks generated (/tasks command) - NOT STARTED
- [ ] Phase 4: Implementation complete - NOT STARTED
- [ ] Phase 5: Validation passed - NOT STARTED

**Gate Status**:
- [x] Initial Constitution Check: PASS - All principles satisfied, no violations
- [x] Post-Design Constitution Check: PASS - Design maintains compliance
- [x] All NEEDS CLARIFICATION resolved - Technical Context fully specified
- [x] Complexity deviations documented - None (no Complexity Tracking violations)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
