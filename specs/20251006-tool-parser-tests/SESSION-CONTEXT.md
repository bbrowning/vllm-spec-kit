# Session Context: Comprehensive Tool Parser Test Suite

**Last Updated**: 2025-10-06 PM
**Branch**: `20251006-tool-parser-tests`
**Project Status**: Iteration 3 In Progress (2 tasks completed)

---

## 🎯 Project Overview

**Goal**: Create comprehensive unit tests for vLLM tool call parsers (15/24 parsers completed)

**What's a tool parser?** A component that converts raw LLM model output into OpenAI-compatible tool call objects. Each parser handles model-specific output formats (XML, JSON, Python-like syntax, etc.)

**Current Progress**:
- ✅ 15/24 parsers have comprehensive unit tests in `tests/entrypoints/openai/tool_parsers/`
- ⚠️ 9/24 parsers have old-style unit tests in `tests/tool_use/` (excluded from current scope)
- ✅ 16,152 lines of test code written for comprehensive tests
- ✅ ~607 test cases created across 15 parsers
- 🔄 433 passing, 58 failing, 93 xfailed, 0 xpassed ✅
- 🎯 Target: 0 failures (all tests passing or properly marked xfail)
- 📈 Recent: Fixed qwen3xml xpassed + step3 streaming test (2025-10-06)

---

## 📁 Critical Files to Read First

### Start Here (in order):

1. **specs/20251006-tool-parser-tests/spec.md**
   - Original feature specification
   - Functional requirements
   - Test architecture overview
   - Read first to understand WHAT we're building

2. **specs/20251006-tool-parser-tests/test-suite-reconciliation.md**
   - **CRITICAL**: Explains test duplication issue discovered
   - Documents THREE test categories: new unit tests, old duplicate unit tests, true integration tests
   - Must read to avoid confusion about duplicate test files
   - **Updated 2025-10-06**: 9 parser tests in `tests/tool_use/` are DUPLICATES that should be removed

3. **specs/20251006-tool-parser-tests/tasks-iteration-2.md**
   - What was accomplished in iteration 2
   - Files modified and changes made
   - Progress metrics: 401→432 passed, 71→59 failed
   - Shows completed work

4. **specs/20251006-tool-parser-tests/tasks-iteration-3.md**
   - **START YOUR WORK HERE** for next session
   - Complete roadmap for achieving zero failures
   - 16 task groups organized by priority
   - Detailed investigation steps for each parser

5. **specs/20251006-tool-parser-tests/known-failures.md**
   - Parser-by-parser status after iteration 1
   - Known issues and failure patterns
   - Baseline for measuring progress

---

## 🏗️ Test Architecture

### Test Suite Organization (UPDATED 2025-10-06)

**IMPORTANT**: Tool parser tests exist in TWO locations with different scopes

#### Category 1: New Comprehensive Unit Tests (15 parsers) ✅
**Location**: `tests/entrypoints/openai/tool_parsers/`
**Purpose**: Fast, comprehensive parser logic testing
**Status**: PRIMARY test suite for current work
**Characteristics**:
- Mocked tokenizers (no model downloads)
- Runs in < 2 minutes
- 10 standard tests per parser
- Both streaming and non-streaming modes
- 15 parsers covered

**Parsers covered**: deepseekv3, granite, granite_20b_fc, hermes, hunyuan_a13b, internlm2, llama, llama3_json, llama4_pythonic, longcat, mistral, phi4mini, pythonic, qwen3xml, step3

**Pattern**: Each parser has `test_<parser>_tool_parser.py` with:
- Standard tests: no_tool_calls, single_tool_call, parallel_tool_calls, various_data_types, empty_arguments, surrounding_text, escaped_strings, malformed_input, streaming_reconstruction, streaming_boundary_splits
- Parser-specific extension tests

#### Category 2: Old-Style Unit Tests (9 parsers) ⚠️
**Location**: `tests/tool_use/test_*_tool_parser.py` (9 files)
**Purpose**: Legacy unit tests for remaining parsers
**Status**: **NOT being migrated** - will remain in current location
**Characteristics**:
- Import parser classes directly
- Use `get_tokenizer()` for mocked tokenizers
- No server needed
- Similar approach to comprehensive tests but less standardized

**Parsers**: deepseekv31, glm4_moe, jamba, kimi_k2, minimax, openai, qwen3coder, seed_oss, xlam

**Decision**: These tests will remain as-is for now. Future work may consolidate all unit tests into a single location.

#### Category 3: True Integration Tests (6 files) ✅
**Location**: `tests/tool_use/test_chat_*.py`, `test_tool_*.py` (6 files)
**Purpose**: End-to-end testing with real vLLM server
**Status**: KEEP - different purpose than unit tests
**Characteristics**:
- Import `openai` client library
- Use `AsyncOpenAI` to connect to running vLLM server
- Require actual model loaded in server
- Test full request/response API cycle
- Slower, heavyweight, real E2E behavior

**Files**: test_chat_completions.py, test_parallel_tool_calls.py, test_tool_calls.py, test_chat_completion_request_validations.py, test_tool_choice_required.py, mistral/test_mistral_tool_calls.py

