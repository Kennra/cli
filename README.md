# Kennra CLI

Kennra from the terminal: customers, companies, deals and your workspace's structure (traits, Kinds,
pipelines, programs and segments) as code, through Kennra's public API with your own access.

Full documentation: **https://kennra.com/docs/cli**

## Install

macOS and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/Kennra/cli/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/Kennra/cli/main/install.ps1 | iex
```

With [Bun](https://bun.sh), or npm on Node 22 or newer:

```sh
bun add -g kennra      # or: npm i -g kennra
bunx kennra --help     # run it once without installing (or: npx kennra --help)
```

Or download the binary for your system from the [latest release](https://github.com/Kennra/cli/releases/latest)
and check it against `SHA256SUMS`:

| System | File |
|---|---|
| macOS, Apple silicon | `kennra-darwin-arm64` |
| macOS, Intel | `kennra-darwin-x64` |
| Linux, x64 | `kennra-linux-x64` |
| Linux, arm64 | `kennra-linux-arm64` |
| Windows, x64 | `kennra-windows-x64.exe` |

The binaries contain their own runtime, so you need neither Node nor anything else.

> **macOS:** the binaries are not signed yet. The install script works as is. If you download a binary
> with a browser, remove the quarantine flag once: `xattr -d com.apple.quarantine kennra-darwin-arm64`.

## Sign in

Create a developer token in Kennra (Developers → Tokens), then pipe it in:

```sh
pbpaste | kennra login --token-stdin
kennra whoami
```

`kennra whoami` shows the workspace and what your access allows. To work on a workspace's structure you
need schema rights; see the documentation. Signing in through the browser comes in a later version.

## Reporting problems

Open an [issue](https://github.com/Kennra/cli/issues) with the output of `kennra --version` and the command
you ran. Never paste a token.

## Licence

MIT, see [LICENSE](LICENSE). The CLI is developed in Kennra's main repository and published here.
