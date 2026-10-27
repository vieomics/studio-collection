# studio-collection

The collection of studio images used as web applications on the Omicslab
platform. Each studio is a self-contained Docker image built from a pinned
upstream base, with its own build context, documentation, and local compose
setup.

## Studios

| Studio | Directory | Base image | Web port | Notes |
| --- | --- | --- | --- | --- |
| code-server | [`code-server/`](code-server/) | `codercom/code-server:4.143.1-noble` | `8080` | Root runtime, direct `apt`, Zsh/Oh My Zsh, Pixi, OpenCode, nf-core extension pack, Dark Modern; auth handled by the platform |

## Repository conventions

- **Pin the base image.** Use an exact upstream tag (and record the digest).
  Never build from `latest`.
- **One directory per studio.** Each directory contains a `Dockerfile`,
  `README.md`, `compose.yaml`, and `.env.example`.
- **Use the upstream user model.** The code-server studio runs as root so
  `apt install` works directly. Document that container root is not host root.
- **Keep runtime state in the home volume.** For code-server, that is
  `/home/coder`. Anything baked into that path at build time is hidden when the
  volume is mounted.
- **Document the inventory.** Each studio README lists what the base image
  contains, what this repository adds, and what is intentionally absent.
- **Add features in small layers.** One `RUN` per feature group, with
  `apt-get clean` and package-list cleanup.
- **Verify before publishing.** Build locally and check the health endpoint,
  tool versions, first-boot settings, and the process user.

## Build and run

Build a studio directly:

```bash
docker build -t studio-collection/code-server:4.143.1 code-server
```

Or use its compose file:

```bash
cd code-server
cp .env.example .env
docker compose up --build -d
docker compose logs -f
```

Then open <http://localhost:8080> directly. The image has **no built-in
authentication**; protect it with the platform/proxy or a private network.

Or use the Makefile:

```bash
make start
make test
make stop
```

## Additional features

The code-server studio adds:

| Feature | What it does |
| --- | --- |
| Pixi 0.83.0 | Reproducible Python/conda environments from the IDE terminal. |
| OpenCode CLI 2.2.0 | AI coding agent available as `opencode`. |
| nf-core extension pack 0.8.0 | Nextflow/nf-core VS Code extensions, installed from Open VSX. |
| Zsh + Oh My Zsh | Default shell with git, docker, docker-compose, history, rsync, safe-paste, autosuggestions, and syntax highlighting. |
| Dark Modern theme | First-boot VS Code theme default. |
| Root runtime | `apt install` works directly in the integrated terminal. |
| License notices | `LICENSE`, `THIRD_PARTY_NOTICES.md`, and third-party license texts shipped in the image. |

## Make targets

Run these from the repository root:

| Target | Description |
| --- | --- |
| `make dev` | Build `$(IMAGE_NAME):$(VERSION)` |
| `make start` | Build and run the container as `code-server-dev` on port `8080` |
| `make test` | Check health, no-login mode, zsh/plugins, nf-core extensions, Pixi, and OpenCode |
| `make stop` | Remove `code-server-dev` |
| `make publish` | Build and push `$(IMAGE_NAME):$(VERSION)` to Docker Hub |

Defaults are in the [`Makefile`](Makefile):

- `VERSION := 4.143.1`
- `IMAGE_NAME ?= nttg8100/omicslab-code-server`
- `PORT ?= 8080`

Use `make start PORT=18080` if port 8080 is already in use. Override the image
name with `make publish IMAGE_NAME=<dockerhub-user>/<repo>`.

## Docker Hub CI

The workflow [`.github/workflows/test_and_publish.yml`](.github/workflows/test_and_publish.yml)
follows the same Makefile-driven pattern:

- **Pull requests to `main`**: build, start, and test the image.
- **Push to `main`**: build, test, then publish to Docker Hub.

The publish job uses the `PROD` GitHub environment. Add these secrets there (or
as repository secrets):

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub account name |
| `DOCKERHUB_TOKEN` | Docker Hub access token with Read & Write permission |

The image name and version come from the `Makefile`:
`nttg8100/omicslab-code-server:4.143.1` by default. Create the Docker Hub
repository first, or change `IMAGE_NAME` in the Makefile before publishing.

## Licensing

Original code in this repository is MIT-licensed (see [`LICENSE`](LICENSE)).
The images include third-party components under their own licenses:

| Component | License |
| --- | --- |
| code-server and the official image build scripts | MIT |
| Ubuntu 24.04 packages | GPL/LGPL/mixed |
| Pixi | BSD-3-Clause |
| OpenCode | MIT |
| Oh My Zsh | MIT |
| zsh-autosuggestions | MIT |
| zsh-syntax-highlighting | BSD-3-Clause |

The image is **not MIT-only**. Keep the notices inside each image. If you
distribute images publicly, provide corresponding source or a written offer for
GPL/LGPL components where required. Check the license of any new package or VS
Code extension before adding it. See each studio's `THIRD_PARTY_NOTICES.md` for
the detailed notices.

## Adding the next studio

1. Create `<studio>/`.
2. Pin the upstream image in `FROM`.
3. Copy the `code-server` scaffold (`Dockerfile`, `compose.yaml`,
   `.env.example`, `.dockerignore`).
4. Replace the inventory in `README.md` with the new image's actual contents.
5. Add the studio to the table above.
