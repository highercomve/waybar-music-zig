const std = @import("std");
const json = std.json;
const c = @cImport({
    @cInclude("dbus/dbus.h");
    @cInclude("stdio.h");
});

const INTERFACE = "org.mpris.MediaPlayer2";
const PATH = "/org/mpris/MediaPlayer2";
const MATCH_NOC = "type='signal',path='/org/freedesktop/DBus',interface='org.freedesktop.DBus',member='NameOwnerChanged'";
const MATCH_PC = "type='signal',path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties'";

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

fn formatTime(us: i64) []const u8 {
    const total_seconds = @divTrunc(us, 1_000_000);
    const minutes_val = @divTrunc(total_seconds, 60);
    const seconds_val = @rem(total_seconds, 60);

    var buffer: [6]u8 = undefined; // MM:SS\0

    // Minutes (up to 99 for MM:SS display)
    const disp_minutes: u8 = @intCast(if (minutes_val > 99) 99 else minutes_val);
    buffer[0] = @divTrunc(disp_minutes, 10) + '0';
    buffer[1] = @rem(disp_minutes, 10) + '0';
    buffer[2] = ':';

    // Seconds (always 0-59)
    const disp_seconds: u8 = @intCast(seconds_val); // seconds_val is always 0-59, so fits u8
    buffer[3] = @divTrunc(disp_seconds, 10) + '0';
    buffer[4] = @rem(disp_seconds, 10) + '0';

    return buffer[0..5]; // Return slice "MM:SS"
}

const PlayerOutput = struct {
    title: []const u8,
    album: []const u8,
    artist: []const u8,
    length: i64,
    position: i64,
    status: []const u8,
};

pub const Player = struct {
    allocator: std.mem.Allocator,
    name: []const u8,
    title: []const u8,
    album: []const u8,
    artist: []const u8,
    length: i64,
    position: i64,
    status: []const u8,

    pub fn deinit(self: Player) void {
        self.allocator.free(self.name);
        self.allocator.free(self.title);
        self.allocator.free(self.album);
        self.allocator.free(self.artist);
        self.allocator.free(self.status);
    }

    pub fn Toggle(self: Player) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const player_name_len = self.name.len;
        const player_name_buf = try arena.alloc(u8, player_name_len + 1);
        @memcpy(player_name_buf[0..player_name_len], self.name);
        player_name_buf[player_name_len] = 0;

        defer arena.free(player_name_buf);

        const msg = c.dbus_message_new_method_call(
            player_name_buf.ptr,
            "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player",
            "PlayPause",
        );
        if (msg == null) {
            return PlayerError.DBusMessageCreationFailed;
        }
        defer c.dbus_message_unref(msg);

        _ = c.dbus_connection_send(conn, msg, null);
        _ = c.dbus_connection_flush(conn);
    }

    pub fn Previous(self: Player) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const player_name_len = self.name.len;
        const player_name_buf = try arena.alloc(u8, player_name_len + 1);
        @memcpy(player_name_buf[0..player_name_len], self.name);
        player_name_buf[player_name_len] = 0;

        defer arena.free(player_name_buf);

        const msg = c.dbus_message_new_method_call(
            player_name_buf.ptr,
            "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player",
            "Previous",
        );
        if (msg == null) {
            return PlayerError.DBusMessageCreationFailed;
        }
        defer c.dbus_message_unref(msg);

        _ = c.dbus_connection_send(conn, msg, null);
        _ = c.dbus_connection_flush(conn);
    }

    pub fn Next(self: Player) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const player_name_len = self.name.len;
        const player_name_buf = try arena.alloc(u8, player_name_len + 1);
        @memcpy(player_name_buf[0..player_name_len], self.name);
        player_name_buf[player_name_len] = 0;

        defer arena.free(player_name_buf);

        const msg = c.dbus_message_new_method_call(
            player_name_buf.ptr,
            "/org/mpris/MediaPlayer2",
            "org.mpris.MediaPlayer2.Player",
            "Next",
        );
        if (msg == null) {
            return PlayerError.DBusMessageCreationFailed;
        }
        defer c.dbus_message_unref(msg);

        _ = c.dbus_connection_send(conn, msg, null);
        _ = c.dbus_connection_flush(conn);
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

    pub fn RefreshPosition(self: *Player) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const player_name_cstring = try arena.dupeZ(u8, self.name);
        defer arena.free(player_name_cstring);

        const get_position_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );

        if (get_position_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get Position for {s})\n", .{self.name});
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
            std.debug.print("D-Bus Reply Error (Get Position for {s}: {s})\n", .{ self.name, cStringToString(err.message) });
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
                    self.position = position;
                }
            }
        }
    }

    pub fn Refresh(self: *Player) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const player_name_cstring = try arena.dupeZ(u8, self.name);
        defer arena.free(player_name_cstring);

        // Reset current player's data before refreshing
        self.allocator.free(self.title);
        self.allocator.free(self.album);
        self.allocator.free(self.artist);
        self.allocator.free(self.status);

        self.title = try self.allocator.dupe(u8, "");
        self.album = try self.allocator.dupe(u8, "");
        self.artist = try self.allocator.dupe(u8, "");
        self.status = try self.allocator.dupe(u8, "");
        self.length = 0;
        self.position = 0;

        // Get Metadata
        const get_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );
        if (get_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get Metadata for {s})\n", .{self.name});
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
            std.debug.print("D-Bus Reply Error (Get Metadata for {s}: {s})\n", .{ self.name, cStringToString(err.message) });
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
                                    self.title = try self.allocator.dupe(u8, std.mem.span(title));
                                }
                            }
                        } else if (std.mem.eql(u8, std.mem.span(key), "xesam:album")) {
                            if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                var value_iter: c.DBusMessageIter = undefined;
                                c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_STRING) {
                                    var album: [*c]const u8 = undefined;
                                    c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&album));
                                    self.album = try self.allocator.dupe(u8, std.mem.span(album));
                                }
                            }
                        } else if (std.mem.eql(u8, std.mem.span(key), "mpris:length")) {
                            if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                var value_iter: c.DBusMessageIter = undefined;
                                c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_INT64) {
                                    var length: i64 = undefined;
                                    c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&length));
                                    self.length = length;
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
                                        self.artist = try self.allocator.dupe(u8, std.mem.span(artist));
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
        }

        // Get PlaybackStatus
        const get_status_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );

        if (get_status_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get PlaybackStatus for {s})\n", .{self.name});
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
            std.debug.print("D-Bus Reply Error (Get PlaybackStatus for {s}: {s})\n", .{ self.name, cStringToString(err.message) });
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
                    self.status = try self.allocator.dupe(u8, std.mem.span(status));
                }
            }
        }

        // Get Position
        const get_position_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );

        if (get_position_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get Position for {s})\n", .{self.name});
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
            std.debug.print("D-Bus Reply Error (Get Position for {s}: {s})\n", .{ self.name, cStringToString(err.message) });
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
                    self.position = position;
                }
            }
        }
    }
};

