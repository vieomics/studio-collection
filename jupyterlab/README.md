# Studio: JupyterLab

JupyterLab studio for the Omicslab platform, built from Ubuntu and managed with
Pixi. Python and R kernels come from Pixi environments.

## At a glance

| Item | Value |
| --- | --- |
| Base image | `ubuntu:26.04` |
| JupyterLab | `4.6.4` (Pixi) |
| Python | `3.13` (Pixi) |
| R | `4.5.3` (Pixi) |
| User | `jovyan` (UID/GID `1000:100`) |
| Web UI | `http://<host>:8888/lab` (no login page) |
| Authentication | Disabled by design; platform/proxy handles access control |
| Persistent path | `/home/jovyan` |
| Kernel specs | `/usr/local/share/jupyter` |
| Built image size | Pixi cache removed at build time; check `docker image ls` |

## What is in the image

- Ubuntu 26.04
- JupyterLab 4.6.4 and the Python 3.13 kernel, installed with Pixi at
  `/opt/jupyter`
- Pixi R 4.5.3 with IRkernel at `/opt/r-kernel`
- Zsh + Oh My Zsh with `git`, `docker`, `docker-compose`, `history`, `rsync`,
  `safe-paste`, `zsh-autosuggestions`, and `zsh-syntax-highlighting`
- `git`, `curl`, build tools, and common R compilation libraries from Ubuntu
- No conda base environment and no Julia

## Kernels

| Kernel | Environment |
| --- | --- |
| `python-pixi` | `/opt/jupyter` (Python 3.13) |
| `ir-pixi` | `/opt/r-kernel` (R 4.5.3) |

New notebooks default to `python-pixi`. Select `ir-pixi` from the JupyterLab
launcher when you want the R environment. JupyterLab/ipykernel also exposes a
`python3` alias that points to the same Pixi Python environment.

## Run

```bash
cd jupyterlab
cp .env.example .env
docker compose up --build -d
```

Open <http://localhost:8888/lab>. There is no token/password prompt.

Or from the repository root:

```bash
make -C jupyterlab start
make -C jupyterlab test
make -C jupyterlab stop
```

Makefile defaults:

- `VERSION := 2026-10-26`
- `IMAGE_NAME ?= nttg8100/omicslab-jupyterlab`
- `PORT ?= 8888`

## Install packages

### Python

```bash
cd /opt/jupyter
pixi add numpy pandas scikit-learn
```

The Python kernel and JupyterLab share this environment. Restart the kernel
after adding packages.

### R

```bash
cd /opt/r-kernel
pixi add r-<package>
```

If a package is not available from conda-forge for R 4.5.3, install it with R
from the `ir-pixi` kernel:

```r
install.packages("<package>")
```

## Security notes

- **No built-in authentication.** Anyone who can reach port 8888 gets
  JupyterLab as `jovyan`. Use the Omicslab platform/proxy, TLS, OIDC, or a
  private network. Do not expose 8888 to the internet.
- The application runs as the unprivileged `jovyan` user. The entrypoint starts
  as root only long enough to fix the home directory and drop privileges.
- The image is single-user. Run one container per user/session.
- Runtime Pixi/pip/R installs are lost when the container is recreated. Put
  durable tools in the Dockerfile.

## Licensing

The image is a multi-license aggregate. It is **not MIT-only**.

| Component | License | Notes |
| --- | --- | --- |
| Ubuntu 26.04 | GPL/LGPL/mixed | Keep the distro notices. |
| JupyterLab / Jupyter Server | BSD-3-Clause | Keep the notices. |
| Python | PSF-2.0 | Keep the PSF license. |
| R | GPL-2.0 / GPL-3.0 | Keep the R license. |
| Pixi | BSD-3-Clause | Keep the copyright notice and disclaimer. |
| Oh My Zsh | MIT | Keep the license text. |
| zsh-autosuggestions | MIT | Keep the license text. |
| zsh-syntax-highlighting | BSD-3-Clause | Keep the copyright notice and disclaimer. |
| Our Dockerfile, entrypoint, Makefile, zsh config, and docs | MIT | Keep `LICENSE`. |

License texts are in [`LICENSES/`](LICENSES/) and are copied into the image under
`/usr/share/doc/studio-collection/`. Packages installed later keep their own
licenses; some bioinformatics packages are academic-only or non-commercial.

This image does not contain RStudio Server (AGPL) or the large datascience
stack. The main copyleft components are Ubuntu's GPL/LGPL packages and R itself.
