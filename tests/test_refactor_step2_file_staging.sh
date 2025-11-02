#!/bin/bash
#
# Test Step 2: stage_release_files() function refactoring
# RED phase - These tests should FAIL until we implement the function

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CHANGELOG_SCRIPT="$PROJECT_DIR/changelog"

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

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
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Expected: $expected"
        print_color "$RED" "    Got:      $actual"
        return 1
    fi
}

assert_contains() {
    local text=$1
    local substring=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$text" | grep -q "$substring"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Expected to contain: $substring"
        print_color "$RED" "    In text: $text"
        return 1
    fi
}

test_stage_release_files_stages_changelog() {
    echo ""
    echo "Test: stage_release_files stages CHANGELOG.md"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    
    # Create initial files
    echo "v1.0.0" > VERSION
    echo "# Changelog" > CHANGELOG.md
    echo "# README" > README.md
    git add -A
    git commit -q -m "initial"
    
    # Modify files
    echo "v1.1.0" > VERSION
    echo "## v1.1.0" >> CHANGELOG.md
    echo "Updated" >> README.md
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    stage_release_files
    
    # Assert: CHANGELOG.md should be staged
    local staged
    staged=$(git diff --cached --name-only)
    assert_contains "$staged" "CHANGELOG.md" "CHANGELOG.md should be staged"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

test_stage_release_files_stages_version() {
    echo ""
    echo "Test: stage_release_files stages VERSION"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    
    # Create initial files
    echo "v1.0.0" > VERSION
    echo "# Changelog" > CHANGELOG.md
    echo "# README" > README.md
    git add -A
    git commit -q -m "initial"
    
    # Modify files
    echo "v1.1.0" > VERSION
    echo "## v1.1.0" >> CHANGELOG.md
    echo "Updated" >> README.md
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    stage_release_files
    
    # Assert: VERSION should be staged
    local staged
    staged=$(git diff --cached --name-only)
    assert_contains "$staged" "VERSION" "VERSION should be staged"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

test_stage_release_files_stages_readme() {
    echo ""
    echo "Test: stage_release_files stages README.md"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    
    # Create initial files
    echo "v1.0.0" > VERSION
    echo "# Changelog" > CHANGELOG.md
    echo "# README" > README.md
    git add -A
    git commit -q -m "initial"
    
    # Modify files
    echo "v1.1.0" > VERSION
    echo "## v1.1.0" >> CHANGELOG.md
    echo "Updated" >> README.md
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    stage_release_files
    
    # Assert: README.md should be staged
    local staged
    staged=$(git diff --cached --name-only)
    assert_contains "$staged" "README.md" "README.md should be staged"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

test_stage_release_files_only_stages_release_files() {
    echo ""
    echo "Test: stage_release_files only stages release files, not other changes"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    
    # Create initial files
    echo "v1.0.0" > VERSION
    echo "# Changelog" > CHANGELOG.md
    echo "# README" > README.md
    git add -A
    git commit -q -m "initial"
    
    # Modify release files and other files
    echo "v1.1.0" > VERSION
    echo "## v1.1.0" >> CHANGELOG.md
    echo "Updated" >> README.md
    echo "other change" > other_file.txt
    echo "src change" > src_file.js
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    stage_release_files
    
    # Assert: Only release files should be staged
    local staged
    staged=$(git diff --cached --name-only)
    local staged_count
    staged_count=$(echo "$staged" | wc -l)
    
    assert_equals "3" "$staged_count" "Should stage exactly 3 files"
    assert_contains "$staged" "CHANGELOG.md" "Should include CHANGELOG.md"
    assert_contains "$staged" "VERSION" "Should include VERSION"
    assert_contains "$staged" "README.md" "Should include README.md"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

# Run all tests
echo "=== Testing stage_release_files() function ==="
test_stage_release_files_stages_changelog
test_stage_release_files_stages_version
test_stage_release_files_stages_readme
test_stage_release_files_only_stages_release_files

echo ""
echo "=== Test Summary ==="
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    print_color "$GREEN" "All tests passed! ✓"
    exit 0
else
    print_color "$RED" "Some tests failed!"
    exit 1
fi
