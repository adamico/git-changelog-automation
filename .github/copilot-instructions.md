# Copilot Instructions for git-changelog-automation

## Project Overview
This is a bash-based tool for automatically generating and managing changelogs from conventional commits. The tool parses git history, categorizes commits by type (feat, fix, docs, etc.), and maintains a structured CHANGELOG.md file with proper version sections.

## Critical Rules

### CHANGELOG Management
**NEVER manually edit CHANGELOG.md files.** Always use the changelog tool commands:
- Use `changelog` to generate unreleased changes from git history
- Use `changelog --release VERSION` to convert unreleased content to a versioned release
- Use `changelog --clean` to remove duplicate entries (for fixing corrupted CHANGELOGs)
- Manual edits to CHANGELOG.md defeat the purpose of automation and create inconsistencies

### Tool Usage Workflow
1. Make git commits following conventional commit format
2. Run `changelog` to generate unreleased content from commits
3. Run `changelog --release X.Y.Z` to release the version
4. The tool automatically updates VERSION file and README.md badge
5. If duplicates exist, run `changelog --clean` to fix them

### When Bugs Appear in Generated CHANGELOGs
- **DO NOT** manually fix the CHANGELOG
- **DO** fix the tool's code generation logic
- **DO** use `changelog --clean` if duplicates need removal
- **DO** regenerate the CHANGELOG using the fixed tool
- The tool should handle all edge cases programmatically

## Key Files
- `changelog`: Main bash script (~900 lines)
  * Lines 149-184: `clean_duplicates()` - Removes duplicate commit entries
  * Lines 186-195: `get_existing_commits()` - Extracts commits from existing CHANGELOG
  * Lines 197-306: `generate_changelog()` - Main changelog generation with deduplication
  * Lines 400-475: `release_version()` - Converts unreleased to versioned content
  * Lines 468-472: VERSION file creation/update
  * Lines 425+: `update_readme_badge()` - Updates README version badge
  * Lines 700+: Command-line argument parsing

- `tests/test_changelog.sh`: Test suite (28 tests)
  * Tests for generation, deduplication, VERSION file, README badge updates

## Architecture

### Deduplication System
The tool implements a two-stage deduplication system:
1. **get_existing_commits()**: Extracts commit messages already in CHANGELOG
2. **deduplicate_commits()**: Inline function filters out commits already documented
3. Applied to all 11 commit types before adding to changelog

### Commit Types
Supports 11 conventional commit types:
- feat, fix, docs, refactor, perf, test, build, ci, style, chore, revert

### Auto-Sync Feature
The tool automatically detects missing version tags in CHANGELOG and adds placeholder sections. This helps keep CHANGELOG in sync with git tags.

## Development Workflow
1. **Make changes** to the changelog script
2. **Run tests**: `./tests/test_changelog.sh`
3. **Test manually** on a real project (e.g., PicoTestDriver)
4. **Generate changelog**: `changelog --auto-accept`
5. **Release version**: `changelog --release X.Y.Z --auto-accept`
6. **Commit and tag**: `git commit -m "..." && git tag vX.Y.Z`

## Terminal Command Patterns (CRITICAL)

When working with GitHub Copilot in VS Code, follow these patterns for auto-approvable commands:

### ✅ AUTO-APPROVABLE PATTERNS (BEST TO WORST)

**Pattern 1: Check Cwd, then run simple commands (BEST)**
```bash
# The terminal maintains a persistent working directory (Cwd)
# Check context: Cwd: /home/user/project

# If already in the right directory, just run the command:
git status
ls -la
git commit -m "message"

# If not in the right directory, change once:
cd /target/dir

# Then run simple commands (all auto-approved):
git status
ls -la
```

**Pattern 2: Subshell for one-off operations (GOOD)**
```bash
# Single operation in different directory without changing terminal state
(cd /target/dir && command1 && command2)

# Example:
(cd ~/project && git status && wc -l CHANGELOG.md)
```

### ❌ CANNOT AUTO-APPROVE

**Avoid these patterns:**
```bash
# This CANNOT be auto-approved by Copilot
cd /path && command

# This CANNOT be auto-approved
cd /path && command1 && command2
```

### Why This Matters
- Commands starting with `cd /path &&` cannot be auto-approved in VS Code
- Simple commands ARE auto-approved when terminal is already in the right directory
- Check the `Cwd` in context before running commands
- Use `cd` once to change directory, then run multiple simple commands
- Subshells `(cd ... && ...)` work for one-off operations but don't persist directory changes

