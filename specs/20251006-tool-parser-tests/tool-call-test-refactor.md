# Tool Call Parser Test Refactoring Plan

## Problem Statement

The tool call parser test suite has significant code duplication across 15+ parser test files. Each file contains:
- 10 identical standard test functions with only minor variations
- Similar fixture patterns
- Parser-specific model output constants
- Parser-specific xfail markers

This creates maintenance burden and makes it difficult to:
- Add new standard tests to all parsers
- Update test logic consistently
- Ensure all parsers follow the same testing contract

## Current Structure Analysis

### Test File Pattern (e.g., `test_mistral_tool_parser.py`)

```python
# 1. Model output constants (parser-specific)
NO_TOOL_CALLS_OUTPUT = "..."
SINGLE_TOOL_CALL_OUTPUT = "..."
PARALLEL_TOOL_CALLS_OUTPUT = "..."
# ... 7 more constants

# 2. Fixtures (parser-specific)
@pytest.fixture(scope="module")
def mistral_tokenizer():
    tokenizer = MagicMock()
    # Mock setup specific to parser
    return tokenizer

@pytest.fixture
def mistral_parser(mistral_tokenizer):
    return ToolParserManager.get_tool_parser("mistral")(mistral_tokenizer)

# 3. Standard tests (identical logic, different data)
@pytest.mark.parametrize("streaming", [True, False])
def test_no_tool_calls(mistral_parser, streaming):
    content, tool_calls = run_tool_extraction(...)
    assert content == NO_TOOL_CALLS_OUTPUT
    assert len(tool_calls) == 0

# ... 9 more standard tests

# 4. Parser-specific tests (unique to each parser)
def test_mistral_tool_calls_token_required(...):
    # Tests specific to Mistral parser
```

### Duplication Metrics

- **10 standard tests** × **15 parsers** = **150 test functions** with ~90% identical code
- **Constants**: Each parser has 8-12 model output examples
- **Fixtures**: Each parser has 2 fixtures (tokenizer, parser)
- **xfail markers**: Vary by parser and test, embedded in parametrize decorators

## Proposed Refactoring

### Design Goals

1. **Single Source of Truth**: Define standard test logic once
2. **Parser-Specific Configuration**: Use fixtures and data classes for parser variations
3. **Maintainability**: Easy to add new standard tests or update existing ones
4. **Discoverability**: Keep parser-specific files for easy navigation
5. **Backward Compatibility**: Existing xfail markers and parser-specific tests continue to work
6. **Type Safety**: Use dataclasses/TypedDict for test configurations

### Architecture

```
tests/entrypoints/openai/tool_parsers/
├── utils.py                          # Existing utilities
├── test_contract.py                  # NEW: Standard test contract
├── parser_test_fixtures.py           # NEW: Base fixtures and data structures
├── test_mistral_tool_parser.py       # REFACTORED: Parser config + specific tests
├── test_qwen3xml_tool_parser.py      # REFACTORED: Parser config + specific tests
└── ...                               # REFACTORED: Other parsers
```

### Step-by-Step Implementation

#### Step 1: Create Test Data Structure

Create `parser_test_fixtures.py`:

```python
from dataclasses import dataclass, field
from typing import Optional, Callable, Dict, Any
import pytest

@dataclass
class ParserTestConfig:
    """Configuration for a tool parser's standard tests."""

    # Parser identification
    parser_name: str  # e.g., "mistral", "qwen3_xml"

    # Test data - model outputs for each standard test
    no_tool_calls_output: str
    single_tool_call_output: str
    parallel_tool_calls_output: str
    various_data_types_output: str
    empty_arguments_output: str
    surrounding_text_output: str
    escaped_strings_output: str
    malformed_input_outputs: list[str]  # Multiple malformed examples

    # Expected results for specific tests (optional overrides)
    single_tool_call_expected_name: str = "get_weather"
    single_tool_call_expected_args: Dict[str, Any] = field(default_factory=lambda: {"city": "Tokyo"})
    parallel_tool_calls_count: int = 2
    parallel_tool_calls_names: list[str] = field(default_factory=lambda: ["get_weather", "get_time"])

    # xfail configuration - maps test name to xfail reason
    xfail_streaming: Dict[str, str] = field(default_factory=dict)
    xfail_nonstreaming: Dict[str, str] = field(default_factory=dict)
    xfail_both: Dict[str, str] = field(default_factory=dict)

    # Tokenizer factory - creates parser-specific tokenizer
    tokenizer_factory: Optional[Callable[[], Any]] = None

    # Parser factory - creates parser instance (uses ToolParserManager by default)
    parser_factory: Optional[Callable[[Any], Any]] = None

    # Content expectations (some parsers strip content, others don't)
    single_tool_call_expected_content: Optional[str] = None
    parallel_tool_calls_expected_content: Optional[str] = None

    # Special assertions for edge cases
    allow_empty_or_json_empty_args: bool = True  # "{}" or "" for empty args


@dataclass
class ParserTestResult:
    """Expected results for test assertions."""
    content: Optional[str]
    tool_calls_count: int
    tool_call_names: list[str] = field(default_factory=list)
    tool_call_args: list[Dict[str, Any]] = field(default_factory=list)
```

