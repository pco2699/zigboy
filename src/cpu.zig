const std = @import("std");
const op = @import("opcode.zig").opcode;
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

    memory: []u8,

    halted: bool,
    ime: bool,

    cycles: u64,

    fn af(self: *CPU) u16 {
        return @as(u16, self.a) << 8 | @as(u16, self.f);
    }

    fn bc(self: *CPU) u16 {
        return @as(u16, self.b) << 8 | @as(u16, self.c);
    }

    fn de(self: *CPU) u16 {
        return @as(u16, self.d) << 8 | @as(u16, self.e);
    }

    fn hl(self: *CPU) u16 {
        return @as(u16, self.h) << 8 | @as(u16, self.l);
    }

    fn set_zero_flag(self: *CPU, value: bool) void {
        if (value) {
            self.f |= 0x80; // Set the zero flag
        } else {
            self.f &= 0x7F; // Clear the zero flag
        }
    }

    fn get_zero_flag(self: *CPU) bool {
        return (self.f & 0x80) != 0;
    }

    fn load_cartridge(self: *CPU, filename: []const u8) usize {
        const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
        const read_bytes = try file.readAll(&self.memory);
        return read_bytes;
    }

    fn read_byte(self: *CPU, address: u16) u8 {
        return self.memory[address];
    }

    fn write_byte(self: *CPU, address: u16, value: u8) void {
        self.memory[address] = value;
    }

    fn read_next_two_bytes(self: *CPU) struct { u8, u8 } {
        const lowByte = self.memory[self.pc];
        self.pc += 1;

        const highByte = self.memory[self.pc];
        self.pc += 1;

        return .{ lowByte, highByte };
    }

    fn cpu_execute(self: *CPU) u32 {
        if (self.halted) {
            return 4;
        }

        // Fetch the next opcode
        const opcode: op = @enumFromInt(self.memory[self.pc]);
        var cycles: u32 = 4;

        self.pc += 1;

        switch (opcode) {
            // NOP
            op.NOP => {
                std.debug.print("NOP\n", .{});
            },

            // B register destination (0x40-0x47)
            op.LD_B_B => {
                std.debug.print("LD B, B\n", .{});
                // No operation needed as B = B
            },
            op.LD_B_C => {
                std.debug.print("LD B, C\n", .{});
                self.b = self.c;
            },
            op.LD_B_D => {
                std.debug.print("LD B, D\n", .{});
                self.b = self.d;
            },
            op.LD_B_E => {
                std.debug.print("LD B, E\n", .{});
                self.b = self.e;
            },
            op.LD_B_H => {
                std.debug.print("LD B, H\n", .{});
                self.b = self.h;
            },
            op.LD_B_L => {
                std.debug.print("LD B, L\n", .{});
                self.b = self.l;
            },
            op.LD_B_HL => {
                std.debug.print("LD B, (HL)\n", .{});
                self.b = self.read_byte(self.hl());
                cycles = 8; // Takes 8 cycles due to memory access
            },
            op.LD_B_A => {
                std.debug.print("LD B, A\n", .{});
                self.b = self.a;
            },

            // C register destination (0x48-0x4F)
            op.LD_C_B => {
                std.debug.print("LD C, B\n", .{});
                self.c = self.b;
            },
            op.LD_C_C => {
                std.debug.print("LD C, C\n", .{});
                // No operation needed as C = C
            },
            op.LD_C_D => {
                std.debug.print("LD C, D\n", .{});
                self.c = self.d;
            },
            op.LD_C_E => {
                std.debug.print("LD C, E\n", .{});
                self.c = self.e;
            },
            op.LD_C_H => {
                std.debug.print("LD C, H\n", .{});
                self.c = self.h;
            },
            op.LD_C_L => {
                std.debug.print("LD C, L\n", .{});
                self.c = self.l;
            },
            op.LD_C_HL => {
                std.debug.print("LD C, (HL)\n", .{});
                self.c = self.read_byte(self.hl());
                cycles = 8;
            },
            op.LD_C_A => {
                std.debug.print("LD C, A\n", .{});
                self.c = self.a;
            },

            // D register destination (0x50-0x57)
            op.LD_D_B => {
                std.debug.print("LD D, B\n", .{});
                self.d = self.b;
            },
            op.LD_D_C => {
                std.debug.print("LD D, C\n", .{});
                self.d = self.c;
            },
            op.LD_D_D => {
                std.debug.print("LD D, D\n", .{});
                // No operation needed as D = D
            },
            op.LD_D_E => {
                std.debug.print("LD D, E\n", .{});
                self.d = self.e;
            },
            op.LD_D_H => {
                std.debug.print("LD D, H\n", .{});
                self.d = self.h;
            },
            op.LD_D_L => {
                std.debug.print("LD D, L\n", .{});
                self.d = self.l;
            },
            op.LD_D_HL => {
                std.debug.print("LD D, (HL)\n", .{});
                self.d = self.read_byte(self.hl());
                cycles = 8;
            },
            op.LD_D_A => {
                std.debug.print("LD D, A\n", .{});
                self.d = self.a;
            },

            // E register destination (0x58-0x5F)
            op.LD_E_B => {
                std.debug.print("LD E, B\n", .{});
                self.e = self.b;
            },
            op.LD_E_C => {
                std.debug.print("LD E, C\n", .{});
                self.e = self.c;
            },
            op.LD_E_D => {
                std.debug.print("LD E, D\n", .{});
                self.e = self.d;
            },
            op.LD_E_E => {
                std.debug.print("LD E, E\n", .{});
                // No operation needed as E = E
            },
            op.LD_E_H => {
                std.debug.print("LD E, H\n", .{});
                self.e = self.h;
            },
            op.LD_E_L => {
                std.debug.print("LD E, L\n", .{});
                self.e = self.l;
            },
            op.LD_E_HL => {
                std.debug.print("LD E, (HL)\n", .{});
                self.e = self.read_byte(self.hl());
                cycles = 8;
            },
            op.LD_E_A => {
                std.debug.print("LD E, A\n", .{});
                self.e = self.a;
            },

            // H register destination (0x60-0x67)
            op.LD_H_B => {
                std.debug.print("LD H, B\n", .{});
                self.h = self.b;
            },
            op.LD_H_C => {
                std.debug.print("LD H, C\n", .{});
                self.h = self.c;
            },
            op.LD_H_D => {
                std.debug.print("LD H, D\n", .{});
                self.h = self.d;
            },
            op.LD_H_E => {
                std.debug.print("LD H, E\n", .{});
                self.h = self.e;
            },
            op.LD_H_H => {
                std.debug.print("LD H, H\n", .{});
                // No operation needed as H = H
            },
            op.LD_H_L => {
                std.debug.print("LD H, L\n", .{});
                self.h = self.l;
            },
            op.LD_H_HL => {
                std.debug.print("LD H, (HL)\n", .{});
                self.h = self.read_byte(self.hl());
                cycles = 8;
            },
            op.LD_H_A => {
                std.debug.print("LD H, A\n", .{});
                self.h = self.a;
            },

            // L register destination (0x68-0x6F)
            op.LD_L_B => {
                std.debug.print("LD L, B\n", .{});
                self.l = self.b;
            },
            op.LD_L_C => {
                std.debug.print("LD L, C\n", .{});
                self.l = self.c;
            },
            op.LD_L_D => {
                std.debug.print("LD L, D\n", .{});
                self.l = self.d;
            },
            op.LD_L_E => {
                std.debug.print("LD L, E\n", .{});
                self.l = self.e;
            },
            op.LD_L_H => {
                std.debug.print("LD L, H\n", .{});
                self.l = self.h;
            },
            op.LD_L_L => {
                std.debug.print("LD L, L\n", .{});
                // No operation needed as L = L
            },
            op.LD_L_HL => {
                std.debug.print("LD L, (HL)\n", .{});
                self.l = self.read_byte(self.hl());
                cycles = 8;
            },
            op.LD_L_A => {
                std.debug.print("LD L, A\n", .{});
                self.l = self.a;
            },

            // LD [HL], reg (0x70)
            op.LD_HL_B => {
                std.debug.print("LD (HL), B\n", .{});
                self.write_byte(self.hl(), self.b);
                cycles = 8;
            },

            // 16-bit loads
            op.LD_BC_D16 => {
                std.debug.print("LD BC, d16\n", .{});
                const readBytes = self.read_next_two_bytes();
                self.c = readBytes[0];
                self.b = readBytes[1];
                cycles = 12;
                std.debug.print("BC: {x}\n", .{self.bc()});
            },
            op.LD_DE_D16 => {
                std.debug.print("LD DE, d16\n", .{});
                const readBytes = self.read_next_two_bytes();
                self.e = readBytes[0];
                self.d = readBytes[1];
                cycles = 12;
                std.debug.print("DE: {x}\n", .{self.de()});
            },
            op.LD_HL_D16 => {
                std.debug.print("LD HL, d16\n", .{});
                const readBytes = self.read_next_two_bytes();
                self.l = readBytes[0];
                self.h = readBytes[1];
                cycles = 12;
                std.debug.print("HL: {x}\n", .{self.hl()});
            },
            op.LD_SP_D16 => {
                std.debug.print("LD SP, d16\n", .{});
                const readBytes = self.read_next_two_bytes();
                self.sp = @as(u16, readBytes[0]) | @as(u16, readBytes[1]) << 8;
                cycles = 12;
                std.debug.print("SP: {x}\n", .{self.sp});
            },
            else => std.debug.print("Unknown opcode: {x}\n", .{opcode}),
        }

        self.cycles += cycles;
        return cycles;
    }

    fn emulate(self: *CPU) void {
        while (self.pc < 0x10000) {
            self.cpu_execute();
        }
    }
};

