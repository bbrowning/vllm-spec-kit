<!--
Sync Impact Report:
- Version: 1.0.0 (Initial constitution)
- Principles: 5 core principles established
- Sections: Core Principles, Testing Standards, Development Workflow, Governance
- Templates status:
  ✅ plan-template.md - Constitution Check section aligned
  ✅ spec-template.md - Requirements alignment verified
  ✅ tasks-template.md - Task categorization aligned with testing principles
- Follow-up: None - all placeholders resolved
-->

# vLLM Constitution

## Core Principles

### I. Performance First
vLLM MUST maintain state-of-the-art serving throughput and memory efficiency as its primary design goal. Every feature addition and code change MUST be evaluated for its performance impact. Performance regressions are non-negotiable blockers unless explicitly justified with corresponding functionality gains that cannot be achieved otherwise.

**Rationale**: vLLM's core value proposition is "fast and easy-to-use library for LLM inference and serving." Performance is not a feature but the foundation.

### II. Hardware Diversity
vLLM MUST support multiple hardware platforms (NVIDIA GPUs, AMD CPUs/GPUs, Intel CPUs/GPUs, PowerPC CPUs, TPU, and hardware plugins). Code changes MUST NOT break existing hardware support without migration plans and community consensus.

**Rationale**: vLLM serves a diverse ecosystem. Hardware lock-in contradicts the project's accessibility mission.

### III. Comprehensive Testing
- All functional changes MUST include tests at the appropriate level (unit, integration, or end-to-end)
- Performance-sensitive code MUST include benchmark tests when adding new kernels or optimization paths
- Hardware-specific features MUST include tests for that platform using pytest markers
- Test markers MUST be used appropriately: `slow_test`, `distributed`, `cpu_test`, `core_model`, `skip_v1`, etc.
- Breaking changes MUST update all affected tests before merge

**Rationale**: High-quality inference serving demands correctness guarantees across diverse workloads and hardware configurations. Tests are the contract.

### IV. Modular Architecture
Code MUST be organized by functional responsibility:
- `/vllm/` - Source code organized by component (models, kernels, engine, executor, worker)
- `/tests/` - Tests mirroring source structure with additional categorization (basic_correctness, benchmarks, distributed, quantization, etc.)
- New features MUST fit into existing module boundaries or justify new modules with architectural reasoning

**Rationale**: vLLM is a complex system requiring clear separation of concerns for maintainability as it scales.

### V. Backward Compatibility
- Public API changes MUST maintain backward compatibility or follow deprecation policy
- Breaking changes require major version bump and migration guide
- Internal refactoring MUST NOT change public interfaces without deprecation cycle
- Model support additions/removals MUST be documented in release notes

**Rationale**: vLLM powers production systems. Unexpected breaks erode trust and adoption.

## Testing Standards

### Test Organization
- **Unit tests**: `/tests/<component>/` for component-specific logic (e.g., `/tests/kernels/`, `/tests/samplers/`)
- **Integration tests**: `/tests/entrypoints/` for API contract validation, `/tests/distributed/` for multi-GPU scenarios
- **Model tests**: `/tests/models/` for model-specific correctness verification
- **Benchmarks**: `/tests/benchmarks/` for performance regression detection

### Test Execution Requirements
- All PRs MUST pass CI test suites before merge
- Core model tests (marked with `core_model`) run on every PR
- Full model suite runs nightly
- Hardware-specific tests use appropriate markers and run in dedicated CI pipelines

### Test Quality Standards
- Tests MUST be deterministic (no flaky tests in main branch)
- Tests MUST include clear failure messages indicating what broke and why
- Tests MUST clean up resources (marked with `skip_global_cleanup` only when justified)
- Tests MUST run in reasonable time (slow tests marked with `slow_test`)

## Development Workflow

### Code Quality Gates
- **Linting**: Code MUST pass `ruff` linter with project configuration (80 char line length, specific rules enabled)
- **Type Checking**: Type hints MUST be added for new code; `mypy` checks enabled
- **Formatting**: Code MUST follow project style (see `pyproject.toml` for `ruff` and `isort` configuration)

### Documentation Requirements
- Public APIs MUST include docstrings with parameter descriptions and return types
- Complex algorithms MUST include inline comments explaining approach
- New features MUST update relevant documentation (refer to external docs at https://docs.vllm.ai/en/latest/contributing/)
- Breaking changes MUST include migration examples

### Review Process
- All changes MUST go through pull request review
- Performance-sensitive changes MUST include benchmark results
- Hardware-specific changes MUST be tested on that hardware before merge
- Breaking changes MUST receive maintainer approval

## Governance

### Amendment Process
- Constitution changes require documentation of rationale and impact analysis
- Version bumps follow semantic versioning:
  - **MAJOR**: Backward-incompatible principle changes or removals
  - **MINOR**: New principles or significant expansions
  - **PATCH**: Clarifications, wording improvements, non-semantic refinements
- Changes MUST propagate to dependent templates (plan, spec, tasks)

### Compliance
- All PRs MUST verify compliance with constitutional principles
- Violations MUST be justified in PR description with "Complexity Tracking" reasoning
- Unjustifiable violations MUST be simplified before merge
- Constitutional principles supersede ad-hoc practices

### Version Control
- This constitution serves as the authoritative source for development standards
- Template files in `.specify/templates/` derive their requirements from this document
- Conflicts between templates and constitution MUST be resolved in favor of constitution

**Version**: 1.0.0 | **Ratified**: 2025-09-30 | **Last Amended**: 2025-09-30
