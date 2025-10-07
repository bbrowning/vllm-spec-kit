# Comprehensive Tool Parser Test Suite - Documentation Index

**Project**: Comprehensive unit tests for vLLM tool parsers
**Branch**: `20251006-tool-parser-tests`

This directory contains all documentation for the comprehensive unit test suite for vLLM's tool call parsers. For current project status and remaining work, see **tasks.md**.

---

## 📚 Documentation Files

### Foundation Documents

**spec.md** - Feature Specification
- What we're building and why
- Functional requirements (FR-001 through FR-026)
- User scenarios and acceptance criteria
- Test architecture overview
- Read first to understand project goals

**plan.md** - Implementation Plan
- How we built the test suite
- Architecture and design decisions
- Implementation approach and phases
- Testing strategy
- Constitutional compliance verification

**tasks.md** - Current Task Status
- **⭐ CHECK HERE FOR PROJECT STATUS ⭐**
- Current progress and completion metrics
- Remaining work and task breakdown
- Success criteria
- Historical task iterations

**research.md** - Parser Format Research
- Research on each parser's expected format
- Model output examples
- Parser-specific quirks and edge cases
- Reference for creating test constants

**data-model.md** - Data Structures
- Test data model and patterns
- ToolCall and FunctionCall structures
- Standard test patterns
- Helper utilities

### Analysis Documents

**test-suite-reconciliation.md** ⚠️ IMPORTANT
- Explains TWO test suite locations
- Pre-existing tests: `tests/tool_use/` (integration tests)
- New tests: `tests/entrypoints/openai/tool_parsers/` (comprehensive unit tests)
- Overlap analysis and scope clarification
- **MUST READ** to understand full picture

**tool-call-test-refactor.md**
- Future refactoring opportunity
- Proposed test contract pattern
- Potential to reduce ~4,155 lines of duplicated code
- Implementation plan for DRY improvements

### Contract Documents

**contracts/test_interface.md**
- Standard test patterns (10 required tests per parser)
- Test function signatures
- Expected behaviors
- Shared utilities documentation

**quickstart.md**
- How to run tests
- Investigation workflow for triaging failures
- xfail marker usage patterns
- Example parser test file structure

---

## 📂 Test File Locations

### Comprehensive Unit Tests (This Project)
```
tests/entrypoints/openai/tool_parsers/
├── utils.py                           # Shared test utilities
├── test_deepseekv3_tool_parser.py    # Comprehensive parser tests
├── test_granite_tool_parser.py
├── test_hermes_tool_parser.py
├── test_internlm2_tool_parser.py
├── test_llama3_json_tool_parser.py   # (llama parser tests)
├── test_mistral_tool_parser.py
├── test_qwen3xml_tool_parser.py
└── ... (14 parser test files total)
```

**Characteristics**:
- Fast execution (< 1 minute for full suite)
- No model downloads required (mocked tokenizers)
- Isolated unit tests with fresh parser instances
- 10 standard tests + parser-specific extensions per parser
- Both streaming and non-streaming modes tested

### Integration Tests (Pre-existing - Separate Scope)
```
tests/tool_use/
├── utils.py                           # Server configuration utilities
├── test_deepseekv31_tool_parser.py   # Integration tests for select parsers
├── test_chat_completions.py          # General integration tests
└── mistral/
    └── test_mistral_tool_calls.py
```

**Characteristics**:
- Slower execution (requires vLLM server)
- End-to-end validation with real models
- Some overlap with comprehensive unit tests (9 parsers)
- **Both test suites are valuable** - see test-suite-reconciliation.md

---

## 🔧 Common Commands

### Run Tests
```bash
# All comprehensive unit tests
pytest tests/entrypoints/openai/tool_parsers/ -v

# Specific parser
pytest tests/entrypoints/openai/tool_parsers/test_hermes_tool_parser.py -v

# Stop on first failure with details
pytest tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py -xvs

# Summary only (no tracebacks)
pytest tests/entrypoints/openai/tool_parsers/ -v --tb=no -q

# Run specific test
pytest tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py::test_single_tool_call_simple_args -xvs

# All integration tests (separate scope)
pytest tests/tool_use/ -v
```

### Useful pytest Flags
- `-v` : Verbose (show each test name)
- `-x` : Stop on first failure
- `-s` : Show print statements
- `--tb=no` : Don't show tracebacks
- `-q` : Quiet (less output)
- `-k <pattern>` : Run tests matching pattern
- `--tb=short` : Shorter tracebacks

---

## 💡 Key Insights & Patterns

### Test Suite Architecture
- **TWO independent test suites** with different purposes (see test-suite-reconciliation.md)
- **Unit tests** (this project): Fast, comprehensive, isolated parser logic validation
- **Integration tests** (pre-existing): Slower, end-to-end, real model validation with vLLM server
- **Both are valuable** and serve different purposes - no duplication issue

