ARG IMAGE_SOURCE=centos:stream10
FROM ${IMAGE_SOURCE}

ARG PKG_MANAGER=dnf

RUN useradd -m claude

# Package lists live in packages.txt (common) and packages.<pkg_manager>.txt.
# Edit those files to add tools that may be useful to Claude.
# gh (GitHub CLI) is the exception: it needs GitHub's own repo, set up below.
COPY packages.txt packages.${PKG_MANAGER}.txt /tmp/
RUN set -eu; \
    packages="$(cat /tmp/packages.txt /tmp/packages.${PKG_MANAGER}.txt | sed 's/#.*//' | tr -s '[:space:]' '\n' | grep -v '^$')"; \
    if [ "${PKG_MANAGER}" = "apt" ]; then \
        apt-get update; \
        apt-get install -y --no-install-recommends curl ca-certificates; \
        install -m 0755 -d /etc/apt/keyrings; \
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            -o /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
        chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            > /etc/apt/sources.list.d/github-cli.list; \
        apt-get update; \
        apt-get install -y $packages; \
        rm -rf /var/lib/apt/lists/*; \
    else \
        if grep -q 'platform:el' /etc/os-release; then \
            dnf install -y epel-release; \
        fi; \
        curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo \
            -o /etc/yum.repos.d/gh-cli.repo; \
        dnf install -y $packages; \
        dnf clean all; \
    fi; \
    rm -f /tmp/packages.txt /tmp/packages.${PKG_MANAGER}.txt

RUN echo "claude ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/claude

USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash

COPY init.sh /bin/init.sh

ENTRYPOINT ["/bin/init.sh"]
