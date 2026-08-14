/*
 * 8-bit Output Repetition Monitor
 *
 * Detects consecutive repetition of the 8-bit LFSR output.
 *
 * If:
 *
 *     current_output == previous_output
 *
 * an adaptive event is generated for one clock cycle.
 */

`default_nettype none

module repetition_monitor (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    input  wire [7:0] data_in,

    output reg        adaptive_event,
    output reg  [7:0] prev_output
);

    reg sample_valid;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            prev_output    <= 8'h00;
            adaptive_event <= 1'b0;
            sample_valid   <= 1'b0;

        end

        else if (!enable) begin

            /*
             * Disable monitoring.
             * The previous sample is retained, but no event
             * is generated while monitoring is disabled.
             */
            adaptive_event <= 1'b0;
            sample_valid   <= 1'b0;

        end

        else begin

            /*
             * Default: event is only one clock cycle wide.
             */
            adaptive_event <= 1'b0;

            /*
             * Compare the current output with the previous
             * valid output sample.
             */
            if (sample_valid && (data_in == prev_output))
                adaptive_event <= 1'b1;

            /*
             * Store current output for the next comparison.
             */
            prev_output  <= data_in;
            sample_valid <= 1'b1;

        end

    end

endmodule

`default_nettype wire
