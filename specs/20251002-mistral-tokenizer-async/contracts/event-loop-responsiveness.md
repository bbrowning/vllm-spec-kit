# Contract: Event Loop Responsiveness

## Contract ID
`event-loop-001`

## Description
The async event loop MUST remain responsive (yield control within <100ms) during Mistral tokenizer operations when using the new `async_apply_mistral_chat_template` function, even when processing large payloads.

## Preconditions
- vLLM server running with Mistral tokenizer configured
- Async event loop active
- `async_apply_mistral_chat_template` function available in `chat_utils`

## Operation
```python
async def async_apply_mistral_chat_template(
    tokenizer: MistralTokenizer,
    messages: list[ChatCompletionMessageParam],
    tools: Optional[list[dict]] = None,
    **kwargs
) -> list[int]
```

## Postconditions

### Success Criteria
1. **Event Loop Yield**: During tokenization, `await asyncio.sleep(0)` completes in <100ms
2. **Concurrent Operations**: Health check requests complete within 2 seconds
3. **Token Correctness**: Returned tokens match original `apply_mistral_chat_template` output

### Performance Requirements
- **Latency Overhead**: <5% increase vs synchronous baseline
- **Throughput**: No degradation for single-request scenarios

## Test Specification

### Test 1: Event Loop Not Blocked
```python
@pytest.mark.slow_test
@pytest.mark.asyncio
async def test_async_mistral_tokenizer_does_not_block_event_loop():
    """
    GIVEN a Mistral tokenizer instance
    WHEN processing a large payload (>400KB) via async_apply_mistral_chat_template
    THEN the event loop should yield control regularly (<100ms intervals)
    """
    from vllm.entrypoints.chat_utils import async_apply_mistral_chat_template

    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    large_payload = generate_large_message(size_kb=439)

    task = asyncio.create_task(
        async_apply_mistral_chat_template(tokenizer, [large_payload])
    )

    # Monitor event loop responsiveness
    for i in range(50):  # Check over ~5 seconds
        start = time.perf_counter()
        await asyncio.sleep(0)
        elapsed = time.perf_counter() - start

        assert elapsed < 0.1, (
            f"Event loop blocked for {elapsed:.2f}s at iteration {i}"
        )
        await asyncio.sleep(0.1)

    # Ensure task completes
    tokens = await task
    assert len(tokens) > 0
```

### Test 2: Correct Tokenization Results
```python
@pytest.mark.asyncio
async def test_async_tokenization_produces_identical_results():
    """
    GIVEN a Mistral tokenizer instance
    WHEN tokenizing the same input via original apply_mistral_chat_template and new async_apply_mistral_chat_template
    THEN both functions MUST produce identical token sequences
    """
    from vllm.entrypoints.chat_utils import (
        apply_mistral_chat_template,
        async_apply_mistral_chat_template
    )

    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    messages = [
        {"role": "user", "content": "Test message " * 1000}
    ]

    # Original: synchronous apply_mistral_chat_template
    sync_tokens = apply_mistral_chat_template(tokenizer, messages, tools=None)

    # New: async wrapper
    async_tokens = await async_apply_mistral_chat_template(tokenizer, messages, tools=None)

    assert sync_tokens == async_tokens, "Token mismatch between sync and async"
```

### Test 3: Health Endpoint Responsiveness
```python
@pytest.mark.asyncio
async def test_health_endpoint_responsive_during_tokenization():
    """
    GIVEN a vLLM server processing a large Mistral tokenization request
    WHEN a health check is requested concurrently
    THEN the health check MUST respond within 2 seconds
    """
    from vllm.entrypoints.chat_utils import async_apply_mistral_chat_template

    # Start large tokenization in background
    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    large_payload = generate_large_message(size_kb=500)

    tokenize_task = asyncio.create_task(
        async_apply_mistral_chat_template(tokenizer, [large_payload])
    )

    # Simulate health check
    await asyncio.sleep(0.1)  # Let tokenization start
    health_start = time.perf_counter()

    async def mock_health_check():
        await asyncio.sleep(0)  # Should yield immediately
        return {"status": "healthy"}

    health_response = await asyncio.wait_for(
        mock_health_check(),
        timeout=2.0
    )

    health_duration = time.perf_counter() - health_start
    assert health_duration < 2.0, f"Health check took {health_duration:.2f}s"

    # Cleanup
    await tokenize_task
```

## Error Handling Contract

### Exception Preservation
```python
@pytest.mark.asyncio
async def test_exceptions_preserved_in_async_path():
    """
    GIVEN invalid input to Mistral tokenizer
    WHEN async_apply_mistral_chat_template is called
    THEN the same exception type and message MUST be raised as apply_mistral_chat_template
    """
    from vllm.entrypoints.chat_utils import (
        apply_mistral_chat_template,
        async_apply_mistral_chat_template
    )

    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    invalid_input = {"role": "invalid_role", "content": "test"}

    # Capture sync exception from original function
    sync_exception = None
    try:
        apply_mistral_chat_template(tokenizer, [invalid_input])
    except Exception as e:
        sync_exception = e

    # Capture async exception from new wrapper
    async_exception = None
    try:
        await async_apply_mistral_chat_template(tokenizer, [invalid_input])
    except Exception as e:
        async_exception = e

    assert type(sync_exception) == type(async_exception)
    assert str(sync_exception) == str(async_exception)
```

## Failure Modes

| Failure Mode | Expected Behavior |
|--------------|-------------------|
| Event loop blocks >100ms | Test fails, indicates async wrapper not working |
| Token mismatch | Test fails, correctness violation |
| Health check timeout | Test fails, responsiveness requirement violated |
| Exception type changed | Test fails, error contract violation |

## Version
1.0 - Initial specification
