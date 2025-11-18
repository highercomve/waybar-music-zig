const std = @import("std");
const GetPlayers = @import("mpris2client.zig").GetPlayers;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const player = try GetPlayers(allocator);
    defer player.deinit();

    try std.json.stringify(player.toOutput(), .{}, std.io.getStdOut().writer());

    std.debug.print("\n", .{});
}