pub fn init(allocator: std.mem.Allocator) error{OutOfMemory}!CPU {
    const memory = try allocator.alloc(u8, 0x10000);
    return .{
        // registers
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

        // memory
        .memory = memory,

        .halted = false,
        .ime = false,

        .cycles = 0,
    };
}

pub fn deinit(allocator: std.mem.Allocator, cpu: *CPU) void {
    allocator.free(cpu.memory);
}

test "NOP" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.memory[0] = 0x00; // NOP instruction
    _ = c.cpu_execute();

    // NOP doesn't change state, so just check that it executed without error
}

test "LD BC, d16" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.memory[0] = 0x01; // LD BC, d16 instruction
    c.memory[1] = 0x13; // Low byte
    c.memory[2] = 0x10; // High byte
    _ = c.cpu_execute();

    try expect(c.bc() == 0x1013);
}

test "LD DE, d16" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.memory[0] = 0x11; // LD DE, d16 instruction
    c.memory[1] = 0x24; // Low byte
    c.memory[2] = 0x21; // High byte
    _ = c.cpu_execute();

    try expect(c.de() == 0x2124);
}

test "LD HL, d16" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.memory[0] = 0x21; // LD HL, d16 instruction
    c.memory[1] = 0x34; // Low byte
    c.memory[2] = 0x23; // High byte
    _ = c.cpu_execute();

    try expect(c.hl() == 0x2334);
}

