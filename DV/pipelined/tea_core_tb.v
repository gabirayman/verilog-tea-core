`include "DV/common/test_params.vh"
`timescale 1ns / 1ps

module tea_core_tb();

    // --- Signal Declarations ---
    reg clk, rst_n, start, mode;
    reg [63:0] plaintext;
    reg [127:0] key;
    wire [63:0] ciphertext;
    wire valid, ready;

    // --- Test Memory & Scoreboard Queues ---
    reg [255:0] test_vectors [0:`NUM_TESTS - 1];
    reg [63:0]  expected_queue [0:`NUM_TESTS - 1];
    reg         mode_queue     [0:`NUM_TESTS - 1];

    // --- Simulation Variables ---
    integer send_idx = 0;
    integer check_idx = 0;
    integer pass_count = 0;
    
    // Checker helper variables (declared here to prevent compiler errors)
    reg [63:0] current_expected;
    reg        current_exp_mode;

    // --- UUT Instance ---
    tea_core uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start), 
        .mode(mode),
        .plaintext(plaintext), 
        .key(key), 
        .ciphertext(ciphertext),
        .valid(valid), 
        .ready(ready)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk;

    // --- PROCESS 1: The Feeder (0-1-0-1 Pattern) ---
    initial begin : feeder_block
        $dumpfile("build/pipelined/tea_waves.vcd"); 
        $dumpvars(0, tea_core_tb);

        // Load test vectors from hex file
        $readmemh("DV/common/tea_tests.mem", test_vectors);
        
        // Initialize inputs
        clk = 0; 
        rst_n = 0; 
        start = 0;
        mode = 0;
        plaintext = 0;
        key = 0;

        // Reset Sequence
        #20 rst_n = 1;
        @(posedge clk);

        $display(">>> Starting Toggled Mode Test (0-1-0-1) for %0d vectors", `NUM_TESTS);
        
        for (send_idx = 0; send_idx < `NUM_TESTS; send_idx = send_idx + 1) begin
            // Synchronize: Wait until the core is ready for the next input
            while (!ready) @(posedge clk);
            
            @(posedge clk);
            start <= 1;
            mode  <= (send_idx % 2); // Explicitly toggle 0, 1, 0, 1
            key   <= test_vectors[send_idx][255:128];
            
            if ((send_idx % 2) == 0) begin
                // Mode 0: Encrypt. Feed PT, Expect CT
                plaintext <= test_vectors[send_idx][127:64];
                expected_queue[send_idx] <= test_vectors[send_idx][63:0];
                mode_queue[send_idx]     <= 0;
            end else begin
                // Mode 1: Decrypt. Feed CT, Expect PT
                plaintext <= test_vectors[send_idx][63:0];
                expected_queue[send_idx] <= test_vectors[send_idx][127:64];
                mode_queue[send_idx]     <= 1;
            end
        end
        
        // Finalize feeding
        @(posedge clk);
        start <= 0;
        
        // Wait for Scoreboard to finish checking all vectors
        wait (check_idx == `NUM_TESTS);
        
        $display("---------------------------------------");
        $display(">>> TEST COMPLETE");
        $display(">>> Total Passed: %0d / %0d", pass_count, `NUM_TESTS);
        $display("---------------------------------------");
        $finish;
    end

    // --- PROCESS 2: The Checker (Latency-Independent Scoreboard) ---
    always @(posedge clk) begin : checker_block
        if (valid) begin
            // Identify what we should be seeing based on when it was sent
            current_expected = expected_queue[check_idx];
            current_exp_mode = mode_queue[check_idx];

            if (ciphertext == current_expected) begin
                $display("[PASS] Idx %0d | Mode: %s | Out: %h", 
                         check_idx, (current_exp_mode ? "DEC" : "ENC"), ciphertext);
                pass_count <= pass_count + 1;
            end else begin
                $display("[FAIL] Idx %0d | Mode: %s | Expected: %h | Got: %h", 
                         check_idx, (current_exp_mode ? "DEC" : "ENC"), current_expected, ciphertext);
            end
            
            // Advance the checker index
            check_idx <= check_idx + 1;
        end
    end

endmodule