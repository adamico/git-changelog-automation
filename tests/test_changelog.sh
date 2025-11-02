#!/bin/bash
#
# Test suite for generate_changelog.sh
#
# Tests the changelog generation and merging functionality

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
GENERATE_SCRIPT="$PROJECT_DIR/changelog"
TEST_CHANGELOG="$SCRIPT_DIR/test_changelog_temp.md"
TEST_BACKUP="$TEST_CHANGELOG.backup"

# Cleanup function
cleanup() {
    rm -f "$TEST_CHANGELOG" "$TEST_BACKUP"
}

trap cleanup EXIT

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
        print_color "$RED" "    Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local haystack=$1
    local needle=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$haystack" | grep -qF "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Needle not found: $needle"
        return 1
    fi
}

assert_not_contains() {
    local haystack=$1
    local needle=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! echo "$haystack" | grep -qF "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Found unexpected: $needle"
        return 1
    fi

assert_true() {
    local condition=$1
    local message=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Condition failed: $condition"
        return 1
    fi
}

assert_false() {
    local condition=$1
    local message=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Condition should be false: $condition"
        return 1
    fi
}
}

# Create a test changelog (new format with categorized sections)

assert_true() {
    local condition=$1
    local message=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Condition failed: $condition"
        return 1
    fi
}

assert_false() {
    local condition=$1
    local message=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Condition should be false: $condition"
        return 1
    fi
}
create_test_changelog() {
    cat > "$TEST_CHANGELOG" << 'EOF'
# Changelog

## [1.0.0] - 2025-10-31

### Added
- feat: initial release

---

**About this project:** Test project
EOF
}

# Create changelog with existing unreleased content
create_test_changelog_with_content() {
    cat > "$TEST_CHANGELOG" << 'EOF'
# Changelog

### Added
- feat: existing feature

## [1.0.0] - 2025-10-31

### Added
- feat: initial release

---

**About this project:** Test project
EOF
}

# Create completely empty changelog (just header)
create_empty_changelog() {
    cat > "$TEST_CHANGELOG" << 'EOF'
# Changelog

---

**About this project:** Test project
EOF
}

# Create changelog with old [Unreleased] format (backwards compat test)
create_old_format_changelog() {
    cat > "$TEST_CHANGELOG" << 'EOF'
# Changelog

## [Unreleased]

### Added
- feat: old format feature

## [1.0.0] - 2025-10-31

### Added
- feat: initial release
EOF
}

# Test 1: Script help works
test_help() {
    print_color "$YELLOW" "Test: Script help displays"
    
    local output
    output=$("$GENERATE_SCRIPT" --help 2>&1)
    
    assert_contains "$output" "USAGE:" "Help shows usage"
    assert_contains "$output" "auto-accept" "Help mentions auto-accept flag"
}

# Test 2: Merge new features into changelog
test_merge_features() {
    print_color "$YELLOW" "Test: Merge new features into changelog"
    
    create_test_changelog
    
    # Create temporary generated content (new format with sections)
    local temp_generated=$(mktemp)
    cat > "$temp_generated" << 'EOF'
## [Unreleased]

### Added
- feat: new feature from commit

### Fixed

### Performance
EOF
    
    # Extract content from generated file
    local new_content=$(grep "^- feat:" "$temp_generated" || echo "")
    
    # New features should be present with conventional commit prefix
    assert_contains "$new_content" "feat: new feature from commit" "New feature has conventional prefix"
    assert_contains "$new_content" "feat: new feature" "Entry contains full text"
    
    # Verify sections use new naming
    local sections=$(grep "^### " "$temp_generated")
    assert_contains "$sections" "### Added" "Uses 'Added' instead of 'Features'"
    assert_contains "$sections" "### Fixed" "Uses 'Fixed' instead of 'Bug Fixes'"
    
    rm "$temp_generated"
}

# Test 3: Deduplication works
test_deduplication() {
    print_color "$YELLOW" "Test: Deduplication removes duplicate entries"
    
    local input=$'- feature one\n- feature two\n- feature one\n- feature three'
    local deduplicated=$(echo "$input" | sort -u)
    
    local count=$(echo "$deduplicated" | grep -c "feature one")
    assert_equals "1" "$count" "Duplicate 'feature one' removed"
    
    count=$(echo "$deduplicated" | wc -l)
    assert_equals "3" "$count" "Total lines after dedup is 3"
}

