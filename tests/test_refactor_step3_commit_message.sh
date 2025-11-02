#!/bin/bash
#
# Test Step 3: build_release_commit_message() function refactoring
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

test_build_commit_message_format() {
    echo ""
    echo "Test: build_release_commit_message formats conventional commit"
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    local message
    message=$(build_release_commit_message "1.2.3")
    
    # Assert: Should follow conventional commit format
    assert_equals "chore: release v1.2.3" "$message" "Message should be 'chore: release v1.2.3'"
}

test_build_commit_message_with_different_version() {
    echo ""
    echo "Test: build_release_commit_message works with different versions"
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test multiple versions
    local msg1 msg2 msg3
    msg1=$(build_release_commit_message "0.1.0")
    msg2=$(build_release_commit_message "2.0.0")
    msg3=$(build_release_commit_message "10.5.3")
    
    # Assert
    assert_equals "chore: release v0.1.0" "$msg1" "Message should format v0.1.0"
    assert_equals "chore: release v2.0.0" "$msg2" "Message should format v2.0.0"
    assert_equals "chore: release v10.5.3" "$msg3" "Message should format v10.5.3"
}

test_build_commit_message_returns_string() {
    echo ""
    echo "Test: build_release_commit_message returns non-empty string"
    
    # Source changelog to get the function
    source "$CHANGELOG_SCRIPT"
    
    # Test
    local message
    message=$(build_release_commit_message "1.0.0")
    
    # Assert: Should not be empty
    if [ -n "$message" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        TESTS_RUN=$((TESTS_RUN + 1))
        print_color "$GREEN" "  ✓ Message is not empty"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        print_color "$RED" "  ✗ Message should not be empty"
    fi
}

# Run all tests
echo "=== Testing build_release_commit_message() function ==="
test_build_commit_message_format
test_build_commit_message_with_different_version
test_build_commit_message_returns_string

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
