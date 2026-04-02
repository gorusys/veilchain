const std = @import("std");
const blake3 = @import("../crypto/blake3.zig");

pub const Note = struct {
    value: u64,
    asset_id: u32,
    rho: [32]u8,
    r: [32]u8,

    pub fn commitment(self: Note) [32]u8 {
        var buf: [8 + 4 + 32 + 32]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();
        w.writeInt(u64, self.value, .little) catch unreachable;
        w.writeInt(u32, self.asset_id, .little) catch unreachable;
        w.writeAll(&self.rho) catch unreachable;
        w.writeAll(&self.r) catch unreachable;
        return blake3.hash(buf[0..fbs.pos]);
    }
};
