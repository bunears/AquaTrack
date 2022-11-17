#!/usr/bin/env bash

set -e

BUILD_MODE=""
case "$1" in
    ""|"release")
        bash scripts/build.sh
        BUILD_MODE="release"
        ;;
    "debug")
        bash scripts/build.sh debug
        BUILD_MODE="debug"
        ;;
    *)
        echo "Wrong argument. Only \"debug\"/\"release\" arguments are supported"
        exit 1;;
esac

export ESP_ARCH=xtensa-esp32-espidf
cargo espflash save-image --chip esp32 --merge target/${ESP_ARCH}/${BUILD_MODE}/aqua-track --partition-table partitions.csv
qemu-system-xtensa -nographic -machine esp32 -drive file=dlogv2,if=mtd,format=raw