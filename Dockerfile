# Multi-stage Dockerfile for POS System
FROM ubuntu:22.04 as base

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ARG FLUTTER_VERSION=3.35.4
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Verify Flutter installation
RUN flutter doctor

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source code
COPY . .

# Build the application
ARG BUILD_ENV=production
RUN flutter build windows --dart-define=FLUTTER_ENV=$BUILD_ENV

# Final stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxss1 \
    libgconf-2-4 \
    libnss3 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy built application
COPY --from=base /app/build/windows/x64/runner/Release /app

# Set working directory
WORKDIR /app

# Expose port (if needed)
EXPOSE 3000

# Run the application
CMD ["./deneme1.exe"]