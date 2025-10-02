# Contract: Performance Overhead Bounds

## Contract ID
`performance-001`

## Description
The new `async_apply_mistral_chat_template` function MUST NOT introduce more than 5% performance overhead compared to the original `apply_mistral_chat_template` function.

## Measurement Methodology

### Baseline (Original Synchronous Function)
```python
def measure_sync_tokenization(tokenizer, messages):
    """Measure original apply_mistral_chat_template time"""
    from vllm.entrypoints.chat_utils import apply_mistral_chat_template

    times = []
    for _ in range(10):  # 10 iterations for statistical significance
        start = time.perf_counter()
        tokens = apply_mistral_chat_template(tokenizer, messages)
        elapsed = time.perf_counter() - start
        times.append(elapsed)

    return {
        "mean": statistics.mean(times),
        "median": statistics.median(times),
        "stdev": statistics.stdev(times),
    }
```

### New Async Wrapper
```python
async def measure_async_tokenization(tokenizer, messages):
    """Measure new async_apply_mistral_chat_template time"""
    from vllm.entrypoints.chat_utils import async_apply_mistral_chat_template

    times = []
    for _ in range(10):
        start = time.perf_counter()
        tokens = await async_apply_mistral_chat_template(tokenizer, messages)
        elapsed = time.perf_counter() - start
        times.append(elapsed)

    return {
        "mean": statistics.mean(times),
        "median": statistics.median(times),
        "stdev": statistics.stdev(times),
    }
```

## Test Specification

### Test 1: Small Payload Overhead
```python
@pytest.mark.benchmark
def test_small_payload_performance_overhead():
    """
    GIVEN a small payload (1KB)
    WHEN measuring sync vs async tokenization
    THEN overhead MUST be <5%
    """
    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    messages = [{"role": "user", "content": "Hello " * 50}]  # ~1KB

    sync_stats = measure_sync_tokenization(tokenizer, messages)
    async_stats = asyncio.run(measure_async_tokenization(tokenizer, messages))

    overhead = (async_stats["mean"] - sync_stats["mean"]) / sync_stats["mean"]
    assert overhead < 0.05, (
        f"Small payload overhead {overhead:.1%} exceeds 5% limit\n"
        f"Sync: {sync_stats['mean']:.4f}s, Async: {async_stats['mean']:.4f}s"
    )
```

### Test 2: Medium Payload Overhead
```python
@pytest.mark.benchmark
def test_medium_payload_performance_overhead():
    """
    GIVEN a medium payload (100KB)
    WHEN measuring sync vs async tokenization
    THEN overhead MUST be <5%
    """
    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    messages = [{"role": "user", "content": "Test content " * 5000}]  # ~100KB

    sync_stats = measure_sync_tokenization(tokenizer, messages)
    async_stats = asyncio.run(measure_async_tokenization(tokenizer, messages))

    overhead = (async_stats["mean"] - sync_stats["mean"]) / sync_stats["mean"]
    assert overhead < 0.05, (
        f"Medium payload overhead {overhead:.1%} exceeds 5% limit\n"
        f"Sync: {sync_stats['mean']:.4f}s, Async: {async_stats['mean']:.4f}s"
    )
```

### Test 3: Large Payload Overhead
```python
@pytest.mark.benchmark
@pytest.mark.slow_test
def test_large_payload_performance_overhead():
    """
    GIVEN a large payload (500KB)
    WHEN measuring sync vs async tokenization
    THEN overhead MUST be <5%
    """
    tokenizer = MistralTokenizer.from_pretrained("mistralai/Mistral-7B-Instruct-v0.3")
    messages = [{"role": "user", "content": "Large test content " * 20000}]  # ~500KB

    sync_stats = measure_sync_tokenization(tokenizer, messages)
    async_stats = asyncio.run(measure_async_tokenization(tokenizer, messages))

    overhead = (async_stats["mean"] - sync_stats["mean"]) / sync_stats["mean"]
    assert overhead < 0.05, (
        f"Large payload overhead {overhead:.1%} exceeds 5% limit\n"
        f"Sync: {sync_stats['mean']:.4f}s, Async: {async_stats['mean']:.4f}s"
    )
```

## Acceptance Criteria

| Payload Size | Max Overhead | Rationale |
|--------------|--------------|-----------|
| Small (1KB) | 5% | Quick requests shouldn't suffer thread overhead |
| Medium (100KB) | 5% | Common case, overhead amortized |
| Large (500KB) | 5% | Primary use case, overhead negligible vs tokenization time |

## Performance Regression Detection

If overhead exceeds 5% for any payload size:
1. Check if ThreadPoolExecutor is being created per-request (should be module-level singleton)
2. Verify no unnecessary async/await overhead in hot path
3. Confirm thread pool has single worker (sequential execution)
4. Profile thread startup time (should be <1ms for warmed pool)

## Version
1.0 - Initial specification
