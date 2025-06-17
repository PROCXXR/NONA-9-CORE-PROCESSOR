`timescale 1ns / 1ps

module tb_ninecoreprocessor;

  // Clock and reset
  logic clk;
  logic reset;

  // Inputs and outputs
  logic [7:0] in_data;
  logic [7:0] out_data;

  // Instantiate the processor
  ninecoreprocessor uut (
    .clk(clk),
    .reset(reset),
    .in_data(in_data),
    .out_data(out_data)
  );

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $display("Starting testbench for ninecoreprocessor...");
    $dumpfile("ninecoreprocessor_tb.vcd");
    $dumpvars(0, tb_ninecoreprocessor);

    // Initialize
    reset = 1;
    in_data = 0;
    #20;

    // Release reset
    reset = 0;
    #10;

    // Provide input stimulus
    in_data = 8'hAA; #10;
    in_data = 8'h55; #10;
    in_data = 8'hFF; #10;
    in_data = 8'h00; #10;

    // Wait and finish
    #100;
    $display("Finished simulation.");
    $finish;
  end

endmodule
