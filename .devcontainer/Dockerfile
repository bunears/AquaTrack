ARG VARIANT=bullseye
FROM debian:${VARIANT}
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Arguments
ARG CONTAINER_USER=esp
ARG CONTAINER_GROUP=esp
ARG TOOLCHAIN_VERSION=1.64.0.0
ARG ESP_IDF_VERSION=release/v4.4
ARG ESP_BOARD=esp32
ARG INSTALL_RUST_TOOLCHAIN=install-rust-toolchain.sh

# Install dependencies
RUN apt-get update \
    && apt-get install -y wget git curl gcc clang ninja-build libudev-dev unzip xz-utils\
    python3 python3-pip python3-venv libusb-1.0-0 libssl-dev pkg-config libtinfo5 libpython2.7 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# QEMU
ENV QEMU_REL=esp-develop-20210220
ENV QEMU_SHA256=44c130226bdce9aff6abf0aeaab44f09fe4f2d71a5f9225ac1708d68e4852c02
ENV QEMU_DIST=qemu-${QEMU_REL}.tar.bz2
ENV QEMU_URL=https://github.com/espressif/qemu/releases/download/${QEMU_REL}/${QEMU_DIST}

RUN wget --no-verbose ${QEMU_URL} \
  && echo "${QEMU_SHA256} *${QEMU_DIST}" | sha256sum --check --strict - \
  && tar -xf $QEMU_DIST -C /opt \
  && rm ${QEMU_DIST}

ENV PATH=/opt/qemu/bin:${PATH}

# Set users
RUN adduser --disabled-password --gecos "" ${CONTAINER_USER}
USER ${CONTAINER_USER}
WORKDIR /home/${CONTAINER_USER}


# Install Rust toolchain, extra crates and esp-idf
ENV PATH=${PATH}:/home/${CONTAINER_USER}/.cargo/bin:/home/${CONTAINER_USER}/opt/bin

ADD --chown=${CONTAINER_USER}:${CONTAINER_GROUP} \
    https://github.com/esp-rs/rust-build/releases/download/v${TOOLCHAIN_VERSION}/${INSTALL_RUST_TOOLCHAIN} \
    /home/${CONTAINER_USER}/${INSTALL_RUST_TOOLCHAIN}

RUN chmod a+x ${INSTALL_RUST_TOOLCHAIN} \
    && ./${INSTALL_RUST_TOOLCHAIN} \
    --extra-crates "ldproxy cargo-espflash web-flash" \
    --export-file /home/${CONTAINER_USER}/export-esp.sh \
    --esp-idf-version "${ESP_IDF_VERSION}" \
    --minified-esp-idf "YES" \
    --build-target "${ESP_BOARD}" \
    && rustup component add clippy rustfmt

# Activate ESP environment
RUN echo "source /home/${CONTAINER_USER}/export-esp.sh" >> ~/.bashrc

CMD [ "/bin/bash" ]
