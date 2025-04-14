FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble AS base

ARG SIGIL_VERSION=2.4.2
LABEL maintainer="TheGameProfi"
LABEL org.opencontainers.image.authors="TheCfU"
LABEL org.opencontainers.image.description="Docker Image for running Sigil-Ebook on linuxservers"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/thecfu/sigil-docker"
LABEL org.opencontainers.image.source="https://github.com/thecfu/sigil-docker"
LABEL org.opencontainers.image.title="Sigil-Ebook"
LABEL org.opencontainers.image.url="https://github.com/thecfu/sigil-docker/packages"
LABEL org.opencontainers.image.vendor="TheCfU"
LABEL org.opencontainers.image.version="${SIGIL_VERSION}"
LABEL org.opencontainers.image.ref.name="thecfu/sigil-docker:${SIGIL_VERSION}"
LABEL org.opencontainers.image.revision=""

RUN apt update && \
    apt install -y \
    qt6-webengine-dev \
    qt6-webengine-dev-tools \
    qt6-base-dev-tools \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qt6-l10n-tools \
    qt6-5compat-dev \
    libqt6svg6-dev \
    libqt6webenginecore6-bin \
    libhunspell-dev \
    libpcre2-dev \
    libminizip-dev \
    wget \
    build-essential \
    cmake \
    python3-dev \
    python3-pip \
    python3-lxml \
    python3-six \
    python3-css-parser \
    python3-dulwich \
    python3-pil.imagetk \
    python3-html5lib \
    python3-regex \
    python3-pillow \
    python3-cssselect \
    python3-chardet

FROM base AS builder

RUN mkdir -p /sigil/latest /sigil-builded

WORKDIR /sigil

# Download Sigil source code
RUN wget -O sigil.tar.gz https://github.com/Sigil-Ebook/Sigil/archive/refs/tags/${SIGIL_VERSION}.tar.gz
RUN tar -xf sigil.tar.gz --strip-components=1 -C latest/

WORKDIR /sigil/latest

RUN cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/sigil-builded -DCMAKE_BUILD_TYPE=Release .
RUN make install

FROM base AS realease

ENV SIGIL_PREFS_DIR= \
    SIGIL_EXTRA_ROOT= \
    SIGIL_DICTIONARIES= \
    SKIP_SIGIL_UPDATE_CHECK= 

VOLUME /home/abc/.local/share/sigil-ebook

COPY sigil.png /sigil/

COPY --from=builder /sigil-builded /sigil-builded
COPY branding /etc/s6-overlay/s6-rc.d/init-adduser

RUN mkdir -p /defaults && echo "/sigil-builded/bin/sigil" > /defaults/autostart
COPY menu.xml /defaults/menu.xml
