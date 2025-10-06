# Feature Specification: Comprehensive Unit Tests for All vLLM Tool Call Parsers

**Feature Branch**: `20251006-tool-parser-tests`
**Created**: 2025-10-06
**Status**: Draft
**Input**: User description: "I need to write unit tests for every tool call parser currently in vLLM. Some of them have unit test files already, and some do not. I need a consistent set of tests to run for every single tool parser, as well as allowing some parsers to have their own extensions to the consistent set of tests for any issues specific to the models that tool parser covers. A tool parser is written to parse the model output of one or more types of large language models, where it takes the raw model output and converts it into OpenAI-compatible tool calls to be passed back to clients. I need help both in creating the example model outputs that the parser will parse as well as the expected tool call objects that the parser should generate. Look at the existing tests and find common patterns, like testing for empty tool calls, testing for surrounding text or whitespace, testing for parallel tool calls, etc. Come up with a list of the things every parser should test. Then, write test cases for every parser using that knowledge. It's ok if the tests fail at this stage, as the parsers are not all bug-free."

## Execution Flow (main)
```
1. Parse user description from Input
   → Extract requirement for comprehensive test coverage
2. Extract key concepts from description
   → Identify: tool parsers, test patterns, OpenAI compatibility, streaming/non-streaming
3. For each unclear aspect:
   → N/A - requirements are clear
4. Fill User Scenarios & Testing section
   → Focus on developer testing workflow
5. Generate Functional Requirements
   → Each requirement covers specific test scenarios
6. Identify Key Entities
   → Tool parsers, test cases, model outputs, expected outputs
7. Run Review Checklist
   → Verify no implementation details leak through
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT tests need to cover and WHY
- ❌ Avoid HOW to implement tests (no pytest details, specific assertions)
- 👥 Written for QA stakeholders and developers understanding test requirements

---

## Clarifications

### Session 2025-10-06
- Q: When creating example model outputs for parsers that don't have existing tests, how should realistic model-specific formats be determined? → A: Search the web for official documentation or examples of the model, then combine that research with examination of the parser's implementation code to create reasonable estimations of expected model output
- Q: The spec acknowledges "tests may fail at this stage, as parsers are not all bug-free." What defines successful completion of this test suite work? → A: Tests written and documented failures recorded as known issues
- Q: For the standard test patterns (empty calls, single calls, parallel calls, etc.), how many distinct test cases should each parser have per pattern? → A: As many as needed to cover edge cases discovered during implementation
- Q: Should tests for different parsers share common test infrastructure (fixtures, helper functions, test data), or should each parser's tests be completely independent? → A: Hybrid - shared utilities but parser-specific fixtures and test data
- Q: When testing parsers in streaming mode, should each test case reset parser state independently, or can tests share parser instances? → A: Full isolation - each test creates a fresh parser instance
- Q: How should known test failures be documented? → A: Use pytest xfail marker to mark tests that are expected to fail, as these represent bugs to fix later

---

## User Scenarios & Testing

### Primary User Story
Developers working on vLLM tool call parsers need comprehensive test coverage to ensure all parsers correctly convert model outputs into OpenAI-compatible tool calls. When a parser is created or modified, developers must be able to verify it handles all common scenarios (empty outputs, parallel calls, whitespace, invalid inputs) as well as model-specific edge cases. The test suite must make it easy to identify what common behaviors all parsers should support and what behaviors are parser-specific.

### Acceptance Scenarios

1. **Given** a new tool parser is added to vLLM, **When** the developer runs the test suite, **Then** the parser must pass all standard test cases that apply to every parser (empty calls, single calls, parallel calls, whitespace handling, etc.)

2. **Given** an existing tool parser, **When** examining its test file, **Then** the developer can clearly distinguish between standard tests (common to all parsers) and parser-specific tests (edge cases for particular models)

3. **Given** a tool parser receives model output with no tool calls, **When** parsing in both streaming and non-streaming modes, **Then** the parser must return the original text content with no tool call objects

4. **Given** a tool parser receives model output containing a single valid tool call, **When** parsing in both streaming and non-streaming modes, **Then** the parser must extract the tool name and arguments correctly into OpenAI-compatible format

5. **Given** a tool parser receives model output containing multiple parallel tool calls, **When** parsing in both streaming and non-streaming modes, **Then** the parser must extract all tool calls with correct indexing and arguments

6. **Given** a tool parser receives model output with surrounding whitespace or text, **When** parsing, **Then** the parser must correctly identify and extract only the tool call portions

7. **Given** a tool parser receives malformed or invalid model output, **When** parsing, **Then** the parser must handle the error gracefully without crashing

8. **Given** a parser-specific edge case (e.g., specific JSON format, tag structure), **When** testing that parser, **Then** additional parser-specific tests must validate those unique behaviors

9. **Given** the test suite work is complete, **When** evaluating success, **Then** all test files must be created with comprehensive coverage and any failing tests must be marked with pytest xfail marker to track them as known bugs

### Edge Cases
- What happens when model output is empty or only whitespace?
- How does the parser handle tool calls with no arguments (parameterless functions)?
- How does the parser handle tool calls with complex nested data structures?
- How does the parser handle tool calls with escaped strings or special characters?
- What happens when streaming delivers partial tool calls across multiple deltas?
- How does the parser handle model outputs that mix tool calls with regular text content?
- What happens when tool call JSON is malformed or incomplete?
- How does the parser handle tool calls with various data types (strings, integers, booleans, arrays, objects, null values)?

## Requirements

### Functional Requirements

- **FR-001**: Test suite MUST cover all tool parsers currently implemented in vLLM (deepseekv31, deepseekv3, glm4_moe, granite, granite_20b_fc, hermes, hunyuan_a13b, internlm2, jamba, kimi_k2, llama, llama4_pythonic, longcat, minimax, mistral, openai, phi4mini, pythonic, qwen3coder, qwen3xml, seed_oss, step3, xlam)

- **FR-002**: Every tool parser MUST have tests verifying correct behavior when model output contains no tool calls

- **FR-003**: Every tool parser MUST have tests verifying correct extraction of a single tool call with simple arguments

- **FR-004**: Every tool parser MUST have tests verifying correct extraction of multiple parallel tool calls

- **FR-005**: Every tool parser MUST have tests verifying correct handling of tool calls with various data types (strings, integers, booleans, null values, nested objects, arrays)

- **FR-006**: Every tool parser MUST have tests verifying correct handling of empty or parameterless tool calls

- **FR-007**: Every tool parser MUST have tests verifying correct handling of model output with surrounding text or whitespace

- **FR-008**: Every tool parser MUST have tests verifying correct handling of tool calls with escaped strings or special characters

- **FR-009**: Every tool parser MUST have tests verifying behavior when receiving malformed or invalid model output

- **FR-010**: Every tool parser MUST have tests covering both streaming and non-streaming extraction modes

- **FR-011**: Streaming tests MUST verify that tool calls are correctly reconstructed from incremental deltas; each streaming test MUST use a fresh parser instance to ensure full test isolation

- **FR-012**: Streaming tests MUST verify proper handling of tool call chunks split across multiple tokens

- **FR-013**: Test suite MUST allow individual parsers to extend standard tests with parser-specific test cases; the number of test cases per standard pattern MUST be as many as needed to cover edge cases discovered during implementation, not limited to a fixed minimum

- **FR-014**: Test cases MUST include example model outputs that are representative of actual model behavior for each parser's target models; for parsers without existing tests, model output formats MUST be determined by searching for official model documentation or examples on the web and combining that research with examination of the parser's implementation code

- **FR-015**: Test cases MUST include expected OpenAI-compatible tool call objects for validation

- **FR-016**: Test outputs MUST clearly indicate which parser is being tested and which test scenario failed when tests fail

- **FR-017**: Tests MUST verify that tool call IDs are properly generated when required by the OpenAI format

- **FR-018**: Tests MUST verify that function names are extracted exactly as they appear in model output

- **FR-019**: Tests MUST verify that function arguments are correctly converted to valid JSON strings

- **FR-020**: Tests MUST verify correct handling of tool calls that contain empty dictionaries or empty arrays as arguments

- **FR-021**: Any test failures discovered during test creation MUST be marked with pytest xfail marker to document expected failures as known bugs that need fixing later

- **FR-022**: Test infrastructure MUST use a hybrid approach with shared utilities and helper functions common across all parsers, while maintaining parser-specific fixtures and test data

### Key Entities

- **Tool Parser**: A component that converts raw model output from specific LLM models into OpenAI-compatible tool call objects; each parser understands the output format of one or more model families

- **Model Output**: Raw text or token sequences generated by LLM models that may contain tool call information in model-specific formats (e.g., XML tags, JSON blocks, Python-like function calls)

- **OpenAI-Compatible Tool Call**: Standardized representation of a tool call following OpenAI's API specification, containing tool call ID, type (function), function name, and JSON-encoded arguments

- **Test Case**: A scenario defining example model output, the parser to use, expected tool call objects, and expected content; may apply to all parsers or be parser-specific

- **Streaming Delta**: Incremental text or token fragments delivered during streaming mode; parsers must reconstruct complete tool calls from these fragments

- **Standard Test Pattern**: A test scenario that applies universally to all tool parsers, ensuring consistent baseline behavior across the system

- **Parser-Specific Test**: A test scenario that addresses unique behaviors, edge cases, or output formats specific to a particular parser's target models

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---
