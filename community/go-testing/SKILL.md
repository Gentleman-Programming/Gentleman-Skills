---
name: go-testing
description: >
  Go testing patterns with stdlib, testify, and Bubbletea TUI testing.
  Trigger: When writing Go tests, when testing Go packages, when building TUIs with Bubbletea.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- Writing unit tests, table-driven tests, or benchmarks in Go
- Testing packages with `testing.T`, `testing.B`, or `testing.F`
- Building TUIs with Bubbletea and needing to test views/update logic
- Using testify assertions or suite patterns
- Setting up test fixtures, mocks, or test containers

## Critical Patterns

- **Table-driven tests are the default**: never duplicate test logic across
  separate test functions — put cases in a `[]struct` table.
- **`require` vs `assert`**: `require` stops the test immediately (preconditions);
  `assert` continues but reports (assertions).
- **Suites for shared setup**: use a testify suite (`SetupSuite`, `TearDownSuite`,
  `SetupTest`) when tests share setup and teardown.
- **Automatic cleanup**: mark helpers with `t.Helper()` and use `t.TempDir()` /
  `t.Cleanup()`; never rely on manual cleanup.
- **Test behavior, not internals**: assert on exported behavior (e.g.,
  `DisplayName()`), never on private fields.
- **No `init()` in tests**: it runs for every test in the package, including
  unrelated ones.
- **TUI logic without rendering**: drive `Model.Update()` with `tea.Msg` values and
  assert on the returned model and command.
- **Real dependencies via test containers**: use testcontainers-go with a
  listening-port wait strategy and `t.Cleanup` for termination.

## Table-Driven Tests (REQUIRED)

Always use table-driven tests for multiple test cases. Never duplicate test logic.

```go
// ✅ GOOD: Table-driven test
func TestCalculateDiscount(t *testing.T) {
	tests := []struct {
		name     string
		price    float64
		quantity int
		want     float64
	}{
		{"no discount under 10", 100.0, 5, 0},
		{"10% discount at 10", 100.0, 10, 100.0},
		{"20% discount at 20", 100.0, 20, 400.0},
		{"zero quantity", 100.0, 0, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := CalculateDiscount(tt.price, tt.quantity)
			if got != tt.want {
				t.Errorf("CalculateDiscount(%v, %v) = %v, want %v",
					tt.price, tt.quantity, got, tt.want)
			}
		})
	}
}
```

```go
// ❌ NEVER: Duplicated test logic
func TestCalculateDiscount_NoDiscount(t *testing.T) {
	got := CalculateDiscount(100.0, 5)
	if got != 0 { t.Error("...") }
}
func TestCalculateDiscount_WithDiscount(t *testing.T) {
	got := CalculateDiscount(100.0, 10)
	if got != 100.0 { t.Error("...") }
}
```

## Testify Assertions

Use testify for cleaner assertions when the project already uses it.

```go
import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestParseConfig(t *testing.T) {
	cfg, err := ParseConfig("test.yaml")

	require.NoError(t, err)    // fail immediately if error
	assert.Equal(t, "dev", cfg.Env)
	assert.True(t, cfg.Debug)
	assert.Contains(t, cfg.AllowedHosts, "localhost")
}

// Use require for preconditions that must pass
func TestServerStart(t *testing.T) {
	cfg, err := LoadConfig()
	require.NoError(t, err, "config must load before server test")

	srv, err := NewServer(cfg)
	require.NoError(t, err)
	assert.NotNil(t, srv)
}
```

**Rule**: `require` = stop test immediately (precondition). `assert` = continue but report (assertion).

## Testify Suite

Use suites for tests that share setup/teardown.