### Best Practice Workflow
1. **Check context**: Look at `Cwd: /current/path` in the context
2. **If in right directory**: Run simple commands directly (auto-approved)
3. **If wrong directory**: Run `cd /target/path` once
4. **Then**: All subsequent simple commands are auto-approved
5. **For one-off**: Use subshell `(cd /path && command)` if you don't want to change terminal state

### Enforcement
**ALWAYS check Cwd first**. If terminal is already in the right directory, just run simple commands. Never use `cd /path && command` as a single command string.

## Common Commands
```bash
# Generate unreleased content
changelog

# Generate and auto-accept
changelog --auto-accept
changelog -y

# Generate from specific tag
changelog v1.0.0

# Generate between two tags
changelog v1.0.0 v1.1.0

# Release a version
changelog --release 1.2.0
changelog -r 1.2.0 -y

# Clean duplicate entries
changelog --clean

# Install git hooks
changelog --install-hooks
```

## Testing
- **Unit tests**: `./tests/test_changelog.sh` (28 tests)
- Tests cover: generation, deduplication, VERSION file, README badge, edge cases
- Always run tests before committing changes

## Integration Points
- **VERSION file**: Single source of truth for version number
- **README.md badge**: Auto-updated on release (shields.io format)
- **Git hooks**: commit-msg validation, prepare-commit-msg reminders
- **Conventional commits**: Parses commit messages following conventional format

## Known Issues & Future Improvements
- The auto-sync feature can interfere with custom CHANGELOG structures
- Consider adding `--rebuild` command to regenerate entire CHANGELOG from git tags
- grep encoding issues with special characters (partially fixed with awk in --clean)

## Code Patterns
```bash
# Function definition
function_name() {
    local var_name=$1
    # implementation
}

# Print with color
print_color "$BLUE" "Message text..."

# Git log parsing
git log --pretty=format:"%s" "$git_range" | grep -E "^feat:"

# Deduplication pattern
local existing=$(get_existing_commits)
commits=$(deduplicate_commits "$commits")
```

## Best Practices
- Keep functions focused and single-purpose
- Use local variables in functions
- Always backup files before modifying (create .backup)
- Provide user feedback with colored output
- Handle edge cases (missing files, empty commits, etc.)
- Use `--auto-accept` flag for non-interactive mode (CI/CD)

---

*Remember: The tool exists to automate CHANGELOG management. If you're manually editing CHANGELOGs, the tool needs improvement, not the CHANGELOG.*

## Test-Driven Development (TDD)

### TDD Philosophy for This Project
This project follows strict TDD practices. All new features must be developed using the RED-GREEN-REFACTOR cycle with **incremental baby steps**.

### The Problem with Large TDD Cycles
**What We Learned:** Implementing the `--commit` and `--tag` flags taught us that trying to write all tests at once and implement everything together leads to:
- Hard-to-debug issues (e.g., bash exit code capture, `set -e` interactions, command substitution quirks)
- Unclear failure points (which piece actually broke?)
- Time wasted on test infrastructure instead of feature code
- Cognitive overload trying to think about too many things simultaneously

### The Baby Steps Approach (RECOMMENDED)

Break features into the smallest testable units. For the `--commit` and `--tag` feature, this would have been:

#### Step 1: Flag Parsing (5 minutes)
```bash
# Test: Does --commit flag get recognized?
test_commit_flag_exists() {
    output=$(./changelog --commit 2>&1 || true)
    # Just check it doesn't error on "unknown option"
}
```
**Implement:** Add `--commit|-c)` to case statement, set `auto_commit="false"` variable.
**Run test:** Should pass. If not, fix just the parsing.

#### Step 2: Validation Logic (10 minutes)
```bash
# Test: --commit without --release should fail
test_commit_requires_release() {
    result=$(./changelog --commit 2>&1)
    [[ $? -eq 1 ]] || fail
}
```
**Implement:** Add `if [ "$auto_commit" = "true" ] && [ "$release_mode" != "true" ]; then error; fi`
**Run test:** Should pass. Debug just validation logic if needed.

#### Step 3: File Staging (10 minutes)
```bash
# Test: Files get staged when --commit is used
test_stages_files() {
    # Don't commit yet, just test git add works
    git diff --cached --name-only | grep CHANGELOG.md
}
```
**Implement:** Add `git add CHANGELOG.md VERSION README.md`
**Run test:** Should pass. Fix just staging logic.

#### Step 4: Commit Creation (10 minutes)
```bash
# Test: Commit has correct message format
test_commit_message() {
    last_commit=$(git log -1 --pretty=%B)
    [[ "$last_commit" == "chore: release v1.2.0" ]] || fail
}
```
**Implement:** Add `git commit -m "chore: release v${version}"`
**Run test:** Should pass. Fix just commit logic.

#### Step 5: Repeat for --tag (4 steps × 10 min)

