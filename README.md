# Waybar Music Zig

A small program to control MPRIS-compatible music players, intended for use with Waybar.

## Building

This project has two main dependencies:

*   **Zig 0.15.0 or later:** The programming language and build system.
*   **D-Bus development library:** For communicating with MPRIS players.

### 1. Install Zig

A Zig version manager is recommended for easy installation and management. We suggest using [zvm](https://github.com/highercomve/zvm).

After installing `zvm`, you can get the correct Zig version by running:
```sh
zvm i 0.15.2
zvm use 0.15.2
```

### 2. Install D-Bus

You will also need the `dbus-1` development library. You can install it with your system's package manager:

```
sudo apt-get install libdbus-1-dev  # Debian/Ubuntu
sudo dnf install dbus-devel          # Fedora
sudo pacman -S dbus                  # Arch Linux
sudo zypper install libdbus-1-0-devel # openSUSE
```

### 3. Compile

With the dependencies installed, you can build the project. You can either use the Zig build system directly or the provided Makefile wrapper.

**Using Zig:**

```sh
# Compile the program
zig build

# Compile and install
zig build install
```

**Using Make:**

```sh
# Compile the program
make

# Install the program
make install
```

The compiled binaries can be found in `zig-out/bin/`.

## Commands

`waybar-music` uses subcommands to control players.

| Command | Description |
| --- | --- |
| `listen [--max-len <N>]` | Listens for MPRIS events and prints player state changes as JSON. This is the main command for Waybar integration. Optional `--max-len` sets the scrolling window size (default 20). |
| `list` | Lists all available players. |
| `toggle [player_index]` | Toggles play/pause for the specified player. If no index is provided, it controls the current active player. |
| `next [player_index]` | Skips to the next track for the specified player. If no index is provided, it controls the current active player. |
| `previous [player_index]`| Skips to the previous track for the specified player. If no index is provided, it controls the current active player. |
| `help` | Shows the help message. |

## Waybar Configuration

Add the following to your Waybar config file:

```json
"custom/waybar-music": {
    "return-type": "json",
    "exec": "waybar-music listen --max-len 20",
    "on-click": "waybar-music toggle",
    "on-click-right": "waybar-music next",
    "on-scroll-up": "waybar-music next",
    "on-scroll-down": "waybar-music previous",
}
```

### Waybar Configuration Explained

*   `"return-type": "json"`: This is required for Waybar to understand the output of `waybar-music`.
*   `"exec": "waybar-music listen --max-len 20"`: This command is executed by Waybar to get the music information. It listens for events and prints updates. You can adjust `--max-len` to control the scrolling text width.
*   `"on-click": "waybar-music toggle"`: When you left-click the Waybar module, it will send the `toggle` command.
*   `"on-click-right": "waybar-music next"`: When you right-click the Waybar module, it will skip to the next track.
*   `"on-scroll-up": "waybar-music next"`: When you scroll up on the Waybar module, it will skip to the next track.
*   `"on-scroll-down": "waybar-music previous"`: When you scroll down on the Waybar module, it will go to the previous track.
*   `"format": "{icon} {text}"`: This defines how the information will be displayed in Waybar. `{icon}` will be replaced by one of the icons in `format-icons`, and `{text}` will be the music information.
*   `"format-icons"`: This section defines the icons to be used based on the music player's status.
