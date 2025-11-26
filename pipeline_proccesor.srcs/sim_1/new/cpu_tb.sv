`timescale 1ns/1ps

module cpu_tb;
    reg clk;
    reg reset;

    // DUT
    cpu_top DUT (
        .clk   (clk),
        .reset (reset)
    );

    // reloj 100 MHz (T = 10 ns)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;

        // programa entero (instrucciones)
        $readmemh("program.hex", DUT.imem_u.mem);

        // datos para pruebas de memoria / FP
        $readmemh("data.hex", DUT.dmem_u.mem);

        // mantener reset unos ciclos
        #20;
        reset = 0;

        // tiempo total de simulación
        #2000;
        $finish;
    end

endmodule
