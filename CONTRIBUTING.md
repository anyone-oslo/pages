# Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/anyone-oslo/pages). Everyone participating is
expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Getting started

Install the dependencies, build the frontend and run the test suite:

```sh
bundle install
pnpm install
pnpm build-debug && pnpm build:css
bundle exec rspec
```

The frontend build output in `app/assets/builds` is not checked in. CI
builds a minified bundle with `pnpm build` when a release is published.
Rebuild after changing `app/javascript` or the stylesheets, including when
you're using Pages from a `path:` source in another app.

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
