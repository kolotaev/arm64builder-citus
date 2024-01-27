ARG DEBIAN_IMAGE_VERSION
FROM debian:${DEBIAN_IMAGE_VERSION}

ARG POSTGRES_MAJOR_VERSION
ARG CITUS_VERSION
ARG BUILD_ARCH
ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="kolotaev at Github"
LABEL version="citus-${CITUS_VERSION}-pgsql-${POSTGRES_MAJOR_VERSION}-builder"
LABEL description="Container image for building the Citus extension for Postgres ${POSTGRES_MAJOR_VERSION} on the ${BUILD_ARCH} architecture"

ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}
ENV POSTGRES_MAJOR_VERSION=${POSTGRES_MAJOR_VERSION}
ENV CITUS_VERSION=${CITUS_VERSION}
ENV BUILD_ARCH=${BUILD_ARCH}
ENV BUILD_HOME="/var/citus"
ENV OUTPUT_HOME="/var/output"


# Taken from citus extbuilder image.
# See: https://github.com/citusdata/the-process/blob/master/circleci/images/extbuilder/Dockerfile
RUN apt-get update \
    # install dependencies
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    build-essential \
    ca-certificates \
    curl \
    debian-archive-keyring \
    gcc \
    gnupg \
    gosu \
    libcurl4 \
    libcurl4-openssl-dev \
    libicu-dev \
    liblz4-1 \
    liblz4-dev \
    libreadline-dev \
    libselinux1-dev \
    libssl-dev \
    libxslt-dev \
    libzstd-dev \
    libzstd1 \
    locales \
    make \
    perl \
    # clear apt cache
    && rm -rf /var/lib/apt/lists/* && \
    apt clean

# Additional tools for this method of building.
RUN apt-get update && \
    apt install -y \
        lsb-release \
        flex \
        bison \
        libkrb5-dev \
        git \
        debhelper \
        dh-make \
        python3-pip \
        tini && \
    pip3 install jinja2-cli && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# Taken from citus extbuilder
# add postgres repository
RUN curl -sf https://www.postgresql.org/media/keys/ACCC4CF8.asc | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -
RUN echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/postgresql.list \
    && echo "deb https://apt-archive.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg-archive main" >> /etc/apt/sources.list.d/postgresql.list \
    && apt-get update \
    # infer the pgdgversion of postgres based on the $POSTGRES_MAJOR_VERSION
    && pgdg_version=$(apt list -a postgresql-server-dev-${POSTGRES_MAJOR_VERSION} 2>/dev/null | grep "${POSTGRES_MAJOR_VERSION}" | awk '{print $2}' | head -n1 ) \
    && apt-get install -y --no-install-recommends --allow-downgrades \
        libpq-dev=${pgdg_version} \
        libpq5=${pgdg_version} \
        postgresql-client-${POSTGRES_MAJOR_VERSION}=${pgdg_version} \
        postgresql-${POSTGRES_MAJOR_VERSION}-dbgsym=${pgdg_version} \
        postgresql-server-dev-${POSTGRES_MAJOR_VERSION}=${pgdg_version} \
    # clear apt cache
    && rm -rf /var/lib/apt/lists/*


WORKDIR /var/citus
COPY citus.sh /usr/local/bin/citus.sh
COPY control.tmpl /var/citus/control.tmpl
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/citus.sh"]
