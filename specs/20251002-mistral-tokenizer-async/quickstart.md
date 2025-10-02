# Quickstart: Verify Mistral Tokenizer Async Fix

## Purpose
This quickstart validates that the Mistral tokenizer event loop blocking bug is fixed by confirming:
1. Event loop remains responsive during large payload tokenization with new async wrapper
2. New `async_apply_mistral_chat_template` produces identical results to original `apply_mistral_chat_template`
3. Performance overhead is within acceptable bounds (<5%)

## Prerequisites
- vLLM installed with Mistral tokenizer support (`pip install mistral_common`)
- Mistral model downloaded (e.g., `mistralai/Mistral-7B-Instruct-v0.3`)
- Python 3.9+

## Step 1: Create Test Payload

```python
# test_mistral_fix.py
import asyncio
import time
from vllm.transformers_utils.tokenizers.mistral import MistralTokenizer
from vllm.entrypoints.chat_utils import (
    apply_mistral_chat_template,
    async_apply_mistral_chat_template
)

def generate_large_message(size_kb: int) -> dict:
    """Generate a message of approximately size_kb kilobytes"""
    # Each "word " is 5 bytes, so repeat to reach target size
    words_needed = (size_kb * 1024) // 5
    content = "word " * words_needed
    return {"role": "user", "content": content}

# Create test payloads
SMALL_PAYLOAD = generate_large_message(1)      # 1KB
MEDIUM_PAYLOAD = generate_large_message(100)   # 100KB
LARGE_PAYLOAD = generate_large_message(500)    # 500KB
```

## Step 2: Test Event Loop Responsiveness

```python
async def test_event_loop_not_blocked():
    """Verify event loop stays responsive during tokenization"""
    print("Testing event loop responsiveness...")

    tokenizer = MistralTokenizer.from_pretrained(
        "mistralai/Mistral-7B-Instruct-v0.3"
    )

    # Start large tokenization in background using NEW async wrapper
    task = asyncio.create_task(
        async_apply_mistral_chat_template(tokenizer, [LARGE_PAYLOAD])
    )

    # Monitor event loop - should yield frequently
    blocked_count = 0
    for i in range(50):  # Check over ~5 seconds
        start = time.perf_counter()
        await asyncio.sleep(0)  # Should yield immediately
        elapsed = time.perf_counter() - start

        if elapsed > 0.1:  # >100ms means blocked
            blocked_count += 1
            print(f"  WARNING: Loop blocked {elapsed:.3f}s at iteration {i}")

        await asyncio.sleep(0.1)

    # Wait for tokenization to complete
    tokens = await task

    if blocked_count == 0:
        print("✓ PASS: Event loop never blocked")
    else:
        print(f"✗ FAIL: Event loop blocked {blocked_count}/50 times")

    return blocked_count == 0
```

## Step 3: Verify Tokenization Correctness

```python
async def test_tokenization_correctness():
    """Verify async wrapper produces identical results to original function"""
    print("\nTesting tokenization correctness...")

    tokenizer = MistralTokenizer.from_pretrained(
        "mistralai/Mistral-7B-Instruct-v0.3"
    )

    messages = [MEDIUM_PAYLOAD]

    # Original sync function (unchanged)
    sync_tokens = apply_mistral_chat_template(tokenizer, messages, tools=None)

    # New async wrapper
    async_tokens = await async_apply_mistral_chat_template(tokenizer, messages, tools=None)

    if sync_tokens == async_tokens:
        print(f"✓ PASS: {len(sync_tokens)} tokens match exactly")
        return True
    else:
        print(f"✗ FAIL: Token mismatch")
        print(f"  Sync:  {len(sync_tokens)} tokens")
        print(f"  Async: {len(async_tokens)} tokens")
        return False
```

## Step 4: Measure Performance Overhead

