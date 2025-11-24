const std = @import("std");
const json = std.json;
const c = @cImport({
    @cInclude("dbus/dbus.h");
    @cInclude("stdio.h");
});

const INTERFACE = "org.mpris.MediaPlayer2";
const PATH = "/org/mpris/MediaPlayer2";

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

fn formatTime(buffer: []u8, us: i64) []const u8 {
    const total_seconds = @divTrunc(us, 1_000_000);
    const minutes_val = @divTrunc(total_seconds, 60);
    const seconds_val = @rem(total_seconds, 60);

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
    id: usize,
    name: []const u8,
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

    pub fn toOutput(self: Player, id: usize) PlayerOutput {
        return PlayerOutput{
            .id = id,
            .name = self.name,
            .title = self.title,
            .album = self.album,
            .artist = self.artist,
            .length = self.length,
            .position = self.position,
            .status = self.status,
        };
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
    last_printed_output: std.ArrayList(u8),
    scroll_positions: std.StringHashMap(usize),
    max_len: usize,

    pub fn init(allocator: std.mem.Allocator, max_len: usize) !Mpris2Client {
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
            .players = std.ArrayList(Player){},
            .player_ctld_uid = player_ctld_uid,
            .autofocus = true, // Initialize autofocus to true
            .current_player = null, // No current player initially
            .last_printed_output = std.ArrayList(u8){},
            .scroll_positions = std.StringHashMap(usize).init(allocator),
            .max_len = max_len,
        };
    }

    pub fn deinit(self: *Mpris2Client) void {
        for (self.players.items) |player| {
            player.deinit();
        }
        self.players.deinit(self.allocator);
        self.allocator.free(self.player_ctld_uid);
        self.last_printed_output.deinit(self.allocator);
        self.scroll_positions.deinit();
        c.dbus_connection_unref(self.conn);
    }

    pub fn printPlayerInfo(self: *Mpris2Client) !void {
        var current_output_buffer = std.ArrayList(u8){};
        defer current_output_buffer.deinit(self.allocator);
        var current_output_writer = current_output_buffer.writer(self.allocator);

        if (self.current_player) |player| {
            const separator = " | ";

            var class_str: []const u8 = undefined;
            var status_icon: []const u8 = undefined;

            if (std.mem.eql(u8, player.status, "Playing")) {
                class_str = "playing";
                status_icon = "⏸";
            } else if (std.mem.eql(u8, player.status, "Paused")) {
                class_str = "paused";
                status_icon = "▶";
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

            try text_writer.print("{s} ", .{status_icon});

            if (title_str.len > self.max_len) {
                var scroll_pos: usize = 0;
                if (self.scroll_positions.get(player.name)) |pos| {
                    scroll_pos = pos;
                } else {
                    // New player in scroll map, dupe the key
                    const key = try self.allocator.dupe(u8, player.name);
                    try self.scroll_positions.put(key, 0);
                }

                const scrolling_text = try std.fmt.allocPrint(self.allocator, "{s}{s}{s}", .{ title_str, separator, title_str });
                defer self.allocator.free(scrolling_text);

                const window_end = @min(scroll_pos + self.max_len, scrolling_text.len);
                const title_to_display = scrolling_text[scroll_pos..window_end];

                try text_writer.print("{s}", .{title_to_display});

                scroll_pos += 1;
                if (scroll_pos > (title_str.len + separator.len)) {
                    scroll_pos = 0;
                }

                // Update the value, key is already there and owned
                try self.scroll_positions.put(player.name, scroll_pos);
            } else {
                try text_writer.print("{s}", .{title_str});
                // Reset scroll position if title is short
                if (self.scroll_positions.contains(player.name)) {
                    try self.scroll_positions.put(player.name, 0);
                }
            }

            if (player.length > 0) {
                var pos_buf: [5]u8 = undefined;
                var len_buf: [5]u8 = undefined;
                try text_writer.print(" ({s}/{s})", .{ formatTime(&pos_buf, player.position), formatTime(&len_buf, player.length) });
            }
            const final_text_slice = text_stream.getWritten();

            var tooltip_display_buf: [512]u8 = undefined;
            var tooltip_stream = std.io.fixedBufferStream(&tooltip_display_buf);
            var tooltip_writer = tooltip_stream.writer();

            try tooltip_writer.print("{s}\\nby {s}\\nfrom {s}\\n({s})", .{
                title_str, // Use the full title for the tooltip
                artist_str,
                album_str,
                player.name,
            });
            const final_tooltip_slice = tooltip_stream.getWritten();

            try current_output_writer.print(
                \\{{"class":"{s}","text":"{s}","tooltip":"{s}"}}
            , .{
                class_str,
                final_text_slice,
                final_tooltip_slice,
            });
            try current_output_writer.writeAll("\n");
        } else {
            // No player, print empty JSON
            try current_output_writer.writeAll("{}\n");
        }

        // Compare with last printed output and print only if different
        if (!std.mem.eql(u8, current_output_buffer.items, self.last_printed_output.items)) {
            const stdout_file = std.fs.File.stdout();
            var stdout_buffer: [4096]u8 = undefined;
            var stdout_writer = stdout_file.writer(&stdout_buffer);
            const stdout = &stdout_writer.interface;

            try stdout.writeAll(current_output_buffer.items);
            try stdout.flush();

            self.last_printed_output.clearAndFree(self.allocator);
            try self.last_printed_output.appendSlice(self.allocator, current_output_buffer.items);
        }
    }

    pub fn selectCurrentPlayer(self: *Mpris2Client) !void {
        self.current_player = null; // Reset current player

        if (!self.autofocus) {
            if (self.players.items.len > 0) {
                self.current_player = &self.players.items[0];
            }
            return;
        }

        // Try to find a playing player
        for (self.players.items) |*player| {
            if (std.mem.eql(u8, player.status, "Playing")) {
                self.current_player = player;
                return;
            }
        }

        // If no playing player, try to find a paused player
        for (self.players.items) |*player| {
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

    pub fn Listen(self: *Mpris2Client) !void {
        while (true) {
            // Deinit and clear players before repopulating
            for (self.players.items) |player| {
                player.deinit();
            }
            self.players.clearRetainingCapacity();
            // Do NOT clear scroll_positions here, we want to persist them.

            try self.populatePlayers();
            try self.selectCurrentPlayer();

            // Garbage collect scroll_positions
            var keys_to_remove = std.ArrayList([]const u8){};
            defer keys_to_remove.deinit(self.allocator);

            var it = self.scroll_positions.iterator();
            while (it.next()) |entry| {
                const name = entry.key_ptr.*;
                var found = false;
                for (self.players.items) |player| {
                    if (std.mem.eql(u8, player.name, name)) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    try keys_to_remove.append(self.allocator, name);
                }
            }

            for (keys_to_remove.items) |key| {
                _ = self.scroll_positions.remove(key);
                self.allocator.free(key);
            }

            try self.printPlayerInfo();

            std.Thread.sleep(std.time.ns_per_s);
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
            .title = std.ArrayList(u8){},
            .album = std.ArrayList(u8){},
            .artist = std.ArrayList(u8){},
            .status = std.ArrayList(u8){},
            .length = 0,
            .position = 0,
        };
        defer player_internal.deinit(self.allocator);

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
                                    try player_internal.title.appendSlice(self.allocator, std.mem.span(title));
                                }
                            }
                        } else if (std.mem.eql(u8, std.mem.span(key), "xesam:album")) {
                            if (c.dbus_message_iter_get_arg_type(&entry_iter) == c.DBUS_TYPE_VARIANT) {
                                var value_iter: c.DBusMessageIter = undefined;
                                c.dbus_message_iter_recurse(&entry_iter, &value_iter);
                                if (c.dbus_message_iter_get_arg_type(&value_iter) == c.DBUS_TYPE_STRING) {
                                    var album: [*c]const u8 = undefined;
                                    c.dbus_message_iter_get_basic(&value_iter, @ptrCast(&album));
                                    try player_internal.album.appendSlice(self.allocator, std.mem.span(album));
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
                                        try player_internal.artist.appendSlice(self.allocator, std.mem.span(artist));
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
                    try player_internal.status.appendSlice(self.allocator, std.mem.span(status));
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

        try self.players.append(self.allocator, Player{
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

    pub fn deinit(self: *PlayerInternal, allocator: std.mem.Allocator) void {
        self.title.deinit(allocator);
        self.album.deinit(allocator);
        self.artist.deinit(allocator);
        self.status.deinit(allocator);
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
