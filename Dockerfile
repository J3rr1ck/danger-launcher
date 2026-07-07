FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install all build dependencies
RUN apt-get update && apt-get install -y \
    git curl wget unzip xz-utils zip \
    openjdk-17-jdk-headless \
    build-essential file \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:${PATH}"

# Pre-cache Flutter Android dependencies
RUN flutter precache --android

# Accept Android licenses non-interactively
RUN echo "y" | flutter doctor --android-licenses || true

WORKDIR /app

# Copy project source
COPY . .

# Build APK
RUN flutter pub get && \
    flutter build apk --debug --no-tree-shake

# Extract APK to /release
RUN mkdir -p /release && \
    cp build/app/outputs/flutter-apk/app-debug.apk \
       /release/danger-launcher-v0.0.1-debug.apk && \
    cp build/app/outputs/flutter-apk/app-release.apk \
       /release/danger-launcher-v0.0.1.apk || \
    cp build/app/outputs/flutter-apk/app-debug.apk \
       /release/danger-launcher-v0.0.1.apk

FROM scratch
COPY --from=0 /release/ /
