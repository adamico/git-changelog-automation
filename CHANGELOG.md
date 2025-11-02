# Changelog

## [1.3.0] - 2025-11-02



### Added
- feat: add --clean command to remove duplicate entries from CHANGELOG
- feat: add --rebuild command with modular helper functions
- feat: automatically update README version badge when releasing
- feat: initial release of git-changelog-automation
- feat: populate missing tagged versions with real commits from git history

### Fixed
- fix: correct --rebuild to isolate commits per version
- fix: deduplicate already-released commits when generating changelog
- fix: align all help text comments consistently
- fix: align help text comment for release command with date parameter
- fix: use print_color for help output instead of heredoc to display ANSI colors properly
- fix: always create/update VERSION file, not just when it exists

### Documentation
- docs: add copilot-instructions enforcing no manual CHANGELOG edits
- docs: add help text for automatic VERSION and README badge updates
- docs: add terminal command patterns for auto-approval in Copilot
- docs: improve terminal command patterns with Cwd checking
- docs: update version badge to 1.0.1

### Tests
- test: add tests for missing tag filling and unreleased commits
- test: add tests for VERSION file and README badge updates

### Chores
- chore: release v1.1.1
- chore: release v1.1.0
- chore: bump version to 1.0.1


## [1.2.1] - 2025-11-01



### Added
- feat: add --rebuild command with modular helper functions
- feat: add --clean command to remove duplicate entries from CHANGELOG

### Fixed
- fix: correct --rebuild to isolate commits per version

### Documentation
- docs: add copilot-instructions enforcing no manual CHANGELOG edits


## [1.1.1] - 2025-11-01

### Fixed
- fix: deduplicate already-released commits when generating changelog

### Chores
- chore: release v1.1.1

## [1.1.0] - 2025-11-01

### Added
- feat: automatically update README version badge when releasing

### Documentation
- docs: add help text for automatic VERSION and README badge updates

### Tests
- test: add tests for VERSION file and README badge updates

### Chores
- chore: release v1.1.0

## [1.0.1] - 2025-11-01

### Fixed
- fix: align all help text comments consistently
- fix: align help text comment for release command with date parameter
- fix: use print_color for help output instead of heredoc to display ANSI colors properly
- fix: always create/update VERSION file, not just when it exists

### Documentation
- docs: update version badge to 1.0.1

### Chores
- chore: bump version to 1.0.1

## [1.0.0] - 2025-11-01

### Added
- feat: initial release of git-changelog-automation

