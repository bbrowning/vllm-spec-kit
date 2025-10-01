
# Implementation Plan: Llama 3 JSON Tool Parser Prefix/Suffix Retention

**Branch**: `001-i-need-to` | **Date**: 2025-09-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Volumes/SourceCode/vllm/specs/001-i-need-to/spec.md`

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
Fix bug in Llama 3 JSON tool parser (`Llama3JsonToolParser`) where plain-text content before and after JSON tool calls is being discarded. The parser currently extracts only the JSON tool calls and sets `content=None`, but should preserve all surrounding text in a shared context field. Additionally, the "; " delimiter between multiple tool calls should be stripped (not preserved as content). Focus is on fixing this specific bug in the non-streaming `extract_tool_calls` method and updating the corresponding test expectations.

## Technical Context
**Language/Version**: Python 3.9+ (vLLM supports Python 3.9-3.13)
**Primary Dependencies**: regex, partial_json_parser, transformers, vLLM core types
**Storage**: N/A (stateless parser)
**Testing**: pytest with vLLM test infrastructure
**Target Platform**: Cross-platform (Linux, macOS, Windows - wherever vLLM runs)
**Project Type**: Single project (vLLM monorepo)
**Performance Goals**: No performance regression (parser is not on critical path during inference)
**Constraints**:
  - Non-streaming mode only (streaming mode out of scope)
  - Must maintain backward compatibility with existing API
  - Must handle "; " as delimiter between tool calls
  - Whitespace-only context treated as empty
**Scale/Scope**: Small bug fix - modify 1 method + update 1-2 tests

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Performance First (Principle I)
- [x] Performance impact evaluated and documented (minimal - parsing happens outside inference loop)
- [x] Benchmarks planned for performance-sensitive code paths (not needed - text extraction is O(n) and not on critical path)
- [x] No known regressions without justification (adding text extraction will have negligible performance impact)

### Hardware Diversity (Principle II)
- [x] Feature works across supported platforms (parser is pure Python, platform-agnostic)
- [x] No breaking changes to existing hardware support (not hardware-related)
- [x] Hardware-specific features have appropriate test markers (N/A - not hardware-specific)

### Comprehensive Testing (Principle III)
- [x] Test strategy defined (unit tests in tests/entrypoints/openai/tool_parsers/)
- [x] Performance-sensitive code includes benchmark tests (not performance-sensitive)
- [x] Appropriate pytest markers planned (no special markers needed - standard unit tests)

### Modular Architecture (Principle IV)
- [x] Feature fits within existing `/vllm/` and `/tests/` structure (modifying existing parser in vllm/entrypoints/openai/tool_parsers/)
- [x] New modules justified with architectural reasoning (no new modules - bug fix in existing code)
- [x] Clear separation of concerns maintained (parser logic stays in tool_parsers module)

### Backward Compatibility (Principle V)
- [x] Public API changes maintain compatibility (ExtractedToolCallInformation already has content field, just changing from None to actual text)
- [x] Breaking changes documented with migration guide (no breaking changes - callers ignoring content will continue to work)
- [x] Release notes plan includes compatibility notes (will note that content is now populated for tool calls)

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
- This is a focused bug fix, not a feature build
- No contract generation needed (no API changes)
- No model creation needed (reusing existing types)
- Generate tasks from:
  - research.md (implementation approach)
  - data-model.md (context extraction logic)
  - quickstart.md (test scenarios)

**Specific Tasks to Generate**:
1. **Test Updates** (TDD - tests first):
   - Update `test_extract_tool_calls_simple` to expect content
   - Update `test_extract_tool_calls_multiple_json_with_surrounding_text` to expect content
   - Add test for whitespace-only context
   - Add test for semicolon delimiter stripping

2. **Implementation**:
   - Modify `extract_tool_calls` method to extract prefix/suffix
   - Implement context combination logic
   - Implement delimiter stripping
   - Implement whitespace-only handling

3. **Validation**:
   - Run updated tests
   - Run full tool parser test suite
   - Code quality checks (ruff, mypy)

**Ordering Strategy**:
- TDD order: Update/add tests BEFORE implementation
- All test tasks can run [P] (different test functions)
- Implementation is single file, sequential
- Validation tasks [P] after implementation

**Estimated Output**: 8-10 tasks in tasks.md (small, focused bug fix)

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
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [x] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none - straightforward bug fix)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