pub const Mpris2Client = struct {
    allocator: std.mem.Allocator,
    conn: *c.DBusConnection,
    players: std.ArrayList(Player),
    player_ctld_uid: []const u8, // Store the D-Bus unique ID of the playerctld service
    autofocus: bool,
    current_player: ?*Player,

    pub fn init(allocator: std.mem.Allocator) !Mpris2Client {
        // Implementation will go here
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn_nullable = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn_nullable == null) {
            return PlayerError.DBusConnectionFailed;
        }
        const conn: *c.DBusConnection = conn_nullable.?;

        // Dummy player_ctld_uid for now, will be populated later
        const player_ctld_uid = try allocator.dupe(u8, "");

        return Mpris2Client{
            .allocator = allocator,
            .conn = conn,
            .players = std.ArrayList(Player).init(allocator),
            .player_ctld_uid = player_ctld_uid,
            .autofocus = true, // Initialize autofocus to true
            .current_player = null, // No current player initially
        };
    }

    pub fn deinit(self: *Mpris2Client) void {
        for (self.players.items) |player| {
            player.deinit();
        }
        self.players.deinit();
        self.allocator.free(self.player_ctld_uid);
        c.dbus_connection_unref(self.conn);
    }

    pub fn printPlayerInfo(self: *Mpris2Client) !void {
        const writer = std.io.getStdOut().writer();

        if (self.current_player) |player| {
            // Refresh the player data before printing
            player.Refresh() catch |err| {
                std.debug.print("Failed to refresh player {s}: {}\n", .{ player.name, err });
                return; // Exit if refresh fails
            };

            var class_str: []const u8 = undefined;
            var status_icon: []const u8 = undefined;

            if (std.mem.eql(u8, player.status, "Playing")) {
                class_str = "playing";
                status_icon = "▶";
            } else if (std.mem.eql(u8, player.status, "Paused")) {
                class_str = "paused";
                status_icon = "⏸";
            } else {
                class_str = "stopped";
                status_icon = "⏹";
            }

            const title_str = if (player.title.len > 0) player.title else "Unknown Title";
            const artist_str = if (player.artist.len > 0) player.artist else "Unknown Artist";
            const album_str = if (player.album.len > 0) player.album else "Unknown Album";

            var text_display_buf: [256]u8 = undefined;
            var text_stream = std.io.fixedBufferStream(&text_display_buf);
            var text_writer = text_stream.writer();

            try text_writer.print("{s} {s}", .{ status_icon, title_str });
            if (player.length > 0) {
                try text_writer.print(" ({s}/{s})", .{ formatTime(player.position), formatTime(player.length) });
            }
            const final_text_slice = text_stream.getWritten();

            var tooltip_display_buf: [512]u8 = undefined;
            var tooltip_stream = std.io.fixedBufferStream(&tooltip_display_buf);
            var tooltip_writer = tooltip_stream.writer();

            try tooltip_writer.print("{s}\\nby {s}\\nfrom {s}\\n({s})", .{
                title_str,
                artist_str,
                album_str,
                player.name,
            });
            const final_tooltip_slice = tooltip_stream.getWritten();

            std.debug.print(
                \\{{"class":"{s}","text":"{s}","tooltip":"{s}"}}
            , .{
                class_str,
                final_text_slice,
                final_tooltip_slice,
            });
            try writer.writeAll("\n");
        } else {
            // No player, print empty JSON
            try writer.writeAll("{}\n");
        }
    }

    pub fn selectCurrentPlayer(self: *Mpris2Client) !void {
        const arena_state = std.heap.ArenaAllocator.init(self.allocator);
        defer arena_state.deinit();
        self.current_player = null; // Reset current player

        if (!self.autofocus) {
            if (self.players.items.len > 0) {
                self.current_player = &self.players.items[0];
            }
            return;
        }

        // Try to find a playing player
        for (self.players.items) |*player| {
            _ = player.Refresh() catch |err| {
                std.debug.print("Failed to refresh player {s} for autofocus: {}\n", .{ player.name, err });
                continue; // Skip this player if refresh fails
            };
            if (std.mem.eql(u8, player.status, "Playing")) {
                self.current_player = player;
                return;
            }
        }

        // If no playing player, try to find a paused player
        for (self.players.items) |*player| {
            _ = player.Refresh() catch |err| {
                std.debug.print("Failed to refresh player {s} for autofocus: {}\n", .{ player.name, err });
                continue; // Skip this player if refresh fails
            };
            if (std.mem.eql(u8, player.status, "Paused")) {
                self.current_player = player;
                return;
            }
        }

        // If no playing or paused player, default to the first player in the list
        if (self.players.items.len > 0) {
            self.current_player = &self.players.items[0];
        }
        return;
    }

    pub fn AddMatch(self: *Mpris2Client, rule: []const u8) !void {
        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const rule_cstring = try arena.dupeZ(u8, rule);
        defer arena.free(rule_cstring);

        c.dbus_bus_add_match(self.conn, rule_cstring.ptr, @as(?*c.DBusError, null));
        _ = c.dbus_connection_flush(self.conn);
    }

    pub fn Listen(self: *Mpris2Client) !void {
        // Add D-Bus match rules for NameOwnerChanged and PropertiesChanged
        try self.AddMatch(MATCH_NOC);
        try self.AddMatch(MATCH_PC);

        // Populate initial players
        try self.populatePlayers();
        try self.selectCurrentPlayer();
        try self.printPlayerInfo();

        // Add the filter function to process D-Bus messages
        // The last argument is user_data, which will be a pointer to 'self'
        if (c.dbus_connection_add_filter(self.conn, mpris2_filter_function, @ptrCast(self), null) == 0) {
            std.debug.print("Failed to add D-Bus filter.\n", .{});
            return PlayerError.DBusConnectionFailed;
        }

        // Enter the D-Bus message dispatch loop
        while (true) {
            // Read incoming messages, blocking until there is data or 500ms timeout
            _ = c.dbus_connection_read_write_dispatch(self.conn, 500);

            if (self.current_player) |player| {
                if (std.mem.eql(u8, player.status, "Playing")) {
                    _ = player.RefreshPosition() catch {};
                    _ = self.printPlayerInfo() catch {};
                }
            }
        }
    }

    pub fn AddPlayer(self: *Mpris2Client, player_name_slice: []const u8) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

        var arena_state = std.heap.ArenaAllocator.init(self.allocator);
        var arena = arena_state.allocator();
        defer arena_state.deinit();

        const player_name_cstring = try arena.dupeZ(u8, player_name_slice);
        defer arena.free(player_name_cstring);

        var player_internal = PlayerInternal{
            .title = std.ArrayList(u8).init(self.allocator),
            .album = std.ArrayList(u8).init(self.allocator),
            .artist = std.ArrayList(u8).init(self.allocator),
            .status = std.ArrayList(u8).init(self.allocator),
            .length = 0,
            .position = 0,
        };
        defer player_internal.deinit();

        // Get Metadata
        const get_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );
        if (get_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get Metadata for {s})\n", .{player_name_slice});
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
            std.debug.print("D-Bus Reply Error (Get Metadata for {s}: {s})\n", .{ player_name_slice, cStringToString(err.message) });
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
                                    try player_internal.title.appendSlice(std.mem.span(title));
                                }
                            }
                        } else if (std.mem.eql(u8, std.mem.span(key), "xesam:album")) {
                            if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                var value_iter: c.DBusMessageIter = undefined;
                                c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_STRING) {
                                    var album: [*c]const u8 = undefined;
                                    c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&album));
                                    try player_internal.album.appendSlice(std.mem.span(album));
                                }
                            }
                        } else if (std.mem.eql(u8, std.mem.span(key), "mpris:length")) {
                            if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                var value_iter: c.DBusMessageIter = undefined;
                                c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_INT64) {
                                    var length: i64 = undefined;
                                    c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&length));
                                    player_internal.length = length;
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
                                        try player_internal.artist.appendSlice(std.mem.span(artist));
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
        }

        // Get PlaybackStatus
        const get_status_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );

        if (get_status_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get PlaybackStatus for {s})\n", .{player_name_slice});
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
            std.debug.print("D-Bus Reply Error (Get PlaybackStatus for {s}: {s})\n", .{ player_name_slice, cStringToString(err.message) });
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
                    try player_internal.status.appendSlice(std.mem.span(status));
                }
            }
        }

        // Get Position
        const get_position_msg = c.dbus_message_new_method_call(
            player_name_cstring.ptr,
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "Get",
        );

        if (get_position_msg == null) {
            std.debug.print("D-Bus Message Creation Failed (Get Position for {s})\n", .{player_name_slice});
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
            std.debug.print("D-Bus Reply Error (Get Position for {s}: {s})\n", .{ player_name_slice, cStringToString(err.message) });
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
                    player_internal.position = position;
                }
            }
        }

        try self.players.append(Player{
            .allocator = self.allocator,
            .name = try self.allocator.dupe(u8, player_name_slice),
            .title = try self.allocator.dupe(u8, player_internal.title.items),
            .album = try self.allocator.dupe(u8, player_internal.album.items),
            .artist = try self.allocator.dupe(u8, player_internal.artist.items),
            .status = try self.allocator.dupe(u8, player_internal.status.items),
            .position = player_internal.position,
            .length = player_internal.length,
        });
        try self.selectCurrentPlayer();
    }

    pub fn RemovePlayer(self: *Mpris2Client, player_name_slice: []const u8) !void {
        var found_idx: ?usize = null;
        for (self.players.items, 0..) |player, i| {
            if (std.mem.eql(u8, player.name, player_name_slice)) {
                found_idx = i;
                break;
            }
        }

        if (found_idx) |idx| {
            self.players.items[idx].deinit(); // Deinitialize the player
            _ = self.players.swapRemove(idx); // Remove from ArrayList
            try self.selectCurrentPlayer();
        } else {
            std.debug.print("Player {s} not found for removal.\n", .{player_name_slice});
        }
    }

    pub fn findPlayer(self: *Mpris2Client, player_name_slice: []const u8) ?*Player {
        for (self.players.items) |*player| {
            if (std.mem.eql(u8, player.name, player_name_slice)) {
                return player;
            }
        }
        return null;
    }

    pub fn populatePlayers(self: *Mpris2Client) !void {
        var err: DBusError = undefined;
        c.dbus_error_init(@ptrCast(&err));
        defer c.dbus_error_free(@ptrCast(&err));

        const conn = c.dbus_bus_get(c.DBUS_BUS_SESSION, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Connection Error ({s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusConnectionFailed;
        }
        if (conn == null) {
            return PlayerError.DBusConnectionFailed;
        }
        defer c.dbus_connection_unref(conn);

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
        defer c.dbus_message_unref(list_msg);

        const list_reply = c.dbus_connection_send_with_reply_and_block(conn, list_msg, -1, @ptrCast(&err));
        if (c.dbus_error_is_set(@ptrCast(&err)) != 0) {
            std.debug.print("D-Bus Reply Error (ListNames: {s})\n", .{cStringToString(err.message)});
            return PlayerError.DBusReplyFailed;
        }
        if (list_reply == null) {
            return PlayerError.DBusReplyFailed;
        }
        defer c.dbus_message_unref(list_reply);

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
                    // Try to add the player
                    _ = self.AddPlayer(std.mem.span(player_name)) catch |add_err| {
                        std.debug.print("Failed to add player {s}: {}\n", .{ std.mem.span(player_name), add_err });
                    };
                }

                if (c.dbus_message_iter_next(&sub) == 0) {
                    break;
                }
            }
        }
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

