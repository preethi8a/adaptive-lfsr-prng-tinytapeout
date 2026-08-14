/*
 * Self-Seeding Adaptive 16-bit Galois LFSR PRNG
 * Tiny Tapeout SKY130
 */

`default_nettype none

module tt_um_adaptive_lfsr_prng (
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
    // Tiny Tapeout input mapping
    //
    // ui_in[7]   = user enable
    // ui_in[6:0] = external seed
    // ------------------------------------------------

    wire       user_enable;
    wire [7:0] seed_in;

    assign user_enable = ui_in[7];

    // Convert 7-bit external seed to 8-bit seed.
    assign seed_in = {1'b0, ui_in[6:0]};


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

        .enable         (user_enable & ena),
        .seed_in        (seed_in),

        .random_out     (random_out),
        .poly_status    (poly_status),
        .adaptive_event (adaptive_event)
    );


    // ------------------------------------------------
    // Tiny Tapeout outputs
    // ------------------------------------------------

    assign uo_out = random_out;


    // Bidirectional pins are unused.
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;


    // Prevent unused-input warnings.
    wire _unused;
    assign _unused = &{
        uio_in,
        1'b0
    };

endmodule

`default_nettype wire