**Total:** ~90 minutes with clear progress markers vs. 3+ hours debugging monolithic tests.

### Key TDD Principles for Bash Scripts

#### 1. One Assertion Per Test
```bash
# BAD: Multiple things tested at once
test_commit_and_tag() {
    # Tests commit message, tag creation, file staging, error handling
}

# GOOD: Focused single assertion
test_commit_message_format() {
    assert_equals "chore: release v1.0.0" "$(git log -1 --pretty=%B)"
}
```

#### 2. Separate Test Files by Concern
```bash
tests/
├── test_flag_parsing.sh      # Just argument parsing
├── test_validation.sh         # Just validation logic
├── test_file_operations.sh    # Just git add/commit/tag
├── test_error_handling.sh     # Just error cases
└── test_integration.sh        # End-to-end scenarios
```

#### 3. Fix Test Infrastructure First
When tests fail for infrastructure reasons (not feature reasons):
1. **STOP** implementing the feature
2. **FIX** the test infrastructure issue in isolation
3. **VERIFY** fix with a simple dummy test
4. **THEN** continue with feature TDD

**Example:** When we hit the `local` exit code issue:
```bash
# Infrastructure test (should be in tests/test_bash_helpers.sh)
test_exit_code_capture() {
    local result
    output=$(exit 1)
    result=$?  # This should be 1, not 0
    assert_equals "1" "$result"
}
```
Fix this FIRST before continuing with feature tests.

#### 4. Use Descriptive Test Names
```bash
# BAD: Unclear what's being tested
test_commit() { ... }

# GOOD: Clear expectation
test_commit_flag_requires_release_flag() { ... }
test_commit_message_follows_conventional_format() { ... }
test_commit_includes_only_release_files() { ... }
```

#### 5. Keep Tests Independent
```bash
# BAD: Tests depend on each other
test_1_setup() { ... }      # Creates state
test_2_commit() { ... }     # Uses state from test_1
test_3_tag() { ... }        # Uses state from test_2

# GOOD: Each test has own setup/teardown
test_commit_creates_proper_message() {
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    # Setup git repo
    # Run test
    # Cleanup
    cd / && rm -rf "$test_dir"
}
```

### TDD Workflow Checklist

For every new feature:

- [ ] **Break into smallest units** (aim for 5-10 steps)
- [ ] **Write ONE failing test** for first unit
- [ ] **Run test** - see it RED
- [ ] **Write minimal code** to pass (no more!)
- [ ] **Run test** - see it GREEN
- [ ] **Commit** with message: "feat(step-1): description"
- [ ] **Repeat** for next unit
- [ ] **Refactor** only after all tests pass
- [ ] **Document** the feature

### Red Flags (Stop and Decompose)

If you experience any of these, your steps are too large:
- ❌ Spending >30 minutes debugging a single test
- ❌ Not sure which part of code is causing failure
- ❌ Fighting with test infrastructure instead of feature logic
- ❌ Test has >3 assertions
- ❌ Implementation touches >2 functions
- ❌ Can't explain test failure in one sentence

**Solution:** Back up, break into smaller steps, test infrastructure separately.

### Real Example: The --commit/--tag Feature

**What we did (monolithic):**
- 5 complex tests written at once
- ~3 hours of debugging
- Issues with bash internals, exit codes, subshells
- Unclear which piece was broken

**What we should have done (baby steps):**
- 12 simple tests written incrementally
- ~1.5 hours total
- Each test takes 5-10 minutes
- Always know exactly what's broken
- Test infrastructure issues caught early with simple tests

### Testing Bash Specifics

#### Exit Code Capture
```bash
# WRONG: local combines with assignment
local result=$(command)  # $? is exit of local, not command

# RIGHT: Separate declaration and assignment
local result
result=$(command)
local exit_code=$?  # Now captures command exit code
```

#### Command Substitution
```bash
# Works: Exit code preserved in subshell
result=$(./script --flag)
echo $?  # Gets script's exit code

# Broken by: || true at end
result=$(./script --flag || true)
echo $?  # Always 0
```

#### set -e Interactions
```bash
# Test needs to capture errors without exiting
test_error_handling() {
    set +e  # Disable exit-on-error
    local result
    output=$(command_that_fails)
    result=$?
    set -e  # Re-enable
    assert_equals "1" "$result"
}
```

### When to Skip TDD

TDD is not required for:
- **Documentation** changes
- **Trivial** refactoring (renaming, formatting)
- **Experimental** prototypes (throw-away code)

But even experiments benefit from a few smoke tests!

---

**Remember:** Small steps feel slower but are faster. If debugging takes longer than writing the test, your steps are too big.