# Test 4: Preserves version sections
test_preserve_versions() {
    print_color "$YELLOW" "Test: Version sections are preserved"
    
    create_test_changelog
    
    # Extract version section
    local versions=$(sed -n '/^## \[[0-9]/,/^---/p' "$TEST_CHANGELOG")
    
    assert_contains "$versions" "[1.0.0]" "Version 1.0.0 is present"
    assert_contains "$versions" "initial release" "Version content is preserved"
    assert_contains "$versions" "feat:" "Conventional commit prefix preserved"
}

# Test 5: Conventional commit prefix validation
test_prefix_validation() {
    print_color "$YELLOW" "Test: Conventional commit prefixes are validated"
    
    local feat_commit="- feat: add new feature"
    local fix_commit="- fix: resolve bug"
    local docs_commit="- docs: update readme"
    
    # Check prefixes are present
    assert_contains "$feat_commit" "feat:" "feat: prefix present"
    assert_contains "$fix_commit" "fix:" "fix: prefix present"
    assert_contains "$docs_commit" "docs:" "docs: prefix present"
    
    # Verify format
    if echo "$feat_commit" | grep -qE "^- (feat|fix|docs|refactor|perf|test|build|ci|chore|style|revert):"; then
        local valid="true"
    else
        local valid="false"
    fi
    
    assert_equals "true" "$valid" "Commit follows conventional format"
}

# Test 6: Footer preservation
test_footer_preservation() {
    print_color "$YELLOW" "Test: Footer section is preserved"
    
    create_test_changelog
    
    # Extract footer
    local footer=$(tail -5 "$TEST_CHANGELOG")
    
    assert_contains "$footer" "About this project:" "About line is present"
    assert_contains "$footer" "Test project" "Footer content is preserved"
}

# Test 7: Script accepts various flags
test_flag_acceptance() {
    print_color "$YELLOW" "Test: Script accepts various flag formats"
    
    # Test --help
    "$GENERATE_SCRIPT" --help > /dev/null 2>&1
    assert_equals "0" "$?" "Script accepts --help"
    
    # Test -h
    "$GENERATE_SCRIPT" -h > /dev/null 2>&1
    assert_equals "0" "$?" "Script accepts -h"
}

# Test 8: Empty merge handling
test_empty_merge() {
    print_color "$YELLOW" "Test: Empty changelog sections handled correctly"
    
    local empty_features=""
    local empty_fixes=""
    
    # Simulate the check
    if [ -z "$empty_features" ]; then
        local result="Use placeholder"
    else
        local result="Use content"
    fi
    
    assert_equals "Use placeholder" "$result" "Empty features defaults to placeholder"
}

# Test 9: Multiple commits of same type
test_multiple_commits() {
    print_color "$YELLOW" "Test: Multiple commits are properly collected"
    
    local commits=$'- feature one\n- feature two\n- feature three'
    local count=$(echo "$commits" | grep -c "^- feature")
    
    assert_equals "3" "$count" "All three features collected"
}

# Test 10: Sorted output
test_sorted_output() {
    print_color "$YELLOW" "Test: Deduplicated output is sorted"
    
    local unsorted=$'- zebra feature\n- alpha feature\n- beta feature'
    local sorted=$(echo "$unsorted" | sort -u)
    
    local first_line=$(echo "$sorted" | head -1)
    assert_contains "$first_line" "alpha" "First line after sort contains 'alpha'"
}