test "LD SP, d16" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.memory[0] = 0x31; // LD SP, d16 instruction
    c.memory[1] = 0x45; // Low byte
    c.memory[2] = 0x23; // High byte
    _ = c.cpu_execute();

    try expect(c.sp == 0x2345);
}

// B register destination tests
test "LD B, B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x42;
    c.memory[0] = 0x40; // LD B, B instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, C" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.c = 0x42;
    c.memory[0] = 0x41; // LD B, C instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, D" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.d = 0x42;
    c.memory[0] = 0x42; // LD B, D instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, E" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.e = 0x42;
    c.memory[0] = 0x43; // LD B, E instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, H" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.h = 0x42;
    c.memory[0] = 0x44; // LD B, H instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, L" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.l = 0x42;
    c.memory[0] = 0x45; // LD B, L instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, (HL)" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.h = 0x20;
    c.l = 0x10;
    c.memory[0x2010] = 0x42; // Value at (HL) address
    c.memory[0] = 0x46; // LD B, (HL) instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

test "LD B, A" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.b = 0x00;
    c.a = 0x42;
    c.memory[0] = 0x47; // LD B, A instruction
    _ = c.cpu_execute();

    try expect(c.b == 0x42);
}

// C register destination tests
test "LD C, B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.b = 0x42;
    c.memory[0] = 0x48; // LD C, B instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, C" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x42;
    c.memory[0] = 0x49; // LD C, C instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, D" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.d = 0x42;
    c.memory[0] = 0x4A; // LD C, D instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, E" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.e = 0x42;
    c.memory[0] = 0x4B; // LD C, E instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, H" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.h = 0x42;
    c.memory[0] = 0x4C; // LD C, H instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, L" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.l = 0x42;
    c.memory[0] = 0x4D; // LD C, L instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, (HL)" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.h = 0x20;
    c.l = 0x10;
    c.memory[0x2010] = 0x42; // Value at (HL) address
    c.memory[0] = 0x4E; // LD C, (HL) instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

test "LD C, A" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.c = 0x00;
    c.a = 0x42;
    c.memory[0] = 0x4F; // LD C, A instruction
    _ = c.cpu_execute();

    try expect(c.c == 0x42);
}

