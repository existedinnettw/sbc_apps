ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM

FROM alpine:3.20

# Re-declare build args for this stage (needed to access inside RUN if desired)
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM

LABEL org.opencontainers.image.title="APK package extractor"
LABEL org.opencontainers.image.description="Utility image with apps prepared for SBC offline use (Alpine base)"
LABEL org.opencontainers.image.source="https://github.com/existedinnettw/sbc_apps"

ENV TZ=UTC \
	LC_ALL=C.UTF-8 \
	LANG=C.UTF-8

# Ensure main and community repos are enabled (pin to image version)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.20/main" > /etc/apk/repositories \
 	&& echo "https://dl-cdn.alpinelinux.org/alpine/v3.20/community" >> /etc/apk/repositories

# Ensure repositories are reachable and install minimal runtime tools
RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
	apk update \
	&& apk add --no-cache \
	ca-certificates \
	bash \
	busybox \
	coreutils \
	shadow

RUN mkdir -p /app/tools \
	&& apk add --no-cache apk-tools-static \
	&& cp /sbin/apk.static /app/tools/apk.static \
	&& chmod +x /app/tools/apk.static

# Where packages will be fetched to
RUN mkdir -p /app/pkgs

# Fetch .apk packages (and their dependencies) into /app/pkgs for offline use
# We try to keep close equivalents to the previous Ubuntu packages.
# Some packages may not exist on Alpine; those will be skipped gracefully.
RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
	set -eux; \
	apk update; \
	# List of Alpine packages to fetch (best-effort mapping)
	apk_pkgs="\
	  busybox \
	  nano \
	  zstd \
	  xz \
	  lz4 \
	  firejail \
	  mosquitto \
	  mosquitto-clients \
	  avahi \
	  avahi-tools \
	  nss-mdns \
	  nfs-utils \
	  rt-tests \
	  mesa-demos \
	"; \
	for p in $apk_pkgs; do \
	  if apk search -x "$p" >/dev/null 2>&1; then \
	    echo "Fetching $p and dependencies..."; \
	    if ! apk fetch --recursive -o /app/pkgs "$p"; then \
	      echo "WARN: fetch failed for $p (continuing)"; \
	    fi; \
	  else \
	    echo "NOTE: $p not found in current Alpine repos; skipping"; \
	  fi; \
	done

# Default command drops you into a shell; tweak as needed
CMD ["/bin/bash"]

