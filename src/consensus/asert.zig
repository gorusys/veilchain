pub fn nextTarget(parent_target: u64, time_delta: i64, ideal_block_time: i64) u64 {
    if (ideal_block_time <= 0) return parent_target;

    var target = parent_target;
    if (time_delta > ideal_block_time and target < 0x00ff_ffff_ffff_ffff) {
        target += @as(u64, @intCast(@divTrunc(time_delta - ideal_block_time, 2) + 1));
    } else if (time_delta < ideal_block_time and target > 1024) {
        const shrink = @as(u64, @intCast(@divTrunc(ideal_block_time - time_delta, 2) + 1));
        target = if (target > shrink) target - shrink else 1024;
    }
    return target;
}

test "asert responds to slow and fast blocks" {
    const slow = nextTarget(100_000, 220, 120);
    const fast = nextTarget(100_000, 30, 120);
    try std.testing.expect(slow > 100_000);
    try std.testing.expect(fast < 100_000);
}

const std = @import("std");
