`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 23:14:45
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module alu_8bit (
    input  wire [7:0]  A,
    input  wire [7:0]  B,
    input  wire [3:0]  ALU_Sel,
    output reg  [15:0] Y,     // unified output (full MUL)
    output wire        Z,     // Zero
    output wire        N,     // Negative
    output wire        C,     // Carry / Borrow
    output wire        V      // Overflow
);

    // Parallel Datapath (Dataflow)

    wire [8:0]  sum_ext  = {1'b0, A} + {1'b0, B};
    wire [8:0]  diff_ext = {1'b0, A} - {1'b0, B};

    wire [7:0]  add_res  = sum_ext[7:0];
    wire [7:0]  sub_res  = diff_ext[7:0];
    wire [7:0]  and_res  = A & B;
    wire [7:0]  or_res   = A | B;
    wire [7:0]  xor_res  = A ^ B;
    wire [7:0]  shl_res  = A << 1;
    wire [7:0]  shr_res  = A >> 1;

    wire [15:0] mul_res  = A * B; // full precision

    wire [7:0] slt_signed =
        ($signed(A) < $signed(B)) ? 8'd1 : 8'd0;

    wire [7:0] eq_res =
        (A == B) ? 8'd1 : 8'd0;

    // Output Selection (MUX)

    always @(*) begin
        case (ALU_Sel)
            4'b0000: Y = {8'd0, add_res};   // ADD
            4'b0001: Y = {8'd0, sub_res};   // SUB
            4'b0010: Y = {8'd0, and_res};   // AND
            4'b0011: Y = {8'd0, or_res};    // OR
            4'b0100: Y = {8'd0, xor_res};   // XOR
            4'b0101: Y = {8'd0, shl_res};   // SHL
            4'b0110: Y = {8'd0, shr_res};   // SHR
            4'b0111: Y = mul_res;           // MUL (16-bit)
            4'b1000: Y = {8'd0, slt_signed}; // SLT signed
            4'b1001: Y = {8'd0, eq_res};     // EQUAL
            default: Y = 16'd0;
        endcase
    end


    // Status Flags
    assign Z = (Y == 16'd0);
    assign N = Y[15];

    assign C = (ALU_Sel == 4'b0000) ? sum_ext[8] :
               (ALU_Sel == 4'b0001) ? diff_ext[8] :
               1'b0;

    // Signed overflow
    assign V = (ALU_Sel == 4'b0000) ?
               (~(A[7] ^ B[7]) & (A[7] ^ Y[7])) :
               (ALU_Sel == 4'b0001) ?
               ((A[7] ^ B[7]) & (A[7] ^ Y[7])) :
               1'b0;

endmodule

