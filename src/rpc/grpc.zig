const std = @import("std");

pub const RpcServer = struct {
    allocator: std.mem.Allocator,
    bind_addr: []const u8,

    pub fn init(allocator: std.mem.Allocator, bind_addr: []const u8) RpcServer {
        return .{
            .allocator = allocator,
            .bind_addr = bind_addr,
        };
    }

    pub fn start(self: *RpcServer) !void {
        _ = self;
        // Placeholder for future gRPC integration.
    }
};
