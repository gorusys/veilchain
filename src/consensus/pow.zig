const std = @import("std");
const blake3 = @import("../crypto/blake3.zig");
const types = @import("../types.zig");

pub fn headerHash(header: types.BlockHeader) types.Hash {
    var buf: [32 + 8 + 8 + 8 + 8 + 32]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const w = fbs.writer();
    w.writeAll(&header.prev_hash) catch unreachable;
    w.writeInt(u64, header.height, .little) catch unreachable;
    w.writeInt(i64, header.timestamp, .little) catch unreachable;
    w.writeInt(u64, header.nonce, .little) catch unreachable;
    w.writeInt(u64, header.target, .little) catch unreachable;
    w.writeAll(&header.merkle_root) catch unreachable;
    return blake3.hash(buf[0..fbs.pos]);
}

pub fn meetsTarget(hash: types.Hash, target: u64) bool {
    const leading = std.mem.readInt(u64, hash[0..8], .little);
    return leading <= target;
}

pub fn mineHeader(base: types.BlockHeader, max_iters: u64) ?types.BlockHeader {
    var header = base;
    var i: u64 = 0;
    while (i < max_iters) : (i += 1) {
        const h = headerHash(header);
        if (meetsTarget(h, header.target)) return header;
        header.nonce +%= 1;
    }
    return null;
}

test "mineHeader finds a solution" {
    const header = types.BlockHeader{
        .prev_hash = types.zeroHash(),
        .height = 1,
        .timestamp = 1_700_000_000,
        .nonce = 0,
        .target = 0x0000_ffff_ffff_ffff,
        .merkle_root = types.zeroHash(),
    };
    const mined = mineHeader(header, 2_000_000) orelse return error.NotMined;
    const h = headerHash(mined);
    try std.testing.expect(meetsTarget(h, mined.target));
}
