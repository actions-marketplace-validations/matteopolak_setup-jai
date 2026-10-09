# setup-jai

Install the [Jai toolchain](https://github.com/matteopolak/jai) (`jaic`, `jaifmt`, `jailint`, `jailsp`) in GitHub Actions.

```yaml
- uses: matteopolak/setup-jai@v1
- run: jaic --version
```

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `version` | `latest` | `latest`, or a release such as `0.4.3` or `v0.4.3`. |
| `tools` | `all` | Comma or space separated subset of `jaic`, `jaifmt`, `jailint`, `jailsp`, or `all`. |
| `cache` | `true` | Cache the unpacked toolchain, keyed by version and platform. |
| `token` | `${{ github.token }}` | Token for resolving `latest` through the GitHub API. |

## Outputs

| Output | Description |
| --- | --- |
| `version` | Installed version, without a leading `v`. |
| `path` | Directory added to `PATH`. |

The action also sets `JAIC_STDLIB` to the bundled standard library, and checks the archive against the release's `SHA256SUMS`.

## Example

```yaml
name: ci
on: [push, pull_request]

jobs:
  check:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: matteopolak/setup-jai@v1
        with:
          version: 0.4.3
      - run: jaifmt --check .
      - run: jailint -D warnings .
      - run: jaic build main.jai
```

## Platforms

Linux x64 and arm64, macOS arm64 and x64, Windows x64 and arm64. Releases up to 0.4.1 have no macOS x64 or Linux arm64 build; requesting one fails with a clear error. With a `tools` subset the action links just those tools, or puts the whole release folder on `PATH` if links cannot be created.

## Versioning

Use `@v1` for compatible updates, or a full tag such as `@v1.0.0`. The action's version is independent of the toolchain version, which `version` selects. The toolchain lives in [matteopolak/jai](https://github.com/matteopolak/jai).

## License

MIT
