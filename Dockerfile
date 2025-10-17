ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

# FROM ubuntu:22.04 #default use zstd for deb
FROM ubuntu:20.04
# FROM bookworm-slim

LABEL org.opencontainers.image.title="Apt package extractor"
LABEL org.opencontainers.image.description="Utility image with apps prepared for SBC offline use"
LABEL org.opencontainers.image.source="https://github.com/existedinnettw/sbc_apps"

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=UTC \
	LC_ALL=C.UTF-8 \
	LANG=C.UTF-8

# Install required apps at build time so runtime is offline
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
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

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
	--mount=type=cache,target=/cache/pkgs,sharing=locked \
	apt-get install -y --reinstall --download-only -o Dir::Cache::archives=/pkgs \
	busybox \
	# gcc-10-base libgcc-s1 libcrypt1 libc6 \
	zstd xz-utils liblzma5 liblz4-1 lz4 liblz4-tool libgcrypt20 \
	libncurses5 libtinfo6 libncursesw6 nano \
	libcap2 libsystemd0 \
	firejail \
	mosquitto mosquitto-clients \
	avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan \
	nfs-ganesha \
	rt-tests \
	mesa-utils
# xfwm4 \
# libgtk-3-0  libblkid1  liblzma5 \
# x11vnc

# RUN apt-get install -y -o Dir::Cache::archives=/pkgs $APT_PACKAGES

# Default command drops you into a shell; tweak as needed
CMD ["/bin/bash"]

