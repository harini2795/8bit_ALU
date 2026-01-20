`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 23:18:52
// Design Name: 
// Module Name: tb_alu
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

module tb_alu_8bit;

    // Inputs
    reg  [7:0] A;
    reg  [7:0] B;
    reg  [3:0] ALU_Sel;

    // Outputs
    wire [15:0] Y;
    wire        Z;
    wire        N;
    wire        C;
    wire        V;

    // Instantiate the ALU
    alu_8bit DUT (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Y(Y),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

    // Task to calculate expected results
    task automatic check_alu;
        input [7:0] a, b;
        input [3:0] sel;
        output logic [15:0] exp_Y;
        output logic exp_Z, exp_N, exp_C, exp_V;

        reg signed [7:0] sa, sb;
        reg signed [8:0] sum_ext, diff_ext;
        reg [15:0] mul_res;
        reg [7:0] add_res, sub_res, and_res, or_res, xor_res, shl_res, shr_res, slt_signed, eq_res;

        begin
            sa = a; sb = b;

            sum_ext = {1'b0,a} + {1'b0,b};
            diff_ext = {1'b0,a} - {1'b0,b};

            add_res = sum_ext[7:0];
            sub_res = diff_ext[7:0];
            and_res = a & b;
            or_res  = a | b;
            xor_res = a ^ b;
            shl_res = a << 1;
            shr_res = a >> 1;
            mul_res = a * b;
            slt_signed = (sa < sb) ? 8'd1 : 8'd0;
            eq_res = (a == b) ? 8'd1 : 8'd0;

            case(sel)
                4'b0000: exp_Y = {8'd0, add_res};
                4'b0001: exp_Y = {8'd0, sub_res};
                4'b0010: exp_Y = {8'd0, and_res};
                4'b0011: exp_Y = {8'd0, or_res};
                4'b0100: exp_Y = {8'd0, xor_res};
                4'b0101: exp_Y = {8'd0, shl_res};
                4'b0110: exp_Y = {8'd0, shr_res};
                4'b0111: exp_Y = mul_res;
                4'b1000: exp_Y = {8'd0, slt_signed};
                4'b1001: exp_Y = {8'd0, eq_res};
                default: exp_Y = 16'd0;
            endcase

            exp_Z = (exp_Y == 16'd0);
            exp_N = exp_Y[15];

            exp_C = (sel == 4'b0000) ? sum_ext[8] :
                    (sel == 4'b0001) ? diff_ext[8] : 1'b0;

            exp_V = (sel == 4'b0000) ? (~(a[7] ^ b[7]) & (a[7] ^ add_res[7])) :
                    (sel == 4'b0001) ? ((a[7] ^ b[7]) & (a[7] ^ sub_res[7])) :
                    1'b0;
        end
    endtask

    // Self-checking procedure
    initial begin
        reg [15:0] exp_Y;
        reg exp_Z, exp_N, exp_C, exp_V;
        integer i, j;

        // Test all ALU operations with multiple values
        for (i = 0; i < 256; i = i + 51) begin
            for (j = 0; j < 256; j = j + 77) begin
                A = i; B = j;
                // Test each ALU operation
                for (int sel = 0; sel <= 9; sel = sel + 1) begin
                    ALU_Sel = sel;
                    #1; // small delay for combinational ALU

                    // Calculate expected results
                    check_alu(A, B, ALU_Sel, exp_Y, exp_Z, exp_N, exp_C, exp_V);

                    // Assertions
                    assert(Y === exp_Y) else $fatal("ALU Y mismatch: A=%0d B=%0d Sel=%b, Got=%0h, Expected=%0h", A, B, ALU_Sel, Y, exp_Y);
                    assert(Z === exp_Z) else $fatal("Zero flag mismatch: A=%0d B=%0d Sel=%b, Got=%b, Expected=%b", A, B, ALU_Sel, Z, exp_Z);
                    assert(N === exp_N) else $fatal("Negative flag mismatch: A=%0d B=%0d Sel=%b, Got=%b, Expected=%b", A, B, ALU_Sel, N, exp_N);
                    assert(C === exp_C) else $fatal("Carry flag mismatch: A=%0d B=%0d Sel=%b, Got=%b, Expected=%b", A, B, ALU_Sel, C, exp_C);
                    assert(V === exp_V) else $fatal("Overflow flag mismatch: A=%0d B=%0d Sel=%b, Got=%b, Expected=%b", A, B, ALU_Sel, V, exp_V);

                    $display("PASS: A=%0d B=%0d Sel=%b => Y=%0h Z=%b N=%b C=%b V=%b", A, B, ALU_Sel, Y, Z, N, C, V);
                end
            end
        end
        $display("All ALU tests passed!");
        $finish;
    end

endmodule