fn cStringToString(c_string: ?[*c]const u8) []const u8 {
    if (c_string) |str_ptr| {
        return std.mem.span(str_ptr);
    }
    return "(unknown error)";
}

fn mpris2_filter_function(
    connection: ?*c.DBusConnection,
    message: ?*c.DBusMessage,
    user_data: ?*anyopaque,
) callconv(.c) c.DBusHandlerResult {
    _ = connection; // Unused
    if (user_data == null) {
        return c.DBUS_HANDLER_RESULT_HANDLED;
    }
    const clientPtr = user_data.?;
    // const PtrInfo = @typeInfo(Ptr);
    // std.debug.assert(PtrInfo == .Pointer); // Must be a pointer
    // std.debug.assert(PtrInfo.Pointer.size == .One); // Must be a single-item pointer
    // std.debug.assert(@typeInfo(PtrInfo.Pointer.child) == .Struct); // Must point to a struct

    const client = @as(*Mpris2Client, @ptrCast(@alignCast(clientPtr)));

    if (message) |msg| {
        const sender = c.dbus_message_get_sender(msg);
        const path = c.dbus_message_get_path(msg);
        const interface = c.dbus_message_get_interface(msg);
        const member = c.dbus_message_get_member(msg);
        const type_str = c.dbus_message_type_to_string(c.dbus_message_get_type(msg));

        std.debug.print("D-Bus Message: type={s}, sender={s}, path={s}, interface={s}, member={s}\n", .{
            cStringToString(type_str),
            cStringToString(sender),
            cStringToString(path),
            cStringToString(interface),
            cStringToString(member),
        });
    } else {
        std.debug.print("Received null D-Bus message in filter function.\n", .{});
    }

    // Check for NameOwnerChanged signal
    if (c.dbus_message_is_signal(message, "org.freedesktop.DBus", "NameOwnerChanged") != 0) {
        var iter: c.DBusMessageIter = undefined;
        _ = c.dbus_message_iter_init(message, &iter);

        var name: [*c]const u8 = undefined;
        // The first argument is the name that changed
        if (c.dbus_message_iter_get_arg_type(&iter) == c.DBUS_TYPE_STRING) {
            c.dbus_message_iter_get_basic(&iter, @ptrCast(&name));
            std.debug.print("NameOwnerChanged: name={s}\n", .{std.mem.span(name)}); // Debug print

            // Check if it's an MPRIS player
            const mpris_prefix = "org.mpris.MediaPlayer2.";
            if (std.mem.startsWith(u8, std.mem.span(name), mpris_prefix)) {
                // Determine if player was added or removed
                // The third argument of NameOwnerChanged is the new owner (empty string if removed)
                _ = c.dbus_message_iter_next(&iter); // Skip old owner
                _ = c.dbus_message_iter_next(&iter); // Skip new owner
                var new_owner: [*c]const u8 = undefined;
                if (c.dbus_message_iter_get_arg_type(&iter) == c.DBUS_TYPE_STRING) {
                    c.dbus_message_iter_get_basic(&iter, @ptrCast(&new_owner));
                    if (std.mem.eql(u8, std.mem.span(new_owner), "")) {
                        // Player removed
                        std.debug.print("MPRIS player {s} removed.\n", .{std.mem.span(name)});
                        _ = client.RemovePlayer(std.mem.span(name)) catch {};
                    } else {
                        // Player added
                        std.debug.print("MPRIS player {s} added.\n", .{std.mem.span(name)});
                        _ = client.AddPlayer(std.mem.span(name)) catch {};
                    }
                    _ = client.selectCurrentPlayer() catch {};
                    _ = client.printPlayerInfo() catch {};
                }
            }
        }
    } else if (c.dbus_message_is_signal(message, "org.freedesktop.DBus.Properties", "PropertiesChanged") != 0) {
        var iter: c.DBusMessageIter = undefined;
        _ = c.dbus_message_iter_init(message, &iter);

        var interface_name: [*c]const u8 = undefined;
        if (c.dbus_message_iter_get_arg_type(&iter) == c.DBUS_TYPE_STRING) {
            c.dbus_message_iter_get_basic(&iter, @ptrCast(&interface_name));

        std.debug.print("Property: interface={s}\n", .{std.mem.span(interface_name)}); // Debug print

        if (std.mem.eql(u8, std.mem.span(interface_name), INTERFACE ++ ".Player")) {
            // Get the player's D-Bus name from the sender of the message
            const sender_name = c.dbus_message_get_sender(message);
            std.debug.print("Player: name={s}\n", .{std.mem.span(sender_name)}); // Debug print
            if (sender_name != null) {
                if (client.findPlayer(std.mem.span(sender_name))) |player| {
                    _ = c.dbus_message_iter_next(&iter); // Advance to the changed_properties dictionary
                    if (c.dbus_message_iter_get_arg_type(&iter) == c.DBUS_TYPE_ARRAY) {
                        var dict_iter: c.DBusMessageIter = undefined;
                        c.dbus_message_iter_recurse(&iter, &dict_iter);
                        while (c.dbus_message_iter_get_arg_type(&dict_iter) == c.DBUS_TYPE_DICT_ENTRY) {
                            var entry_iter: c.DBusMessageIter = undefined;
                            c.dbus_message_iter_recurse(&dict_iter, &entry_iter);

                            var key: [*c]const u8 = undefined;
                            if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_STRING) {
                                c.dbus_message_iter_get_basic(&entry_iter, @ptrCast(&key));
                            }
                            _ = c.dbus_message_iter_next(&entry_iter);

                            if (std.mem.eql(u8, std.mem.span(key), "Position")) {
                                if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                    var value_iter: c.DBusMessageIter = undefined;
                                    c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                    if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_INT64) {
                                        var position: i64 = undefined;
                                        c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&position));
                                        player.position = position;
                                        std.debug.print("MPRIS player {s} Position changed to {d}\n", .{std.mem.span(sender_name), position});
                                    }
                                }
                            } else if (std.mem.eql(u8, std.mem.span(key), "PlaybackStatus")) {
                                if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                    var value_iter: c.DBusMessageIter = undefined;
                                    c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                    if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_STRING) {
                                        var status: [*c]const u8 = undefined;
                                        c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&status));
                                        player.allocator.free(player.status);
                                        player.status = player.allocator.dupe(u8, std.mem.span(status)) catch {
                                            std.debug.print("Failed to duplicate status string\n", .{});
                                            return c.DBUS_HANDLER_RESULT_HANDLED;
                                        };
                                        std.debug.print("MPRIS player {s} PlaybackStatus changed to {s}\n", .{std.mem.span(sender_name), std.mem.span(status)});
                                    }
                                }
                            } else if (std.mem.eql(u8, std.mem.span(key), "Metadata")) {
                                // For metadata changes, we need to refresh all metadata properties
                                _ = player.Refresh() catch {}; // This will get all metadata
                                std.debug.print("MPRIS player {s} Metadata changed.\n", .{std.mem.span(sender_name)});
                            } else {
                                // For any other property change, just refresh everything
                                _ = player.Refresh() catch {};
                                std.debug.print("MPRIS player {s} property '{s}' changed, performing full refresh.\n", .{std.mem.span(sender_name), std.mem.span(key)});
                            }

                            if (c.dbus_message_iter_next(&dict_iter) == 0) {
                                break;
                            }
                        }
                    }
                    _ = client.selectCurrentPlayer() catch {};
                    _ = client.printPlayerInfo() catch {};
                }
            }
        }
        }
    }
    return c.DBUS_HANDLER_RESULT_HANDLED;
}
