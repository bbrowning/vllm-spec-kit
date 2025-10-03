# Review Findings Schema

**Date**: 2025-10-03
**Purpose**: Define the expected structure and format of review analysis outputs

## Overview

This contract defines the structure of the review analysis document that will be generated as the final deliverable for PR #19425 review. All analysis tasks must produce findings conforming to this schema.

---

## Contract 1: Test Coverage Analysis Output

**Input**: test_mistral_tool_parser.py + spec requirements FR-001 to FR-003
**Output**: TestCoverageAnalysis structure

### Expected Structure

```markdown
## Test Coverage Analysis

### Critical Path Coverage
| Scenario | Tokenizer Version | Covered | Test Names | Severity if Missing |
|----------|-------------------|---------|------------|---------------------|
| Single tool call extraction | pre-v11 |  | test_extract_tool_calls_pre_v11_tokenizer[single_tool_add] | Critical |
| Multiple tool calls | v11+ |  | test_extract_tool_calls[multiple_tool_calls] | Critical |
| Integer argument parsing | pre-v11 |  | test_extract_tool_calls_streaming_pre_v11_tokenizer[single_tool_add] | Critical (Issue #13622) |
| Streaming for Mistral Small 3.2 | v11+ |  | test_extract_tool_calls_streaming (mistral_tokenizer fixture) | Critical (Issue #20028) |
| Corrupt tool_calls prevention | All |   | Indirect via streaming tests | Critical (Issue #17585) |

### Non-Critical Path Coverage
| Scenario | Tokenizer Version | Covered | Gap Description | Recommendation |
|----------|-------------------|---------|-----------------|----------------|
| v13 tokenizer explicit tests | v13+ | L | No v13-specific fixture | Add mistral_v13_tokenizer fixture |
| Extremely nested arguments | All | L | No deep nesting tests | Add stress test for nested objects |

### Summary
- **Critical scenarios covered**: X/Y (Z%)
- **Non-critical scenarios covered**: A/B (C%)
- **Critical gaps requiring attention**: [list]
```

