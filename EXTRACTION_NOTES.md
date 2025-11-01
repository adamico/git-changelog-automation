# Extraction Notes

This repository was extracted from [PicoTestDriver](https://github.com/adamico/obsi/tree/main/lib/picotestdriver) v2.0.2 on November 1, 2025.

## What Was Extracted

The changelog automation system consisting of:

- **generate_changelog.sh** → Refactored into standalone `changelog` command
- **Git hooks** (commit-msg, prepare-commit-msg) → Integrated into `changelog --install-hooks`
- **Test suite** (test_generate_changelog.sh, 22 tests) → Adapted for standalone use
- **Configuration** (git-conventional-commits.yaml.example)

## Why Extract?

The changelog automation system is **project-agnostic**:
- Works with any git repository using conventional commits
- Not specific to PICO-8 or testing frameworks
- Useful across many different types of projects
- Already being used in both obsi and PicoTestDriver

Following the Unix philosophy: tools that do one thing well.

## Key Improvements During Extraction

1. **Unified Command**: Single `changelog` executable instead of multiple scripts
2. **Embedded Git Hooks**: No separate install_hooks.sh, hooks generated on-the-fly
3. **Enhanced Help**: Colorized help text with comprehensive examples
4. **Standalone**: Zero dependencies on PICO-8 or testing frameworks
5. **Self-Contained**: All functionality in one file for easy distribution

## Backward Compatibility

PicoTestDriver v2.0.2 retains the original scripts for backward compatibility. The bundled changelog tools will likely be removed in v3.0 with full migration to this standalone library.

## Version History

- **v1.0.0** (2025-11-01): Initial release
  - Extracted from PicoTestDriver v2.0.2
  - 22/22 tests passing
  - Complete feature parity with original
  - Enhanced documentation and examples

## Original Source

- **Repository**: https://github.com/adamico/obsi
- **Path**: lib/picotestdriver/scripts/
- **Version**: PicoTestDriver v2.0.2
- **Commit**: See PicoTestDriver git history for original development

## Credits

Originally developed as part of PicoTestDriver, which was itself extracted from the obsi game project. The changelog automation was recognized as valuable beyond its original context and extracted for broader use.

---

Created with the intention of helping developers manage changelogs more effectively across all types of projects.
