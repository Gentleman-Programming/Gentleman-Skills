---

name: jest
description: >
Jest testing patterns and best practices for modern TypeScript/JavaScript projects.
Trigger: Writing, refactoring, or reviewing Jest unit/integration tests (matchers, async, mocks, timers, snapshots, setup/teardown).
license: Apache-2.0
metadata:
author: gentleman-programming
version: "1.0"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
-----------------------------------------------------------------------------

## When to Use

Use this skill when you are:

* Adding or refactoring Jest tests.
* Designing a mocking strategy (unit vs integration boundaries).
* Testing async code (Promises, async/await, callbacks).
* Testing time-dependent logic (timers, debouncing, polling).
* Introducing snapshots or maintaining existing snapshots.
* Standardizing setup/teardown and test isolation.

---

## Critical Patterns

### 1) Determinism and isolation (MUST)

* **MUST** keep tests deterministic: no real network, no real time, no shared global mutable state.
* **MUST** isolate side effects:

  * Prefer dependency injection.
  * Reset/clear mocks between tests.
  * Use setup/teardown hooks (`beforeEach`, `afterEach`, etc.). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/setup-teardown))

### 2) Arrange / Act / Assert (MUST)

* **MUST** structure each test as:

  * Arrange (inputs + dependencies)
  * Act (execute)
  * Assert (observable outcome)
* Avoid “mega tests” that validate many behaviors at once.

### 3) Matchers: be precise (MUST)

* **MUST** choose the most precise matcher:

  * `toBe` for exact equality (uses `Object.is`).
  * `toEqual` for deep equality (objects/arrays).
  * `toBeCloseTo` for floats.
  * `toThrow` requires wrapping the call in a function. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/using-matchers))

### 4) Async tests: don’t leak promises (MUST)

* **MUST** test async code using **one** of these correct patterns:

  1. Return the Promise
  2. Use `async/await`
  3. Use `done` callback **only** for legacy callback APIs
* **MUST** assert errors explicitly:

  * `await expect(promise).rejects.toThrow(...)`
  * or `return expect(promise).rejects...`
* **MUST** prevent false positives:

  * Use `expect.assertions(n)` or `expect.hasAssertions()` when appropriate. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/asynchronous))

### 5) Setup/teardown: keep state clean (MUST)

* **MUST** use lifecycle hooks:

  * `beforeEach/afterEach` for per-test setup/cleanup.
  * `beforeAll/afterAll` for expensive one-time setup.
* **MUST** keep cleanup symmetrical (what you create, you destroy). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/setup-teardown))

### 6) Mocking strategy: mock boundaries, not implementation details (MUST)

* **MUST** prefer mocking system boundaries:

  * HTTP, DB, filesystem, timers, external SDKs.
* **SHOULD** avoid mocking internal helpers if behavior can be tested through public API.
* **MUST** prefer `jest.spyOn` when you want to observe/override a real method.
* **MUST** understand module mocks:

  * `jest.mock()` replaces a module.
  * manual mocks live in `__mocks__/`.
  * use `jest.requireActual()` when you need partial mocking. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/mock-functions))

### 7) Mock functions: verify behavior, not noise (MUST)

* **MUST** assert the important interactions:

  * `toHaveBeenCalledTimes`, `toHaveBeenCalledWith`, `toHaveBeenNthCalledWith`.
* **MUST** keep call assertions focused (avoid over-specifying order unless it matters).
* **MUST** reset mock state between tests (`clearAllMocks`/`resetAllMocks`/`restoreAllMocks`) according to repo policy. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/mock-functions))

### 8) Timers: use fake timers for time-based logic (MUST)

* **MUST** use `jest.useFakeTimers()` for debounce/throttle/polling logic.
* **MUST** advance time explicitly (`advanceTimersByTime`, `runAllTimers`).
* **MUST** restore real timers after the test to avoid cross-test contamination. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/timer-mocks))

