const std = @import("std");

pub const Hash = [32]u8;

pub const BlockHeader = struct {
    prev_hash: Hash,
    height: u64,
    timestamp: i64,
    nonce: u64,
    target: u64,
    merkle_root: Hash,
};

pub const Block = struct {
    header: BlockHeader,
    hash: Hash,
};

pub fn zeroHash() Hash {
    return [_]u8{0} ** 32;
}

pub fn hashToHex(allocator: std.mem.Allocator, h: Hash) ![]u8 {
    const out = try allocator.alloc(u8, 64);
    _ = std.fmt.bufPrint(out, "{s}", .{std.fmt.fmtSliceHexLower(&h)}) catch unreachable;
    return out;
}
