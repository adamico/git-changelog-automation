# Changelog

## [1.1.0] - 2025-11-01

### Added
- feat: automatically update README version badge when releasing

### Documentation
- docs: add help text for automatic VERSION and README badge updates

### Tests
- test: add tests for VERSION file and README badge updates

## [1.0.1] - 2025-11-01

### Fixed
- fix: align all help text comments consistently
- fix: align help text comment for release command with date parameter
- fix: use print_color for help output instead of heredoc to display ANSI colors properly
- fix: always create/update VERSION file, not just when it exists

## [1.0.0] - 2025-11-01

### Added
- Initial release of git-changelog-automation
- Automatic changelog generation from conventional commits
- Support for release versioning
- Git hooks for commit validation and changelog reminders
- VERSION file management