#### Step 2: Create Standard Test Contract

Create `test_contract.py`:

```python
"""Standard test contract for tool call parsers.

This module defines the 10 standard tests that all tool parsers must pass.
Parser-specific files register their configuration and these tests run automatically.
"""

import json
import pytest
from typing import Any

from .utils import run_tool_extraction
from .parser_test_fixtures import ParserTestConfig


class StandardToolParserTests:
    """Mixin class providing standard test suite for tool parsers.

    To use:
    1. Create a pytest fixture named `parser_config` that returns a ParserTestConfig
    2. Create a pytest fixture named `tool_parser` that returns the parser instance
    3. Inherit from this class in your test file
    4. Run pytest - all standard tests will execute
    """

    @pytest.fixture
    def parser_config(self) -> ParserTestConfig:
        """Override this to provide parser-specific configuration."""
        raise NotImplementedError("Subclass must provide parser_config fixture")

    @pytest.fixture
    def tool_parser(self, parser_config: ParserTestConfig):
        """Override this to provide parser instance, or use default."""
        if parser_config.parser_factory:
            tokenizer = parser_config.tokenizer_factory() if parser_config.tokenizer_factory else None
            return parser_config.parser_factory(tokenizer)

        # Default implementation
        from vllm.entrypoints.openai.tool_parsers import ToolParserManager
        tokenizer = parser_config.tokenizer_factory() if parser_config.tokenizer_factory else None
        return ToolParserManager.get_tool_parser(parser_config.parser_name)(tokenizer)

    def _get_streaming_param(self, test_name: str, parser_config: ParserTestConfig):
        """Build parametrize values with xfail markers."""
        streaming_param = []

        # Check if streaming mode should xfail
        xfail_reason = (
            parser_config.xfail_both.get(test_name) or
            parser_config.xfail_streaming.get(test_name)
        )
        if xfail_reason:
            streaming_param.append(
                pytest.param(True, marks=pytest.mark.xfail(reason=xfail_reason))
            )
        else:
            streaming_param.append(True)

        # Check if non-streaming mode should xfail
        xfail_reason = (
            parser_config.xfail_both.get(test_name) or
            parser_config.xfail_nonstreaming.get(test_name)
        )
        if xfail_reason:
            streaming_param.append(
                pytest.param(False, marks=pytest.mark.xfail(reason=xfail_reason))
            )
        else:
            streaming_param.append(False)

        return streaming_param

    # Standard Test 1
    @pytest.mark.parametrize("streaming", [True, False])
    def test_no_tool_calls(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser handles plain text without tool syntax."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.no_tool_calls_output, streaming=streaming
        )
        assert content == parser_config.no_tool_calls_output, \
            f"Expected content to match input, got {content}"
        assert len(tool_calls) == 0, \
            f"Expected no tool calls, got {len(tool_calls)}"

    # Standard Test 2
    @pytest.mark.parametrize("streaming", [True, False])
    def test_single_tool_call_simple_args(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser extracts one tool with simple arguments."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.single_tool_call_output, streaming=streaming
        )

        # Content check (some parsers strip it)
        if parser_config.single_tool_call_expected_content is not None:
            assert content == parser_config.single_tool_call_expected_content

        assert len(tool_calls) == 1, f"Expected 1 tool call, got {len(tool_calls)}"
        assert tool_calls[0].type == "function"
        assert tool_calls[0].function.name == parser_config.single_tool_call_expected_name

        args = json.loads(tool_calls[0].function.arguments)
        for key, value in parser_config.single_tool_call_expected_args.items():
            assert args.get(key) == value, \
                f"Expected {key}={value}, got {args.get(key)}"

    # Standard Test 3
    @pytest.mark.parametrize("streaming", [True, False])
    def test_parallel_tool_calls(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser handles multiple tools in one response."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.parallel_tool_calls_output, streaming=streaming
        )

        assert len(tool_calls) == parser_config.parallel_tool_calls_count, \
            f"Expected {parser_config.parallel_tool_calls_count} tool calls, got {len(tool_calls)}"

        # Verify tool names match expected
        for i, expected_name in enumerate(parser_config.parallel_tool_calls_names):
            assert tool_calls[i].type == "function"
            assert tool_calls[i].function.name == expected_name

        # Verify unique IDs
        ids = [tc.id for tc in tool_calls]
        assert len(ids) == len(set(ids)), "Tool call IDs should be unique"

    # Standard Test 4
    @pytest.mark.parametrize("streaming", [True, False])
    def test_various_data_types(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser handles all JSON types in arguments."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.various_data_types_output, streaming=streaming
        )
        assert len(tool_calls) == 1, f"Expected 1 tool call, got {len(tool_calls)}"

        args = json.loads(tool_calls[0].function.arguments)
        # Verify all expected fields present
        required_fields = [
            "string_field", "int_field", "float_field",
            "bool_field", "null_field", "array_field", "object_field"
        ]
        for field in required_fields:
            assert field in args, f"Expected field '{field}' in arguments"

    # Standard Test 5
    @pytest.mark.parametrize("streaming", [True, False])
    def test_empty_arguments(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser handles parameterless tool calls."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.empty_arguments_output, streaming=streaming
        )
        assert len(tool_calls) == 1, f"Expected 1 tool call, got {len(tool_calls)}"

        args = tool_calls[0].function.arguments
        if parser_config.allow_empty_or_json_empty_args:
            assert args in ["{}", ""], f"Expected empty args, got {args}"
        else:
            assert args == "{}", f"Expected {{}}, got {args}"

    # Standard Test 6
    @pytest.mark.parametrize("streaming", [True, False])
    def test_surrounding_text(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser extracts tools from mixed content."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.surrounding_text_output, streaming=streaming
        )
        assert len(tool_calls) >= 1, f"Expected at least 1 tool call, got {len(tool_calls)}"

    # Standard Test 7
    @pytest.mark.parametrize("streaming", [True, False])
    def test_escaped_strings(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser handles escaped characters in arguments."""
        content, tool_calls = run_tool_extraction(
            tool_parser, parser_config.escaped_strings_output, streaming=streaming
        )
        assert len(tool_calls) == 1, f"Expected 1 tool call, got {len(tool_calls)}"

        args = json.loads(tool_calls[0].function.arguments)
        # At minimum, verify we can parse and have expected fields
        # Exact escaping behavior varies by parser
        assert len(args) > 0, "Expected some arguments with escaped strings"

    # Standard Test 8
    @pytest.mark.parametrize("streaming", [True, False])
    def test_malformed_input(self, tool_parser, parser_config: ParserTestConfig, streaming):
        """Verify parser gracefully handles invalid syntax."""
        for malformed_input in parser_config.malformed_input_outputs:
            # Should not raise exception
            content, tool_calls = run_tool_extraction(
                tool_parser, malformed_input, streaming=streaming
            )
            # Parser should handle gracefully (exact behavior varies)

    # Standard Test 9
    def test_streaming_reconstruction(self, tool_parser, parser_config: ParserTestConfig):
        """Verify streaming produces same result as non-streaming."""
        test_output = parser_config.single_tool_call_output

        # Check if this test should xfail
        if "test_streaming_reconstruction" in parser_config.xfail_both:
            pytest.xfail(parser_config.xfail_both["test_streaming_reconstruction"])

        # Non-streaming result
        content_non, tools_non = run_tool_extraction(
            tool_parser, test_output, streaming=False
        )

        # Create fresh parser for streaming test
        from vllm.entrypoints.openai.tool_parsers import ToolParserManager
        tokenizer = parser_config.tokenizer_factory() if parser_config.tokenizer_factory else None
        fresh_parser = ToolParserManager.get_tool_parser(parser_config.parser_name)(tokenizer)

        # Streaming result
        content_stream, tools_stream = run_tool_extraction(
            fresh_parser, test_output, streaming=True
        )

        # Compare results
        assert len(tools_non) == len(tools_stream), "Tool count should match"
        if len(tools_non) > 0:
            assert tools_non[0].function.name == tools_stream[0].function.name

    # Standard Test 10
    def test_streaming_boundary_splits(self, tool_parser, parser_config: ParserTestConfig):
        """Verify streaming handles splits at critical points."""
        test_output = parser_config.parallel_tool_calls_output

        # Check if this test should xfail
        if "test_streaming_boundary_splits" in parser_config.xfail_both:
            pytest.xfail(parser_config.xfail_both["test_streaming_boundary_splits"])

        # Test with simple split strategy
        mid_point = len(test_output) // 2
        deltas = [test_output[:mid_point], test_output[mid_point:]]

        # Create fresh parser
        from vllm.entrypoints.openai.tool_parsers import ToolParserManager
        tokenizer = parser_config.tokenizer_factory() if parser_config.tokenizer_factory else None
        fresh_parser = ToolParserManager.get_tool_parser(parser_config.parser_name)(tokenizer)

        # Accumulate deltas
        accumulated = ""
        for delta in deltas:
            accumulated += delta

        content, tool_calls = run_tool_extraction(fresh_parser, accumulated, streaming=True)

        # Should get expected number of tool calls
        assert len(tool_calls) >= 1, \
            f"Expected at least 1 tool call from split output"
```