### Key Differentiator
- **Unit tests** (Category 1 & 2): Import parser classes, use `get_tokenizer()`, no server
- **Integration tests** (Category 3): Import `openai` client, require running server

### Current Scope
This project focuses ONLY on the 15 parsers in Category 1. The 9 parsers in Category 2 are excluded from current work.

---

## 📊 Current Status (Iteration 3 In Progress)

### Test Metrics (2025-10-06 PM)
```
433 passed (+1 from iteration 2)
58 failed (-1 from iteration 2)
8 skipped
93 xfailed (+1 from iteration 2)
0 xpassed ✅ (was 1, now fixed!)
15 errors (kimi_k2 blobfile dependency)
```

### Progress from Iteration 2
- ✅ Fixed qwen3xml test_no_tool_calls xpassed (removed xfail marker)
- ✅ Fixed step3 test_streaming_reconstruction (added xfail marker for known bug)
- ✅ All xfail markers now accurate (0 xpassed)
- 🔄 Next: kimi_k2 errors, then triage remaining 58 failures

### Files Modified in Iteration 3
1. test_qwen3xml_tool_parser.py - removed xfail from test_no_tool_calls[True]
2. test_step3_tool_parser.py - added xfail to test_streaming_reconstruction

### Files Modified in Iteration 2
1. test_granite_tool_parser.py - removed 15 xfail markers
2. test_step3_tool_parser.py - removed 9 xfail markers
3. test_internlm2_tool_parser.py - removed 3 xfail markers
4. test_glm4_moe_tool_parser.py - removed 2 xfail markers
5. test_qwen3coder_tool_parser.py - removed 2 xfail markers
6. test_kimi_k2_tool_parser.py - added trust_remote_code=True
7. test_qwen3xml_tool_parser.py - fixed XML format + added streaming xfail markers
8. tasks-iteration-2.md - documented iteration 2

---

## 🎯 Next Steps (Iteration 3)

### Priority 0: Quick Wins
1. ✅ **P0-T001**: Fix qwen3xml xpassed test - COMPLETED

### Priority 1-3: Triage Remaining Failures
- 58 failures across 12 parsers (was 59, fixed 1 in step3)
- Systematic investigation: run tests, identify issues, fix or xfail
- See tasks-iteration-3.md for complete breakdown

### Goal
```
~443-480 passed
0 failed
23 skipped
120-157 xfailed
0 xpassed
15/24 parsers with comprehensive tests fully validated
```

---

## 🔧 How to Work on This Project

### Running Tests

```bash
# Run all comprehensive unit tests
pytest tests/entrypoints/openai/tool_parsers/ -v

# Run specific parser
pytest tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py -v

# Run with detailed output and stop on first failure
pytest tests/entrypoints/openai/tool_parsers/ -xvs

# Run just one test
pytest tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py::test_no_tool_calls -xvs

# Get summary of results
pytest tests/entrypoints/openai/tool_parsers/ -v --tb=no -q
```

### Common Tasks

**Investigating a Failure**:
1. Run the failing test with `-xvs` flags
2. Read the error message to understand what's wrong
3. Read the parser implementation to understand expected behavior
4. Determine if it's:
   - Test format issue → Fix test examples
   - Parser bug → Mark as xfail with reason
   - Streaming bug → Mark streaming as xfail
   - Dependency issue → Add skipif decorator

**Removing an xfail Marker**:
```python
# Before
@pytest.mark.parametrize("streaming", [
    pytest.param(True, marks=pytest.mark.xfail(reason="Parser streaming issues")),
    False
])

# After (if test now passes)
@pytest.mark.parametrize("streaming", [True, False])
```

**Adding an xfail Marker**:
```python
@pytest.mark.parametrize("streaming", [
    pytest.param(True, marks=pytest.mark.xfail(reason="Parser streaming not implemented")),
    False
])
```

---

## 🧩 Key Concepts

### Tool Call Format
OpenAI-compatible tool calls have this structure:
```python
ToolCall(
    id="call_12345",           # Unique identifier
    type="function",           # Always "function"
    function=FunctionCall(
        name="get_weather",    # Function name
        arguments='{"city": "Tokyo"}'  # JSON string
    )
)
```

### Parser Types
- **XML-based**: qwen3xml, seed_oss (use XML tags like `<tool_call>`)
- **JSON-based**: llama3_json, mistral (use JSON blocks)
- **Token-based**: kimi_k2, jamba (use special tokens like `<|tool_call_begin|>`)
- **Python-like**: pythonic, llama4_pythonic (use Python function syntax)
- **Custom**: Each parser has unique quirks

### Common Patterns

**Streaming Issues**: Many parsers have incomplete streaming implementations
- Solution: Mark streaming tests as xfail, document limitation

**Test Format Issues**: Test examples might not match parser expectations
- Solution: Read parser code, fix test constants

**Dependencies**: Some parsers need special libraries
- Solution: Add skipif decorator when dependency missing

---

## 📚 Parser List (24 total)

