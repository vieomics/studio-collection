# syntax=docker/dockerfile:1
# SPDX-License-Identifier: MIT

# Omicslab Studio: RStudio Server
#
# Upstream: rocker/rstudio:4.6.1
#   R 4.6.1, RStudio Server 2026.10.0+233, Ubuntu 24.04
#
# Additions:
#   - Zsh + Oh My Zsh with the same plugin set as the code-server studio
#   - Pixi 0.83.0 and a Pixi R 4.6.1 environment at /opt/r-pixi
#   - IRkernel and rstudioapi installed in the Pixi R environment
#   - RStudio Server uses the Pixi R binary
#   - RStudio authentication disabled; platform/proxy handles access control

FROM rocker/rstudio:4.6.1

ARG RSTUDIO_VERSION=4.6.1
ARG PIXI_VERSION=0.83.0
ARG R_PIXI_VERSION=4.6.1

LABEL org.opencontainers.image.title="Omicslab Studio: RStudio Server" \
      org.opencontainers.image.version="${RSTUDIO_VERSION}" \
      org.opencontainers.image.source="https://github.com/vieomics/studio-collection" \
      org.opencontainers.image.base.name="rocker/rstudio:4.6.1" \
      io.omicslab.studio="rstudio" \
      io.omicslab.pixi.version="${PIXI_VERSION}" \
      io.omicslab.r.version="${R_PIXI_VERSION}" \
      io.omicslab.licenses="See /usr/share/doc/studio-collection/THIRD_PARTY_NOTICES.md"

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/usr/bin/zsh
ENV DISABLE_AUTH=true
ENV R_HOME=/opt/r-pixi/.pixi/envs/default/lib/R
ENV PATH="/opt/pixi/bin:/opt/r-pixi/.pixi/envs/default/bin:${PATH}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      zsh \
      libzmq3-dev \
      uuid-dev \
      libssl-dev \
      libcurl4-openssl-dev \
      libxml2-dev \
      pkg-config \
      jupyter-core \
      jupyter-client; \
    rm -rf /var/lib/apt/lists/*

# Pixi
RUN set -eux; \
    curl -fsSL https://pixi.sh/install.sh | \
      PIXI_HOME=/opt/pixi \
      PIXI_VERSION="${PIXI_VERSION}" \
      PIXI_NO_PATH_UPDATE=1 \
      PIXI_NO_TELEMETRY=1 \
      sh; \
    pixi --version; \
    rm -rf /tmp/pixi* /root/.cache/rattler /root/.cache/pixi /root/.pixi

# Pixi R 4.6.1 environment with conda-forge and bioconda.
RUN set -eux; \
    export PIXI_CACHE_DIR=/tmp/pixi-cache; \
    pixi init /opt/r-pixi --channel conda-forge --channel bioconda; \
    cd /opt/r-pixi; \
    pixi add "r-base=${R_PIXI_VERSION}"; \
    pixi run R --version | head -2; \
    rm -rf /tmp/pixi-cache /root/.cache/rattler /root/.cache/pixi /root/.pixi

# rstudioapi is needed by the RStudio IDE; BiocManager is the standard
# fallback for Bioconductor packages not available as R 4.6.1 Pixi builds.
RUN set -eux; \
    export PIXI_CACHE_DIR=/tmp/pixi-cache; \
    cd /opt/r-pixi; \
    pixi run Rscript -e 'install.packages(c("rstudioapi", "BiocManager"), repos = "https://cloud.r-project.org")'; \
    pixi run Rscript -e 'stopifnot(requireNamespace("rstudioapi", quietly = TRUE)); stopifnot(requireNamespace("BiocManager", quietly = TRUE))'; \
    touch /opt/r-pixi/.pixi/envs/default/lib/R/etc/Renviron.site; \
    chown -R rstudio:rstudio /opt/r-pixi; \
    rm -rf /tmp/pixi-cache /tmp/Rtmp* /root/.cache/rattler /root/.cache/pixi /root/.pixi

# Zsh + Oh My Zsh, installed system-wide so a home volume does not hide it.
COPY --chmod=644 zsh/zshrc /etc/zsh/zshrc.omz
RUN set -eux; \
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /opt/oh-my-zsh; \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
      /opt/oh-my-zsh/custom/plugins/zsh-autosuggestions; \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
      /opt/oh-my-zsh/custom/plugins/zsh-syntax-highlighting; \
    rm -rf \
      /opt/oh-my-zsh/.git \
      /opt/oh-my-zsh/custom/plugins/zsh-autosuggestions/.git \
      /opt/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git; \
    cat /etc/zsh/zshrc.omz >> /etc/zsh/zshrc; \
    rm -f /etc/zsh/zshrc.omz; \
    usermod -s /usr/bin/zsh root; \
    usermod -s /usr/bin/zsh rstudio; \
    sed -i 's/"posix_terminal_shell": "bash"/"posix_terminal_shell": "zsh"/' \
      /home/rstudio/.config/rstudio/rstudio-prefs.json

# RStudio Server: use the Pixi R and disable app-level auth.
RUN printf 'rsession-which-r=%s\nauth-none=1\n' \
      "/opt/r-pixi/.pixi/envs/default/bin/R" \
      > /etc/rstudio/disable_auth_rserver.conf

# License notices shipped with the image.
COPY LICENSE /usr/share/doc/studio-collection/LICENSE
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/studio-collection/THIRD_PARTY_NOTICES.md
COPY LICENSES/ /usr/share/doc/studio-collection/LICENSES/

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD curl -fsS -o /dev/null http://127.0.0.1:8787/ || exit 1

EXPOSE 8787