```go
type UserServiceTestSuite struct {
	suite.Suite
	db     *sql.DB
	userSvc *UserService
}

func (s *UserServiceTestSuite) SetupSuite() {
	s.db = testutil.OpenTestDB()
	s.userSvc = NewUserService(s.db)
}

func (s *UserServiceTestSuite) TearDownSuite() {
	s.db.Close()
}

func (s *UserServiceTestSuite) SetupTest() {
	// Clear data between tests
	s.db.Exec("TRUNCATE users")
}

func (s *UserServiceTestSuite) TestCreateUser() {
	user, err := s.userSvc.Create("alice@example.com")
	s.NoError(err)
	s.Equal("alice@example.com", user.Email)
}

func TestUserService(t *testing.T) {
	suite.Run(t, new(UserServiceTestSuite))
}
```

## Benchmarks

```go
func BenchmarkMapLarge(b *testing.B) {
	data := make([]int, 100000)
	for i := range data {
		data[i] = i
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		result := make(map[int]int, len(data))
		for _, v := range data {
			result[v] = v * 2
		}
	}
}

// Run: go test -bench=. -benchmem
```

## Fuzzing (Go 1.18+)

```go
func FuzzParseJSON(f *testing.F) {
	// Add seed corpus
	f.Add([]byte(`{"key": "value"}`))
	f.Add([]byte(`[]`))
	f.Add([]byte(`null`))

	f.Fuzz(func(t *testing.T, data []byte) {
		var result any
		err := json.Unmarshal(data, &result)
		if err != nil {
			return // skip invalid input
		}
		// Re-marshal should not panic
		_, err = json.Marshal(result)
		if err != nil {
			t.Errorf("roundtrip failed: %v", err)
		}
	})
}
```

## Bubbletea TUI Testing

Test Model update logic without rendering.

```go
func TestModel_Init(t *testing.T) {
	m := InitialModel()
	cmd := m.Init()
	assert.Nil(t, cmd) // no startup command
}

func TestModel_KeyPress(t *testing.T) {
	m := InitialModel()

	// Simulate key press
	msg := tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'j'}}
	updated, cmd := m.Update(msg)

	newModel := updated.(model)
	assert.Equal(t, 1, newModel.cursor)
	assert.Nil(t, cmd)
}

func TestModel_Quit(t *testing.T) {
	m := InitialModel()
	msg := tea.KeyMsg{Type: tea.KeyCtrlC}
	updated, cmd := m.Update(msg)

	// Update returns the same model; quitting is signalled by the command.
	assert.Equal(t, m, updated)

	if assert.NotNil(t, cmd) {
		_, ok := cmd().(tea.QuitMsg)
		assert.True(t, ok) // command produces tea.QuitMsg
	}
}

func TestModel_View(t *testing.T) {
	m := InitialModel()
	m.items = []string{"Item 1", "Item 2"}
	m.cursor = 0

	view := m.View()
	assert.Contains(t, view, "Item 1")
	assert.Contains(t, view, ">") // cursor indicator
}
```

## Test Helpers

```go
// testutil/helpers.go
func OpenTestDB(t *testing.T) *sql.DB {
	t.Helper()
	db, err := sql.Open("sqlite", ":memory:")
	require.NoError(t, err)
	t.Cleanup(func() { db.Close() })
	return db
}

func TempDir(t *testing.T) string {
	t.Helper()
	dir := t.TempDir() // auto-cleanup
	return dir
}

// Usage in tests:
func TestSomething(t *testing.T) {
	db := OpenTestDB(t)
	dir := TempDir(t)
	// no cleanup needed — t.Cleanup handles it
}
```

## Test Containers

```go
import (
	"testing"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func TestWithPostgres(t *testing.T) {
	ctx := context.Background()

	req := testcontainers.ContainerRequest{
		Image:        "postgres:16",
		ExposedPorts: []string{"5432/tcp"},
		Env: map[string]string{
			"POSTGRES_DB":       "testdb",
			"POSTGRES_PASSWORD": "test",
		},
		WaitingFor: wait.ForListeningPort("5432/tcp"),
	}

	container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	require.NoError(t, err)
	t.Cleanup(func() { container.Terminate(ctx) })

	host, _ := container.Host(ctx)
	port, _ := container.MappedPort(ctx, "5432")

	dsn := fmt.Sprintf("postgres://postgres:test@%s:%s/testdb?sslmode=disable", host, port.Port())
	// use dsn...
}
```

