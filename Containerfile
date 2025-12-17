ARG IMAGE_SOURCE=centos:stream10

FROM ${IMAGE_SOURCE}

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN dnf install -y git python3 python3-pip

COPY init.sh /bin/init.sh

ENTRYPOINT ["/bin/init.sh"]
