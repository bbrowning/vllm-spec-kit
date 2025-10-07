# Comprehensive Tool Parser Test Suite - Documentation Index

**Project**: Comprehensive unit tests for all 23 tool parsers in vLLM
**Branch**: `20251006-tool-parser-tests`
**Status**: Iteration 2 Complete → Iteration 3 In Progress

---

## 🚀 Quick Start

**New to this project?** Start here in order:

1. **SESSION-CONTEXT.md** ⭐ **START HERE** ⭐
   - Complete project overview
   - Current status and metrics
   - How to run tests and continue work
   - Quick start guide for new sessions

2. **test-suite-reconciliation.md** ⚠️ **CRITICAL** ⚠️
   - Explains we have TWO test suites (unit + integration)
   - Must read to avoid confusion about duplicate files
   - Created during reconciliation analysis

3. **tasks-iteration-3.md** 🎯 **YOUR WORK HERE**
   - Complete roadmap for next work
   - 16 task groups to achieve zero failures
   - Start with Priority 0 tasks

---

## 📚 Documentation Files

### Foundation Documents

**spec.md** - Feature Specification
- What we're building and why
- Functional requirements (FR-001 through FR-022)
- User scenarios and acceptance criteria
- Test architecture overview
- Read first to understand project goals

**plan.md** - Implementation Plan
- How we'll build the test suite
- Architecture and design decisions
- Implementation approach
- Testing strategy

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

### Progress Documents

**tasks.md** - Original Task Breakdown (Iteration 1)
- Initial task list
- Parser categorization
- Original 23-parser breakdown
- Historical reference

**tasks-iteration-2.md** - Iteration 2 Results
- What was accomplished
- Files modified (8 files)
- Progress metrics: 401→432 passed, 71→59 failed
- Key learnings and discoveries
- Status: ✅ COMPLETE

**tasks-iteration-3.md** - Iteration 3 Roadmap
- 16 task groups to complete
- Priority 0: 3 quick wins
- Priority 1-3: Triage 59 failures
- Detailed investigation steps
- Status: 🔄 IN PROGRESS

**known-failures.md** - Known Issues Tracking
- Parser-by-parser status
- Known bugs and limitations
- Failure patterns
- Baseline for measuring progress

### Analysis Documents

**test-suite-reconciliation.md** ⚠️ IMPORTANT ⚠️
- Discovered during reconciliation phase
- Explains TWO test suite locations
- Pre-existing tests: `tests/tool_use/` (integration)
- New tests: `tests/entrypoints/openai/tool_parsers/` (unit)
- Overlap analysis: 8 parsers in both locations
- **MUST READ** to understand full picture

**SESSION-CONTEXT.md** ⭐ QUICKSTART ⭐
- Comprehensive project overview
- How to continue work in new sessions
- Current status and next steps
- Tips and common patterns
- Quick reference guide

### Contract Documents

**contracts/test_interface.md**
- Standard test patterns
- Test function signatures
- Expected behaviors
- Shared utilities documentation

---

## 📂 Test Files Locations

### Unit Tests (This Project)
```
tests/entrypoints/openai/tool_parsers/
├── utils.py                           # Shared utilities
├── test_deepseekv3_tool_parser.py    # And 22 more parser test files...
└── test_xlam_tool_parser.py
```

**Coverage**: 23/24 parsers (OpenAI parser pending - P0-T003)
**Tests**: ~607 test cases, 16,152 lines of code
**Run time**: < 2 minutes (fast, no model downloads)

### Integration Tests (Pre-existing)
```
tests/tool_use/
├── utils.py                           # Server configs
├── test_deepseekv31_tool_parser.py   # And 9 more parser test files...
├── test_chat_completions.py          # General integration tests
└── mistral/                           # Mistral subdirectory
    └── test_mistral_tool_calls.py
```

**Coverage**: 10 parsers
**Tests**: Varies by parser
**Run time**: Slower (requires real models)

**See**: `test-suite-reconciliation.md` for complete analysis

---

## 📊 Current Metrics

### Test Results (After Iteration 2)
```
432 passed   ✅ +31 from iteration 1
59 failed    🔄 -12 from iteration 1
8 skipped    ⏭️
92 xfailed   📋 +7 from iteration 1 (properly documented)
1 xpassed    ⚠️ -26 from iteration 1 (96% reduction!)
15 errors    ❌ kimi_k2 blobfile dependency
```

### Target (End of Iteration 3)
```
~443-480 passed
0 failed
23 skipped
120-157 xfailed
0 xpassed
0 errors
24/24 parsers covered
```

---

## 🎯 Iteration Breakdown

### Iteration 1 (Complete) ✅
- Created comprehensive tests for all 23 parsers
- 16,152 lines of test code
- Result: 420 passed, 106 failed, 55 errors
- Established patterns and utilities

### Iteration 2 (Complete) ✅
- Removed 27 unnecessary xfail markers
- Fixed qwen3xml format issues (16 failures → 8 passed + 11 xfailed)
- Added trust_remote_code for kimi_k2
- Result: 432 passed, 59 failed, 92 xfailed, 1 xpassed, 15 errors
- Files modified: 8

