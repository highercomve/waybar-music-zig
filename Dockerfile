FROM debian:trixie-slim

# 1. Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	make \
	wget \
	xz-utils \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# 2. Define Zig version and platform-specific download info
ARG ZIG_VERSION=0.14.1
ARG ZIG_TARBALL_x86_64="https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz"
ARG ZIG_SHASUM_x86_64="24aeeec8af16c381934a6cd7d95c807a8cb2cf7df9fa40d359aa884195c4716c"
ARG ZIG_TARBALL_aarch64="https://ziglang.org/download/${ZIG_VERSION}/zig-aarch64-linux-${ZIG_VERSION}.tar.xz"
ARG ZIG_SHASUM_aarch64="f7a654acc967864f7a050ddacfaa778c7504a0eca8d2b678839c21eea47c992b"
ARG TARGETPLATFORM

# 3. Install Zig based on the target platform
RUN case ${TARGETPLATFORM} in \
	"linux/amd64") \
	ZIG_TARBALL_URL=${ZIG_TARBALL_x86_64}; \
	ZIG_SHASUM=${ZIG_SHASUM_x86_64}; \
	;; \
	"linux/arm64") \
	ZIG_TARBALL_URL=${ZIG_TARBALL_aarch64}; \
	ZIG_SHASUM=${ZIG_SHASUM_aarch64}; \
	;; \
	*) \
	echo "Unsupported platform: ${TARGETPLATFORM}"; \
	exit 1; \
	;; \
	esac && \
	wget -O zig.tar.xz ${ZIG_TARBALL_URL} && \
	echo "${ZIG_SHASUM}  zig.tar.xz" | sha256sum -c - && \
	mkdir -p /usr/local/zig && \
	tar -xf zig.tar.xz -C /usr/local/zig --strip-components=1 && \
	ln -s /usr/local/zig/zig /usr/bin/zig && \
	rm zig.tar.xz

WORKDIR /app

CMD ["zig", "build"]
