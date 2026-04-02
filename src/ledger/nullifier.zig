const std = @import("std");
const blake3 = @import("../crypto/blake3.zig");

pub fn deriveNullifier(note_commitment: [32]u8, spend_key: [32]u8) [32]u8 {
    var buf: [64]u8 = undefined;
    @memcpy(buf[0..32], spend_key[0..32]);
    @memcpy(buf[32..64], note_commitment[0..32]);
    return blake3.hash(&buf);
}

pub const NullifierSet = struct {
    map: std.AutoHashMap([32]u8, void),

    pub fn init(allocator: std.mem.Allocator) NullifierSet {
        return .{ .map = std.AutoHashMap([32]u8, void).init(allocator) };
    }

    pub fn deinit(self: *NullifierSet) void {
        self.map.deinit();
    }

    pub fn contains(self: *NullifierSet, nf: [32]u8) bool {
        return self.map.contains(nf);
    }

    pub fn insert(self: *NullifierSet, nf: [32]u8) !void {
        try self.map.put(nf, {});
    }
};
