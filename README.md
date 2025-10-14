# SBC apps

The repo creates a docker image which contains apps prepared for SBC.

## Build

```bash
docker build --platform=linux/arm64 -t sbc-apps:arm64 .
docker build --platform=linux/arm/v7 -t sbc-apps:armv7 .
```

Or build a multi-arch manifest using Buildx:

```bash
# optional: docker buildx create --use
docker buildx build \
	--platform linux/amd64,linux/arm64,linux/arm/v7 \
	-t sbc-apps:latest \
	.
```

### get apps

Run a shell in the container (no internet needed):

```bash
docker run --rm -it sbc-apps:arm64 bash
```

```bash
docker run --rm -v $(pwd)/arm64_out:/out -it sbc-apps:arm64 bash -c "cp -r /app/* /out"
docker run --rm -v $(pwd)/armv7_out:/out -it sbc-apps:armv7 bash -c "cp -r /app/* /out"
```