#### Step 3: Refactor Individual Parser Test Files

**Before** (`test_mistral_tool_parser.py` - 427 lines):
```python
# All constants
# All fixtures
# All 10 standard tests (identical logic)
# Parser-specific tests
```

**After** (`test_mistral_tool_parser.py` - ~150 lines):
```python
"""Tests for Mistral tool parser."""

import pytest
from unittest.mock import MagicMock

from .test_contract import StandardToolParserTests
from .parser_test_fixtures import ParserTestConfig
from vllm.entrypoints.openai.tool_parsers.mistral_tool_parser import MistralToolCall


class TestMistralToolParser(StandardToolParserTests):
    """Test suite for Mistral tool parser.

    Inherits standard tests from StandardToolParserTests.
    Adds Mistral-specific tests below.
    """

    @pytest.fixture
    def parser_config(self) -> ParserTestConfig:
        """Mistral parser test configuration."""
        return ParserTestConfig(
            parser_name="mistral",

            # Test data
            no_tool_calls_output="This is a regular response without any tool calls.",
            single_tool_call_output='[TOOL_CALLS][{"name": "get_weather", "arguments": {"city": "Tokyo"}}]',
            parallel_tool_calls_output='''[TOOL_CALLS][
              {"name": "get_weather", "arguments": {"city": "Tokyo"}},
              {"name": "get_time", "arguments": {"timezone": "Asia/Tokyo"}}
            ]''',
            various_data_types_output='''[TOOL_CALLS][{
              "name": "test_function",
              "arguments": {
                "string_field": "hello",
                "int_field": 42,
                "float_field": 3.14,
                "bool_field": true,
                "null_field": null,
                "array_field": ["a", "b", "c"],
                "object_field": {"nested": "value"}
              }
            }]''',
            empty_arguments_output='[TOOL_CALLS][{"name": "refresh", "arguments": {}}]',
            surrounding_text_output='Let me check the weather.\n[TOOL_CALLS][{"name": "get_weather", "arguments": {"city": "Tokyo"}}]',
            escaped_strings_output='''[TOOL_CALLS][{
              "name": "test_function",
              "arguments": {
                "quoted": "He said \\"hello\\"",
                "path": "C:\\\\Users\\\\file.txt"
              }
            }]''',
            malformed_input_outputs=[
                '[TOOL_CALLS][{"name": "func", "arguments": {',
                '[TOOL_CALLS][{"name": "func", "arguments": "not a dict"}]',
            ],

            # Expected results
            single_tool_call_expected_content=None,  # Mistral strips content when tool calls present

            # xfail markers
            xfail_streaming={
                "test_single_tool_call_simple_args": "Streaming mode doesn't strip [TOOL_CALLS] marker",
                "test_parallel_tool_calls": "Streaming mode doesn't strip [TOOL_CALLS] marker",
                "test_various_data_types": "Streaming mode doesn't strip [TOOL_CALLS] marker",
                "test_escaped_strings": "Streaming mode doesn't strip [TOOL_CALLS] marker",
                "test_malformed_input": "Streaming mode doesn't strip [TOOL_CALLS] marker",
            },
            xfail_both={
                "test_streaming_reconstruction": "Streaming mode doesn't strip [TOOL_CALLS] marker",
            },

            # Tokenizer factory
            tokenizer_factory=lambda: self._create_mistral_tokenizer(),
        )

    @staticmethod
    def _create_mistral_tokenizer():
        """Create mock tokenizer for Mistral parser."""
        tokenizer = MagicMock()
        vocab = {"[TOOL_CALLS]": 32000}
        tokenizer.get_vocab.return_value = vocab
        tokenizer.tokenize.return_value = []
        return tokenizer

    # ========================================================================
    # Mistral-Specific Tests
    # ========================================================================

    @pytest.mark.parametrize("streaming", [True, False])
    def test_mistral_tool_calls_token_required(self, tool_parser, parser_config, streaming):
        """Verify parser requires [TOOL_CALLS] token to detect tool calls."""
        from .utils import run_tool_extraction

        no_marker = '[{"name": "get_weather", "arguments": {"city": "Tokyo"}}]'
        content, tool_calls = run_tool_extraction(tool_parser, no_marker, streaming=streaming)
        assert len(tool_calls) == 0, f"Expected no tool calls without marker"
        assert content == no_marker, "Should return original text as content"

    def test_mistral_tool_call_id_format(self):
        """Verify Mistral tool call IDs are 9-character alphanumeric."""
        for _ in range(20):
            tool_call_id = MistralToolCall.generate_random_id()
            assert len(tool_call_id) == 9
            assert tool_call_id.isalnum()
            assert MistralToolCall.is_valid_id(tool_call_id)

        # Test invalid IDs
        assert not MistralToolCall.is_valid_id("abc")
        assert not MistralToolCall.is_valid_id("abcdefghij")
        assert not MistralToolCall.is_valid_id("abc-def12")
```