### 9) Snapshots: only for stable output (SHOULD)

* **SHOULD** use snapshots for stable, meaningful serialized output.
* **SHOULD NOT** snapshot large or frequently-changing structures.
* **MUST** keep snapshots small; prefer targeted assertions when possible.
* Use inline/property matchers to reduce brittleness. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/snapshot-testing))

### 10) Platform/environment: choose correctly (MUST)

* **MUST** select the correct `testEnvironment`:

  * `node` for backend/library code.
  * `jsdom` for DOM-dependent code.
* **MUST** avoid accidental DOM dependencies in node tests. ([archive.jestjs.io](https://archive.jestjs.io/docs/en/jest-platform))

---

## Code Examples

### Matchers (precision)

```ts
test('deep equality for objects', () => {
  expect({ a: 1 }).toEqual({ a: 1 });
  expect({ a: 1 }).not.toBe({ a: 1 }); // different references
});

test('float comparisons', () => {
  expect(0.1 + 0.2).toBeCloseTo(0.3);
});

test('throws requires wrapping function', () => {
  const fn = () => {
    throw new Error('boom');
  };
  expect(fn).toThrow(/boom/);
});
```

### Async (preferred patterns)

```ts
test('async/await', async () => {
  const result = await Promise.resolve(42);
  expect(result).toBe(42);
});

test('rejects', async () => {
  await expect(Promise.reject(new Error('boom'))).rejects.toThrow('boom');
});

test('assertions count (prevents false positives)', async () => {
  expect.assertions(1);
  try {
    await Promise.reject(new Error('boom'));
  } catch {
    expect(true).toBe(true);
  }
});
```

### Setup/teardown + cleanup

```ts
afterEach(() => {
  jest.clearAllMocks();
});
```

### Spies and module mocks (safe partial mocking)

```ts
import * as http from './http';

test('spyOn a real method', async () => {
  jest.spyOn(http, 'get').mockResolvedValue({ ok: true } as any);

  await loadData();

  expect(http.get).toHaveBeenCalledTimes(1);
});

jest.mock('./config', () => {
  const actual = jest.requireActual('./config');
  return {
    ...actual,
    FEATURE_FLAG: true,
  };
});
```

### Timers (debounce)

```ts
beforeEach(() => {
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});

test('debounces', () => {
  const fn = jest.fn();
  const debounced = debounce(fn, 200);

  debounced();
  debounced();

  jest.advanceTimersByTime(200);

  expect(fn).toHaveBeenCalledTimes(1);
});
```

### Snapshots (small and intentional)

```ts
test('serializes stable output', () => {
  const output = { version: 1, items: ['a', 'b'] };
  expect(output).toMatchSnapshot();
});
```

---

## Commands

```bash
# Run all tests
npm test

# Run a single file
npx jest path/to/file.test.ts

# Watch mode
npx jest --watch

# Update snapshots
npx jest -u

# Coverage
npx jest --coverage

# CI-friendly (reduces flakiness in some environments)
npx jest --runInBand
```

---

## Resources

* **Matchers / expect** (precision and choosing the right matcher). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/using-matchers))
* **Async testing** (promises, async/await, callbacks, assertions count). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/asynchronous))
* **Setup & teardown** (hooks and isolation). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/setup-teardown))
* **Mock functions & API** (`jest.fn`, call assertions, mock APIs). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/mock-functions))
* **Manual & class mocks** (`__mocks__`, module/class mocking patterns). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/manual-mocks))
* **Timers** (fake timers, advancing time). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/timer-mocks))
* **Snapshots** (when to use and how to keep them stable). ([archive.jestjs.io](https://archive.jestjs.io/docs/en/snapshot-testing))
* **Mocking best practices** (boundary-first mocking strategy). ([medium.com](https://medium.com/%40anjisingavaram/best-practices-for-mocking-in-unit-tests-using-jest-f8072e482864))
