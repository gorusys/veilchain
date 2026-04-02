pub const MessageType = enum(u8) {
    get_headers = 1,
    headers = 2,
    block = 3,
    tx = 4,
    ping = 5,
    pong = 6,
};

pub const PeerInfo = struct {
    id: u32,
    port: u16,
};
