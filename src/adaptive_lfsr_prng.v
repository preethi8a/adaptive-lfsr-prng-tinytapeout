/*
 * Self-Seeding Adaptive 16-bit Galois LFSR PRNG
 *
 * Core:
 *   16-bit Galois LFSR
 *
 * Features:
 *   - Three internally selected polynomial masks
 *   - 8-bit output repetition monitoring
 *   - Automatic polynomial switching
 *   - Deterministic self-reseeding
 *   - 3-cycle cooldown
 */

`default_nettype none

module adaptive_lfsr_prng (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire [7:0]  seed_in,

    output wire [7:0]  random_out,
    output wire [1:0]  poly_status,
    output wire        adaptive_event
);

    // =========================================================
    // Internal signals
    // =========================================================

    wire [15:0] seed_generated;
    wire [15:0] lfsr_state;

    wire [1:0]  poly_sel;

    wire [7:0]  lfsr_output;

    wire        repetition_event;

    wire        controller_load_seed;
    wire [15:0] controller_new_seed;

    wire        initial_load_seed;

    wire        monitor_enable;

    reg  [1:0]  cooldown;
    reg         init_done;


    // =========================================================
    // SEED GENERATOR
    // =========================================================

    seed_generator seed_gen_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .seed_in  (seed_in),
        .seed_out (seed_generated)
    );


    // =========================================================
    // INITIAL SEED LOADING
    //
    // Load the generated seed once when the PRNG is enabled.
    // =========================================================

    assign initial_load_seed =
        enable && !init_done;


    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            init_done <= 1'b0;
        end

        else if (enable) begin
            init_done <= 1'b1;
        end

    end


    // =========================================================
    // COOLDOWN COUNTER
    //
    // After an adaptive event:
    //
    //   3 -> 2 -> 1 -> 0
    //
    // During non-zero cooldown, repetition monitoring is disabled.
    // =========================================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            cooldown <= 2'b00;

        end

        else if (repetition_event &&
                 (cooldown == 2'b00)) begin

            cooldown <= 2'b11;

        end

        else if (cooldown != 2'b00) begin

            cooldown <= cooldown - 1'b1;

        end

    end


    // =========================================================
    // REPETITION MONITOR ENABLE
    // =========================================================

    assign monitor_enable =
        enable &&
        init_done &&
        (cooldown == 2'b00);


    // =========================================================
    // 16-BIT GALOIS LFSR
    // =========================================================

    lfsr16 lfsr_inst (

        .clk       (clk),
        .rst_n     (rst_n),
        .enable    (enable),

        .load_seed (
            initial_load_seed |
            controller_load_seed
        ),

        .new_seed (
            initial_load_seed ?
            seed_generated :
            controller_new_seed
        ),

        .poly_sel  (poly_sel),

        .state     (lfsr_state)

    );


    // =========================================================
    // RANDOM OUTPUT
    //
    // Lower 8 bits of the 16-bit LFSR state are used as
    // the externally visible random output.
    // =========================================================

    assign lfsr_output = lfsr_state[7:0];

    assign random_out = lfsr_output;


    // =========================================================
    // 8-BIT REPETITION MONITOR
    // =========================================================

    repetition_monitor repetition_inst (

        .clk            (clk),
        .rst_n          (rst_n),
        .enable         (monitor_enable),

        .data_in        (lfsr_output),

        .adaptive_event (repetition_event),

        .prev_output    ()

    );


    // =========================================================
    // ADAPTIVE CONTROLLER
    //
    // Performs:
    //
    //   P0 -> P1 -> P2 -> P0
    //
    // and generates the deterministic self-seed.
    // =========================================================

    adaptive_controller adaptive_inst (

        .clk            (clk),
        .rst_n          (rst_n),

        .adaptive_event (repetition_event),
        .lfsr_state     (lfsr_state),

        .poly_sel       (poly_sel),
        .load_seed      (controller_load_seed),
        .new_seed       (controller_new_seed)

    );


    // =========================================================
    // STATUS OUTPUTS
    // =========================================================

    assign poly_status    = poly_sel;

    assign adaptive_event = repetition_event;


endmodule

`default_nettype wire
