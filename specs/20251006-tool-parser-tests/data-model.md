# Phase 1: Data Model

## Overview
Data entities and structures for comprehensive tool parser testing.

## Core Entities

### 1. TestCase
Represents a single test scenario for a tool parser.

**Fields:**
- `scenario_name`: string - Human-readable test scenario identifier (e.g., "single_tool_call", "parallel_calls")
- `model_output`: string - Raw text that simulates model-generated output
- `expected_tools_called`: boolean - Whether tools should be detected
- `expected_tool_calls`: list[ToolCall] - Expected parsed tool call objects (empty if no tools)
- `expected_content`: string | None - Expected non-tool content portion
- `streaming_mode`: boolean - Whether this test runs in streaming mode
- `parser_name`: string - Name of parser being tested (e.g., "hermes", "pythonic")

**Validation Rules:**
- If `expected_tools_called` is True, `expected_tool_calls` must not be empty
- If `expected_tools_called` is False, `expected_tool_calls` must be empty
- `parser_name` must match a registered parser in `ToolParserManager`
- `model_output` must be non-None (can be empty string)

**State Transitions:**
```
Created -> Executed -> (Passed | Failed | Xfailed)
```

### 2. ToolCall
Standard OpenAI-compatible tool call object (from vllm.entrypoints.openai.protocol).

**Fields:**
- `id`: string - Unique tool call identifier (auto-generated)
- `type`: literal["function"] - Always "function" for function calls
- `function`: FunctionCall - The function call details

**Validation Rules:**
- `id` must be non-empty string, length >= 16 for most parsers
- `type` must equal "function"
- `function` must be valid FunctionCall object

### 3. FunctionCall
Function call details within a tool call (from vllm.entrypoints.openai.protocol).

**Fields:**
- `name`: string - Function name as extracted from model output
- `arguments`: string - JSON-encoded string of function arguments

**Validation Rules:**
- `name` must be non-empty string
- `arguments` must be valid JSON string or empty string
- Special case: Empty arguments can be `"{}"` or `""`

### 4. ExtractedToolCallInformation
Result of non-streaming tool extraction (from vllm.entrypoints.openai.protocol).

**Fields:**
- `tools_called`: boolean - Whether any tools were detected
- `tool_calls`: list[ToolCall] - List of extracted tool calls
- `content`: string | None - Non-tool text content

**Validation Rules:**
- `tools_called` must be True if `tool_calls` is non-empty
- `tools_called` must be False if `tool_calls` is empty
- `content` should be None when tools are called (unless mixed content/tools)

### 5. DeltaMessage
Streaming delta containing incremental tool call or content updates.

**Fields:**
- `content`: string | None - Text content delta
- `tool_calls`: list[DeltaToolCall] | None - Tool call delta updates

**Validation Rules:**
- At least one of `content` or `tool_calls` should be non-None
- `tool_calls` must use proper indexing (0-based, sequential)

### 6. DeltaToolCall
Incremental update to a tool call during streaming.

**Fields:**
- `index`: int - Index of tool call being updated
- `id`: string | None - Tool ID (present only on first delta for this tool)
- `type`: literal["function"] | None - Type (present only on first delta)
- `function`: DeltaFunctionCall - Function call delta

**Validation Rules:**
- `index` must be >= 0
- `id` must be present when tool is first introduced (index not seen before)
- `function.name` must be present when tool is first introduced
- `function.arguments` incrementally builds full arguments string

### 7. StreamingToolReconstructor
Test utility that accumulates streaming deltas into complete tool calls.

**Fields:**
- `tool_calls`: list[ToolCall] - Accumulated complete tool calls
- `other_content`: string - Accumulated non-tool content

**Operations:**
- `append_delta(delta: DeltaMessage)` - Processes one streaming delta
- Validates proper streaming protocol (IDs sent once, names sent once, arguments incremental)

## Standard Test Patterns

### Pattern 1: No Tool Calls
**Purpose:** Verify parser correctly handles plain text without tool syntax

**Model Output Examples:**
- "Hello, how can I help you?"
- "This is a regular response."
- "" (empty string)
- "   \n  " (whitespace only)

**Expected Results:**
- `tools_called`: False
- `tool_calls`: []
- `content`: original model output

### Pattern 2: Single Tool Call
**Purpose:** Verify parser correctly extracts one tool with simple arguments

**Model Output Examples:**
- XML format: `<tool_call>{"name": "get_weather", "arguments": {"city": "Tokyo"}}</tool_call>`
- Pythonic format: `[get_weather(city='Tokyo')]`
- JSON format: `[TOOL_CALLS][{"name": "get_weather", "arguments": {"city": "Tokyo"}}]`

**Expected Results:**
- `tools_called`: True
- `tool_calls`: 1 item
  - `function.name`: "get_weather"
  - `function.arguments`: '{"city": "Tokyo"}'
- `content`: None (or text before tool call if mixed)

### Pattern 3: Multiple Parallel Tool Calls
**Purpose:** Verify parser handles multiple tools in one response

**Model Output Examples:**
- `[get_weather(city='Tokyo'), get_time(timezone='Asia/Tokyo')]`
- Multiple XML tags: `<tool_call>...</tool_call><tool_call>...</tool_call>`