### With New Comprehensive Unit Tests (15 parsers) ✅
1. deepseekv3 ✅
2. granite ✅
3. granite_20b_fc ✅
4. hermes ✅
5. hunyuan_a13b ✅
6. internlm2 ✅
7. llama ✅
8. llama3_json ✅
9. llama4_pythonic ✅
10. longcat ✅
11. mistral ✅
12. phi4mini ✅
13. pythonic ✅
14. qwen3xml ✅
15. step3 ✅

### With Old-Style Unit Tests (9 parsers) ⚠️
16. deepseekv31 ⚠️ (in `tests/tool_use/`)
17. glm4_moe ⚠️ (in `tests/tool_use/`)
18. jamba ⚠️ (in `tests/tool_use/`)
19. kimi_k2 ⚠️ (in `tests/tool_use/`)
20. minimax ⚠️ (in `tests/tool_use/`)
21. openai ⚠️ (in `tests/tool_use/`)
22. qwen3coder ⚠️ (in `tests/tool_use/`)
23. seed_oss ⚠️ (in `tests/tool_use/`)
24. xlam ⚠️ (in `tests/tool_use/`)

---

## 🚨 Known Issues (Comprehensive Test Suite Only)

### qwen3xml
- ✅ test_no_tool_calls[True] xpassed - FIXED (removed xfail marker)

### Various parsers (58 total failures)
- See tasks-iteration-3.md for complete breakdown
- Failures span 12 parsers in the comprehensive test suite
- Needs systematic triage and either fixes or xfail markers

---

## 💡 Tips for New Sessions

1. **Read test-suite-reconciliation.md** to understand test organization (15 new + 9 old-style)
2. **Start with tasks-iteration-3.md** - it has your complete roadmap
3. **Run tests early** to see current state: `pytest tests/entrypoints/openai/tool_parsers/ -v --tb=no -q`
4. **Focus on the 15 parsers** in `tests/entrypoints/openai/tool_parsers/` only
5. **When investigating a parser failure**:
   - Read the parser implementation in `vllm/entrypoints/openai/tool_parsers/`
   - Compare with working parsers to understand patterns
   - Check if it's a real bug or test issue
6. **Document as you go** - update tasks-iteration-3.md with findings
7. **Use xfail liberally** - it's OK to mark tests as expected failures for known bugs
8. **Remember**: 9 parsers with old-style tests are excluded from current scope

---

## 📖 Additional Documentation

### In specs/20251006-tool-parser-tests/:
- `spec.md` - Feature specification (WHAT we're building)
- `plan.md` - Implementation plan (HOW we'll build it)
- `research.md` - Parser format research and examples
- `data-model.md` - Test data structures and patterns
- `tasks.md` - Original task breakdown (iteration 1)
- `tasks-iteration-2.md` - Iteration 2 work and results
- `tasks-iteration-3.md` - Iteration 3 roadmap (YOUR WORK)
- `known-failures.md` - Parser status and known issues
- `test-suite-reconciliation.md` - CRITICAL: explains two test suites
- `contracts/test_interface.md` - Test patterns and requirements

### Test Files:
- `tests/entrypoints/openai/tool_parsers/` - Comprehensive unit tests (this project)
- `tests/tool_use/` - Integration tests (pre-existing)

---

## 🎬 Quick Start for Next Session

```bash
# 1. Read this file (you're doing it!)

# 2. Read the reconciliation document
cat specs/20251006-tool-parser-tests/test-suite-reconciliation.md

# 3. Read iteration 3 tasks
cat specs/20251006-tool-parser-tests/tasks-iteration-3.md

# 4. Run tests to see current state
pytest tests/entrypoints/openai/tool_parsers/ -v --tb=no -q

# 5. Start with P0-T001 (easiest win)
# Edit: tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py
# Find: test_no_tool_calls[True]
# Remove: xfail marker from True parameter
# Run: pytest tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py::test_no_tool_calls -xvs
# Verify: Test passes

# 6. Move to P0-T002 and P0-T003
# See tasks-iteration-3.md for details
```

---

## ✅ Definition of Done

**Iteration 3 Complete When**:
- ✅ 0 failures in comprehensive test suite
- ✅ 0 xpassed in comprehensive test suite
- ✅ All 15 parsers in comprehensive test suite fully validated
- ✅ All xfail markers have clear reason strings
- ✅ All skipped tests have clear reason strings
- ✅ Test suite runs in < 120 seconds
- ✅ known-failures.md updated with final results
- ✅ Ready for CI/CD integration

**Full Project Complete When**:
- ✅ Iteration 3 complete
- ✅ All documentation updated
- ✅ Pull request created with summary of work
- ✅ Tests passing in CI

---

## 🤝 Questions?

If you're a new Claude session and something is unclear:

1. Check if it's explained in test-suite-reconciliation.md (especially test suite overlap)
2. Read the parser implementation in `vllm/entrypoints/openai/tool_parsers/`
3. Look at similar parsers' tests for patterns
4. Run the tests to see what's actually happening
5. Document your findings in tasks-iteration-3.md

Good luck! The hard work is done - now it's just systematic triaging and documentation.
