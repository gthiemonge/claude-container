ARG IMAGE_SOURCE=centos:stream10
FROM ${IMAGE_SOURCE}

ARG PKG_MANAGER=dnf
RUN if [ "${PKG_MANAGER}" = "apt" ]; then \
        apt-get update && apt-get install -y curl; \
    fi

RUN useradd -m claude

# Here you can add other tools that may be useful to Claude
RUN if [ "${PKG_MANAGER}" = "dnf" ]; then \
        dnf install -y git python3 python3-pip tox; \
    elif [ "${PKG_MANAGER}" = "apt" ]; then \
        apt-get install -y git python3 python3-venv python3-pip tox; \
    fi

USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash

COPY init.sh /bin/init.sh

ENTRYPOINT ["/bin/init.sh"]
