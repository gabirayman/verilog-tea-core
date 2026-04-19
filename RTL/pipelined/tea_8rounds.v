
`ifndef TEA_8ROUNDS
`define TEA_8ROUNDS

`include "RTL/common/tea_round.v"

module tea_8rounds(
    input [63:0] v_in,
    input [127:0] k,
    input [31:0] sum_in,
    input mode, // 0 for encrypt, 1 for decrypt
    output [63:0] v_out,
    output [31:0] sum_out
);

localparam [31:0] DELTA = 32'h9E3779B9;
wire [63:0] round_data [0:8];
assign round_data[0] = v_in;

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : round_gen
        wire [31:0] this_round_sum;

        // We calculate the sum offset based on the sum_in
        assign this_round_sum = mode ? (sum_in - (DELTA * i)) : (sum_in + (DELTA * i));

        tea_round round_inst (
            .v_in(round_data[i]),
            .k(k),
            .sum(this_round_sum),
            .mode(mode),
            .v_out(round_data[i+1])
        );
    end
endgenerate

assign v_out = round_data[8];

// Prepare the sum for the next 8-round stage in the pipeline
assign sum_out = mode ? (sum_in - (DELTA * 8)) : (sum_in + (DELTA * 8));
    

endmodule

`endif