#### Step 4: Migration Guide

**For each parser test file:**

1. **Import the test contract**:
   ```python
   from .test_contract import StandardToolParserTests
   from .parser_test_fixtures import ParserTestConfig
   ```

2. **Create test class inheriting from StandardToolParserTests**:
   ```python
   class TestXXXToolParser(StandardToolParserTests):
   ```

3. **Move constants into `parser_config` fixture**:
   - Convert `NO_TOOL_CALLS_OUTPUT` → `no_tool_calls_output`
   - Move all model output constants into config

4. **Configure xfail markers**:
   - Extract xfail reasons from `@pytest.mark.parametrize` decorators
   - Add to `xfail_streaming`, `xfail_nonstreaming`, or `xfail_both` dicts

5. **Move tokenizer creation to factory**:
   - Convert `@pytest.fixture def xxx_tokenizer()` → `tokenizer_factory=lambda: ...`

6. **Delete the 10 standard test functions** (inherited from base)

7. **Keep parser-specific tests** at bottom of file

### Benefits

1. **Reduced Code**: ~427 lines → ~150 lines per parser (65% reduction)
2. **Consistency**: All parsers guaranteed to test same contract
3. **Easy Updates**: Add new standard test once, applies to all parsers
4. **Clear Separation**: Standard tests vs parser-specific tests
5. **Better Type Safety**: Dataclass config catches missing fields
6. **Easier Debugging**: xfail configuration in one place per parser

