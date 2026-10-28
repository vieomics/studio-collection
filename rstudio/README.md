# Studio: RStudio Server

RStudio Server for the Omicslab platform, built on `rocker/rstudio:4.6.1`.
The image runs RStudio with the Pixi-managed R 4.6.1 environment, and keeps the
same zsh/Oh My Zsh setup as the code-server studio.

## At a glance

| Item | Value |
| --- | --- |
| Upstream image | `rocker/rstudio:4.6.1` |
| R | `4.6.1` |
| RStudio Server | `2026.10.0+233` |
| Base OS | Ubuntu `24.04.5` LTS |
| User | `rstudio` (UID/GID `1000`) |
| R runtime used by RStudio | Pixi R `4.6.1` at `/opt/r-pixi` |
| Shell | `zsh` + Oh My Zsh |
| Web UI | `http://<host>:8787` (no login page) |
| Authentication | Disabled by design; platform/proxy handles access control |
| Persistent path | `/home/rstudio` |

## What is in the base image

- RStudio Server 2026.10.0+233 at `/usr/local/bin/rserver`
- R 4.6.1 at `/usr/local/bin/R` (`R_HOME=/usr/local/lib/R`)
- Pandoc and Quarto
- Default user `rstudio` (UID/GID 1000, home `/home/rstudio`)
- `gcc`, `g++`, `make`, `git`, `wget`, `python3`, `sudo`
- No `zsh`, `curl`, `jq`, or Pixi
- s6-overlay v2 init at `/init`, RStudio on port `8787`

## What we add

- **Zsh + Oh My Zsh** at `/opt/oh-my-zsh`, with `git`, `docker`,
  `docker-compose`, `history`, `rsync`, `safe-paste`, `zsh-autosuggestions`,
  and `zsh-syntax-highlighting`
- **Pixi 0.83.0** at `/opt/pixi/bin/pixi`
- **Pixi R 4.6.1 environment** at `/opt/r-pixi`, with `rstudioapi` installed
- RStudio Server is configured to use
  `/opt/r-pixi/.pixi/envs/default/bin/R`
- RStudio's terminal preference is zsh
- RStudio authentication is disabled (`DISABLE_AUTH=true`) so the platform/proxy
  owns access control
- License notices at `/usr/share/doc/studio-collection/`

## R packages

RStudio uses the Pixi R 4.6.1 runtime. The `rsession` process starts R from
`/opt/r-pixi/.pixi/envs/default/lib/R/bin/exec/R`.

### Install with Pixi

```bash
cd /opt/r-pixi
pixi add r-<package>
```

This updates the Pixi environment used by RStudio. It works when conda-forge
has a build for R 4.6.1. Some R packages are still built only for older R
versions; for example, `pixi add r-jsonlite` fails to solve against R 4.6.1.

### Install with CRAN

If Pixi has no compatible build, use R's normal package installer from the
RStudio console or a terminal:

```r
install.packages("<package>", repos = "https://cloud.r-project.org")
```

CRAN packages install into the `rstudio` user library under
`/home/rstudio/R/...`. Both pure-R and compiled packages were verified:

- `install.packages("crayon")` — pure R, works
- `install.packages("Rcpp")` — compiled C++, works

The RStudio session sees the Pixi environment library and the user library, so
packages installed through either path are available after the session reloads.

## Run

```bash
cd rstudio
cp .env.example .env
docker compose up --build -d
```

Open <http://localhost:8787>. There is no login page; RStudio loads directly.

Or from the repository root:

```bash
make -C rstudio start
make -C rstudio test
make -C rstudio stop
```

The Makefile defaults:

- `VERSION := 4.6.1`
- `IMAGE_NAME ?= nttg8100/omicslab-rstudio`
- `PORT ?= 8787`

## Security notes

- **No built-in authentication.** Anyone who can reach port 8787 gets RStudio
  as the `rstudio` user. Use the Omicslab platform/proxy, TLS, OIDC, or a
  private network. Do not expose 8787 to the internet.
- The image is single-user. Run one container per user/session.
- `apt` and `pixi` installs at runtime are lost when the container is recreated.
  Put durable tools in the Dockerfile.
- RStudio Server is AGPL-3.0; see the licensing note below.

## Licensing

The image is a multi-license aggregate. It is **not MIT-only**.

| Component | License | Notes |
| --- | --- | --- |
| RStudio Server | AGPL-3.0 | Network use triggers AGPL source/notice obligations. Source: <https://github.com/rstudio/rstudio>. |
| R | GPL-2.0 / GPL-3.0 | Keep the R license notices. |
| rocker/rstudio image scripts | GPL-2.0-or-later | Upstream: <https://github.com/rocker-org/rocker-versioned2>. |
| Ubuntu base packages | GPL/LGPL/mixed | See `/usr/share/doc/*/copyright`. |
| Pixi | BSD-3-Clause | Keep the copyright notice and disclaimer. |
| Oh My Zsh | MIT | Keep the license text. |
| zsh-autosuggestions | MIT | Keep the license text. |
| zsh-syntax-highlighting | BSD-3-Clause | Keep the copyright notice and disclaimer. |
| Our Dockerfile, Makefile, zsh config, and docs | MIT | Keep `LICENSE`. |

License texts are in [`LICENSES/`](LICENSES/) and are copied into the image under
`/usr/share/doc/studio-collection/`. R packages installed later from CRAN or
conda-forge keep their own licenses; some bioinformatics packages are
academic-only or non-commercial.

## Notes

- The base image is large (~5–6 GB uncompressed with the Pixi R environment and
  RStudio Server). Check `docker image ls` after building.
- RStudio Server does not use Jupyter/IRkernel; its R session is the R kernel.
- The container logs may show harmless `chpasswd` warnings because Rocker's init
  still tries to set a Unix password while authentication is disabled. RStudio
  itself is unaffected.
