module cpu_tb;

    reg clk = 0;
    reg reset = 1;

    always #5 clk = ~clk;

    cpu_top DUT (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $readmemh("program.hex", DUT.u_mem.u_instr_mem.rom);
        #20 reset = 0;

        #2000 $finish;
    end

endmodule
