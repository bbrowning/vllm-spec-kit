# Feature Specification: Llama 3 JSON Tool Parser Prefix/Suffix Retention

**Feature Branch**: `001-i-need-to`
**Created**: 2025-09-30
**Status**: Draft
**Input**: User description: "I need to fix a bug in the Llama 3 json tool parser when extracting non-streaming tool calls. It uses a regular expression to extract tool calls, but is throwing away all text from before the regular expression found a match and after the match ends. Essentially, I need it to extract plain-text prefixes and suffixes the happen before / after the actual JSON tool call in the model output. There is currently a test that expects this content to be dropped (ie checks for None), but that test is wrong and we should actually retain the content."

## Execution Flow (main)
```
1. Parse user description from Input
   → Feature description provided: fix tool parser content retention bug
2. Extract key concepts from description
   → Actors: LLM model, tool call parser, API consumers
   → Actions: extract tool calls, preserve text content
   → Data: JSON tool calls, plain-text prefixes/suffixes
   → Constraints: non-streaming mode, existing test needs correction
3. No unclear aspects identified
4. Fill User Scenarios & Testing section
   → Primary scenario: model output with text around JSON tool call
5. Generate Functional Requirements
   → All requirements testable and clear
6. Identify Key Entities
   → Model output, tool call, prefix text, suffix text
7. Run Review Checklist
   → No [NEEDS CLARIFICATION] markers
   → No implementation details in spec
8. Return: SUCCESS (spec ready for planning)
```

---

## Clarifications

### Session 2025-09-30
- Q: When the model output contains multiple JSON tool calls, what should the parser do? → A: Extract all tool calls and return them as a list/array
- Q: When the parser encounters malformed JSON (invalid syntax) within the expected tool call location, what should happen? → A: Return the malformed JSON as-is in plain text (treat as non-tool-call content)
- Q: Should whitespace-only text (spaces, tabs, newlines) be preserved as prefix/suffix, or treated as empty? → A: Treat whitespace-only text as empty (set prefix/suffix to empty string)
- Q: When multiple tool calls are present with text between them, how should the interleaved text segments be associated? → A: All interleaved text collected into a single "context" field shared by all calls
- Q: How should the parser handle special characters (quotes, braces, backslashes) in prefix/suffix/context text that might interfere with JSON parsing? → A: Keep text as-is; no escaping needed (plain text separate from JSON)
- Implementation note: The "; " delimiters between tool calls are captured within the regex match and do not appear in prefix/suffix text, so no explicit stripping is needed

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
When a language model generates output containing a JSON tool call with additional text before or after it, the tool parser MUST extract both the structured tool call and preserve any surrounding plain-text content. This allows the model to provide explanatory text or reasoning alongside tool invocations.

### Acceptance Scenarios

1. **Given** a model output containing plain text followed by a JSON tool call, **When** the parser extracts the tool call, **Then** the prefix text MUST be retained and available to the caller

2. **Given** a model output containing a JSON tool call followed by plain text, **When** the parser extracts the tool call, **Then** the suffix text MUST be retained and available to the caller

3. **Given** a model output with text both before and after a JSON tool call, **When** the parser extracts the tool call, **Then** both prefix and suffix text MUST be retained

4. **Given** a model output containing only a JSON tool call with no surrounding text, **When** the parser extracts the tool call, **Then** the parser MUST handle this case without errors (empty prefix/suffix)

5. **Given** a model output containing multiple JSON tool calls separated by "; " delimiters, **When** the parser extracts the tool calls, **Then** all tool calls MUST be extracted and returned as a list/array with surrounding text preserved, and the "; " delimiters MUST be stripped

### Edge Cases
- How should empty model output (no tool calls, no text) be handled?
- What happens if the regular expression finds a match but JSON parsing fails?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Parser MUST extract all JSON tool calls from model output using the existing regular expression pattern and return them as a list/array

- **FR-002**: Parser MUST capture and retain all plain-text content from the model output (text before, after, and between tool calls)

- **FR-003**: Parser MUST collect all interleaved text segments into a single shared context field available to callers

- **FR-004**: Parser MUST make the collected context text available to callers through the return value or output structure

- **FR-005**: Parser MUST operate in non-streaming mode (streaming mode is out of scope for this fix)

- **FR-006**: Existing test that expects prefix/suffix to be None MUST be updated to verify content retention instead

- **FR-007**: Parser MUST handle cases where prefix, suffix, or both are absent without errors

- **FR-008**: Parser behavior MUST remain backward compatible for cases where callers do not use prefix/suffix data

- **FR-009**: Parser MUST treat malformed JSON (invalid syntax) as plain text content, not as a tool call; malformed JSON remains in prefix/suffix text

- **FR-010**: Parser MUST treat whitespace-only context text (spaces, tabs, newlines) as empty; only non-whitespace content is retained

- **FR-011**: When multiple tool calls exist, all text segments (before first call, between calls, after last call) MUST be collected into a single context field shared by all calls

- **FR-012**: Parser MUST preserve special characters (quotes, braces, backslashes, etc.) in context text as-is without escaping or sanitization; context text is kept separate from JSON parsing

- **FR-013**: Parser MUST NOT preserve semicolons followed by whitespace ("; ") between tool calls; this pattern is the delimiter used by the model to separate multiple tool calls and must be stripped

### Key Entities *(include if feature involves data)*

- **Model Output**: The complete text response generated by the language model, potentially containing a mix of plain text and JSON tool calls

- **Tool Call**: The structured JSON object within the model output that represents a function/tool invocation

- **Context Text**: All plain-text content from the model output (appearing before, after, and between tool calls), collected into a single shared field

- **Parser Result**: The data structure returned by the parser containing the list of extracted tool calls and the shared context text

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
- [x] All clarifications resolved (5 questions answered)

---