// D register destination tests
test "LD D, B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.b = 0x42;
    c.memory[0] = 0x50; // LD D, B instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, C" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.c = 0x42;
    c.memory[0] = 0x51; // LD D, C instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, D" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x42;
    c.memory[0] = 0x52; // LD D, D instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, E" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.e = 0x42;
    c.memory[0] = 0x53; // LD D, E instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, H" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.h = 0x42;
    c.memory[0] = 0x54; // LD D, H instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, L" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.l = 0x42;
    c.memory[0] = 0x55; // LD D, L instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, (HL)" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.h = 0x20;
    c.l = 0x10;
    c.memory[0x2010] = 0x42; // Value at (HL) address
    c.memory[0] = 0x56; // LD D, (HL) instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

test "LD D, A" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.d = 0x00;
    c.a = 0x42;
    c.memory[0] = 0x57; // LD D, A instruction
    _ = c.cpu_execute();

    try expect(c.d == 0x42);
}

// E register destination tests
test "LD E, B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.b = 0x42;
    c.memory[0] = 0x58; // LD E, B instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, C" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.c = 0x42;
    c.memory[0] = 0x59; // LD E, C instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, D" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.d = 0x42;
    c.memory[0] = 0x5A; // LD E, D instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, E" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x42;
    c.memory[0] = 0x5B; // LD E, E instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, H" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.h = 0x42;
    c.memory[0] = 0x5C; // LD E, H instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, L" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.l = 0x42;
    c.memory[0] = 0x5D; // LD E, L instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, (HL)" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.h = 0x20;
    c.l = 0x10;
    c.memory[0x2010] = 0x42; // Value at (HL) address
    c.memory[0] = 0x5E; // LD E, (HL) instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

test "LD E, A" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.e = 0x00;
    c.a = 0x42;
    c.memory[0] = 0x5F; // LD E, A instruction
    _ = c.cpu_execute();

    try expect(c.e == 0x42);
}

// H register destination tests
test "LD H, B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x00;
    c.b = 0x42;
    c.memory[0] = 0x60; // LD H, B instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, C" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x00;
    c.c = 0x42;
    c.memory[0] = 0x61; // LD H, C instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, D" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x00;
    c.d = 0x42;
    c.memory[0] = 0x62; // LD H, D instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, E" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x00;
    c.e = 0x42;
    c.memory[0] = 0x63; // LD H, E instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, H" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x42;
    c.memory[0] = 0x64; // LD H, H instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, L" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x00;
    c.l = 0x42;
    c.memory[0] = 0x65; // LD H, L instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, (HL)" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x20;
    c.l = 0x10;
    c.memory[0x2010] = 0x42; // Value at (HL) address
    c.memory[0] = 0x66; // LD H, (HL) instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

test "LD H, A" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x00;
    c.a = 0x42;
    c.memory[0] = 0x67; // LD H, A instruction
    _ = c.cpu_execute();

    try expect(c.h == 0x42);
}

// L register destination tests
test "LD L, B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x00;
    c.b = 0x42;
    c.memory[0] = 0x68; // LD L, B instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, C" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x00;
    c.c = 0x42;
    c.memory[0] = 0x69; // LD L, C instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, D" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x00;
    c.d = 0x42;
    c.memory[0] = 0x6A; // LD L, D instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, E" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x00;
    c.e = 0x42;
    c.memory[0] = 0x6B; // LD L, E instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, H" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x00;
    c.h = 0x42;
    c.memory[0] = 0x6C; // LD L, H instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, L" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x42;
    c.memory[0] = 0x6D; // LD L, L instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, (HL)" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x20;
    c.l = 0x10;
    c.memory[0x2010] = 0x42; // Value at (HL) address
    c.memory[0] = 0x6E; // LD L, (HL) instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

test "LD L, A" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.l = 0x00;
    c.a = 0x42;
    c.memory[0] = 0x6F; // LD L, A instruction
    _ = c.cpu_execute();

    try expect(c.l == 0x42);
}

// LD (HL), reg tests
test "LD (HL), B" {
    const allocator = std.testing.allocator;
    var c = try init(allocator);
    defer deinit(allocator, &c);

    c.h = 0x20;
    c.l = 0x10;
    c.b = 0x42;
    c.memory[0x2010] = 0x00; // Initial value at (HL) address
    c.memory[0] = 0x70; // LD (HL), B instruction
    _ = c.cpu_execute();

    try expect(c.memory[0x2010] == 0x42);
}
