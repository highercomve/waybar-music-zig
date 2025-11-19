.PHONY: all clean release-amd64 install

TARGET_NAME := waybar-music
DIST_DIR := dist
ARCH := $(shell uname -m)

all: release

release:
	@echo "Building for $(shell uname -m)..."
	@zig build -Doptimize=ReleaseSmall
	@mkdir -p $(DIST_DIR)
	@mv zig-out/bin/$(TARGET_NAME) $(DIST_DIR)/$(TARGET_NAME)
	@echo "Generated binary is located at: $(DIST_DIR)/$(TARGET_NAME)"

clean:
	@rm -rf zig-out zig-cache $(DIST_DIR)

install:
	@echo "Installing for $(shell uname -m)..."
	$(MAKE) release;
	sudo install -m 755 $(DIST_DIR)/$(TARGET_NAME) /usr/bin/$(TARGET_NAME);
