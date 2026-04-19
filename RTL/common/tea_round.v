`ifndef TEA_ROUND
`define TEA_ROUND

module tea_round(
    input [63:0] v_in,
    input [127:0] k,
    input [31:0] sum,
    input mode, // 0 for encrypt, 1 for decrypt
    output [63:0] v_out
);

wire [31:0] v0 = v_in[63:32];
wire [31:0] v1 = v_in[31:0];
wire [31:0] k0 = k[127:96];
wire [31:0] k1 = k[95:64];
wire [31:0] k2 = k[63:32];
wire [31:0] k3 = k[31:0];

wire [31:0] v0_enc = v0 + (((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1));
wire [31:0] v1_enc = v1 + (((v0_enc << 4) + k2) ^ (v0_enc + sum) ^ ((v0_enc >> 5) + k3));

wire [31:0] v1_dec = v1 - (((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3));
wire [31:0] v0_dec = v0 - (((v1_dec << 4) + k0) ^ (v1_dec + sum) ^ ((v1_dec >> 5) + k1));

assign v_out = mode ? {v0_dec, v1_dec} : {v0_enc, v1_enc};

endmodule

`endif