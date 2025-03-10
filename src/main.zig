const std = @import("std");
const CPU = @import("cpu.zig");

var memory: [0x10000]u8 = undefined; // 64KB of memory

pub fn main() !void {
    // Open the binary file
    const file = try std.fs.cwd().openFile("test-roms/first/first.bin", .{ .mode = .read_only });

    defer file.close();

    const allocator = std.heap.page_allocator;
    var c = CPU.init(allocator);
    defer c.deinit(allocator, &c);
    // Read the entire file into memory
    _ = c.load_cartridge("test-roms/first/first.bin");
    c.emulate();
}
