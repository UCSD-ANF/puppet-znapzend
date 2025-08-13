# Repetitive Tasks: puppet-znapzend

This file documents repetitive tasks and their workflows for future reference.

## Commit Memory Bank Changes
**Last performed:** 2025-08-13
**Context:** After major project modernization updates (PDK adoption, v2.0.0)

**Files typically involved:**
- `.kilocode/rules/memory-bank/architecture.md` - System architecture and code paths
- `.kilocode/rules/memory-bank/context.md` - Current work focus and recent changes
- `.kilocode/rules/memory-bank/product.md` - Project purpose and user experience
- `.kilocode/rules/memory-bank/tech.md` - Technologies and development setup

**Steps:**
1. Check git status to identify modified memory bank files:
   ```bash
   git status
   ```
2. Stage all modified memory bank files:
   ```bash
   git add .kilocode/rules/memory-bank/
   ```
3. Create semantic commit with proper format:
   - **Type:** `docs` (documentation update)
   - **Scope:** `memory-bank` (specific to memory bank files)
   - **Format:** `docs(memory-bank): [brief description]`

**Commit message template:**
```
docs(memory-bank): update to reflect [major change description]

Updated memory bank documentation to capture [specific changes]:
- [Change 1: e.g., PDK adoption with modern development workflow]
- [Change 2: e.g., Template architecture evolution]
- [Change 3: e.g., Hiera v5 data migration]
- [Change 4: e.g., CI/CD automation implementation]
- [Additional context as needed]
```

**Important notes:**
- Use semantic commit format for consistency with project standards
- Include detailed commit body when changes are substantial
- Focus on major architectural or workflow changes that impact future development
- Stage only memory bank files to keep commits focused
- Verify all modified memory bank files are included before committing

**Example successful commit:**
```
Hash: e70adfb83dd180d277eefe69ae6f535225902983
Message: docs(memory-bank): update to reflect PDK modernization and v2.0.0 changes
```

**When to use this task:**
- After major project modernization updates
- Following architectural changes that affect memory bank documentation
- When memory bank files need to be committed separately from code changes
- During documentation maintenance cycles

## Prepare and Publish GitHub Release with Semantic Versioning
**Last performed:** 2025-08-13
**Context:** Major version release (v2.0.0) for puppet-znapzend with breaking changes

**Files typically modified:**
- `metadata.json` - Version update and dependency changes
- `CHANGELOG.md` - Release notes and migration guide
- `GITHUB_RELEASE_NOTES.md` - GitHub release content
- Git repository - Semantic commits and tags

**Steps taken:**
1. Check git status and analyze pending changes:
   ```bash
   git status
   ```
2. Group changes logically by component (templates, docs, manifests, etc.)
3. Create multiple semantic commits using proper format:
   - `feat:` for new features
   - `docs:` for documentation updates
   - `refactor:` for code restructuring
   - `chore:` for maintenance tasks
   - Use descriptive scopes (e.g., `templates`, `manifests`, `data`)
4. Determine appropriate semantic version based on change impact:
   - **MAJOR**: Breaking changes (API changes, removed features)
   - **MINOR**: New features, backward compatible
   - **PATCH**: Bug fixes, backward compatible
5. Update `metadata.json` with new version number
6. Update `CHANGELOG.md` with comprehensive release notes:
   - Include migration guide for breaking changes
   - Document all new features and improvements
   - List any deprecated functionality
7. Create and push git tag for the version:
   ```bash
   git tag v2.0.0
   git push origin v2.0.0
   ```
8. Prepare GitHub release notes in `GITHUB_RELEASE_NOTES.md`
9. Publish GitHub release using gh CLI:
   ```bash
   gh release create v2.0.0 --notes-file GITHUB_RELEASE_NOTES.md
   ```

**Important considerations:**
- Use semantic commit format consistently across all commits
- Group commits by component/scope for better organization (12 commits in this case)
- For major releases, thoroughly document all breaking changes
- Include comprehensive migration guide for API/architecture changes
- Test release process in development environment before publishing
- Verify git tag exists and is pushed before creating GitHub release
- Ensure CI/CD workflows complete successfully after tag creation

**Breaking changes handled in this release:**
- **Puppet version requirements**: Updated minimum supported version
- **Template format migration**: Transition from ERB-only to dual ERB/EPP support
- **Architecture changes**: Removal of `params.pp`, migration to data-in-modules pattern
- **Modern tooling adoption**: Full PDK integration and modern dependency management
- **Hiera v5 migration**: Updated data hierarchy and configuration approach

**Workflow patterns:**
- **Pre-release validation**: Comprehensive testing and linting before tagging
- **Semantic versioning**: Strict adherence to semver principles for version determination
- **Documentation first**: Update all documentation before publishing release
- **Automated publishing**: Use GitHub CLI for consistent release creation
- **Change communication**: Clear migration paths and upgrade instructions

**When to use this task:**
- Major version releases with breaking changes requiring semantic versioning
- Minor/patch releases following the same systematic approach
- Any Puppet module release requiring comprehensive documentation
- Projects needing migration guides for API or architectural changes
- Releases with significant modernization or tooling updates

**Example commit sequence from this release:**
```
feat(templates): add dual ERB/EPP template support with type safety
docs(changelog): add comprehensive v2.0.0 release notes with migration guide
refactor(data): migrate OS-specific parameters from params.pp to Hiera
chore(pdk): adopt PDK 3.4.0 with modern development workflow
feat(hiera): implement v5 data hierarchy with OS-specific lookups
docs(memory-bank): update architecture documentation for v2.0.0 changes
```