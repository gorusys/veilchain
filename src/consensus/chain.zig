const std = @import("std");
const types = @import("../types.zig");
const pow = @import("pow.zig");
const asert = @import("asert.zig");

pub const Chain = struct {
    allocator: std.mem.Allocator,
    blocks: std.ArrayList(types.Block),
    ideal_block_time: i64 = 120,

    pub fn init(allocator: std.mem.Allocator) !Chain {
        var blocks = std.ArrayList(types.Block).init(allocator);
        const genesis_header = types.BlockHeader{
            .prev_hash = types.zeroHash(),
            .height = 0,
            .timestamp = 1_700_000_000,
            .nonce = 0,
            .target = 0x0000_ffff_ffff_ffff,
            .merkle_root = types.zeroHash(),
        };
        const genesis = types.Block{ .header = genesis_header, .hash = pow.headerHash(genesis_header) };
        try blocks.append(genesis);
        return .{ .allocator = allocator, .blocks = blocks };
    }

    pub fn deinit(self: *Chain) void {
        self.blocks.deinit();
    }

    pub fn tip(self: *const Chain) types.Block {
        return self.blocks.items[self.blocks.items.len - 1];
    }

    pub fn nextTarget(self: *const Chain, now_ts: i64) u64 {
        const parent = self.tip();
        return asert.nextTarget(parent.header.target, now_ts - parent.header.timestamp, self.ideal_block_time);
    }

    pub fn mineNext(self: *Chain, now_ts: i64, max_iters: u64) !types.Block {
        const parent = self.tip();
        const candidate = types.BlockHeader{
            .prev_hash = parent.hash,
            .height = parent.header.height + 1,
            .timestamp = now_ts,
            .nonce = 0,
            .target = self.nextTarget(now_ts),
            .merkle_root = types.zeroHash(),
        };
        const solved = pow.mineHeader(candidate, max_iters) orelse return error.NoSolution;
        const block = types.Block{
            .header = solved,
            .hash = pow.headerHash(solved),
        };
        try self.append(block);
        return block;
    }

    pub fn append(self: *Chain, block: types.Block) !void {
        const parent = self.tip();
        if (!std.mem.eql(u8, &block.header.prev_hash, &parent.hash)) return error.BadPrevHash;
        if (block.header.height != parent.header.height + 1) return error.BadHeight;
        if (!pow.meetsTarget(block.hash, block.header.target)) return error.InvalidPow;
        try self.blocks.append(block);
    }
};

test "chain mines and appends blocks" {
    var chain = try Chain.init(std.testing.allocator);
    defer chain.deinit();

    _ = try chain.mineNext(1_700_000_120, 2_000_000);
    _ = try chain.mineNext(1_700_000_240, 2_000_000);
    try std.testing.expectEqual(@as(usize, 3), chain.blocks.items.len);
}
