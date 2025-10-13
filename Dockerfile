ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

FROM ubuntu:18.04

ARG APT_PACKAGES="busybox xfwm4 libgtk-3-0 libblkid1 liblzma5"

LABEL org.opencontainers.image.title="Apt package extractor"
LABEL org.opencontainers.image.description="Utility image with preinstalled packages for offline use"
LABEL org.opencontainers.image.source="https://example.local/t507"

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=UTC \
	LC_ALL=C.UTF-8 \
	LANG=C.UTF-8

# Install required apps at build time so runtime is offline
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update \
	 && apt-get install -y --no-install-recommends \
		 ca-certificates \
		 gnupg \
		 apt-transport-https \
		 software-properties-common \
	 && add-apt-repository -y universe \
	 && apt-get update

# Download all .deb files for APT_PACKAGES into /pkgs (includes Recommends by default)
RUN mkdir -p /pkgs
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/cache/pkgs,sharing=locked \
    apt-get install -y --download-only -o Dir::Cache::archives=/pkgs $APT_PACKAGES

# RUN apt-get install -y -o Dir::Cache::archives=/pkgs $APT_PACKAGES

# Default command drops you into a shell; tweak as needed
CMD ["/bin/bash"]

