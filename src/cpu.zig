const std = @import("std");
const expect = std.testing.expect;
const CPU = struct {
    a: u8,
    b: u8,
    c: u8,
    d: u8,
    e: u8,
    h: u8,
    l: u8,
    f: u8,
    sp: u16,
    pc: u16,

    fn af(self: *CPU) u16 {
        return @as(u16, self.a) << 8 | @as(u16, self.f);
    }

    fn bc(self: *CPU) u16 {
        return @as(u16, self.b) << 8 | @as(u16, self.c);
    }

    fn executeInstuction(self: *CPU, memory: []const u8) void {
        // Fetch the next opcode
        const opcode = memory[self.pc];

        switch (opcode) {
            // NOP
            0x00 => {
                std.debug.print("NOP\n", .{});
            },
            // LD BC, d16
            0x01 => {
                std.debug.print("LD\n", .{});
                self.pc += 1;
                const lowByte = memory[self.pc];

                self.pc += 1;
                const highByte = memory[self.pc];

                self.b = highByte;
                self.c = lowByte;
                std.debug.print("BC: {x}\n", .{self.bc()});
            },
            else => std.debug.print("Unknown opcode: {x}\n", .{opcode}),
        }

        self.pc += 1;
    }
};

pub fn init() CPU {
    return .{
        .a = 0x01,
        .b = 0x00,
        .c = 0x13,
        .d = 0x00,
        .e = 0xd8,
        .h = 0x01,
        .l = 0x4d,
        .f = 0xb0,
        .sp = 0xfffe,
        .pc = 0x0,
    };
}

test "NOP" {
    var c = init();
    const memory = [_]u8{0x00};
    c.executeInstuction(&memory);
}

test "LD BC, d16" {
    var c = init();
    const memory = [_]u8{ 0x01, 0x13, 0x10 };
    c.executeInstuction(&memory);

    try expect(c.bc() == 0x1013);
}
