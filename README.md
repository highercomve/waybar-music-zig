# Waybar Music Zig

A small program to control MPRIS-compatible music players, intended for use with Waybar.

## Building

To build this project, you will need Zig 0.14.1 or later.

You will also need the `dbus-1` development library. On Debian-based systems, you can install it with:

```sh
sudo apt-get install libdbus-1-dev
```

Then, you can build the project using the provided Makefile:

```sh
# Build for amd64 and arm64
make

# Or to build for a specific architecture
make release-amd64
make release-arm64
```

The binaries will be placed in the `dist/` directory.
