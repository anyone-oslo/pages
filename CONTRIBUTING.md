# Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/anyone-oslo/pages). Everyone participating is
expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Getting started

Install the dependencies and run the test suite:

```sh
bundle install
bundle exec rspec
```

The specs run against an internal Rails app in `spec/internal`.

Check style before pushing:

```sh
bundle exec rubocop
```

The JavaScript side has its own checks:

```sh
pnpm install
pnpm lint
pnpm tsc --noEmit
```

## Pull requests

- Add tests for any behavior you change.
- Write commit messages using
  [Conventional Commits](https://www.conventionalcommits.org). The
  changelog and releases are generated from them, so the `feat:` and
  `fix:` prefixes decide what ends up in the next release.
- Leave the version and `CHANGELOG.md` alone. Both are updated
  automatically when a release is cut.
