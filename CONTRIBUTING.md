# Contributing

## Development setup

```sh
brew install xcodegen swiftlint
xcodegen generate
```

Open `MicStatusAI.xcodeproj` or build from Terminal:

```sh
xcodebuild \
  -project MicStatusAI.xcodeproj \
  -scheme MicStatusAI \
  -configuration Debug \
  -destination 'generic/platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Workflow

1. Create a branch from `main`.
2. Keep changes focused.
3. Update `project.yml`, never generated project files.
4. Run SwiftLint and build locally.
5. Open a pull request using repository template.
6. Merge only after required checks pass.

Direct pushes to `main` are blocked. Generated `MicStatusAI.xcodeproj` is intentionally not committed.

## Source organization

- Keep one top-level type per Swift file.
- Put models, views, services, interfaces, errors, and coordinators in matching folders.
- Depend on focused protocols where implementation substitution is useful.
