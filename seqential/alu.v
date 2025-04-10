
module or_op(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            or or_inst (
                result[i],
                a[i],
                b[i]
            );
        end
    endgenerate
endmodule

module and_op(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            and and_inst (
                result[i],
                a[i],
                b[i]
            );
        end
    endgenerate
endmodule

module FA(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule


module add(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result,
    output overflow
);
    wire [63:0] sum;
    wire [63:0] carry;
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : adder_loop
            if (i == 0) begin
                FA fa_inst (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(1'b0),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end else begin
                FA fa_inst (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate
    assign result = sum;
    assign overflow = carry[63];
endmodule

module sub(
    input  [63:0] a,
    input  [63:0] b,
    output [63:0] result,
    output final_carry,
    output carry_in_msb
);
    wire [63:0] sum;
    wire [63:0] carry;
    genvar i;
    
    generate
        for (i = 0; i < 64; i = i + 1) begin : adder_loop
            if (i == 0) begin
                FA fa_inst (
                    .a(a[i]),
                    .b(~b[i]),
                    .cin(1'b1),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end else begin
                FA fa_inst (
                    .a(a[i]),
                    .b(~b[i]),
                    .cin(carry[i-1]),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate
    assign result = sum;
    assign final_carry = carry[63];
    assign carry_in_msb = carry[62];
endmodule

module alu (
    input  [63:0] a,
    input  [63:0] b,
    input  [1:0] ALUControl,
    output [63:0] result,
    output        zero_flag
);
    wire [63:0] add_result, sub_result, or_result, and_result;
    wire add_overflow, sub_final_carry, sub_carry_in_msb;

    add add_inst (
        .a(a),
        .b(b),
        .result(add_result),
        .overflow(add_overflow)
    );

    sub sub_inst (
        .a(a),
        .b(b),
        .result(sub_result),
        .final_carry(sub_final_carry),
        .carry_in_msb(sub_carry_in_msb)
    );

    and_op and_inst (
        .a(a),
        .b(b),
        .result(and_result)
    );

    or_op or_inst (
        .a(a),
        .b(b),
        .result(or_result)
    );

    wire [63:0] mux1_out, mux2_out;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_gen
            wire [1:0] sel;
            assign sel = ALUControl;
            mux2x1 mux1 (.a(add_result[i]), .b(sub_result[i]), .sel(sel[0]), .y(mux1_out[i]));
            mux2x1 mux2 (.a(or_result[i]), .b(and_result[i]), .sel(sel[0]), .y(mux2_out[i]));
            mux2x1 mux3 (.a(mux1_out[i]), .b(mux2_out[i]), .sel(sel[1]), .y(result[i]));
        end
    endgenerate

    wire eq_flag;
    assign eq_flag = (sub_result == 64'b0);

    wire beq_zero_flag;
    and (beq_zero_flag, (ALUControl == 2'b01), eq_flag);

    assign zero_flag = beq_zero_flag;
endmodule


// module alu_tb;
//     reg [63:0] a, b;
//     reg [1:0] ALUControl;
//     wire [63:0] result;
//     wire zero_flag;

//     alu uut (
//         .a(a),
//         .b(b),
//         .ALUControl(ALUControl),
//         .result(result),
//         .zero_flag(zero_flag)
//     );

//     initial begin
//         $dumpfile("alu_tb.vcd");
//         $dumpvars(0, alu_tb);
        
//         // ADD Test
//         ALUControl = 2'b00;
//         a = 64'd10; b = 64'd20;
//         #10; $display("ADD: a=%d, b=%d, Result=%d, Zero Flag=%b", a, b, result, zero_flag);
        
//         // SUB Test
//         ALUControl = 2'b01;
//         a = 64'd20; b = 64'd10;
//         #10; $display("SUB: a=%d, b=%d, Result=%d, Zero Flag=%b", a, b, result, zero_flag);
        
//         // OR Test
//         ALUControl = 2'b10;
//         a = 64'd10; b = 64'd20;
//         #10; $display("OR: a=%d, b=%d, Result=%d, Zero Flag=%b", a, b, result, zero_flag);
        
//         // AND Test
//         ALUControl = 2'b11;
//         a = 64'd10; b = 64'd20;
//         #10; $display("AND: a=%d, b=%d, Result=%d, Zero Flag=%b", a, b, result, zero_flag);
        
//         // BEQ Test (Equal)
//         ALUControl = 2'b01;
//         a = 64'd10; b = 64'd10;
//         #10; $display("BEQ (Equal): a=%d, b=%d, Result=%d, Zero Flag=%b", a, b, result, zero_flag);
        
//         // BEQ Test (Not Equal)
//         ALUControl = 2'b01;
//         a = 64'd10; b = 64'd20;
//         #10; $display("BEQ (Not Equal): a=%d, b=%d, Result=%d, Zero Flag=%b", a, b, result, zero_flag);
        
//         $finish;
//     end
// endmodule