## Anti-Patterns

### Don't: Use `init()` in tests

```go
// ❌ BAD: init() runs for ALL tests in package, even unrelated ones
func init() {
	os.Setenv("TESTING", "1")
}
```

### Don't: Test implementation details

```go
// ❌ BAD: testing internal state
func TestUserInternalState(t *testing.T) {
	u := &user{name: "alice", internalScore: 42}
	assert.Equal(t, 42, u.internalScore) // don't test internals
}

// ✅ GOOD: test behavior
func TestUserDisplayName(t *testing.T) {
	u := NewUser("alice")
	assert.Equal(t, "Alice", u.DisplayName())
}
```

### Don't: Skip cleanup

```go
// ❌ BAD: manual cleanup
func TestTempFile(t *testing.T) {
	f, _ := os.CreateTemp("", "test")
	// forget to cleanup

// ✅ GOOD: use t.Cleanup or t.TempDir
func TestTempFile(t *testing.T) {
	f, _ := os.CreateTemp(t.TempDir(), "test")
	// auto-cleaned up
}
```

## Run Commands

```bash
go test ./...                    # all tests
go test -v ./pkg/...             # verbose
go test -run TestCalculate       # by name
go test -bench=. -benchmem       # benchmarks
go test -fuzz=FuzzParseJSON      # fuzzing
go test -cover                   # coverage %
go test -race                    # race detector
go test -count=1 ./...           # disable cache
```

## Code Examples

### Example 1: Table-Driven Test (Testify)

```go
package pricing

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// CalculateDiscount applies a volume discount to a line total.
func CalculateDiscount(price float64, quantity int) float64 {
	switch {
	case quantity >= 20:
		return price * float64(quantity) * 20 / 100
	case quantity >= 10:
		return price * float64(quantity) * 10 / 100
	default:
		return 0
	}
}

func TestCalculateDiscount(t *testing.T) {
	tests := []struct {
		name     string
		price    float64
		quantity int
		want     float64
	}{
		{"no discount under 10", 100.0, 5, 0},
		{"10% discount at 10", 100.0, 10, 100.0},
		{"20% discount at 20", 100.0, 20, 400.0},
		{"zero quantity", 100.0, 0, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := CalculateDiscount(tt.price, tt.quantity)
			assert.Equal(t, tt.want, got)
		})
	}
}
```

### Example 2: Bubbletea TUI Test (No Rendering)

```go
package ui

import (
	"testing"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/stretchr/testify/assert"
)

// Minimal model matching the update/view logic under test.
type model struct {
	cursor int
	items  []string
}

func InitialModel() model {
	return model{items: []string{"Item 1", "Item 2"}}
}

func (m model) Init() tea.Cmd { return nil }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyRunes:
			if msg.String() == "j" {
				m.cursor++
			}
		case tea.KeyCtrlC:
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m model) View() string {
	out := ""
	for i, item := range m.items {
		if i == m.cursor {
			out += "> " + item + "\n"
		} else {
			out += "  " + item + "\n"
		}
	}
	return out
}

func TestModel_KeyPress(t *testing.T) {
	m := InitialModel()

	msg := tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'j'}}
	updated, cmd := m.Update(msg)

	newModel := updated.(model)
	assert.Equal(t, 1, newModel.cursor)
	assert.Nil(t, cmd)
}

func TestModel_View(t *testing.T) {
	m := InitialModel()

	view := m.View()
	assert.Contains(t, view, "Item 1")
	assert.Contains(t, view, ">") // cursor indicator
}
```

## References

- [Go testing package](https://pkg.go.dev/testing)
- [Testify](https://github.com/stretchr/testify)
- [Testcontainers Go](https://golang.testcontainers.org/)
- [Bubbletea](https://github.com/charmbracelet/bubbletea)
