# Git Changelog Automation

[![Version](https://img.shields.io/badge/version-1.4.0-blue.svg)](https://github.com/adamico/git-changelog-automation)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

Automatically generate changelogs from conventional commits. Parse git history to create categorized, maintainable changelogs without manual effort.

## ✨ Features

- 🎯 **Conventional Commits**: Automatically categorizes commits by type (feat, fix, docs, etc.)
- 📝 **Smart Categorization**: Creates sections (Added, Fixed, Changed, Performance, etc.)
- 🔄 **Git Integration**: Works seamlessly with your existing git workflow
- 🪝 **Git Hooks**: Optional hooks for commit validation and changelog prompts
- 🤖 **CI/CD Ready**: Non-interactive mode for automation (`--auto-accept`)
- 🎨 **Colorized Output**: Clear, readable terminal output
- 📦 **Zero Dependencies**: Pure bash, optional npm integration
- 🔖 **Version Release**: Convert unreleased changes to tagged versions
- 🧹 **Smart Deduplication**: Prevents duplicate commits in changelog sections
- 💾 **Backup Control**: Optional timestamped backups when cleaning duplicates
- 📥 **Easy Install**: `--install` command copies script to `~/.local/bin`

## 🚀 Quick Start

### Installation

**Option 1: Auto-install (Recommended)**
```bash
# Clone and install to ~/.local/bin
git clone https://github.com/adamico/git-changelog-automation.git
cd git-changelog-automation
./changelog --install
```

**Option 2: Direct download**
```bash
curl -o changelog https://raw.githubusercontent.com/adamico/git-changelog-automation/main/changelog
chmod +x changelog
sudo mv changelog /usr/local/bin/
```

**Option 3: Clone and symlink**
```bash
git clone https://github.com/adamico/git-changelog-automation.git
cd git-changelog-automation
sudo ln -s "$(pwd)/changelog" /usr/local/bin/changelog
```

**Option 4: Use in project**
```bash
# Add as git submodule
git submodule add https://github.com/adamico/git-changelog-automation.git tools/changelog
ln -s tools/changelog/changelog changelog

# Or copy directly
curl -o changelog https://raw.githubusercontent.com/adamico/git-changelog-automation/main/changelog
chmod +x changelog
```

### Basic Usage

```bash
# Generate changelog from last tag to HEAD
changelog

# Generate from specific tag
changelog v1.0.0

# Generate between two tags
changelog v1.0.0 v2.0.0

# Auto-accept (no prompts) - great for CI/CD
changelog --auto-accept

# Release unreleased changes as version 1.2.0
changelog --release 1.2.0

# Install git hooks for commit validation
changelog --install-hooks
```

## 📖 Documentation

### Conventional Commits Format

Commit messages must follow this format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Supported types:**
- `feat`: New features → **Added** section
- `fix`: Bug fixes → **Fixed** section
- `refactor`: Code changes → **Changed** section
- `perf`: Performance improvements → **Performance** section
- `docs`: Documentation → **Documentation** section
- `style`: Code style changes → **Style** section
- `test`: Test changes → **Tests** section
- `build`: Build system → **Build** section
- `ci`: CI/CD changes → **CI/CD** section
- `chore`: Maintenance → **Chores** section
- `revert`: Reverted changes → **Reverted** section

**Examples:**
```bash
git commit -m "feat: add user authentication"
git commit -m "fix(parser): resolve null pointer exception"
git commit -m "docs: update installation instructions"
git commit -m "perf: optimize database queries"
```

### Command Options

```
changelog [OPTIONS] [from_tag] [to_tag]
changelog --release VERSION [DATE]
changelog --install
changelog --uninstall
changelog --clean [--no-backup]
changelog --rebuild
changelog --install-hooks

OPTIONS:
  --non-interactive, --auto-accept, -y
                    Auto-accept changes without prompting
  --release VERSION [DATE], -r VERSION [DATE]
                    Convert unreleased section to version release
  --install         Install script to ~/.local/bin
  --uninstall       Remove script from ~/.local/bin
  --clean           Remove duplicate entries (creates timestamped backup)
  --no-backup       Skip backup when using --clean
  --rebuild         Rebuild entire changelog from git tag history
  --install-hooks   Install git hooks for commit validation
  --version, -v     Show version
  --help, -h        Show help
```

### Environment Variables

```bash
# Override changelog file location
export CHANGELOG_FILE=/path/to/CHANGELOG.md

# Set project directory
export PROJECT_DIR=/path/to/project

# Config file (optional, for git-conventional-commits npm package)
export GIT_CHANGELOG_CONFIG=/path/to/config.yaml
```

### Cleaning Duplicates

Remove duplicate entries from your changelog with optional backup:

```bash
# Clean with timestamped backup (default)
changelog --clean

# Clean without backup
changelog --clean --no-backup
```

Backups are saved as `CHANGELOG.md.backup_YYYYMMDD_HHMMSS`.

### Rebuilding Changelog

Rebuild entire changelog from git tag history:

```bash
changelog --rebuild
```

This command:
- Scans all git tags
- Extracts commits between tags
- Generates proper changelog sections
- Preserves existing Unreleased section

### Git Hooks

Install git hooks to enforce conventional commits and prompt for changelog updates:

```bash
changelog --install-hooks
```

**Installed hooks:**
- `commit-msg`: Validates commit message format
- `prepare-commit-msg`: Prompts for changelog updates on version commits

### Automation & CI/CD

Use `--auto-accept` flag for automated workflows:

```bash
# GitHub Actions example
- name: Update Changelog
  run: changelog --auto-accept

# GitLab CI example
update_changelog:
  script:
    - ./changelog --auto-accept
```

### Release Workflow

**Typical release process:**

```bash
# 1. Generate/update changelog
changelog

# 2. Review changes
git diff CHANGELOG.md

# 3. Commit changelog
git add CHANGELOG.md
git commit -m "docs: update changelog"

# 4. Release version
changelog --release 1.2.0

# 5. Commit release
git add CHANGELOG.md VERSION  # if VERSION file exists
git commit -m "build: release v1.2.0"

# 6. Tag release
git tag v1.2.0
git push origin main --tags
```

## 📋 Examples

### Example CHANGELOG.md Output

```markdown
# Changelog

### Added
- feat: add user authentication system
- feat: implement dark mode

### Fixed
- fix: resolve login timeout issue
- fix(api): handle null responses correctly

### Changed
- refactor: simplify database queries
- refactor: reorganize project structure

### Performance
- perf: optimize image loading

### Documentation
- docs: update API documentation
- docs: add contribution guidelines


## [1.0.0] - 2025-11-01

### Added
- feat: initial release
```

### Project Integration

**In your project:**

```bash
# Add to your project
git submodule add https://github.com/adamico/git-changelog-automation.git tools/changelog

# Create convenience script
cat > scripts/update-changelog.sh << 'EOF'
#!/bin/bash
./tools/changelog/changelog "$@"
EOF
chmod +x scripts/update-changelog.sh

# Use it
./scripts/update-changelog.sh
```

## 🧪 Testing

Run the test suite:

```bash
cd tests
bash test_changelog.sh
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Use conventional commits
4. Add tests for new features
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Repository**: https://github.com/adamico/git-changelog-automation
- **Issues**: https://github.com/adamico/git-changelog-automation/issues
- **Conventional Commits**: https://www.conventionalcommits.org/

## 💡 Inspiration

Extracted from [PicoTestDriver](https://github.com/adamico/obsi/tree/main/lib/picotestdriver), this tool was designed to be project-agnostic and reusable across any git repository following conventional commits.

## 🙏 Acknowledgments

- Conventional Commits specification
- git-conventional-commits npm package (optional integration)
- The open source community

---

Made with ❤️ for better changelog management
