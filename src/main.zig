const std = @import("std");
const chain_mod = @import("consensus/chain.zig");
const testnet = @import("testnet/testnet.zig");

fn parseU64(s: []const u8) !u64 {
    return std.fmt.parseInt(u64, s, 10);
}

fn parseUsize(s: []const u8) !usize {
    return std.fmt.parseInt(usize, s, 10);
}

fn printUsage() void {
    std.debug.print(
        \\VeilChain CLI
        \\Usage:
        \\  veilchain testnet [nodes] [blocks_per_node]
        \\  veilchain mine [blocks]
        \\  veilchain status
        \\
    , .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    if (argv.len < 2) {
        printUsage();
        return;
    }

    if (std.mem.eql(u8, argv[1], "testnet")) {
        const nodes: usize = if (argv.len >= 3) try parseUsize(argv[2]) else 3;
        const blocks_per_node: usize = if (argv.len >= 4) try parseUsize(argv[3]) else 3;
        try testnet.run(allocator, .{
            .nodes = nodes,
            .blocks_per_node = blocks_per_node,
        });
        return;
    }

    if (std.mem.eql(u8, argv[1], "mine")) {
        const blocks_to_mine: u64 = if (argv.len >= 3) try parseU64(argv[2]) else 5;
        var chain = try chain_mod.Chain.init(allocator);
        defer chain.deinit();

        var now: i64 = chain.tip().header.timestamp;
        var i: u64 = 0;
        while (i < blocks_to_mine) : (i += 1) {
            now += 120;
            const b = try chain.mineNext(now, 2_000_000);
            std.log.info("mined block height={d} hash_prefix={x}", .{ b.header.height, b.hash[0..4] });
        }
        std.log.info("chain height={d}", .{chain.tip().header.height});
        return;
    }

    if (std.mem.eql(u8, argv[1], "status")) {
        var chain = try chain_mod.Chain.init(allocator);
        defer chain.deinit();
        std.log.info("veilchain status: tip_height={d} target={d}", .{
            chain.tip().header.height,
            chain.tip().header.target,
        });
        return;
    }

    printUsage();
}

test {
    _ = @import("consensus/pow.zig");
    _ = @import("consensus/asert.zig");
    _ = @import("consensus/chain.zig");
    _ = @import("ledger/note.zig");
    _ = @import("ledger/nullifier.zig");
    _ = @import("ledger/commitment_tree.zig");
}
