# setup-jai

A GitHub Action that installs the [Jai toolchain](https://github.com/matteopolak/jai) (`jaic`, `jaifmt`, `jailint` and optionally `jailsp`) from its GitHub releases, so CI can compile, format and lint Jai projects.

It downloads the release archive for the runner, verifies it against the release's `SHA256SUMS`, unpacks it, adds the tools to `PATH` and sets `JAIC_STDLIB` to the bundled standard library.

## Usage

```yaml
name: ci
on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: matteopolak/setup-jai@v1
      - run: jaifmt --check .
      - run: jailint -D warnings .
      - run: jaic build main.jai
```

Pin a toolchain release, and pick which tools you want:

```yaml
- uses: matteopolak/setup-jai@v1
  with:
    version: 0.4.3          # or v0.4.3; default: latest
    tools: jaic, jailsp     # default: all
```

Run on several platforms:

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, ubuntu-24.04-arm, macos-latest, macos-15-intel, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: matteopolak/setup-jai@v1
      - run: jaic run main.jai
```

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `version` | `latest` | `latest`, or an exact release such as `0.4.3` or `v0.4.3`. |
| `tools` | `all` | Comma or space separated subset of `jaic`, `jaifmt`, `jailint`, `jailsp`, or `all`. |
| `cache` | `true` | Cache the unpacked toolchain with `actions/cache`, keyed by version and platform. |
| `token` | `${{ github.token }}` | Token for the GitHub API call that resolves `latest`. Falls back to the unauthenticated redirect if the call fails. |

## Outputs

| Output | Description |
| --- | --- |
| `version` | The installed version, without a leading `v`. |
| `path` | The directory added to `PATH`. |

## Platforms

Linux x64 and arm64, macOS arm64 and x64, Windows x64 and arm64. Any other runner fails with an error naming it. Releases up to 0.4.1 have no macOS x64 or Linux arm64 archive; asking for one of those fails with a message saying so.

## Choosing tools

With `tools: all` the release folder itself is put on `PATH`. With a subset, the action creates a folder of links to just those tools. If links cannot be created (a Windows runner without symlink rights), it warns and puts the whole release folder on `PATH` instead.

## Versioning

Use the major tag, `matteopolak/setup-jai@v1`, to get compatible updates. The action's own version is independent of the toolchain version: `version` chooses the toolchain. For reproducible builds pin both, for example `@v1.0.0` and `version: 0.4.3`.

## License

AGPL-3.0, the same license as the toolchain. See [LICENSE](LICENSE).
