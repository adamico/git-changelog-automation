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
