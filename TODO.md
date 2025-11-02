# TODO

## Active Refactoring: --commit/--tag Feature (In Progress)

We're refactoring the `--commit` and `--tag` feature implementation using incremental TDD.

### Completed Steps ✅

- **Step 1**: `check_git_clean()` function - 3 tests passing
  - Validates repo state before committing
  - Checks both tracked and untracked changes
  - Commit: `8c54746`

- **Step 2**: `stage_release_files()` function - 7 tests passing
  - Stages only CHANGELOG.md, VERSION, README.md
  - Prevents accidental staging of other files
  - Commit: `2e6615b`

- **Step 3**: `build_release_commit_message()` function - 5 tests passing
  - Formats conventional commit message: "chore: release vX.Y.Z"
  - Commit: `217d466`

### Remaining Steps 🔄

- [ ] **Step 4**: Extract tag annotation builder
  - Create `build_tag_annotation()` function
  - Format: "Release version X.Y.Z"
  - Write tests first (TDD)
  - Update `create_release_tag()` to use it

- [ ] **Step 5**: Add user feedback messages
  - Create `print_commit_summary()` function
  - Create `print_tag_summary()` function
  - Add colored output for user visibility
  - Show what files were committed, commit hash, tag name

- [ ] **Step 6**: Refactor error handling
  - Check if repo is dirty before committing
  - Handle commit failures gracefully
  - Check if tag already exists
  - Provide clear error messages with exit codes

- [ ] **Step 7**: Integration test full workflow
  - End-to-end test using all refactored pieces
  - Verify nothing broke
  - Test error cases

### Benefits of This Approach

Each step:
- Takes ~5-10 minutes
- Has its own tests
- Is independently committable
- Makes debugging easy (single focus)
- Follows proper TDD: RED → GREEN → COMMIT

### Test Coverage

Current: **15 unit tests + 11 integration tests = 26 tests passing**

Target: ~35-40 tests when complete

### References

- Test files: `tests/test_refactor_step*.sh`
- Original implementation: `tests/test_git_automation.sh`
- TDD documentation: `.github/copilot-instructions.md` (TDD section)

---

**Note**: This refactoring demonstrates the TDD baby steps approach documented in our copilot instructions. Each step is small, focused, and testable.
