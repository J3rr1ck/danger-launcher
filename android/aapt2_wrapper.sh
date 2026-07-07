#!/bin/bash
# Wrapper to run x86_64 aapt2 via QEMU on arm64 host
export QEMU_LD_PREFIX=/tmp/amd64-root
exec qemu-x86_64 /home/danger/android-sdk/build-tools/36.0.0/aapt2 "$@"