### Validation Rules
1. All three reported issues (#13622, #17585, #20028) MUST be in Critical Path Coverage table
2. Each uncovered critical scenario MUST generate a High severity finding
3. Missing non-critical scenarios generate Medium or Low findings based on edge case importance

---

## Contract 2: PR Comment Resolution Output

**Input**: PR comments from gh api + code changes
**Output**: ReviewerConcernResolution structure

### Expected Structure

```markdown
## PR Comment Resolution Analysis

### Resolved via Code Changes
| Commenter | Concern Summary | Resolution Commit | Verification |
|-----------|-----------------|-------------------|--------------|
| sfbemerk | Function name split across chunks | a338dc1 |  Verified - name sent in single chunk |
| DarkLight1337 | finish_reason not sent | [commit] |  Verified - empty DeltaMessage() pattern |

### Resolved via Documented Rationale
| Commenter | Concern Summary | Rationale | Acceptance |
|-----------|-----------------|-----------|------------|
| gemini-code-assist | Code complexity | Inherent to stateful parsing; state enum provides clarity |  Acceptable tradeoff |

### Unresolved Concerns
| Commenter | Concern Summary | Finding ID | Severity |
|-----------|-----------------|------------|----------|
| [none expected] | - | - | - |

### Summary
- **Total concerns raised**: N
- **Resolved via code**: X
- **Resolved via rationale**: Y
- **Unresolved**: Z (must be 0 or generate findings)
```

### Validation Rules
1. Each PR comment must appear in exactly one category
2. Unresolved concerns WITHOUT documented rationale MUST generate High severity finding
3. Code fix verification must include actual code inspection, not just commit SHA

---

## Contract 3: Streaming Logic Analysis Output

**Input**: mistral_tool_parser.py code + research findings
**Output**: StreamingLogicAnalysis structure

### Expected Structure

```markdown
## Streaming Logic Analysis

### Pre-v11 Tokenizer Path (ijson-based)

**Entry Point**: `_extract_tool_calls_streaming_pre_v11_tokenizer` (line 360)

**State Machine**:
| State | Transition Trigger | Next State | Line |
|-------|-------------------|------------|------|
| WAITING_FOR_TOOL_START | `[TOOL_CALLS]` in delta | WAITING_FOR_TOOL_KEY | 386-390 |
| WAITING_FOR_TOOL_KEY | ijson map_key event "name" | PARSING_NAME | 341-342 |
| ... | ... | ... | ... |

**Edge Cases Handled**:
-  Content before tool calls (lines 373-377)
-  Multiple tool calls in array (ijson end_array event)
-  Arguments before name in JSON (ijson handles any order)

**Edge Cases Missing**:
- L Malformed JSON recovery (no try/catch around ijson.send) - **Medium severity**
- L Extremely nested objects optimization (comment at line 418-420) - **Low severity**

**Complexity Assessment**:
- Lines of code: ~160
- State transitions: 8
- Complexity score: 7/10
- Justification: _split_delta logic is intricate but necessary for ijson event correlation

### v11+ Tokenizer Path (Custom State Machine)

**Entry Point**: `_extract_tool_calls_streaming` (line 226)

**State Machine**:
[Similar structure to pre-v11]

### Findings
- **SL-001**: Missing error recovery for malformed ijson input (Medium)
- **SL-002**: Regex allows only [a-zA-Z0-9_-] in function names; edge case if model generates others (Low)
```

### Validation Rules
1. Must analyze both pre-v11 and v11+ paths separately
2. Each identified missing edge case must have severity assignment
3. Complexity justification required if score > 6

---

## Contract 4: Subsystem Integration Analysis Output

**Input**: serving_chat.py + abstract_tool_parser.py + integration points
**Output**: SubsystemIntegrationAnalysis structure

### Expected Structure

```markdown
## Subsystem Integration Analysis

### Integration Points
| Component | File:Line | Integration Type | Coupling Strength | Verified |
|-----------|-----------|------------------|-------------------|----------|
| serving_chat.py | serving_chat.py:1000-1027 | State Inspection (prev_tool_call_arr) | Tight |  |
| abstract_tool_parser | abstract_tool_parser.py | Inheritance | Medium |  |

### HACK/Workaround Analysis

**HACK #1: prev_tool_call_arr Dummy Value**
- **Location**: mistral_tool_parser.py:268-274, 504-510
- **Purpose**: serving_chat.py inspects prev_tool_call_arr to determine finish_reason
- **Necessity**: New parser doesn't use prev_tool_call_arr for state; sets dummy value to trigger finish_reason
- **Alternatives Considered**:
  - Refactor serving_chat.py to not inspect internal state (HIGH effort, affects all parsers)
  - Use different signal mechanism (would require API change)
- **Assessment**: Acceptable workaround; clearly documented in comments; low risk

### Compatibility Risks
- **None identified**: Integration points tested; HACK is documented and low-risk

### Findings
- **SI-001**: serving_chat.py tight coupling to parser internals; future refactor opportunity (Low)
```

### Validation Rules
1. All HACKs mentioned in code comments must be analyzed
2. Tight coupling must have justification or generate finding
3. Each integration point must have verification status

---

## Contract 5: Final Review Report Structure

**Output**: Complete review document

### Expected Structure

```markdown
# PR #19425 Review: Mistral Tool Parser Streaming Refactor

**Reviewer**: [Name]
**Date**: 2025-10-03
**PR**: https://github.com/vllm-project/vllm/pull/19425
**Branch**: mistral-tool-parser-streaming-update

## Executive Summary

[2-3 paragraph summary of PR purpose, review scope, and key findings]

**Overall Assessment**: [Positive with minor recommendations | Has issues requiring attention | etc.]

**Severity Distribution**:
- Critical: X findings
- High: Y findings
- Medium: Z findings
- Low: W findings

## Detailed Analysis

### 1. Test Coverage Analysis
[Content per Contract 1]

### 2. PR Comment Resolution
[Content per Contract 2]

### 3. Streaming Logic Analysis
[Content per Contract 3]

### 4. Subsystem Integration Analysis
[Content per Contract 4]

## All Findings (Sorted by Severity)

### Critical Findings
[None expected for this PR based on research]

### High Findings
[List with Finding IDs, titles, recommendations]

### Medium Findings
[List with Finding IDs, titles, recommendations]

### Low Findings
[List with Finding IDs, titles, recommendations]

## Recommendations

1. [Recommendation 1]
2. [Recommendation 2]
...

## Conclusion

[Final paragraph with merge recommendation and next steps]

**Note**: This review does not have blocking authority. Findings are categorized to inform maintainer decisions.
```

### Validation Rules
1. Executive Summary must reference severity distribution
2. All findings must appear in both category sections AND consolidated findings section
3. Recommendations must be actionable and prioritized
4. Conclusion must explicitly state review is informational, not blocking

---

## Cross-Contract Validation

### Global Consistency Rules
1. **Finding ID Uniqueness**: All Finding IDs across all contracts must be unique
2. **Cross-References**: Any Finding referenced in multiple sections must have same ID
3. **Severity Alignment**: Critical/High findings must have detailed evidence and recommendations
4. **Completeness**: All five categories (TestCoverage, CommentResolution, StreamingLogic, SubsystemIntegration, Recommendations) must be present

### Success Criteria
-  All three reported issues have test coverage verification
-  All PR comments have resolution status
-  Both streaming paths (pre-v11, v11+) analyzed
-  All integration points documented
-  Final report follows schema structure
-  Findings categorized by severity
-  Recommendations are actionable

---

## Example Finding Format

```
**Finding ID**: TC-001
**Category**: TestCoverage
**Severity**: Medium
**Title**: No explicit v13 tokenizer test fixture
**Description**:
The test suite includes fixtures for pre-v11 (Mistral-7B-Instruct-v0.3) and v11+ (Mistral-Small-3.2)
tokenizers, but v13 tokenizer mentioned in PR comments is not explicitly tested. While v13 format is
stated to be compatible with v11+, lack of explicit testing leaves compatibility unverified.

**Location**: tests/tool_use/test_mistral_tool_parser.py:22-41 (fixtures section)

**Evidence**:
- Fixtures defined: mistral_pre_v11_tokenizer, mistral_tokenizer
- PR comment thread mentions v13 compatibility concerns
- research.md notes v13 compatibility confirmed but not tested

**Impact**:
Cannot verify v13 tokenizer compatibility without dedicated tests. If format differs unexpectedly,
streaming could fail for v13 models.

**Recommendation**:
Add `mistral_v13_tokenizer` fixture using a v13-compatible model and parametrize existing streaming
tests to include v13 cases. This adds minimal test time while confirming compatibility.

**Status**: Verified gap
```

This schema ensures comprehensive, structured review analysis that addresses all functional requirements from the specification.
