const std = @import("std");

pub fn hash(data: []const u8) [32]u8 {
    var out: [32]u8 = undefined;
    std.crypto.hash.Blake3.hash(data, &out, .{});
    return out;
}
