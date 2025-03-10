pub const opcode = enum(u8) {
    NOP = 0x00,

    // LD r16, imm16
    LD_BC_D16 = 0x01,
    LD_DE_D16 = 0x11,
    LD_HL_D16 = 0x21,
    LD_SP_D16 = 0x31,

    // LD r8, r8 (0x40-0x7F range)
    // B register destination (0x40-0x47)
    LD_B_B = 0x40,
    LD_B_C = 0x41,
    LD_B_D = 0x42,
    LD_B_E = 0x43,
    LD_B_H = 0x44,
    LD_B_L = 0x45,
    LD_B_HL = 0x46,
    LD_B_A = 0x47,
    
    // C register destination (0x48-0x4F)
    LD_C_B = 0x48,
    LD_C_C = 0x49,
    LD_C_D = 0x4A,
    LD_C_E = 0x4B,
    LD_C_H = 0x4C,
    LD_C_L = 0x4D,
    LD_C_HL = 0x4E,
    LD_C_A = 0x4F,
    
    // D register destination (0x50-0x57)
    LD_D_B = 0x50,
    LD_D_C = 0x51,
    LD_D_D = 0x52,
    LD_D_E = 0x53,
    LD_D_H = 0x54,
    LD_D_L = 0x55,
    LD_D_HL = 0x56,
    LD_D_A = 0x57,
    
    // E register destination (0x58-0x5F)
    LD_E_B = 0x58,
    LD_E_C = 0x59,
    LD_E_D = 0x5A,
    LD_E_E = 0x5B,
    LD_E_H = 0x5C,
    LD_E_L = 0x5D,
    LD_E_HL = 0x5E,
    LD_E_A = 0x5F,
    
    // H register destination (0x60-0x67)
    LD_H_B = 0x60,
    LD_H_C = 0x61,
    LD_H_D = 0x62,
    LD_H_E = 0x63,
    LD_H_H = 0x64,
    LD_H_L = 0x65,
    LD_H_HL = 0x66,
    LD_H_A = 0x67,
    
    // L register destination (0x68-0x6F)
    LD_L_B = 0x68,
    LD_L_C = 0x69,
    LD_L_D = 0x6A,
    LD_L_E = 0x6B,
    LD_L_H = 0x6C,
    LD_L_L = 0x6D,
    LD_L_HL = 0x6E,
    LD_L_A = 0x6F,
    
    // LD [HL], r instructions (0x70-0x77)
    LD_HL_B = 0x70,

    // LD [r16], r8
    LD_M_BC_A = 0x02,
    INC_BC = 0x03,
    _,
};
