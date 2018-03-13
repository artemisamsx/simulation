`include "wait_control.v"
`include "asserts.v"

`timescale 1ns/100ps
`define CLK_SPEED 3.58 // Mhz

module wait_control_tb;

    reg clk = 1, nextwait = 1, nm1 = 1;
    wire nwait;

    wire #(15, 18) nm1d = nm1;

    wait_control dut(clk, nextwait, nm1d, nwait);

    always #(1000/`CLK_SPEED/2) clk = !clk;

    initial
    begin
        $dumpfile("wait_control.vcd");
        $dumpvars;

        /* Following the timewave at http://home.mit.bme.hu/~benes/oktatas/dig-jegyz_052/Z80-kivonat.pdf */

        /**
         * Simulate a M1 opcode retrieve cycle
         */
        // T1/posedge
        nm1 = 0;

        // T2/negedge
        repeat(2) @(negedge clk) #10;
        `ASSERT(nwait === 0);

        // T3/posedge
        @(posedge clk) #10;
        nm1 = 1;

        // T3/negedge
        @(negedge clk) #10;
        `ASSERT(nwait === 1);

        /**
         * Simulate a external device requesting WAIT
         */
        // T1/posedge
        @(posedge clk) #10;        
        nextwait = 0;

        // T1/negedge
        @(negedge clk) #10;
        `ASSERT(nwait === 0);

        // T4/negedge (and as many as the requester needs)
        repeat(3) @(negedge clk) #10;
        `ASSERT(nwait === 0);
        nextwait = 1;

        // T5/negedge
        @(negedge clk) #10;
        `ASSERT(nwait === 1);

        #100 $finish;
    end
endmodule
