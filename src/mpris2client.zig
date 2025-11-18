const std = @import("std");
const c = @cImport({
    @cInclude("dbus/dbus.h");
    @cInclude("stdio.h");
});

const DBusError = extern struct {
    name: [*c]const u8,
    message: [*c]const u8,
    dummy1: u32,
    dummy2: u32,
    dummy3: u32,
    dummy4: u32,
    dummy5: u32,
    padding1: *anyopaque,
};

const PlayerOutput = struct {
    title: []const u8,
    album: []const u8,
    artist: []const u8,
    length: i64,
    position: i64,
    status: []const u8,
};

const Player = struct {
    allocator: std.mem.Allocator,
    title: []const u8,
    album: []const u8,
    artist: []const u8,
    length: i64,
    position: i64,
    status: []const u8,

    pub fn deinit(self: Player) void {
        self.allocator.free(self.title);
        self.allocator.free(self.album);
        self.allocator.free(self.artist);
        self.allocator.free(self.status);
    }

    pub fn toOutput(self: Player) PlayerOutput {
        return PlayerOutput{
            .title = self.title,
            .album = self.album,
            .artist = self.artist,
            .length = self.length,
            .position = self.position,
            .status = self.status,
        };
    }
};

const PlayerInternal = struct {
    title: std.ArrayList(u8),
    album: std.ArrayList(u8),
    artist: std.ArrayList(u8),
    length: i64,
    position: i64,
    status: std.ArrayList(u8),

    pub fn deinit(self: PlayerInternal) void {
        self.title.deinit();
        self.album.deinit();
        self.artist.deinit();
        self.status.deinit();
    }
};

const PlayerError = error{
    DBusConnectionFailed,
    DBusMessageCreationFailed,
    DBusReplyFailed,
    NoPlayerFound,
};

