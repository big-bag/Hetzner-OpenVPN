ARG ALPINE_VERSION=3.15.0
ARG OP_CLI_VERSION=1.12.3
ARG MITOGEN_VERSION=0.3.0rc1

FROM alpine:$ALPINE_VERSION
ARG OP_CLI_VERSION
ARG MITOGEN_VERSION
RUN apk add --update --no-cache python3 \
                                py3-pip \
                                gcc \
                                python3-dev \
                                musl-dev \
                                libffi-dev \
                                rust \
                                cargo \
                                openssl-dev \
                                py3-wheel
RUN python3 -m pip install ansible==3.4.0 \
                           ansible-base==2.10.15 \
                           jmespath==0.9.5 && \
    find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf
RUN wget https://cache.agilebits.com/dist/1P/op/pkg/v$OP_CLI_VERSION/op_linux_386_v$OP_CLI_VERSION.zip && \
    unzip op_linux_386_v$OP_CLI_VERSION.zip
RUN wget https://github.com/mitogen-hq/mitogen/archive/refs/tags/v$MITOGEN_VERSION.tar.gz && \
    tar -zxvf v$MITOGEN_VERSION.tar.gz

FROM alpine:$ALPINE_VERSION
ARG MITOGEN_VERSION
COPY --from=0 /usr/bin/ansible* /usr/bin/
COPY --from=0 /usr/lib/python3.9/site-packages/ /usr/lib/python3.9/site-packages/
COPY --from=0 /op /usr/bin/
COPY --from=0 /mitogen-$MITOGEN_VERSION/ /opt/mitogen/
RUN apk add --update --no-cache python3 \
                                openssh-client \
                                curl \
                                jq \
                                sudo \
                                rsync && \
    python3 -m pip install hcloud && \
    python3 -m compileall /usr/lib/python3.9/
WORKDIR /etc/ansible
