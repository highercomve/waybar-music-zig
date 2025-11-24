FROM debian:trixie-slim

# 1. Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	make \
	wget \
	xz-utils \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# 2. Define Zig version and platform-specific download info
ARG ZIG_VERSION=0.15.2
ARG ZIG_TARBALL_x86_64="https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz"
ARG ZIG_SHASUM_x86_64="02aa270f183da276e5b5920b1dac44a63f1a49e55050ebde3aecc9eb82f93239"
ARG ZIG_TARBALL_aarch64="https://ziglang.org/download/${ZIG_VERSION}/zig-aarch64-linux-${ZIG_VERSION}.tar.xz"
ARG ZIG_SHASUM_aarch64="958ed7d1e00d0ea76590d27666efbf7a932281b3d7ba0c6b01b0ff26498f667f"
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
