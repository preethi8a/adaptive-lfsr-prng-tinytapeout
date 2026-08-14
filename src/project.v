/*
 * Self-Seeding Adaptive 16-bit Galois LFSR PRNG
 * Tiny Tapeout SKY130
 */

`default_nettype none

module tt_um_preethi8a_adaptive_lfsr_prng (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // ------------------------------------------------
    // Input mapping
    //
    
    // ui_in[7]   = PRNG enable
    // ui_in[6:0] = 7-bit external seed
    // ena        = design enable
    // clk        = clock
    // rst_n      = active-low reset
    // ------------------------------------------------

    wire [7:0] seed_in;

    assign seed_in = ui_in;

    // ------------------------------------------------
    // Internal signals
    // ------------------------------------------------

    wire [7:0] random_out;
    wire [1:0] poly_status;
    wire       adaptive_event;

    // ------------------------------------------------
    // Main Adaptive LFSR PRNG
    // ------------------------------------------------

    adaptive_lfsr_prng prng_inst (
        .clk            (clk),
        .rst_n          (rst_n),

        .enable         (ena),
        .seed_in        (seed_in),

        .random_out     (random_out),
        .poly_status    (poly_status),
        .adaptive_event (adaptive_event)
    );

    // ------------------------------------------------
    // Tiny Tapeout output mapping
    //
    // uo_out[7:0] = 8-bit random output
    // ------------------------------------------------

    assign uo_out = random_out;

    // ------------------------------------------------
    // Bidirectional pins unused
    // ------------------------------------------------

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Prevent unused-input warnings
    wire _unused;
    assign _unused = &{uio_in, poly_status, adaptive_event, 1'b0};

endmodule

`default_nettype wire
