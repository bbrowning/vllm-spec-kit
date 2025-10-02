# Data Model: Mistral Tokenizer Async Event Loop Fix

## Overview
This feature is a bug fix with no new data entities. It modifies the execution model of existing tokenization operations.

## Existing Entities (Reference Only)

### TokenizationRequest
**Source**: Implicit in request handling flow
**Fields**:
- `messages`: list[ChatCompletionMessageParam] - Chat messages to tokenize
- `tools`: Optional[list[dict]] - Tool definitions for function calling
- `payload_size`: int (derived) - Byte size of message content

**State**: Stateless (pure transformation)

### TokenizationResult
**Source**: Return value from `apply_chat_template`
**Fields**:
- `tokens`: list[int] - Encoded token IDs

**Invariants**:
- Must be identical to synchronous implementation output for same input
- Deterministic (same input always produces same tokens)

## Execution Model Changes

### Before (Blocking)
```
[Async Event Loop Thread]
  ↓
  apply_chat_template() [BLOCKS EVENT LOOP]
  ↓ (53s for 439KB payload)
  encode_chat_completion() [CPU-intensive]
  ↓
  return tokens
```

### After (Non-Blocking)
```
[Async Event Loop Thread]
  ↓
  apply_chat_template() [async]
  ↓
  await asyncio.to_thread()
  ↓
  [Worker Thread (sequential queue)]
     ↓
     encode_chat_completion() [CPU-intensive, off event loop]
     ↓
     return tokens
  ↓
  [Back to Event Loop Thread]
  return tokens
```

## Constraints

### Sequential Execution Queue
- **Rule**: Large payload requests (all Mistral tokenization) processed one at a time
- **Implementation**: ThreadPoolExecutor with max_workers=1
- **Rationale**: Resource control per clarifications

### Performance Bounds
- **Overhead**: <5% added latency vs synchronous baseline
- **Health Endpoint**: Must respond <2s during tokenization

### Correctness Guarantee
- **Token Equality**: Async path MUST produce identical tokens to sync path
- **Error Preservation**: Exception types and messages unchanged

## No New Data Structures
This fix introduces no new models, schemas, or persistent state.
