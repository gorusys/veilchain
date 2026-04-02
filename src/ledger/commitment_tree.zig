const std = @import("std");
const blake3 = @import("../crypto/blake3.zig");

pub const CommitmentTree = struct {
    leaves: std.ArrayList([32]u8),

    pub fn init(allocator: std.mem.Allocator) CommitmentTree {
        return .{ .leaves = std.ArrayList([32]u8).init(allocator) };
    }

    pub fn deinit(self: *CommitmentTree) void {
        self.leaves.deinit();
    }

    pub fn append(self: *CommitmentTree, c: [32]u8) !void {
        try self.leaves.append(c);
    }

    pub fn root(self: *const CommitmentTree) [32]u8 {
        if (self.leaves.items.len == 0) return [_]u8{0} ** 32;

        var acc = self.leaves.items[0];
        var i: usize = 1;
        while (i < self.leaves.items.len) : (i += 1) {
            var buf: [64]u8 = undefined;
            @memcpy(buf[0..32], acc[0..32]);
            @memcpy(buf[32..64], self.leaves.items[i][0..32]);
            acc = blake3.hash(&buf);
        }
        return acc;
    }
};
