const std = @import("std");
const mpris2client = @import("mpris2client.zig");

const Action = enum {
    list,
    toggle,
    next,
    previous,
    help,
    listen,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = std.process.argsAlloc(allocator) catch |err| {
        std.debug.print("Error getting arguments: {any}\n", .{err});
        return err;
    };
    defer std.process.argsFree(allocator, args);

    var action: Action = .list;
    var player_idx: ?usize = null;

    if (args.len > 1) {
        if (std.mem.eql(u8, args[1], "list")) {
            action = .list;
        } else if (std.mem.eql(u8, args[1], "toggle")) {
            action = .toggle;
            if (args.len > 2) {
                player_idx = std.fmt.parseUnsigned(usize, args[2], 10) catch |err| {
                    std.debug.print("Invalid player index: {any}\n", .{err});
                    return error.InvalidPlayerIndex;
                };
            }
        } else if (std.mem.eql(u8, args[1], "next")) {
            action = .next;
            if (args.len > 2) {
                player_idx = std.fmt.parseUnsigned(usize, args[2], 10) catch |err| {
                    std.debug.print("Invalid player index: {any}\n", .{err});
                    return error.InvalidPlayerIndex;
                };
            }
        } else if (std.mem.eql(u8, args[1], "previous")) {
            action = .previous;
            if (args.len > 2) {
                player_idx = std.fmt.parseUnsigned(usize, args[2], 10) catch |err| {
                    std.debug.print("Invalid player index: {any}\n", .{err});
                    return error.InvalidPlayerIndex;
                };
            }
        } else if (std.mem.eql(u8, args[1], "help")) {
            action = .help;
        } else if (std.mem.eql(u8, args[1], "listen")) {
            action = .listen;
        } else {
            std.debug.print("Unknown subcommand: {s}\n", .{args[1]});
            action = .help;
        }
    }

    var max_len: usize = 20;
    for (args, 0..) |arg, i| {
        if (std.mem.eql(u8, arg, "--max-len")) {
            if (i + 1 < args.len) {
                max_len = std.fmt.parseUnsigned(usize, args[i + 1], 10) catch |err| {
                    std.debug.print("Invalid max-len: {any}\n", .{err});
                    return err;
                };
            } else {
                std.debug.print("Missing value for --max-len\n", .{});
                return error.MissingArgument;
            }
        }
    }

    var client = try mpris2client.Mpris2Client.init(allocator, max_len);
    defer client.deinit();

    try client.populatePlayers();
    try client.selectCurrentPlayer();

    switch (action) {
        .list => {
            if (client.players.items.len == 0) {
                std.debug.print("No MPRIS players found.\n", .{});
                return;
            }

            const stdout_file = std.fs.File.stdout();
            var stdout_buffer: [4096]u8 = undefined;
            var stdout_writer = stdout_file.writer(&stdout_buffer);
            const stdout = &stdout_writer.interface;

            for (client.players.items, 0..) |player, i| {
                var out: std.io.Writer.Allocating = .init(allocator);
                try std.json.Stringify.value(player.toOutput(i), .{ .whitespace = .indent_2 }, &out.writer);
                var arr = out.toArrayList();
                defer arr.deinit(allocator);

                try stdout.writeAll(arr.items);
                try stdout.writeAll("\n");
            }
            try stdout.flush();
        },
        .toggle => {
            if (player_idx) |idx| {
                if (idx >= client.players.items.len) {
                    std.debug.print("Player index {d} out of bounds (max {d})\n", .{ idx, client.players.items.len - 1 });
                    return error.PlayerIndexOutOfBounds;
                }
                const player = client.players.items[idx];
                try player.Toggle();
                std.debug.print("Toggled player {d}\n", .{idx});
            } else {
                if (client.current_player) |player| {
                    try player.Toggle();
                    std.debug.print("Toggled current player\n", .{});
                } else {
                    std.debug.print("No active player found.\n", .{});
                    return error.NoPlayerFound;
                }
            }
        },
        .next => {
            if (player_idx) |idx| {
                if (idx >= client.players.items.len) {
                    std.debug.print("Player index {d} out of bounds (max {d})\n", .{ idx, client.players.items.len - 1 });
                    return error.PlayerIndexOutOfBounds;
                }
                const player = client.players.items[idx];
                try player.Next();
                std.debug.print("Next track for player {d}\n", .{idx});
            } else {
                if (client.current_player) |player| {
                    try player.Next();
                    std.debug.print("Next track for current player\n", .{});
                } else {
                    std.debug.print("No active player found.\n", .{});
                    return error.NoPlayerFound;
                }
            }
        },
        .previous => {
            if (player_idx) |idx| {
                if (idx >= client.players.items.len) {
                    std.debug.print("Player index {d} out of bounds (max {d})\n", .{ idx, client.players.items.len - 1 });
                    return error.PlayerIndexOutOfBounds;
                }
                const player = client.players.items[idx];
                try player.Previous();
                std.debug.print("Previous track for player {d}\n", .{idx});
            } else {
                if (client.current_player) |player| {
                    try player.Previous();
                    std.debug.print("Previous track for current player\n", .{});
                } else {
                    std.debug.print("No active player found.\n", .{});
                    return error.NoPlayerFound;
                }
            }
        },
        .listen => {
            try client.Listen();
        },
        .help => {
            std.debug.print("Usage: {s} <command> [args]\n", .{args[0]});
            std.debug.print("\nCommands:\n", .{});
            std.debug.print("  list                                   List all active MPRIS players and their current track information.\n", .{});
            std.debug.print("  toggle [player_index]                  Toggle play/pause. Defaults to the current player.\n", .{});
            std.debug.print("  next [player_index]                    Skip to the next track. Defaults to the current player.\n", .{});
            std.debug.print("  previous [player_index]                Skip to the previous track. Defaults to the current player.\n", .{});
            std.debug.print("  listen                                 Start listening for D-Bus MPRIS events (blocking).\n", .{});
            std.debug.print("  help                                   Show this help message.\n", .{});
        },
    }
}