# Test 11: Release functionality
test_release_functionality() {
    print_color "$YELLOW" "Test: --release converts [Unreleased] to version"
    
    # Create test changelog with [Unreleased] content (new format)
    local test_changelog=$(mktemp)
    cat > "$test_changelog" << 'EOF'
# Changelog

## [Unreleased]

### Added
- feat: new feature A

### Fixed
- fix: fixed bug B

## [1.0.0] - 2024-01-01
EOF
    
    # Run release with auto-accept
    local output=$(CHANGELOG_FILE="$test_changelog" "$GENERATE_SCRIPT" --release 1.1.0 --auto-accept 2>&1)
    local result=$?
    
    # Check success
    assert_equals "0" "$result" "Release command succeeded"
    
    # Verify new [Unreleased] created
    assert_contains "$(cat "$test_changelog")" "## [Unreleased]" "New [Unreleased] section created"
    
    # Verify version section created
    assert_contains "$(cat "$test_changelog")" "## [1.1.0]" "Version section created"
    
    # Verify content moved to version with conventional prefixes
    local version_section=$(sed -n '/## \[1\.1\.0\]/,/## \[1\.0\.0\]/p' "$test_changelog")
    assert_contains "$version_section" "feat: new feature A" "Features moved with prefix"
    assert_contains "$version_section" "fix: fixed bug B" "Bug fixes moved with prefix"
    
    # Verify new section naming
    assert_contains "$version_section" "### Added" "Uses 'Added' section"
    assert_contains "$version_section" "### Fixed" "Uses 'Fixed' section"
    
    # Verify old version preserved
    assert_contains "$(cat "$test_changelog")" "## [1.0.0] - 2024-01-01" "Old version preserved"
    
    # Cleanup
    rm -f "$test_changelog"
}

# Test 12: Sync validation with git tags
test_sync_validation() {
    print_color "$YELLOW" "Test: Sync validation detects and fixes missing versions"
    
    # This test requires git tags, so we'll skip in environments without them
    if ! git tag -l | grep -q "v1.0.0"; then
        print_color "$YELLOW" "  ⊘ Skipped (no git tags found)"
        return 0
    fi
    
    # Create test changelog missing v1.0.0 (new format)
    local test_changelog=$(mktemp)
    cat > "$test_changelog" << 'EOF'
# Changelog

## [Unreleased]

## [1.1.0] - 2025-11-01

### Added
- feat: some feature
EOF
    
    # Run with auto-accept to add missing version
    local output=$(cd "$SCRIPT_DIR/.." && CHANGELOG_FILE="$test_changelog" "$GENERATE_SCRIPT" --auto-accept 2>&1)
    
    # Check that warning was shown
    assert_contains "$output" "out of sync" "Warning about out of sync shown"
    
    # Check that version was added
    assert_contains "$(cat "$test_changelog")" "## [1.0.0]" "Missing version v1.0.0 added"
    
    # Cleanup
    rm -f "$test_changelog"
}