pub fn GetPlayers(allocator: std.mem.Allocator) !Player {
    var player = PlayerInternal{
        .title = std.ArrayList(u8).init(allocator),
        .album = std.ArrayList(u8).init(allocator),
        .artist = std.ArrayList(u8).init(allocator),
        .status = std.ArrayList(u8).init(allocator),
        .length = 0,
        .position = 0,
    };
    defer player.deinit();

    var err: DBusError = undefined;
    c.dbus_error_init(@ptrCast(&err));
    defer c.dbus_error_free(@ptrCast(&err)); // Ensure DBusError is always freed

    const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
    if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
        std.debug.print("D-Bus Connection Error ({s})\n", .{std.mem.span(err.message)});
        return PlayerError.DBusConnectionFailed;
    }
    if (conn == null) {
        return PlayerError.DBusConnectionFailed;
    }
    defer c.dbus_connection_unref(conn); // Ensure connection is unreferenced

    const list_msg = c.dbus_message_new_method_call(
        "org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus",
        "ListNames",
    );
    if (list_msg == null) {
        std.debug.print("D-Bus Message Creation Failed (ListNames)\n", .{});
        return PlayerError.DBusMessageCreationFailed;
    }
    defer c.dbus_message_unref(list_msg); // Ensure list_msg is unreferenced

    const list_reply = c.dbus_connection_send_with_reply_and_block(conn, list_msg, -1, @ptrCast(&err));
    if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
        std.debug.print("D-Bus Reply Error (ListNames: {s})\n", .{std.mem.span(err.message)});
        return PlayerError.DBusReplyFailed;
    }
    if (list_reply == null) {
        return PlayerError.DBusReplyFailed;
    }
    defer c.dbus_message_unref(list_reply); // Ensure list_reply is unreferenced

    var iter: c.DBusMessageIter = undefined;
    _ = c.dbus_message_iter_init(list_reply, &iter);

    if (c.dbus_message_iter_get_arg_type(&iter) == c.DBUS_TYPE_ARRAY) {
        var sub: c.DBusMessageIter = undefined;
        c.dbus_message_iter_recurse(&iter, &sub);

        while (true) {
            if (c.dbus_message_iter_get_arg_type(&sub) != c.DBUS_TYPE_STRING) {
                break;
            }
            var player_name: [*c]const u8 = undefined;
            c.dbus_message_iter_get_basic(&sub, @ptrCast(&player_name));

            const mpris_prefix = "org.mpris.MediaPlayer2.";
            if (std.mem.startsWith(u8, std.mem.span(player_name), mpris_prefix)) {
                const get_msg = c.dbus_message_new_method_call(
                    player_name,
                    "/org/mpris/MediaPlayer2",
                    "org.freedesktop.DBus.Properties",
                    "Get",
                );
                if (get_msg == null) {
                    std.debug.print("D-Bus Message Creation Failed (Get Metadata for {s})\n", .{std.mem.span(player_name)});
                    return PlayerError.DBusMessageCreationFailed;
                }
                defer c.dbus_message_unref(get_msg);

                const iface = "org.mpris.MediaPlayer2.Player";
                const prop = "Metadata";
                _ = c.dbus_message_append_args(
                    get_msg,
                    c.DBUS_TYPE_STRING,
                    &iface,
                    c.DBUS_TYPE_STRING,
                    &prop,
                    c.DBUS_TYPE_INVALID,
                );

                const get_reply = c.dbus_connection_send_with_reply_and_block(conn, get_msg, -1, @ptrCast(&err));
                if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
                    std.debug.print("D-Bus Reply Error (Get Metadata for {s}: {s})\n", .{ std.mem.span(player_name), std.mem.span(err.message) });
                    return PlayerError.DBusReplyFailed;
                }
                if (get_reply != null) {
                    defer c.dbus_message_unref(get_reply);

                    var get_iter: c.DBusMessageIter = undefined;
                    _ = c.dbus_message_iter_init(get_reply, &get_iter);

                    if (c.dbus_message_iter_get_arg_type(&get_iter) == c.DBUS_TYPE_VARIANT) {
                        var variant_iter: c.DBusMessageIter = undefined;
                        c.dbus_message_iter_recurse(&get_iter, &variant_iter);

                        if (c.dbus_message_iter_get_arg_type(&variant_iter) == c.DBUS_TYPE_ARRAY) {
                            var dict_iter: c.DBusMessageIter = undefined;
                            c.dbus_message_iter_recurse(&variant_iter, &dict_iter);

                            while (c.dbus_message_iter_get_arg_type(&dict_iter) == c.DBUS_TYPE_DICT_ENTRY) {
                                var entry_iter: c.DBusMessageIter = undefined;
                                c.dbus_message_iter_recurse(&dict_iter, &entry_iter);

                                var key: [*c]const u8 = undefined;
                                if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_STRING) {
                                    c.dbus_message_iter_get_basic(&entry_iter, @ptrCast(&key));
                                }

                                _ = c.dbus_message_iter_next(&entry_iter);

                                if (std.mem.eql(u8, std.mem.span(key), "xesam:title")) {
                                    if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                        var value_iter: c.DBusMessageIter = undefined;
                                        c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                        if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_STRING) {
                                            var title: [*c]const u8 = undefined;
                                            c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&title));
                                            try player.title.appendSlice(std.mem.span(title));
                                        }
                                    }
                                } else if (std.mem.eql(u8, std.mem.span(key), "xesam:album")) {
                                    if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                        var value_iter: c.DBusMessageIter = undefined;
                                        c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                        if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_STRING) {
                                            var album: [*c]const u8 = undefined;
                                            c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&album));
                                            try player.album.appendSlice(std.mem.span(album));
                                        }
                                    }
                                } else if (std.mem.eql(u8, std.mem.span(key), "mpris:length")) {
                                    if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                        var value_iter: c.DBusMessageIter = undefined;
                                        c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                        if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_INT64) {
                                            var length: i64 = undefined;
                                            c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&length));
                                            player.length = length;
                                        }
                                    }
                                } else if (std.mem.eql(u8, std.mem.span(key), "xesam:artist")) {
                                    if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                        var value_iter: c.DBusMessageIter = undefined;
                                        c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                        if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_ARRAY) {
                                            var artist_iter: c.DBusMessageIter = undefined;
                                            c.dbus_message_iter_recurse(&value_iter, &artist_iter);
                                            while (c.dbus_message_iter_get_arg_type(&artist_iter) == c.DBUS_TYPE_STRING) {
                                                var artist: [*c]const u8 = undefined;
                                                c.dbus_message_iter_get_basic(&artist_iter, @ptrCast(&artist));
                                                try player.artist.appendSlice(std.mem.span(artist));
                                                if (c.dbus_message_iter_next(&artist_iter) == 0) {
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                if (c.dbus_message_iter_next(&dict_iter) == 0) {
                                    break;
                                }
                            }
                        }
                    }

                    // Get PlaybackStatus
                    const get_status_msg = c.dbus_message_new_method_call(
                        player_name,
                        "/org/mpris/MediaPlayer2",
                        "org.freedesktop.DBus.Properties",
                        "Get",
                    );

                    if (get_status_msg == null) {
                        std.debug.print("D-Bus Message Creation Failed (Get PlaybackStatus for {s})\n", .{std.mem.span(player_name)});
                        return PlayerError.DBusMessageCreationFailed;
                    }
                    defer c.dbus_message_unref(get_status_msg);

                    const status_iface = "org.mpris.MediaPlayer2.Player";
                    const status_prop = "PlaybackStatus";
                    _ = c.dbus_message_append_args(
                        get_status_msg,
                        c.DBUS_TYPE_STRING,
                        &status_iface,
                        c.DBUS_TYPE_STRING,
                        &status_prop,
                        c.DBUS_TYPE_INVALID,
                    );

                    const get_status_reply = c.dbus_connection_send_with_reply_and_block(conn, get_status_msg, -1, @ptrCast(&err));
                    if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
                        std.debug.print("D-Bus Reply Error (Get PlaybackStatus for {s}: {s})\n", .{ std.mem.span(player_name), std.mem.span(err.message) });
                        return PlayerError.DBusReplyFailed;
                    }

                    if (get_status_reply != null) {
                        defer c.dbus_message_unref(get_status_reply);
                        var status_iter: c.DBusMessageIter = undefined;
                        _ = c.dbus_message_iter_init(get_status_reply, &status_iter);
                        if (c.dbus_message_iter_get_arg_type(&status_iter) == c.DBUS_TYPE_VARIANT) {
                            var status_value_iter: c.DBusMessageIter = undefined;
                            c.dbus_message_iter_recurse(&status_iter, &status_value_iter);
                            if (c.dbus_message_iter_get_arg_type(&status_value_iter) == c.DBUS_TYPE_STRING) {
                                var status: [*c]const u8 = undefined;
                                c.dbus_message_iter_get_basic(&status_value_iter, @ptrCast(&status));
                                try player.status.appendSlice(std.mem.span(status));
                            }
                        }
                    }

                    // Get Position

                    const get_position_msg = c.dbus_message_new_method_call(
                        player_name,
                        "/org/mpris/MediaPlayer2",
                        "org.freedesktop.DBus.Properties",
                        "Get",
                    );

                    if (get_position_msg == null) {
                        std.debug.print("D-Bus Message Creation Failed (Get Position for {s})\n", .{std.mem.span(player_name)});
                        return PlayerError.DBusMessageCreationFailed;
                    }
                    defer c.dbus_message_unref(get_position_msg);

                    const position_iface = "org.mpris.MediaPlayer2.Player";
                    const position_prop = "Position";
                    _ = c.dbus_message_append_args(
                        get_position_msg,
                        c.DBUS_TYPE_STRING,
                        &position_iface,
                        c.DBUS_TYPE_STRING,
                        &position_prop,
                        c.DBUS_TYPE_INVALID,
                    );

                    const get_position_reply = c.dbus_connection_send_with_reply_and_block(conn, get_position_msg, -1, @ptrCast(&err));
                    if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
                        std.debug.print("D-Bus Reply Error (Get Position for {s}: {s})\n", .{ std.mem.span(player_name), std.mem.span(err.message) });
                        return PlayerError.DBusReplyFailed;
                    }

                    if (get_position_reply != null) {
                        defer c.dbus_message_unref(get_position_reply);
                        var position_iter: c.DBusMessageIter = undefined;
                        _ = c.dbus_message_iter_init(get_position_reply, &position_iter);
                        if (c.dbus_message_iter_get_arg_type(&position_iter) == c.DBUS_TYPE_VARIANT) {
                            var position_value_iter: c.DBusMessageIter = undefined;
                            c.dbus_message_iter_recurse(&position_iter, &position_value_iter);
                            if (c.dbus_message_iter_get_arg_type(&position_value_iter) == c.DBUS_TYPE_INT64) {
                                var position: i64 = undefined;
                                c.dbus_message_iter_get_basic(&position_value_iter, @ptrCast(&position));
                                player.position = position;
                            }
                        }
                    }
                }

                return Player{
                    .allocator = allocator,
                    .title = try allocator.dupe(u8, player.title.items),
                    .album = try allocator.dupe(u8, player.album.items),
                    .artist = try allocator.dupe(u8, player.artist.items),
                    .status = try allocator.dupe(u8, player.status.items),
                    .position = player.position,
                    .length = player.length,
                };
            }

            if (c.dbus_message_iter_next(&sub) == 0) {
                break;
            }
        }
    }

    // If no MPRIS player was found after iterating through all names, or the initial list was empty/malformed.
    return PlayerError.NoPlayerFound;
}
