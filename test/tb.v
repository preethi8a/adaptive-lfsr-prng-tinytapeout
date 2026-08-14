`default_nettype none
`timescale 1ns / 1ps

/*
 * Testbench for:
 * Self-Seeding Adaptive 16-bit Galois LFSR PRNG
 *
 * Top module:
 * tt_um_preethi8a_adaptive_lfsr_prng
 */

module tb ();

  // ---------------------------------------------------------
  // Waveform dump
  // ---------------------------------------------------------
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end


  // ---------------------------------------------------------
  // DUT input/output signals
  // ---------------------------------------------------------
  reg        clk;
  reg        rst_n;
  reg        ena;

  reg  [7:0] ui_in;

  reg  [7:0] uio_in;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;


  // ---------------------------------------------------------
  // DUT
  // ---------------------------------------------------------
  tt_um_preethi8a_adaptive_lfsr_prng user_project (

      .ui_in   (ui_in),
      .uo_out  (uo_out),

      .uio_in  (uio_in),
      .uio_out (uio_out),
      .uio_oe  (uio_oe),

      .ena     (ena),
      .clk     (clk),
      .rst_n   (rst_n)
  );


endmodule

`default_nettype wire
