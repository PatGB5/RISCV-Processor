// `timescale 1ns/1ps

module tb_cpu_pipeline;

  reg         clk;
  reg         reset;
  wire [63:0] writeBackData;

  cpu_pipeline uut (
    .clk(clk),
    .reset(reset),
    .writeBackData(writeBackData)
  );

  initial begin
      clk = 0;
      forever #5 clk = ~clk;
  end

  initial begin
      $dumpfile("output.vcd");
      $dumpvars(0, tb_cpu_pipeline);
      
      $monitor("Time=%0t | reset=%b | writeBackData=%d", 
                $time, reset, writeBackData);
  end

  initial begin
      reset = 1;
      #20;
      reset = 0;
      
      #100;
      
      #200;
      
      $display("Simulation finished. Final writeBackData = %d at time %0t", writeBackData, $time);
      $finish;
  end

endmodule