**Expected Results:**
- `tools_called`: True
- `tool_calls`: 2+ items with proper indexing
- Each tool call has unique ID
- `content`: None (or text before tools)

### Pattern 4: Various Data Types
**Purpose:** Verify parser handles all JSON-compatible argument types

**Argument Examples:**
- String: `{"name": "John"}`
- Integer: `{"age": 30}`
- Float: `{"price": 19.99}`
- Boolean: `{"active": true}`
- Null: `{"role": null}`
- Array: `{"tags": ["a", "b"]}`
- Nested object: `{"address": {"city": "Tokyo", "zip": "100-0001"}}`
- Empty array: `{"items": []}`
- Empty object: `{"meta": {}}`

**Expected Results:**
- All types correctly parsed and JSON-encoded in `arguments` string
- Type preservation (true/false not "true"/"false", null not "null" string)

### Pattern 5: Empty/Parameterless Tool Calls
**Purpose:** Verify parser handles functions with no arguments

**Model Output Examples:**
- `[get_current_time()]`
- `<tool_call>{"name": "refresh", "arguments": {}}</tool_call>`

**Expected Results:**
- `tools_called`: True
- `function.arguments`: `"{}"` or `""`

### Pattern 6: Surrounding Text/Whitespace
**Purpose:** Verify parser extracts tool calls from mixed content

**Model Output Examples:**
- `Let me check the weather. <tool_call>...</tool_call>`
- `\n\n[get_weather(city='Tokyo')]\n\n`
- `Text before [tool()] text after`

**Expected Results:**
- `tools_called`: True
- Tool calls extracted correctly
- `content`: Surrounding text (parser-specific behavior)

### Pattern 7: Escaped Strings/Special Characters
**Purpose:** Verify parser handles escaped and special characters

**Argument Examples:**
- `{"text": "He said \"hello\""}`
- `{"path": "C:\\Users\\file.txt"}`
- `{"unicode": "emoji: 🎉"}`
- `{"newline": "line1\\nline2"}`

**Expected Results:**
- Proper escaping maintained in JSON arguments string
- No corruption of special characters

### Pattern 8: Malformed Input
**Purpose:** Verify parser gracefully handles invalid syntax

**Model Output Examples:**
- Incomplete JSON: `<tool_call>{"name": "func", "arguments": {</tool_call>`
- Mismatched brackets: `[func(arg='val']`
- Invalid JSON: `[func(arg=undefined)]`

**Expected Results:**
- `tools_called`: False (graceful degradation)
- `tool_calls`: []
- `content`: original malformed output (treat as text)
- No exceptions raised

### Pattern 9: Streaming Reconstruction
**Purpose:** Verify streaming mode correctly accumulates deltas

**Delta Sequence Examples:**
- `["[get", "_weather", "(city", "='Tokyo", "')]"]`
- Tool name in one chunk, arguments spread across many

**Expected Results:**
- StreamingToolReconstructor produces same final tool calls as non-streaming
- First delta for each tool includes ID and name
- Subsequent deltas for same tool only include argument fragments
- Proper indexing maintained

### Pattern 10: Streaming Boundary Splits
**Purpose:** Verify streaming handles tool calls split at critical points

**Critical Split Points:**
- Mid-function name
- Mid-argument name
- Mid-argument value (especially strings)
- Between multiple tool calls

**Expected Results:**
- Correct reconstruction regardless of split location
- No duplicate IDs or names
- Arguments string correctly assembled

## Parser-Specific Extensions

### Hermes Parser Extensions
- Scratch pad handling: `<scratch_pad>...</scratch_pad>` content
- Nested JSON in arguments
- Tool call token buffering edge cases

### Pythonic Parser Extensions
- AST parsing edge cases
- Python literal syntax variations
- Regex timeout handling (FR from existing tests)

### Mistral Parser Extensions
- `[TOOL_CALLS]` token detection
- 9-character alphanumeric ID format
- Function name regex parsing (v11+ tokenizers)

### OpenAI Parser Extensions
- Harmony encoding format
- Channel-based message routing
- Content-type handling (json vs plain)

## Relationships

```
TestCase (1) -> (1) ToolParser (via parser_name)
TestCase (1) -> (0..n) ToolCall (via expected_tool_calls)
ToolCall (1) -> (1) FunctionCall (via function)
ExtractedToolCallInformation (1) -> (0..n) ToolCall
DeltaMessage (1) -> (0..n) DeltaToolCall
StreamingToolReconstructor (1) -> (0..n) ToolCall (accumulated)
```

## Constraints

### Test Data Constraints
- Model outputs must be realistic representations of actual model behavior
- For parsers without public documentation, combine web research with code analysis
- Test data should exercise both happy path and edge cases

### Execution Constraints
- Each test must create fresh parser instance (no shared state)
- Tests must be deterministic (no randomness in assertions)
- Streaming tests must simulate realistic token-by-token delivery

### Performance Constraints
- Standard tests target <2min per parser
- Extensive streaming tests marked with `@pytest.mark.slow_test`
- Mock tokenizers preferred for speed (real tokenizers only when necessary)
