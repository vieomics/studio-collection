# Studio: code-server

Browser-based VS Code for Omicslab, built on the official Coder code-server
image. The container runs as root so users can `apt install` directly.

## At a glance

| Item | Value |
| --- | --- |
| Upstream image | `codercom/code-server:4.143.1-noble` |
| Application | code-server `4.143.1` (VS Code `1.143.1`) |
| Base OS | Ubuntu `24.04.5` LTS |
| User | `root` inside the container |
| Shell | `zsh` + Oh My Zsh |
| Web UI | `http://<host>:8080` (no login page) |
| Authentication | Disabled by design; platform/proxy handles access control |
| Persistent path | `/home/coder` |

## What is in the base image

- `/usr/bin/code-server` — code-server launcher
- `/usr/lib/code-server` — code-server payload and bundled Node.js `24.22.1`
  (not on `PATH`)
- `/usr/lib/code-server/ThirdPartyNotices.txt` — upstream third-party notices
- 99 built-in VS Code extensions (Git/GitHub, Copilot, Docker, Python/Jupyter/R
  language support, themes, ...)
- Ubuntu packages: `git`, `git-lfs`, `curl`, `wget`, `openssh-client`, `sudo`,
  `nano`, `vim-tiny`, `zsh`, `htop`, `man-db`, `procps`, `locales`, `dumb-init`,
  `fixuid`
- No Python, R, Node/npm on `PATH`, `gcc`, `make`, `jq`, or Docker CLI

## What we add

- **Pixi 0.83.0** at `/opt/pixi/bin/pixi`, on `PATH`
- **OpenCode CLI 2.2.0** at `/usr/local/bin/opencode`
- **nf-core extension pack 0.8.0** and its bundled extensions, installed from
  Open VSX. The pack is baked into the image and re-installed on first boot if
  a bind-mounted `/home/coder` hides it.
- **Zsh + Oh My Zsh**, installed under `/opt/oh-my-zsh` with `git`, `docker`,
  `docker-compose`, `history`, `rsync`, `safe-paste`, `zsh-autosuggestions`, and
  `zsh-syntax-highlighting`.
- **Dark Modern** first-boot theme and zsh terminal profile via
  `/entrypoint.d/10-studio-defaults`
- License notices at `/usr/share/doc/studio-collection/`

The nf-core extension pack provides editor support for Nextflow and related
tools. It does not install the Nextflow runtime; use Pixi or `apt` for that. The
Docker extensions also need a Docker CLI/daemon to be fully useful.

## Run

```bash
cd code-server
cp .env.example .env
docker compose up --build -d
```

Open <http://localhost:8080> directly; there is no login page.

Or with Docker directly:

```bash
docker run -d \
  --name studio-code-server \
  -p 8080:8080 \
  -v "$PWD/code-server/data:/home/coder" \
  --restart unless-stopped \
  studio-collection/code-server:4.143.1
```

## Root user

- `apt install <package>` works directly in the integrated terminal.
- Container root is **not** host root. Do not run the container privileged or
  mount the Docker socket unless you intentionally need that.
- Files written to `./data` are root-owned. If you need to manage them as your
  host user:
  `sudo chown -R "$(id -u):$(id -g)" code-server/data`
- There is no PUID/PGID or sudo-password wrapper. The upstream entrypoint runs
  with `--auth none`, so the IDE opens directly.
- `zsh` is the default shell for `root` and `coder`; `SHELL=/usr/bin/zsh` is set
  and the VS Code terminal profile is configured for zsh.

## Security notes

- The image is single-user. Run one container per user/session; there is no
  multi-user isolation inside the container.
- **There is no built-in authentication.** Anyone who can reach port 8080 gets
  the IDE and a root shell in the container. Put it behind the Omicslab
  platform/proxy, TLS, OIDC/SSO, or a private network.
- Do not expose port 8080 directly to the internet.
- Packages installed with `apt` at runtime are lost when the container is
  recreated. Put durable tools in the Dockerfile.
- OpenCode can send code/context to external model providers. Review its terms
  and data handling before using it on sensitive omics data.
- Pixi/conda packages and VS Code extensions have their own licenses; some
  omics tools are academic-only or non-commercial.

## Licensing

The image is a multi-license aggregate. It is **not MIT-only**.

| Component | License | What it means for you |
| --- | --- | --- |
| code-server and the official image build scripts | MIT | Commercial use, modification, and redistribution are allowed; keep the copyright/license notice. |
| Bundled Node.js and VS Code built-in extensions | MIT / third-party | Keep `/usr/lib/code-server/LICENSE` and `ThirdPartyNotices.txt`. |
| Ubuntu base packages (`git`, `nano`, `htop`, `wget`, `glibc`, ...) | GPL/LGPL/mixed | Using them is fine. If you distribute the image, keep `/usr/share/doc/*/copyright` and provide source or a written offer where required. Do not relicense them as MIT. |
| Pixi | BSD-3-Clause | Keep the copyright notice and disclaimer in binary distributions. |
| OpenCode | MIT | Keep the license text; review its AI-provider terms. |
| Oh My Zsh | MIT | Keep the license text. |
| zsh-autosuggestions | MIT | Keep the license text. |
| zsh-syntax-highlighting | BSD-3-Clause | Keep the copyright notice and disclaimer. |
| Our Dockerfile, theme script, and docs | MIT | Keep `LICENSE`. |

The main practical risk is not using these tools — it is:

1. stripping license notices,
2. describing the whole image as MIT-only,
3. adding a package or extension with a restrictive license,
4. distributing GPL/LGPL binaries without source/notice compliance.

If you only run the image internally on the platform, the GPL/LGPL source
obligations are much less of a concern than if users pull the image from a
public registry. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for the
detailed notices and the top-level [`README.md`](../README.md) for the licensing
summary.

This is not legal advice; have counsel review public/commercial distribution.

## Notes

- Add Python/R/Node/compilers in separate layers only if you need them, or use
  Pixi inside the workspace.
- `jq` is not installed; `apt install jq` works.
- The base image is ~916 MB; the built image is ~1.24 GB.
