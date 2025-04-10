// `timescale 1ns/1ps

module cpu_tb;
    reg clk;
    reg reset;
    wire [63:0] pc;
    wire [63:0] alu_result;
    wire alu_zero;

    cpu uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    initial begin
        #6;
        clk = 1;
        forever #5 clk = ~clk;
    end

  initial begin
    $dumpfile("cpu_dump.vcd");
    $dumpvars(0, cpu_tb);
    reset = 1;
    #10;
    reset = 0;
    #120;
    $display("x0=%d", uut.reg_file.regs[0]);
    $finish;
  end

    initial begin
        $monitor("Time: %t | PC: %h | ALU Result: %d | ALU Zero: %b", 
                 $time, pc, alu_result, alu_zero);
    end

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end

endmodule