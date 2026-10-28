# syntax=docker/dockerfile:1
# SPDX-License-Identifier: MIT

# Omicslab Studio: JupyterLab
#
# Base: ubuntu:26.04
#   JupyterLab, Python, and R are installed through Pixi.
#
# Additions:
#   - Zsh + Oh My Zsh with the same plugin set as the other studios
#   - Pixi 0.83.0
#   - Pixi JupyterLab + Python 3.13 + ipykernel (python-pixi kernel)
#   - Pixi R 4.5.3 + IRkernel (ir-pixi kernel)
#   - Jupyter authentication disabled; platform/proxy handles access control

FROM ubuntu:26.04

ARG PIXI_VERSION=0.83.0
ARG PYTHON_VERSION=3.13
ARG R_VERSION=4.5.3

LABEL org.opencontainers.image.title="Omicslab Studio: JupyterLab" \
      org.opencontainers.image.version="2026-10-26" \
      org.opencontainers.image.source="https://github.com/vieomics/studio-collection" \
      org.opencontainers.image.base.name="ubuntu:26.04" \
      io.omicslab.studio="jupyterlab" \
      io.omicslab.pixi.version="${PIXI_VERSION}" \
      io.omicslab.python.version="${PYTHON_VERSION}" \
      io.omicslab.r.version="${R_VERSION}" \
      io.omicslab.licenses="See /usr/share/doc/studio-collection/THIRD_PARTY_NOTICES.md"

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/usr/bin/zsh
ENV PIXI_NO_TELEMETRY=1
ENV PATH="/opt/pixi/bin:${PATH}"
ENV JUPYTER_PATH=/usr/local/share/jupyter
ENV LANG=C.UTF-8

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      git \
      locales \
      pkg-config \
      procps \
      tini \
      tzdata \
      util-linux \
      zsh \
      libzmq3-dev \
      uuid-dev \
      libssl-dev \
      libcurl4-openssl-dev \
      libxml2-dev; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd -g 100 users 2>/dev/null || true; \
    if getent passwd 1000 >/dev/null; then \
      existing_user="$(getent passwd 1000 | cut -d: -f1)"; \
      userdel -r "$existing_user" 2>/dev/null || userdel "$existing_user"; \
    fi; \
    useradd -m -u 1000 -g users -s /usr/bin/zsh jovyan; \
    usermod -s /usr/bin/zsh root

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

# Pixi JupyterLab + Python kernel
RUN set -eux; \
    export PIXI_CACHE_DIR=/tmp/pixi-cache; \
    pixi init /opt/jupyter --channel conda-forge; \
    cd /opt/jupyter; \
    pixi add "python=${PYTHON_VERSION}" "jupyterlab=4.6.4" ipykernel; \
    pixi run python -m ipykernel install \
      --prefix=/usr/local \
      --name python-pixi \
      --display-name "Python (Pixi)"; \
    rm -rf /opt/jupyter/.pixi/envs/default/share/jupyter/kernels/python3; \
    rm -rf /opt/jupyter/.pixi/envs/default/lib/python*/site-packages/ipykernel/resources; \
    rm -rf /tmp/pixi-cache /root/.cache/rattler /root/.cache/pixi /root/.pixi

# Pixi R kernel
RUN set -eux; \
    export PIXI_CACHE_DIR=/tmp/pixi-cache; \
    pixi init /opt/r-kernel --channel conda-forge; \
    cd /opt/r-kernel; \
    pixi add "r-base=${R_VERSION}" r-irkernel; \
    PATH="/opt/jupyter/.pixi/envs/default/bin:${PATH}" \
      pixi run Rscript -e 'IRkernel::installspec(name = "ir-pixi", displayname = "R (Pixi)", user = FALSE)'; \
    rm -rf /tmp/pixi-cache /root/.cache/rattler /root/.cache/pixi /root/.pixi

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
    chown -R jovyan:users /opt/jupyter /opt/r-kernel /home/jovyan

COPY --chmod=755 start-jupyter.sh /usr/local/bin/start-jupyter.sh

# License notices shipped with the image.
COPY LICENSE /usr/share/doc/studio-collection/LICENSE
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/studio-collection/THIRD_PARTY_NOTICES.md
COPY LICENSES/ /usr/share/doc/studio-collection/LICENSES/

WORKDIR /home/jovyan

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -fsS -o /dev/null http://127.0.0.1:8888/lab || exit 1

EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/usr/local/bin/start-jupyter.sh"]