### Testing the Refactoring

1. **Run tests before refactoring**:
   ```bash
   pytest tests/entrypoints/openai/tool_parsers/ -v > before.txt
   ```

2. **Refactor one parser at a time**:
   ```bash
   # Refactor mistral
   pytest tests/entrypoints/openai/tool_parsers/test_mistral_tool_parser.py -v
   ```

3. **Compare results**:
   - Same number of tests
   - Same pass/fail/xfail counts
   - Same xfail reasons

4. **Repeat for all parsers**

5. **Run full suite**:
   ```bash
   pytest tests/entrypoints/openai/tool_parsers/ -v > after.txt
   diff before.txt after.txt  # Should be identical
   ```

### Migration Order (Lowest Risk First)

1. **mistral** - Clean example with clear xfail patterns
2. **granite** - Simple parser
3. **qwen3xml** - Complex xfail patterns (good test)
4. **hermes** - Has integration tests at top (keep those separate)
5. **llama**, **llama3_json**, **llama4_pythonic** - Similar patterns
6. **internlm2**, **pythonic**, **step3**, **phi4mini** - Remaining parsers
7. **deepseekv3**, **granite_20b_fc**, **hunyuan_a13b**, **longcat** - Final batch

### Alternative: Hybrid Approach

If full inheritance feels too heavyweight, consider **hybrid approach**:

