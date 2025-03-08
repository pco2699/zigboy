const std = @import("std");
const CPU = @import("cpu.zig");

var memory: [0x10000]u8 = undefined; // 64KB of memory

pub fn main() !void {
    // Open the binary file
    const file = try std.fs.cwd().openFile("test-roms/first/first.bin", .{ .mode = .read_only });

    defer file.close();

    var c = CPU.init();
    // Read the entire file into memory
    const read_bytes = try file.readAll(&memory);

    while (c.pc < read_bytes) {
        // Fetch the next opcode
        const opcode = memory[c.pc];
        c.pc += 1;
        c.executeInstruction(&memory, opcode);
    }
}
