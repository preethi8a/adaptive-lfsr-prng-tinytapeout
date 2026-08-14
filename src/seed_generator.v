/*
 * Deterministic Self-Seed Generator
 *
 * Generates a non-zero 16-bit seed from the external
 * 8-bit seed input.
 *
 * The seed is updated every clock cycle using a simple
 * deterministic transformation.
 */

`default_nettype none

module seed_generator (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  seed_in,

    output reg  [15:0] seed_out
);

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            // Fixed non-zero initial value
            seed_out <= 16'h5AA5;

        end

        else begin

            /*
             * Deterministic seed generation.
             *
             * Combines:
             *   - previous seed
             *   - external 8-bit seed
             *   - bit rotation
             *
             * This provides a simple non-zero self-seeding mechanism.
             */

            seed_out <=
                {seed_out[7:0], seed_out[15:8]}
                ^
                {8'hA5, seed_in};

            // Zero-state protection
            if (({seed_out[7:0], seed_out[15:8]}
                 ^ {8'hA5, seed_in}) == 16'h0000)

                seed_out <= 16'h1ACE;

        end

    end

endmodule

`default_nettype wire
