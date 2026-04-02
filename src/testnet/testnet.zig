const std = @import("std");
const chain_mod = @import("../consensus/chain.zig");

pub const TestnetConfig = struct {
    nodes: usize = 3,
    blocks_per_node: usize = 3,
    max_mining_iters: u64 = 2_000_000,
};

pub fn run(allocator: std.mem.Allocator, cfg: TestnetConfig) !void {
    if (cfg.nodes == 0) return error.InvalidNodeCount;

    var chain = try chain_mod.Chain.init(allocator);
    defer chain.deinit();

    var now: i64 = chain.tip().header.timestamp;
    var n: usize = 0;
    while (n < cfg.nodes) : (n += 1) {
        var b: usize = 0;
        while (b < cfg.blocks_per_node) : (b += 1) {
            now += 120;
            const block = try chain.mineNext(now, cfg.max_mining_iters);
            std.log.info("node={d} mined height={d} nonce={d} target={d}", .{
                n,
                block.header.height,
                block.header.nonce,
                block.header.target,
            });
        }
    }

    std.log.info("testnet complete: nodes={d} total_blocks={d}", .{
        cfg.nodes,
        chain.blocks.items.len,
    });
}
