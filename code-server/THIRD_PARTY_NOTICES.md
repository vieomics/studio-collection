# Third-party notices

This image is an aggregate of independently licensed software. The MIT license
in the repository root covers the original Omicslab code in this repository. It
does **not** relicense the third-party components listed below, and the image as
a whole is not "MIT-only".

The full MIT and BSD license texts for the components added by this studio are
in `LICENSES/` and are copied into the image at
`/usr/share/doc/studio-collection/LICENSES/`. The MIT license for the original
Omicslab code is copied into the image at
`/usr/share/doc/studio-collection/LICENSE`.

## Components added or configured by this repository

| Component | Version | License | Source |
| --- | --- | --- | --- |
| code-server | 4.143.1 | MIT | <https://github.com/coder/code-server/tree/v4.143.1> |
| code-server container image | 4.143.1-noble | MIT | <https://github.com/coder/code-server/tree/v4.143.1/ci/release-image> |
| Pixi | 0.83.0 | BSD-3-Clause | <https://github.com/prefix-dev/pixi/tree/v0.83.0> |
| OpenCode CLI | 2.2.0 | MIT | <https://github.com/anomalyco/opencode> |
| nf-core extension pack | 0.8.0 | MIT | <https://github.com/nf-core/vscode-extensionpack> |
| Oh My Zsh | master at build time | MIT | <https://github.com/ohmyzsh/ohmyzsh> |
| zsh-autosuggestions | master at build time | MIT | <https://github.com/zsh-users/zsh-autosuggestions> |
| zsh-syntax-highlighting | master at build time | BSD-3-Clause | <https://github.com/zsh-users/zsh-syntax-highlighting> |

License texts:

- `LICENSES/MIT-code-server.txt` — Copyright (c) 2019 Coder Technologies Inc.
- `LICENSES/BSD-3-Clause-pixi.txt` — Copyright (c) 2023 prefix.dev GmbH
- `LICENSES/MIT-opencode.txt` — Copyright (c) 2025 opencode
- `LICENSES/MIT-nfcore-extensionpack.txt` — Copyright (c) 2018 nf-core
- `LICENSES/MIT-oh-my-zsh.txt` — Copyright (c) 2009-2026 Robby Russell and contributors
- `LICENSES/MIT-zsh-autosuggestions.txt` — Copyright (c) 2013 Thiago de Arruda, 2016-2021 Eric Freese
- `LICENSES/BSD-3-Clause-zsh-syntax-highlighting.txt` — Copyright (c) 2010-2020 zsh-syntax-highlighting contributors

## Base operating system

The image is based on Ubuntu 24.04.5 LTS (`noble`). Ubuntu packages are
independently licensed. Common licenses include GPL-2.0 and GPL-3.0 (including
or-later variants), LGPL-2.1 and LGPL-3.0, MIT, BSD, ISC, and Apache-2.0.
Notable GPL packages include `git` (GPL-2.0), `nano` (GPL-3.0-or-later), and
`htop` (GPL-2.0-or-later). Those programs are separate works in the image, not
part of the MIT-licensed Omicslab code.

- Copyright and license texts: `/usr/share/doc/<package>/copyright` and
  `/usr/share/common-licenses/` inside the image.
- Source code: <https://launchpad.net/ubuntu/noble> and
  <http://archive.ubuntu.com/ubuntu/>.

## code-server and VS Code components

- code-server: MIT, Copyright (c) 2019 Coder Technologies Inc.
- VS Code / Code-OSS built-in extensions: MIT or their own licenses. See
  `/usr/lib/code-server/LICENSE`,
  `/usr/lib/code-server/ThirdPartyNotices.txt`, and
  `/usr/lib/code-server/lib/vscode/extensions/*/LICENSE` inside the image.
- Extensions installed later from Open VSX are licensed by their publishers.
  Review an extension's license before baking it into the image.

## nf-core extension pack

The image installs `nf-core.nf-core-extensionpack` 0.8.0 and its bundled VS Code
extensions from Open VSX:

- `charliermarsh.ruff` — MIT
- `codezombiech.gitignore` — MIT
- `EditorConfig.EditorConfig` — MIT
- `esbenp.prettier-vscode` — MIT
- `Gruntfuggly.todo-tree` — MIT
- `jebbs.markdown-extended` — MIT
- `mechatroner.rainbow-csv` — MIT
- `ms-azuretools.vscode-docker` — MIT (Microsoft)
- `ms-azuretools.vscode-containers` — MIT (Microsoft)
- `nextflow.nextflow` — MIT-style
- `onnovalkering.vscode-singularity` — MIT
- `redhat.vscode-yaml` — MIT

Each extension keeps its own `LICENSE`/`package.json` under
`/home/coder/.local/share/code-server/extensions/`. The pack itself is MIT; its
license text is `LICENSES/MIT-nfcore-extensionpack.txt`. Extensions installed
later by users are licensed by their publishers.

## Zsh and Oh My Zsh

Oh My Zsh and its bundled plugins are MIT-licensed. The image enables:

`git`, `docker`, `docker-compose`, `history`, `rsync`, `safe-paste`,
`zsh-autosuggestions`, and `zsh-syntax-highlighting`.

The first six are part of Oh My Zsh. The last two are separate MIT and
BSD-3-Clause projects; their license texts are in `LICENSES/`. The `zsh` shell
itself comes from the Ubuntu base and retains its own Zsh license.

## Runtime helper binaries

| Component | License | License text |
| --- | --- | --- |
| `fixuid` 0.6.0 | MIT | `LICENSES/MIT-fixuid.txt` (Copyright (c) 2017 BoxBoat Technologies, LLC) |
| `dumb-init` | MIT | `LICENSES/MIT-dumb-init.txt` (Copyright (c) 2015 Yelp, Inc.) |
| `git-lfs` | MIT | `/usr/share/doc/git-lfs/copyright` |
| `zsh` | permissive | `/usr/share/doc/zsh/copyright` |
| `sudo` | ISC | `/usr/share/doc/sudo/copyright` |
| `curl` | MIT-like | `/usr/share/doc/curl/copyright` |
| `openssh-client` | BSD-style | `/usr/share/doc/openssh-client/copyright` |

## Source availability

The source for the Omicslab-specific files is this repository:
<https://github.com/vieomics/studio-collection>

Upstream sources:

- code-server 4.143.1: <https://github.com/coder/code-server/tree/v4.143.1>
- code-server image build: <https://github.com/coder/code-server/tree/v4.143.1/ci/release-image>
- Pixi 0.83.0: <https://github.com/prefix-dev/pixi/tree/v0.83.0>
- OpenCode 2.2.0: <https://github.com/anomalyco/opencode>
- Ubuntu 24.04: <https://launchpad.net/ubuntu/noble>

If you distribute this image, you are responsible for complying with the
licenses of every component, including providing corresponding source or a valid
written offer for GPL/LGPL components. The license texts and notices are in
`/usr/share/doc/studio-collection/`. See the repository README for the licensing
summary: <https://github.com/vieomics/studio-collection#licensing>.
