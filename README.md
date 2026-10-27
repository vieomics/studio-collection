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

Or use the studio Makefile:

```bash
make -C code-server start
make -C code-server test
make -C code-server stop
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

Each studio has its own Makefile. Run these from the studio directory, or with
`make -C <studio>` from the repository root:

| Target | Description |
| --- | --- |
| `make dev` | Build `$(IMAGE_NAME):$(TAG)` |
| `make start` | Build and run the container as `<studio>-dev` on port `8080` |
| `make test` | Check health, no-login mode, zsh/plugins, nf-core extensions, Pixi, and OpenCode |
| `make stop` | Remove the studio container |
| `make publish` | Build and push `$(IMAGE_NAME):$(TAG)` to Docker Hub |

Defaults are in [`code-server/Makefile`](code-server/Makefile):

- `VERSION := 4.143.1`
- `TAG ?= $(VERSION)` (use `TAG=pr-1` for a test tag)
- `IMAGE_NAME ?= nttg8100/omicslab-code-server`
- `PORT ?= 8080`

Use `make -C code-server start PORT=18080` if port 8080 is already in use.
Override the image name with `make -C code-server publish IMAGE_NAME=<dockerhub-user>/<repo>`.

## Docker Hub CI

The workflow [`.github/workflows/test_and_publish.yml`](.github/workflows/test_and_publish.yml)
detects changed studio folders and builds them in parallel with a matrix:

- A studio is any top-level folder containing a `Makefile`.
- **Pull requests to `main`**: build, start, and test every changed studio.
- **Push to `main`**: build, test, and publish every changed studio.
- A workflow-file change selects all studios.
- Manual dispatch selects all studios.

### Publish a PR image for testing

Add the `publish-docker` label to a pull request to trigger publishing of the
changed studio images. PR publishes use the tag `pr-<number>` instead of the
version tag, so they do not overwrite the production tag:

```text
nttg8100/omicslab-code-server:pr-1
```

The publish job uses the `PROD` GitHub environment. Add these secrets there (or
as repository secrets):

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub account name |
| `DOCKERHUB_TOKEN` | Docker Hub access token with Read & Write permission |

The image name and version come from each studio's Makefile:
`nttg8100/omicslab-code-server:4.143.1` for `code-server` by default. Create
the Docker Hub repository first, or change `IMAGE_NAME` in the Makefile before
publishing. PR labels only publish for branches in this repository; fork PRs
cannot access the `PROD` secrets.

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
3. Copy the `code-server` scaffold (`Dockerfile`, `Makefile`, `compose.yaml`,
   `.env.example`, `.dockerignore`).
4. Set `VERSION` and `IMAGE_NAME` in the new `Makefile`.
5. Replace the inventory in `README.md` with the new image's actual contents.
6. Add the studio to the table above.

The CI discovers studios by finding top-level folders with a `Makefile`, so no
workflow edit is needed when a new studio is added.
