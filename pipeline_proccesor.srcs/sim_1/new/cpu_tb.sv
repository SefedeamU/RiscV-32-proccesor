`timescale 1ns/1ps

module cpu_tb;
    reg clk;
    reg reset;

    // DUT
    cpu_top DUT (
        .clk   (clk),
        .reset (reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;   // toggle cada 5ns

    initial begin
        reset = 1;
        // Cargar programa
        $readmemh("program.hex", DUT.imem_u.mem);
        // Mantener reset unos ciclos
        #20;
        reset = 0;


        // Tiempo de simulación 
        #2000;
        $finish;
    end

endmodule