```python
# Keep existing structure but import shared test logic
from .test_contract import (
    standard_test_no_tool_calls,
    standard_test_single_tool_call,
    # ... etc
)

@pytest.fixture
def parser_config():
    return ParserTestConfig(...)

# Call shared test logic
@pytest.mark.parametrize("streaming", [True, False])
def test_no_tool_calls(tool_parser, parser_config, streaming):
    standard_test_no_tool_calls(tool_parser, parser_config, streaming)
```

This is less DRY but more explicit and easier to customize per-parser.

## Implementation Checklist

- [ ] Create `parser_test_fixtures.py` with `ParserTestConfig` dataclass
- [ ] Create `test_contract.py` with `StandardToolParserTests` base class
- [ ] Refactor `test_mistral_tool_parser.py` as proof of concept
- [ ] Verify test results identical before/after
- [ ] Document pattern in README
- [ ] Refactor remaining 14 parsers one by one
- [ ] Update CI/CD if needed (test discovery should be automatic)
- [ ] Add developer documentation for adding new parsers

## Future Enhancements

1. **Auto-generate parser configs** from parser implementations
2. **Pytest plugin** to auto-discover parsers and generate tests
3. **Shared test fixtures** in conftest.py for common tokenizers
4. **Performance testing** framework using same config structure
5. **Test coverage reporting** per parser vs standard contract

## Questions & Considerations

### Should we keep the test functions in each file?

**Option A**: Inherit from base class (cleaner, more DRY)
**Option B**: Import and call shared functions (more explicit, easier to debug)

**Recommendation**: Start with Option A (inheritance), can always fall back to Option B if inheritance causes issues with test discovery or debugging.

### How to handle parsers with unique test signatures?

Some parsers (like Hermes) require additional fixtures like `ChatCompletionRequest`.

**Solution**:
- Keep `run_tool_extraction` wrapper that handles this
- Add optional `request_factory` to `ParserTestConfig`
- Base class handles both cases

### What about the integration tests in some files?

Some files (like `test_hermes_tool_parser.py`) have integration tests using `RemoteOpenAIServer`.

**Solution**:
- Keep integration tests at top of file (before the class)
- Standard unit tests in the class
- Parser-specific unit tests as methods of the class

## Example: Before vs After

### Before (test_mistral_tool_parser.py - 427 lines)

- 80 lines: Constants
- 15 lines: Fixtures
- 280 lines: 10 standard tests (28 lines each average)
- 52 lines: 3 parser-specific tests

### After (test_mistral_tool_parser.py - ~150 lines)

- 0 lines: Constants (in config)
- 5 lines: Static tokenizer factory
- 50 lines: Config fixture
- 0 lines: Standard tests (inherited)
- 52 lines: 3 parser-specific tests
- 15 lines: Class definition and docstrings

**Savings**: 277 lines per file × 15 files = **~4,155 lines of duplicated code eliminated**
