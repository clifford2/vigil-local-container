# SPDX-FileCopyrightText: © 2024 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: MIT-0

FROM docker.io/amd64/alpine:3.22.2

ARG VIGIL_LOCAL_VER=1.2.1
ARG RELEASE_VERSION=1

# Release tarballs contain:
#  ./vigil-local/
#  ./vigil-local/vigil-local
#  ./vigil-local/config.cfg
RUN echo 'Download vigil-local' \
	&& mkdir /src && cd /src \
	&& wget -O vigil-local.tar.gz https://github.com/valeriansaliou/vigil-local/releases/download/v${VIGIL_LOCAL_VER}/v${VIGIL_LOCAL_VER}-x86_64.tar.gz \
	&& tar -xzvf vigil-local.tar.gz ./vigil-local/vigil-local \
	&& mv ./vigil-local/vigil-local /usr/local/bin/vigil-local \
	&& chmod 0755 /usr/local/bin/vigil-local \
	&& rm -r vigil-local.tar.gz vigil-local

CMD [ "/usr/local/bin/vigil-local", "-c", "/etc/vigil-local.cfg" ]
