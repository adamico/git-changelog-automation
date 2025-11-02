#!/bin/bash
#
# Test Step 1: check_git_clean() function refactoring
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

test_check_git_clean_on_clean_repo() {
    echo ""
    echo "Test: check_git_clean returns 0 on clean repo"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    echo "test" > README.md
    git add README.md
    git commit -q -m "initial"
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    local result
    set +e
    check_git_clean
    result=$?
    set -e
    
    # Assert: Clean repo should return 0
    assert_equals "0" "$result" "check_git_clean should return 0 on clean repo"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

test_check_git_clean_on_dirty_repo() {
    echo ""
    echo "Test: check_git_clean returns 1 on dirty repo"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    echo "test" > README.md
    git add README.md
    git commit -q -m "initial"
    
    # Make repo dirty
    echo "new content" > dirty_file.txt
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    local result
    set +e
    check_git_clean
    result=$?
    set -e
    
    # Assert: Dirty repo should return 1
    assert_equals "1" "$result" "check_git_clean should return 1 on dirty repo"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

test_check_git_clean_with_staged_changes() {
    echo ""
    echo "Test: check_git_clean returns 1 with staged changes"
    
    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    git init -q
    git config user.name "Test"
    git config user.email "test@test.com"
    echo "test" > README.md
    git add README.md
    git commit -q -m "initial"
    
    # Stage a change
    echo "staged content" > staged_file.txt
    git add staged_file.txt
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    local result
    set +e
    check_git_clean
    result=$?
    set -e
    
    # Assert: Staged changes should return 1
    assert_equals "1" "$result" "check_git_clean should return 1 with staged changes"
    
    # Cleanup
    cd / && rm -rf "$test_dir"
}

# Run all tests
echo "=== Testing check_git_clean() function ==="
test_check_git_clean_on_clean_repo
test_check_git_clean_on_dirty_repo
test_check_git_clean_with_staged_changes

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
