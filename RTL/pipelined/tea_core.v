`include "RTL/pipelined/tea_8rounds.v"
`include "RTL/common/tea_round.v"

module tea_core (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire mode, // 0 for encrypt, 1 for decrypt
    input wire [63:0] plaintext,
    input wire [127:0] key,
    output reg [63:0] ciphertext,
    output reg valid,
    output wire ready
);

// Constants and state definitions
localparam DELTA = 32'h9E3779B9;
localparam DELTA_TIMES_32 = 32'hC6EF3720; // DELTA * 32

//Internal Registers and wires

// 1. INPUT REGISTERS (Stage 0)
// This captures the "outside world" data when start is high
reg [63:0]  v_reg0;
reg [31:0]  sum_reg0;
reg [127:0] key_reg0;
reg         mode_reg0;
reg         valid_reg0;

// 2. INTERMEDIATE WIRES (The logic outputs)
wire [63:0] v_out0, v_out1, v_out2, v_out3;
wire [31:0] sum_out0, sum_out1, sum_out2, sum_out3;

// 3. PIPELINE REGISTERS (Stages 1, 2, 3)
// These capture the 'v_out' wires on every clock edge.
reg [63:0]  v_reg1, v_reg2, v_reg3;
reg [31:0]  sum_reg1, sum_reg2, sum_reg3;
reg [127:0] key_reg1, key_reg2, key_reg3;
reg         mode_reg1, mode_reg2, mode_reg3;
reg         valid_reg1, valid_reg2, valid_reg3;

// set ready to equal rst_n so we always are ready as long as not in reset
assign ready = rst_n;



// tea_8rounds, 4 instances for 32 rounds total
tea_8rounds inst_0 (
    .v_in(v_reg0),
    .k(key_reg0),
    .sum_in(sum_reg0),
    .mode(mode_reg0),
    .v_out(v_out0),
    .sum_out(sum_out0)
);
tea_8rounds inst_1 (
    .v_in(v_reg1),
    .k(key_reg1),
    .sum_in(sum_reg1),
    .mode(mode_reg1),
    .v_out(v_out1),
    .sum_out(sum_out1)
);
tea_8rounds inst_2 (
    .v_in(v_reg2),
    .k(key_reg2),
    .sum_in(sum_reg2),
    .mode(mode_reg2),
    .v_out(v_out2),
    .sum_out(sum_out2)
);
tea_8rounds inst_3 (
    .v_in(v_reg3),
    .k(key_reg3),
    .sum_in(sum_reg3),
    .mode(mode_reg3),
    .v_out(v_out3),
    .sum_out(sum_out3)
);


// block for pos edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_reg0 <= 1'b0;
        valid_reg1 <= 1'b0;
        valid_reg2 <= 1'b0;
        valid_reg3 <= 1'b0;
        valid      <= 1'b0;
        ciphertext <= 64'b0;
        
    end else begin
        // Input logic
        // check if start is high
        if (start) begin
            // Load initial values into the first stage
            v_reg0 <= plaintext;
            key_reg0 <= key;
            sum_reg0 <= mode ? DELTA_TIMES_32 : DELTA; // Start sum for decryption is DELTA * 32, for encryption is DELTA
            mode_reg0 <= mode;
            valid_reg0 <= 1'b1; // Mark the first stage as valid
        end else begin
            valid_reg0 <= 1'b0; // No new input, so not valid
        end

        // Pipeline logic
        // round 0 results -> stage 1 registers 
        v_reg1 <= v_out0;
        sum_reg1 <= sum_out0;
        key_reg1 <= key_reg0;
        mode_reg1 <= mode_reg0;
        valid_reg1 <= valid_reg0; 

        // round 1 results -> stage 2 registers
        v_reg2 <= v_out1;
        sum_reg2 <= sum_out1;
        key_reg2 <= key_reg1;
        mode_reg2 <= mode_reg1;
        valid_reg2 <= valid_reg1; 

        // round 2 results -> stage 3 registers
        v_reg3 <= v_out2;
        sum_reg3 <= sum_out2;
        key_reg3 <= key_reg2;
        mode_reg3 <= mode_reg2;
        valid_reg3 <= valid_reg2; 

        // Output logic
        ciphertext <= v_out3;
        valid <= valid_reg3;
    end
end

endmodule