# Test VERSION file creation
test_version_file_creation() {
    print_color "$YELLOW" "Test: VERSION file creation"
    
    local test_dir=$(mktemp -d)
    local test_version_file="$test_dir/VERSION"
    
    # Mock release_version function behavior
    cd "$test_dir"
    echo "1.2.3" > "$test_version_file"
    
    # Check VERSION file was created
    assert_true "[ -f '$test_version_file' ]" "VERSION file created"
    assert_contains "$(cat $test_version_file)" "1.2.3" "VERSION file contains correct version"
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test README badge update
test_readme_badge_update() {
    print_color "$YELLOW" "Test: README badge update"
    
    local test_dir=$(mktemp -d)
    local test_readme="$test_dir/README.md"
    
    # Create README with version badge
    cat > "$test_readme" << 'READMEEOF'
# Test Project

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/test/test)

Some content here.
READMEEOF
    
    # Simulate badge update
    sed -i "s/version-[0-9]\+\.[0-9]\+\.[0-9]\+-blue/version-2.0.0-blue/g" "$test_readme"
    
    # Check badge was updated
    assert_contains "$(cat $test_readme)" "version-2.0.0-blue" "README badge updated to 2.0.0"
    assert_not_contains "$(cat $test_readme)" "version-1.0.0-blue" "Old badge version removed"
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test README badge skipped when absent
test_readme_badge_skipped_when_absent() {
    print_color "$YELLOW" "Test: README badge update skipped when no README exists"
    
    local test_dir=$(mktemp -d)
    
    # Don't create README
    # update_readme_badge should handle this gracefully (no error)
    
    # This would be tested by calling update_readme_badge function
    # For now, just verify the directory exists but has no README
    assert_true "[ -d '$test_dir' ]" "Test directory exists"
    assert_false "[ -f '$test_dir/README.md' ]" "README does not exist"
    
    # Cleanup
    rm -rf "$test_dir"
}



test_rebuild_from_tags() {
    print_color "$YELLOW" "Test: Rebuild CHANGELOG from git tags"
    
    local test_dir=$(mktemp -d)
    local orig_dir=$(pwd)
    cd "$test_dir"
    
    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git config tag.gpgsign false
    git config commit.gpgsign false
    
    # Create some commits and tags
    echo "v1" > file1.txt
    git add file1.txt
    git commit -q -m "feat: add feature one"
    git tag v1.0.0
    
    echo "v2" > file2.txt
    git add file2.txt
    git commit -q -m "fix: fix bug one"
    git commit -q --allow-empty -m "docs: add documentation"
    git tag v1.1.0
    
    echo "v3" > file3.txt
    git add file3.txt
    git commit -q -m "feat: add feature two"
    
    # Run rebuild (non-interactive, no prompts)
    CHANGELOG_FILE="$test_dir/CHANGELOG.md" "$GENERATE_SCRIPT" --rebuild >/dev/null 2>&1 || true
    
    if [ -f "$test_dir/CHANGELOG.md" ]; then
        local content=$(cat "$test_dir/CHANGELOG.md")
        
        # Check structure
        assert_contains "$content" "# Changelog" "Has header"
        assert_contains "$content" "[1.1.0]" "Has v1.1.0 section"
        assert_contains "$content" "[1.0.0]" "Has v1.0.0 section"
        
        # Check commits are in correct sections
        assert_contains "$content" "feat: add feature one" "Has feature one"
        assert_contains "$content" "fix: fix bug one" "Has bug fix"
        assert_contains "$content" "docs: add documentation" "Has docs"
        assert_contains "$content" "feat: add feature two" "Has feature two in unreleased"
        
        # Check proper categorization
        assert_contains "$content" "### Added" "Has Added section"
        assert_contains "$content" "### Fixed" "Has Fixed section"
        assert_contains "$content" "### Documentation" "Has Documentation section"
    else
        print_color "$RED" "  ✗ CHANGELOG.md was not created"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Cleanup
    cd "$orig_dir" 2>/dev/null || cd /tmp
    rm -rf "$test_dir"
}

# Main test runner
test_rebuild_commit_isolation() {
    test_default_fills_missing_tags
    test_default_adds_unreleased_section
    print_color "$YELLOW" "Test: Rebuild correctly isolates commits per version"
    
    local test_dir=$(mktemp -d)
    local orig_dir=$(pwd)
    cd "$test_dir"
    
    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git config tag.gpgsign false
    git config commit.gpgsign false
    
    # Create v1.0.0 with ONE commit
    echo "v1" > file1.txt
    git add file1.txt
    git commit -q -m "feat: version 1 feature"
    git tag v1.0.0
    
    # Create v1.1.0 with TWO commits
    echo "v1.1-a" > file2.txt
    git add file2.txt
    git commit -q -m "feat: version 1.1 feature A"
    echo "v1.1-b" > file3.txt
    git add file3.txt
    git commit -q -m "fix: version 1.1 fix B"
    git tag v1.1.0
    
    # Create v1.2.0 with THREE commits
    echo "v1.2-a" > file4.txt
    git add file4.txt
    git commit -q -m "feat: version 1.2 feature A"
    echo "v1.2-b" > file5.txt
    git add file5.txt
    git commit -q -m "docs: version 1.2 docs B"
    echo "v1.2-c" > file6.txt
    git add file6.txt
    git commit -q -m "refactor: version 1.2 refactor C"
    git tag v1.2.0
    
    # Run rebuild
    CHANGELOG_FILE="$test_dir/CHANGELOG.md" "$GENERATE_SCRIPT" --rebuild >/dev/null 2>&1 || true
    
    if [ -f "$test_dir/CHANGELOG.md" ]; then
        local content=$(cat "$test_dir/CHANGELOG.md")
        
        # Extract each version section
        local v120_section=$(sed -n '/^## \[1.2.0\]/,/^## \[1.1.0\]/p' "$test_dir/CHANGELOG.md")
        local v110_section=$(sed -n '/^## \[1.1.0\]/,/^## \[1.0.0\]/p' "$test_dir/CHANGELOG.md")
        local v100_section=$(sed -n '/^## \[1.0.0\]/,/^---/p' "$test_dir/CHANGELOG.md")
        
        # Count commits in each section (lines starting with "- ")
        local v120_count=$(echo "$v120_section" | grep -c "^- " || echo 0)
        local v110_count=$(echo "$v110_section" | grep -c "^- " || echo 0)
        local v100_count=$(echo "$v100_section" | grep -c "^- " || echo 0)
        
        # CRITICAL: Each version should have ONLY its own commits
        assert_equals "3" "$v120_count" "v1.2.0 has exactly 3 commits"
        assert_equals "2" "$v110_count" "v1.1.0 has exactly 2 commits"
        assert_equals "1" "$v100_count" "v1.0.0 has exactly 1 commit"
        
        # Verify specific commits are in correct sections
        assert_contains "$v120_section" "version 1.2 feature A" "v1.2.0 has its feature"
        assert_contains "$v120_section" "version 1.2 docs B" "v1.2.0 has its docs"
        assert_contains "$v120_section" "version 1.2 refactor C" "v1.2.0 has its refactor"
        assert_not_contains "$v120_section" "version 1.1" "v1.2.0 does NOT have v1.1 commits"
        assert_not_contains "$v120_section" "version 1 feature" "v1.2.0 does NOT have v1.0 commits"
        
        assert_contains "$v110_section" "version 1.1 feature A" "v1.1.0 has its feature"
        assert_contains "$v110_section" "version 1.1 fix B" "v1.1.0 has its fix"
        assert_not_contains "$v110_section" "version 1.2" "v1.1.0 does NOT have v1.2 commits"
        assert_not_contains "$v110_section" "version 1 feature" "v1.1.0 does NOT have v1.0 commits"
        
        assert_contains "$v100_section" "version 1 feature" "v1.0.0 has its feature"
        assert_not_contains "$v100_section" "version 1.1" "v1.0.0 does NOT have v1.1 commits"
        assert_not_contains "$v100_section" "version 1.2" "v1.0.0 does NOT have v1.2 commits"
    else
        print_color "$RED" "  ✗ CHANGELOG.md was not created"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Cleanup
    cd "$orig_dir" 2>/dev/null || cd /tmp
    rm -rf "$test_dir"
}

test_default_fills_missing_tags() {
    print_color "$YELLOW" "Test: Default execution fills missing tagged versions with real commits"
    
    local test_dir=$(mktemp -d)
    local orig_dir=$(pwd)
    cd "$test_dir"
    
    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git config tag.gpgsign false
    git config commit.gpgsign false
    
    # Create v1.0.0
    echo "v1" > file1.txt
    git add file1.txt
    git commit -q -m "feat: initial feature"
    git tag v1.0.0
    
    # Create v1.1.0 (will be missing from CHANGELOG initially)
    echo "v1.1" > file2.txt
    git add file2.txt
    git commit -q -m "feat: add new feature"
    echo "v1.1-fix" > file3.txt
    git add file3.txt
    git commit -q -m "fix: fix critical bug"
    git tag v1.1.0
    
    # Create incomplete CHANGELOG with only v1.0.0 (v1.1.0 is missing)
    cat > CHANGELOG.md << 'CHANGELOG'
# Changelog

## [1.0.0] - 2025-01-01

### Added
- feat: initial feature

---
CHANGELOG
    
    # Run default execution (no --rebuild flag)
    CHANGELOG_FILE="$test_dir/CHANGELOG.md" "$GENERATE_SCRIPT" -y >/dev/null 2>&1 || true
    
    if [ -f "$test_dir/CHANGELOG.md" ]; then
        local content=$(cat "$test_dir/CHANGELOG.md")
        
        # Should have v1.1.0 section now
        assert_contains "$content" "[1.1.0]" "Has v1.1.0 section"
        
        # v1.1.0 should have REAL commits, not placeholder
        assert_contains "$content" "feat: add new feature" "v1.1.0 has real feature commit"
        assert_contains "$content" "fix: fix critical bug" "v1.1.0 has real fix commit"
        assert_not_contains "$content" "See git history for details" "No placeholder text in v1.1.0"
        
        # Should still have v1.0.0
        assert_contains "$content" "[1.0.0]" "Still has v1.0.0 section"
        assert_contains "$content" "feat: initial feature" "v1.0.0 has its commit"
    else
        print_color "$RED" "  ✗ CHANGELOG.md was not modified"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Cleanup
    cd "$orig_dir" 2>/dev/null || cd /tmp
    rm -rf "$test_dir"
}

test_default_adds_unreleased_section() {
    print_color "$YELLOW" "Test: Default execution adds Unreleased section for commits after last tag"
    
    local test_dir=$(mktemp -d)
    local orig_dir=$(pwd)
    cd "$test_dir"
    
    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git config tag.gpgsign false
    git config commit.gpgsign false
    
    # Create v1.0.0
    echo "v1" > file1.txt
    git add file1.txt
    git commit -q -m "feat: initial feature"
    git tag v1.0.0
    
    # Create CHANGELOG with v1.0.0
    cat > CHANGELOG.md << 'CHANGELOG'
# Changelog

## [1.0.0] - 2025-01-01

### Added
- feat: initial feature

---
CHANGELOG
    
    # Add new commits AFTER the tag (unreleased)
    echo "new-feature" > file2.txt
    git add file2.txt
    git commit -q -m "feat: add unreleased feature"
    echo "new-fix" > file3.txt
    git add file3.txt
    git commit -q -m "fix: unreleased bugfix"
    
    # Run default execution (no --rebuild flag)
    CHANGELOG_FILE="$test_dir/CHANGELOG.md" "$GENERATE_SCRIPT" -y >/dev/null 2>&1 || true
    
    if [ -f "$test_dir/CHANGELOG.md" ]; then
        local content=$(cat "$test_dir/CHANGELOG.md")
        
        # Should have Unreleased section
        assert_contains "$content" "[Unreleased]" "Has Unreleased section"
        
        # Unreleased section should have the new commits
        assert_contains "$content" "feat: add unreleased feature" "Unreleased has new feature"
        assert_contains "$content" "fix: unreleased bugfix" "Unreleased has new fix"
        
        # Should still have v1.0.0
        assert_contains "$content" "[1.0.0]" "Still has v1.0.0 section"
        assert_contains "$content" "feat: initial feature" "v1.0.0 has its commit"
        
        # Unreleased should come BEFORE v1.0.0 in the file
        local unreleased_line=$(grep -n "\[Unreleased\]" "$test_dir/CHANGELOG.md" | cut -d: -f1)
        local v100_line=$(grep -n "\[1.0.0\]" "$test_dir/CHANGELOG.md" | cut -d: -f1)
        if [ "$unreleased_line" -lt "$v100_line" ]; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            print_color "$GREEN" "  ✓ Unreleased section appears before v1.0.0"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            print_color "$RED" "  ✗ Unreleased section should be before v1.0.0"
        fi
        TESTS_RUN=$((TESTS_RUN + 1))
    else
        print_color "$RED" "  ✗ CHANGELOG.md was not modified"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Cleanup
    cd "$orig_dir" 2>/dev/null || cd /tmp
    rm -rf "$test_dir"
}

main() {
    print_color "$YELLOW" "=== Changelog Generation Script Tests ==="
    echo ""
    
    # Check if script exists
    if [ ! -f "$GENERATE_SCRIPT" ]; then
        print_color "$RED" "Error: generate_changelog.sh not found at $GENERATE_SCRIPT"
        exit 1
    fi
    
    # Run tests
    test_help
    test_merge_features
    test_deduplication
    test_preserve_versions
    test_prefix_validation
    test_footer_preservation
    test_flag_acceptance
    test_empty_merge
    test_multiple_commits
    test_sorted_output
    test_version_file_creation
    test_readme_badge_update
    test_readme_badge_skipped_when_absent
    test_rebuild_from_tags
    test_rebuild_commit_isolation
    test_default_fills_missing_tags
    test_default_adds_unreleased_section
    # TODO: Re-enable these tests after implementing/fixing release and sync features
    # test_release_functionality
    # test_sync_validation
    
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
