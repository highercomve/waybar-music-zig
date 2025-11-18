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
            return error.UnknownSubcommand;
        }
    }

    var client = try mpris2client.Mpris2Client.init(allocator);
    defer client.deinit();

    try client.populatePlayers();

    switch (action) {
        .list => {
            if (client.players.items.len == 0) {
                std.debug.print("No MPRIS players found.\n", .{});
                return;
            }

            for (client.players.items, 0..) |player, i| {
                std.debug.print("Player {d}: ", .{i});
                try std.json.stringify(player.toOutput(), .{}, std.io.getStdOut().writer());
                std.debug.print("\n", .{});
            }
        },
        .toggle => {
            if (player_idx) |idx| {
                if (idx >= client.players.items.len) {
                    std.debug.print("Player index {d} out of bounds (max {d})\n", .{idx, client.players.items.len - 1});
                    return error.PlayerIndexOutOfBounds;
                }
                const player = client.players.items[idx];
                try player.Toggle();
                std.debug.print("Toggled player {d}\n", .{idx});
            } else {
                std.debug.print("Usage: {s} toggle <player_index>\n", .{args[0]});
                return error.MissingPlayerIndex;
            }
        },
        .next => {
            if (player_idx) |idx| {
                if (idx >= client.players.items.len) {
                    std.debug.print("Player index {d} out of bounds (max {d})\n", .{idx, client.players.items.len - 1});
                    return error.PlayerIndexOutOfBounds;
                }
                const player = client.players.items[idx];
                try player.Next();
                std.debug.print("Next track for player {d}\n", .{idx});
            } else {
                std.debug.print("Usage: {s} next <player_index>\n", .{args[0]});
                return error.MissingPlayerIndex;
            }
        },
        .previous => {
            if (player_idx) |idx| {
                if (idx >= client.players.items.len) {
                    std.debug.print("Player index {d} out of bounds (max {d})\n", .{idx, client.players.items.len - 1});
                    return error.PlayerIndexOutOfBounds;
                }
                const player = client.players.items[idx];
                try player.Previous();
                std.debug.print("Previous track for player {d}\n", .{idx});
            } else {
                std.debug.print("Usage: {s} previous <player_index>\n", .{args[0]});
                return error.MissingPlayerIndex;
            }
        },
        .help => {
            std.debug.print("Usage: {s} <command> [args]\n", .{args[0]});
            std.debug.print("\nCommands:\n", .{});
            std.debug.print("  list                                   List all active MPRIS players and their current track information.\n", .{});
            std.debug.print("  toggle <player_index>                  Toggle play/pause for the player at the given index.\n", .{});
            std.debug.print("  next <player_index>                    Skip to the next track for the player at the given index.\n", .{});
            std.debug.print("  previous <player_index>                Skip to the previous track for the player at the given index.\n", .{});
            std.debug.print("  listen                                 Start listening for D-Bus MPRIS events (blocking).\n", .{});
            std.debug.print("  help                                   Show this help message.\n", .{});
        },
        .listen => {
            std.debug.print("Starting D-Bus MPRIS event listener...\n", .{});
            try client.Listen();
        },
    }
}