### Iteration 3 (In Progress) 🔄
- Fix 1 xpassed test
- Handle 15 kimi_k2 errors
- Create OpenAI parser tests (NEW)
- Triage 59 failures across 12 parsers
- Target: 0 failures, 0 errors, 0 xpassed
- See: `tasks-iteration-3.md`

---

## 🧩 Parser Coverage

### All Parsers (24 total)

**With Comprehensive Unit Tests** (23/24):
1. deepseekv3 ✅
2. deepseekv31 ✅ 🔄
3. glm4_moe ✅ 🔄
4. granite ✅
5. granite_20b_fc ✅
6. hermes ✅
7. hunyuan_a13b ✅
8. internlm2 ✅
9. jamba ✅ 🔄
10. kimi_k2 ✅ 🔄 ❌ (blobfile error)
11. llama ✅
12. llama3_json ✅
13. llama4_pythonic ✅
14. longcat ✅
15. minimax ✅ 🔄
16. mistral ✅ 🔄
17. phi4mini ✅
18. pythonic ✅
19. qwen3coder ✅ 🔄
20. qwen3xml ✅ ⚠️ (1 xpassed)
21. seed_oss ✅ 🔄 ❌ (32 failures)
22. step3 ✅
23. xlam ✅ 🔄

**Missing Comprehensive Unit Tests** (1/24):
24. **openai** ⚠️ (has integration tests only) → P0-T003

**Legend**:
- ✅ = Has comprehensive unit tests
- 🔄 = Also has integration tests in `tests/tool_use/`
- ❌ = Has errors or major failures
- ⚠️ = Has xpassed tests

---

## 🔧 Common Commands

### Run Tests
```bash
# All unit tests
pytest tests/entrypoints/openai/tool_parsers/ -v

# Specific parser
pytest tests/entrypoints/openai/tool_parsers/test_qwen3xml_tool_parser.py -v

# Stop on first failure with details
pytest tests/entrypoints/openai/tool_parsers/ -xvs

# Summary only
pytest tests/entrypoints/openai/tool_parsers/ -v --tb=no -q

# All integration tests
pytest tests/tool_use/ -v
```

### Useful Flags
- `-v` : Verbose (show each test name)
- `-x` : Stop on first failure
- `-s` : Show print statements
- `--tb=no` : Don't show tracebacks
- `-q` : Quiet (less output)
- `-k <pattern>` : Run tests matching pattern

---

## 🚨 Known Issues

### High Priority
1. **kimi_k2**: 15 errors due to blobfile dependency → P0-T002
2. **qwen3xml**: 1 xpassed test → P0-T001
3. **openai**: Missing comprehensive unit tests → P0-T003
4. **seed_oss**: 32 failures, parser not extracting → P1-T001

### Medium Priority
- **mistral**: 14 failures → P1-T002
- **granite**: 12 failures → P1-T003
- **llama/minimax**: 20 failures → P1-T004

See `tasks-iteration-3.md` for complete breakdown

---

## 📖 Reading Order for New Sessions

### Essential Reading (Do This First)
1. SESSION-CONTEXT.md - Complete overview
2. test-suite-reconciliation.md - Understand two test suites
3. tasks-iteration-3.md - Your work roadmap

### Background Reading (If Needed)
4. spec.md - Original requirements
5. known-failures.md - Parser status
6. tasks-iteration-2.md - Recent progress

### Reference Reading (As Needed)
7. plan.md - Implementation approach
8. research.md - Parser formats
9. data-model.md - Data structures
10. contracts/test_interface.md - Test patterns

---

## 💡 Key Insights

### Test Suite Architecture
- **TWO test suites** with different purposes (see test-suite-reconciliation.md)
- Unit tests: Fast, comprehensive, isolated parser logic
- Integration tests: Slower, end-to-end, real model validation
- **Both are valuable** and should be maintained

### Common Failure Patterns
1. **Streaming bugs** - Many parsers have incomplete streaming
   - Solution: Mark streaming tests as xfail
2. **Test format issues** - Test examples don't match parser expectations
   - Solution: Read parser code, fix test constants
3. **Dependencies** - Some parsers need special libraries
   - Solution: Add skipif decorators

### Success Patterns
1. Start with easy wins (remove unnecessary xfails)
2. Fix test formats before assuming parser bugs
3. Mark known bugs with xfail for later fixing
4. Test one parser at a time systematically
5. Document findings as you go

---

## ✅ Definition of Done

**Iteration 3 Complete When**:
- [ ] 0 failures
- [ ] 0 errors
- [ ] 0 xpassed
- [ ] 24/24 parsers have comprehensive unit tests
- [ ] All xfail markers have clear reasons
- [ ] known-failures.md updated
- [ ] Ready for CI/CD

**Full Project Complete When**:
- [ ] Iteration 3 complete
- [ ] Documentation updated
- [ ] Pull request created
- [ ] Tests passing in CI

---

## 🎬 Next Steps

**For your next session**:

1. Read SESSION-CONTEXT.md (5 min)
2. Read test-suite-reconciliation.md (5 min)
3. Run tests to see current state (1 min)
4. Start with P0-T001 in tasks-iteration-3.md (5 min)
5. Continue through Priority 0 tasks
6. Move to Priority 1-3 systematically

**You've got this!** Most of the hard work is done. Now it's systematic triaging.

---

**Last Updated**: 2025-10-06
**Questions?** Check SESSION-CONTEXT.md or run the tests!
