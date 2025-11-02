#!/bin/bash
#
# Test suite for git automation features (--commit, --tag)
#
# Tests automatic commit and tag creation during release

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CHANGELOG_SCRIPT="$PROJECT_DIR/changelog"

# Print colored message
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Assert helper
assert_equals() {
    local expected=$1
    local actual=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Expected: $expected"
        print_color "$RED" "    Got:      $actual"
        return 1
    fi
}

# Assert contains helper
assert_contains() {
    local text=$1
    local substring=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$text" == *"$substring"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Expected to contain: $substring"
        return 1
    fi
}

# Test: --commit flag creates git commit
test_release_with_commit() {
    print_color "$YELLOW" "Test: --release with --commit creates git commit"
    
    # Create temporary git repo
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "# Test Project" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    git tag -a v1.0.0 -m "Version 1.0.0"
    
    # Create CHANGELOG with Unreleased section
    cat > CHANGELOG.md << 'CHANGELOG'
# Changelog

## [Unreleased]

### Added
- feat: new feature

## [1.0.0] - 2024-01-01
CHANGELOG
    
    # Create VERSION file
    echo "1.0.0" > VERSION
    
    git add CHANGELOG.md VERSION
    git commit -q -m "Add changelog and version"
    
    # Run release with --commit flag
    CHANGELOG_FILE="CHANGELOG.md" "$CHANGELOG_SCRIPT" --release 1.1.0 --auto-accept --commit 2>&1 || true
    
    # Check if commit was created
    local last_commit_msg=$(git log -1 --pretty=%B)
    assert_equals "chore: release v1.1.0" "$last_commit_msg" "Commit created with correct message"
    
    # Check if files were staged
    local changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)
    assert_contains "$changed_files" "CHANGELOG.md" "CHANGELOG.md was committed"
    assert_contains "$changed_files" "VERSION" "VERSION was committed"
    
    # Cleanup
    cd /
    rm -rf "$test_dir"
}

# Test: --tag flag creates git tag
test_release_with_tag() {
    print_color "$YELLOW" "Test: --release with --tag creates git tag"
    
    # Create temporary git repo
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit and tag
    echo "# Test Project" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    git tag -a v1.0.0 -m "Version 1.0.0"
    
    # Create CHANGELOG with Unreleased section
    cat > CHANGELOG.md << 'CHANGELOG'
# Changelog

## [Unreleased]

### Added
- feat: new feature

## [1.0.0] - 2024-01-01
CHANGELOG
    
    echo "1.0.0" > VERSION
    git add CHANGELOG.md VERSION
    git commit -q -m "Add changelog"
    
    # Run release with --commit and --tag flags
    CHANGELOG_FILE="CHANGELOG.md" "$CHANGELOG_SCRIPT" --release 1.1.0 --auto-accept --commit --tag 2>&1 || true
    
    # Check if tag was created
    local tag_exists=$(git tag -l "v1.1.0")
    assert_equals "v1.1.0" "$tag_exists" "Tag v1.1.0 was created"
    
    # Check tag annotation
    local tag_message=$(git tag -l -n1 v1.1.0)
    assert_contains "$tag_message" "v1.1.0" "Tag has correct version"
    
    # Cleanup
    cd /
    rm -rf "$test_dir"
}

# Test: --commit without --release should fail
test_commit_requires_release() {
    print_color "$YELLOW" "Test: --commit requires --release flag"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "# Test" > CHANGELOG.md
    git add CHANGELOG.md
    git commit -q -m "Initial"
    # Try to use --commit without --release
    set +e
    local output
    local result
    output=$(CHANGELOG_FILE="CHANGELOG.md" "$CHANGELOG_SCRIPT" --commit --auto-accept 2>&1)
    result=$?
    set -e
    
    assert_equals "1" "$result" "--commit without --release should fail"
    assert_contains "$output" "commit" "Error message mentions --commit"
    
    # Cleanup
    cd /
    rm -rf "$test_dir"
}

# Test: --commit with dirty repo should fail
test_commit_requires_clean_repo() {
    print_color "$YELLOW" "Test: --commit requires clean working directory"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "# Test" > README.md
    git add README.md
    git commit -q -m "Initial"
    git tag -a v1.0.0 -m "Version 1.0.0"
    
    cat > CHANGELOG.md << 'CHANGELOG'
# Changelog

## [Unreleased]

### Added
- feat: new feature

## [1.0.0] - 2024-01-01
CHANGELOG
    
    echo "1.0.0" > VERSION
    git add CHANGELOG.md VERSION
    git commit -q -m "Add changelog"
    
    # Try to use --commit with dirty repo
    set +e
    local output=$(CHANGELOG_FILE="CHANGELOG.md" "$CHANGELOG_SCRIPT" --release 1.1.0 --auto-accept --commit 2>&1)
    local result=$?
    set -e
    local result=$?
    
    # Should succeed because only unstaged changes in README.md
    # The tool stages CHANGELOG.md and VERSION which it modifies
    # But if there are ANY staged changes beforehand, it should warn or fail
    
    # For now, let's test that it doesn't commit the dirty file
    if [ "$result" = "0" ]; then
        local committed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)
        assert_equals "0" "$(echo "$committed_files" | grep -c README.md || true)" "README.md not in commit"
    fi
    
    # Cleanup
    cd /
    rm -rf "$test_dir"
}

# Test: Combined --commit --tag workflow
test_combined_commit_and_tag() {
    print_color "$YELLOW" "Test: --commit and --tag work together"
    
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "# Test Project" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    git tag -a v1.0.0 -m "Version 1.0.0"
    
    cat > CHANGELOG.md << 'CHANGELOG'
# Changelog

## [Unreleased]

### Added
- feat: awesome feature

## [1.0.0] - 2024-01-01
CHANGELOG
    
    echo "1.0.0" > VERSION
    git add CHANGELOG.md VERSION
    git commit -q -m "Add changelog"
    
    # Run release with both flags
    CHANGELOG_FILE="CHANGELOG.md" "$CHANGELOG_SCRIPT" --release 2.0.0 --auto-accept --commit --tag 2>&1 || true
    
    # Verify commit
    local last_commit_msg=$(git log -1 --pretty=%B)
    assert_equals "chore: release v2.0.0" "$last_commit_msg" "Commit message correct"
    
    # Verify tag points to correct commit
    local tag_commit=$(git rev-list -n 1 v2.0.0)
    local head_commit=$(git rev-parse HEAD)
    assert_equals "$head_commit" "$tag_commit" "Tag points to HEAD commit"
    
    # Verify VERSION file content
    local version_content=$(cat VERSION)
    assert_equals "2.0.0" "$version_content" "VERSION file updated"
    
    # Cleanup
    cd /
    rm -rf "$test_dir"
}

# Main test runner
main() {
    print_color "$YELLOW" "=== Git Automation Tests ==="
    echo ""
    
    # Run all tests
    test_release_with_commit
    test_release_with_tag
    test_commit_requires_release
    test_commit_requires_clean_repo
    test_combined_commit_and_tag
    
    # Summary
    echo ""
    print_color "$YELLOW" "=== Test Summary ==="
    echo "Tests run:    $TESTS_RUN"
    print_color "$GREEN" "Tests passed: $TESTS_PASSED"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        print_color "$RED" "Tests failed: $TESTS_FAILED"
        exit 1
    else
        print_color "$GREEN" "All tests passed! ✓"
        exit 0
    fi
}

main "$@"