### Common Test Patterns

**Standard Test Contract** (10 tests per parser):
1. No tool calls (plain text)
2. Single tool call with simple arguments
3. Parallel tool calls
4. Various data types (string, int, float, bool, null, array, object)
5. Empty/parameterless tool calls
6. Surrounding text (tool calls mixed with content)
7. Escaped strings and special characters
8. Malformed input handling
9. Streaming reconstruction (streaming == non-streaming)
10. Streaming boundary splits (mid-token splits)

**Parser-Specific Extensions**:
- Additional tests for unique parser features
- Format-specific edge cases
- Parser quirks and limitations

### Test Failure Investigation Process

1. **Run the failing test individually**:
   ```bash
   pytest path/to/test.py::test_name -xvs
   ```

2. **Classify the failure**:
   - **Test format issue**: Test example doesn't match parser's expected format → Fix test
   - **Parser bug**: Parser has a bug or limitation → Mark as xfail
   - **Streaming bug**: Streaming mode differs from non-streaming → Mark streaming as xfail
   - **Dependency issue**: Missing library or requirement → Skip test with skipif

3. **Apply the fix**:
   - Fix test constants if format issue
   - Add `@pytest.mark.xfail(reason="...")` for known bugs
   - Add `@pytest.mark.skip(reason="...")` for missing dependencies
   - Document findings in xfail/skip reasons

4. **Verify the fix**:
   ```bash
   pytest path/to/test.py -v --tb=no -q
   ```

### Success Patterns from Completed Work

1. **Systematic triaging** - Handle one parser at a time, one failure at a time
2. **Test format first** - Most failures are test format issues, not parser bugs
3. **Document with xfail** - Mark known bugs clearly for future fixes
4. **Fresh parser instances** - Always use fresh parser per test (streaming state issues)
5. **xfail marker accuracy** - Keep markers up-to-date (avoid xpassed tests)

### Common Failure Patterns

**Streaming Bugs** (most common):
- Many parsers have incomplete or inconsistent streaming implementations
- Streaming returns different content than non-streaming
- Streaming fails on boundary splits
- **Solution**: Mark streaming tests as xfail with clear reasons

**Test Format Issues**:
- Test examples don't match parser's expected format
- Missing start/end markers
- Wrong JSON field names ("parameters" vs "arguments")
- **Solution**: Read parser source code, fix test constants

**Error Handling**:
- Some parsers raise exceptions on malformed input instead of gracefully handling
- **Solution**: Mark as xfail or add try-except to test

**Dependencies**:
- Some parsers require special libraries (e.g., blobfile for kimi_k2)
- **Solution**: Use `@pytest.mark.skipif` or `pytest.importorskip`

---

## 📖 Recommended Reading Order

### For Understanding Project Context
1. **spec.md** - Understand what we're building and why
2. **test-suite-reconciliation.md** - Understand the two test suites (critical!)
3. **plan.md** - Understand how we built it
4. **tasks.md** - Check current status and remaining work

### For Working on Tests
1. **contracts/test_interface.md** - Standard test patterns
2. **quickstart.md** - How to run and debug tests
3. **research.md** - Parser format examples (as reference)
4. **data-model.md** - Data structures (as reference)

### For Future Improvements
1. **tool-call-test-refactor.md** - Test refactoring opportunity
2. **tasks.md** - Optional future work section

---

## 🎯 Project Goals

### Primary Goals (Achieved ✅)
- Comprehensive unit test coverage for all tool parsers in scope
- 10 standard tests per parser following test contract
- Both streaming and non-streaming mode validation
- Fast test execution (< 2 minutes target)
- No model downloads required (mocked tokenizers)
- Full test isolation (fresh parser per test)

### Secondary Goals
- Document known parser bugs with xfail markers
- Provide clear test examples for each parser format
- Establish patterns for future parser test additions
- Enable CI/CD integration with clean test state

### Non-Goals
- Fixing parser bugs (document with xfail instead)
- Creating integration tests (those already exist in tests/tool_use/)
- Replacing existing tests (both test suites are valuable)
- Testing all 24 parsers (some have adequate old-style tests)

---

## 🔗 Related Documentation

**vLLM Tool Parsers Source**:
- `vllm/entrypoints/openai/tool_parsers/` - Parser implementations
- Each parser has its own file (e.g., `hermes_tool_parser.py`)

**vLLM Documentation**:
- Main docs: https://docs.vllm.ai/
- Contributing guide: https://docs.vllm.ai/en/latest/contributing/

**Constitution**:
- `.specify/memory/constitution.md` - vLLM development principles
- All 5 constitutional principles verified as satisfied for this project

---

**For current project status, see tasks.md**
**Last Documentation Update**: 2025-10-07
