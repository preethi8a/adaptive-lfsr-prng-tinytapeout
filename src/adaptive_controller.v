/*
 * Adaptive Controller
 *
 * Function:
 *   - Starts with polynomial P0
 *   - On an adaptive event, switches:
 *
 *       P0 -> P1 -> P2 -> P0
 *
 *   - Generates a deterministic new seed from the
 *     current LFSR state.
 *
 *   - The new seed is:
 *
 *       new_seed = lfsr_state XOR 16'hA5C3
 *
 *   - Protects against an all-zero seed.
 */

`default_nettype none

module adaptive_controller (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        adaptive_event,
    input  wire [15:0] lfsr_state,

    output reg  [1:0]  poly_sel,
    output wire        load_seed,
    output wire [15:0] new_seed
);

    // ---------------------------------------------------------
    // Deterministic reseeding constant
    // ---------------------------------------------------------

    localparam [15:0] RESEED_CONSTANT = 16'hA5C3;


    // ---------------------------------------------------------
    // Polynomial selection
    //
    // Initial:
    //     P0
    //
    // Adaptive event:
    //     P0 -> P1
    //     P1 -> P2
    //     P2 -> P0
    // ---------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            poly_sel <= 2'b00;

        end

        else if (adaptive_event) begin

            case (poly_sel)

                2'b00:
                    poly_sel <= 2'b01;

                2'b01:
                    poly_sel <= 2'b10;

                2'b10:
                    poly_sel <= 2'b00;

                default:
                    poly_sel <= 2'b00;

            endcase

        end

    end


    // ---------------------------------------------------------
    // Deterministic self-reseed
    //
    // Reseeding occurs exactly when an adaptive event occurs.
    // ---------------------------------------------------------

    assign load_seed = adaptive_event;


    assign new_seed =
        ((lfsr_state ^ RESEED_CONSTANT) == 16'h0000) ?
        16'h0001 :
        (lfsr_state ^ RESEED_CONSTANT);


endmodule

`default_nettype wire
