# SPDX-FileCopyrightText: © 2024 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: MIT-0
#
# Build with: make build

FROM docker.io/library/alpine:3.23.0

ARG VIGIL_LOCAL_VER

# Release tarballs contain:
#  ./vigil-local/
#  ./vigil-local/vigil-local
#  ./vigil-local/config.cfg
# uname -m output returns the expected values of x86_64 and aarch64
RUN echo 'Download vigil-local' \
	&& mkdir /src && cd /src \
	&& wget -O vigil-local.tar.gz https://github.com/valeriansaliou/vigil-local/releases/download/v${VIGIL_LOCAL_VER}/v${VIGIL_LOCAL_VER}-$(uname -m).tar.gz \
	&& tar -xzvf vigil-local.tar.gz ./vigil-local/vigil-local \
	&& mv ./vigil-local/vigil-local /usr/local/bin/vigil-local \
	&& chmod 0755 /usr/local/bin/vigil-local \
	&& cd / \
	&& rm -rf /src

# BUILD_DATE should break old caches of the update & upgrade layers
ARG BUILD_DATE
RUN echo "${BUILD_DATE}"
RUN apk --no-cache update
RUN apk --no-cache upgrade

CMD [ "/usr/local/bin/vigil-local", "-c", "/etc/vigil-local.cfg" ]

LABEL maintainer="Clifford Weinmann <https://www.cliffordweinmann.com/>"
LABEL org.opencontainers.image.authors="Clifford Weinmann <https://www.cliffordweinmann.com/>"
LABEL org.opencontainers.image.description="Vigil Local"
LABEL org.opencontainers.image.licenses="MPL-2.0"
LABEL org.opencontainers.image.source="https://github.com/clifford2/vigil-local-container"
LABEL org.opencontainers.image.title="vigil-local"
LABEL org.opencontainers.image.url="https://github.com/clifford2/vigil-local-container"

ARG IMAGE_VERSION
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
ARG BUILD_TIME
LABEL org.opencontainers.image.created="${BUILD_TIME}"
