const std = @import("std");
const testnet = @import("testnet/testnet.zig");

test "testnet runs with small topology" {
    try testnet.run(std.testing.allocator, .{
        .nodes = 2,
        .blocks_per_node = 1,
        .max_mining_iters = 1_500_000,
    });
}
