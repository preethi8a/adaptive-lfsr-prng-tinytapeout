/*
 * 16-bit Galois LFSR
 *
 * Polynomial selection:
 * P0 = x^16 + x^14 + x^13 + x^11 + 1
 * P1 = x^16 + x^15 + x^13 + x^4  + 1
 * P2 = x^16 + x^14 + x^12 + x^3  + 1
 *
 * Galois configuration:
 * Right shift
 * Feedback from state[0]
 */

`default_nettype none

module lfsr16 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,

    input  wire        load_seed,
    input  wire [15:0] new_seed,

    input  wire [1:0]  poly_sel,

    output reg  [15:0] state
);

    // ---------------------------------------------------------
    // Galois polynomial masks
    // ---------------------------------------------------------

    localparam [15:0] POLY_P0 = 16'hB400;
    localparam [15:0] POLY_P1 = 16'hD008;
    localparam [15:0] POLY_P2 = 16'hA801;


    // ---------------------------------------------------------
    // Selected polynomial
    // ---------------------------------------------------------

    reg [15:0] poly_mask;

    always @(*) begin

        case (poly_sel)

            2'b00:
                poly_mask = POLY_P0;

            2'b01:
                poly_mask = POLY_P1;

            2'b10:
                poly_mask = POLY_P2;

            default:
                poly_mask = POLY_P0;

        endcase

    end


    // ---------------------------------------------------------
    // Next-state calculation
    // ---------------------------------------------------------

    reg [15:0] next_state;

    always @(*) begin

        // Galois right shift
        next_state = state >> 1;

        // Apply feedback polynomial when LSB is 1
        if (state[0])
            next_state = next_state ^ poly_mask;

        // Prevent the LFSR from entering the all-zero state
        if (next_state == 16'h0000)
            next_state = 16'h0001;

    end


    // ---------------------------------------------------------
    // State register
    // ---------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state <= 16'h0001;

        end

        else if (load_seed) begin

            // Protect against an externally generated zero seed
            if (new_seed == 16'h0000)
                state <= 16'h0001;
            else
                state <= new_seed;

        end

        else if (enable) begin

            state <= next_state;

        end

    end

endmodule

`default_nettype wire