```python
async def test_performance_overhead():
    """Verify async overhead is <5%"""
    print("\nTesting performance overhead...")

    tokenizer = MistralTokenizer.from_pretrained(
        "mistralai/Mistral-7B-Instruct-v0.3"
    )

    results = []

    for name, payload in [("Small", SMALL_PAYLOAD),
                          ("Medium", MEDIUM_PAYLOAD),
                          ("Large", LARGE_PAYLOAD)]:
        messages = [payload]

        # Warmup
        for _ in range(3):
            apply_mistral_chat_template(tokenizer, messages)

        # Measure sync (original function)
        sync_times = []
        for _ in range(10):
            start = time.perf_counter()
            apply_mistral_chat_template(tokenizer, messages)
            sync_times.append(time.perf_counter() - start)

        # Measure async (new wrapper)
        async_times = []
        for _ in range(10):
            start = time.perf_counter()
            await async_apply_mistral_chat_template(tokenizer, messages)
            async_times.append(time.perf_counter() - start)

        sync_mean = sum(sync_times) / len(sync_times)
        async_mean = sum(async_times) / len(async_times)
        overhead = (async_mean - sync_mean) / sync_mean

        status = "✓ PASS" if overhead < 0.05 else "✗ FAIL"
        print(f"  {name:6} payload: {status} - Overhead: {overhead:+.1%} "
              f"(sync: {sync_mean:.4f}s, async: {async_mean:.4f}s)")

        results.append(overhead < 0.05)

    return all(results)
```

## Step 5: Run All Tests

```python
async def main():
    """Run all validation tests"""
    print("=" * 60)
    print("Mistral Tokenizer Async Fix Validation")
    print("=" * 60)

    results = []
    results.append(await test_event_loop_not_blocked())
    results.append(await test_tokenization_correctness())
    results.append(await test_performance_overhead())

    print("\n" + "=" * 60)
    if all(results):
        print("✓ ALL TESTS PASSED - Fix verified")
    else:
        print("✗ SOME TESTS FAILED - Fix incomplete")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(main())
```

## Expected Output (Success)

```
============================================================
Mistral Tokenizer Async Fix Validation
============================================================
Testing event loop responsiveness...
✓ PASS: Event loop never blocked

Testing tokenization correctness...
✓ PASS: 12847 tokens match exactly

Testing performance overhead...
  Small  payload: ✓ PASS - Overhead: +2.3% (sync: 0.0012s, async: 0.0012s)
  Medium payload: ✓ PASS - Overhead: +1.8% (sync: 0.0543s, async: 0.0553s)
  Large  payload: ✓ PASS - Overhead: +0.9% (sync: 0.2876s, async: 0.2902s)

============================================================
✓ ALL TESTS PASSED - Fix verified
============================================================
```

## Troubleshooting

### Event Loop Still Blocks
- Check that `async_apply_mistral_chat_template` function exists in `chat_utils.py`
- Verify `asyncio.get_event_loop().run_in_executor()` is being used, not direct call
- Ensure ThreadPoolExecutor is initialized at module level with max_workers=1

### Token Mismatch
- Verify `async_apply_mistral_chat_template` calls `apply_mistral_chat_template` internally
- Check that all function arguments are passed through correctly
- Test with different payload sizes to isolate issue

### High Overhead (>5%)
- Verify ThreadPoolExecutor `_mistral_tokenizer_executor` is reused, not created per-request
- Check for unnecessary async overhead in calling code
- Profile with `py-spy` to identify bottleneck
- Ensure executor has warmed up (may see higher overhead on first call)

## Success Criteria

All three test categories must pass:
- ✓ Event loop responsiveness (no >100ms blocks)
- ✓ Tokenization correctness (byte-exact token match)
- ✓ Performance overhead (<5% for all payload sizes)

## Next Steps

After verifying the fix:
1. Run vLLM's full test suite: `pytest tests/`
2. Deploy to staging environment
3. Monitor health check latency under production load
4. Check Kubernetes pod stability (no liveness probe failures)
