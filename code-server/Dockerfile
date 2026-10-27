# syntax=docker/dockerfile:1
# SPDX-License-Identifier: MIT

# Omicslab Studio: code-server
#
# Upstream: codercom/code-server:4.143.1-noble
#   code-server 4.143.1 (VS Code 1.143.1), Ubuntu 24.04
#
# Additions:
#   - Pixi 0.83.0
#   - OpenCode CLI 2.2.0
#   - nf-core extension pack 0.8.0
#   - Zsh + Oh My Zsh with git/docker/docker-compose/history/rsync/safe-paste,
#     zsh-autosuggestions, and zsh-syntax-highlighting
#   - Dark Modern first-boot theme
#   - code-server authentication disabled by design (platform/proxy handles auth)
#
# The container runs as root so users can run `apt install` directly in the
# integrated terminal.

FROM codercom/code-server:4.143.1-noble

ARG STUDIO_VERSION=4.143.1
ARG PIXI_VERSION=0.83.0
ARG OPENCODE_VERSION=2.2.0
ARG NFCORE_EXTENSIONPACK_VERSION=0.8.0

LABEL org.opencontainers.image.title="Omicslab Studio: code-server" \
      org.opencontainers.image.version="${STUDIO_VERSION}" \
      org.opencontainers.image.source="https://github.com/vieomics/studio-collection" \
      org.opencontainers.image.base.name="codercom/code-server:4.143.1-noble" \
      io.omicslab.studio="code-server" \
      io.omicslab.nfcore-extensionpack.version="${NFCORE_EXTENSIONPACK_VERSION}" \
      io.omicslab.licenses="See /usr/share/doc/studio-collection/THIRD_PARTY_NOTICES.md"

USER root

ENV HOME=/home/coder
ENV NFCORE_EXTENSIONPACK_VERSION="${NFCORE_EXTENSIONPACK_VERSION}"
ENV SHELL=/usr/bin/zsh
ENV PATH="/opt/pixi/bin:${PATH}"

RUN set -eux; \
    mkdir -p /home/coder; \
    curl -fsSL https://pixi.sh/install.sh | \
      PIXI_HOME=/opt/pixi \
      PIXI_VERSION="${PIXI_VERSION}" \
      PIXI_NO_PATH_UPDATE=1 \
      PIXI_NO_TELEMETRY=1 \
      sh; \
    pixi --version

RUN set -eux; \
    mkdir -p /opt/opencode; \
    export HOME=/opt/opencode SHELL=/bin/bash; \
    curl -fsSL https://opencode.ai/v2/install | \
      bash -s -- --version "${OPENCODE_VERSION}" --no-modify-path; \
    install -m 0755 /opt/opencode/.opencode/bin/opencode /usr/local/bin/opencode; \
    rm -rf /opt/opencode; \
    opencode --version

# Zsh + Oh My Zsh. Installed under /opt so a mounted /home/coder does not hide
# it. The config is appended to the system-wide /etc/zsh/zshrc.
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
    usermod -s /usr/bin/zsh coder

# nf-core extension pack and its bundled extensions (all from Open VSX).
# Baked into /home/coder for runs without a home volume; the entrypoint script
# installs it on first boot when a bind-mounted home hides these files.
RUN set -eux; \
    mkdir -p /home/coder/.local/share/code-server/extensions /tmp/code-server-home; \
    HOME=/tmp/code-server-home code-server \
      --extensions-dir /home/coder/.local/share/code-server/extensions \
      --install-extension "nf-core.nf-core-extensionpack@${NFCORE_EXTENSIONPACK_VERSION}" \
      --force; \
    HOME=/tmp/code-server-home code-server \
      --extensions-dir /home/coder/.local/share/code-server/extensions \
      --list-extensions --show-versions \
      | grep -q "nf-core.nf-core-extensionpack@"; \
    rm -rf /tmp/code-server-home

# Default theme and first-boot extension fallback. The upstream entrypoint runs
# executable files in /entrypoint.d.
COPY --chmod=755 entrypoint.d/ /entrypoint.d/

# Keep the image's license texts alongside the image.
COPY LICENSE /usr/share/doc/studio-collection/LICENSE
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/studio-collection/THIRD_PARTY_NOTICES.md
COPY LICENSES/ /usr/share/doc/studio-collection/LICENSES/

# The upstream image gives coder passwordless sudo. The app runs as root here,
# so that rule is redundant.
RUN rm -f /etc/sudoers.d/nopasswd

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/healthz >/dev/null || exit 1

# Authentication is handled by the platform/proxy. code-server serves the IDE
# directly, with no login page.
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "."]

EXPOSE 8080
