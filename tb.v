`timescale 1ns/1ps

module tb();

reg clk = 0;
reg rst_n;
reg [31:0] expected_result;

reg [255:0] file_data [0:3];

always #1 clk = ~clk; // Clock generation

core_top #(
    .MEMORY_FILE("programa.txt") // Specify the memory file
) t (
    .clk(clk),
    .rst_n(rst_n)
);

integer i;
reg [7:0] counter = 0;

initial begin
    $dumpfile("saida.vcd");
    $dumpvars(0, tb);

    $readmemh("teste.txt", file_data); // Read the memory file

    $display("Programa executado:");
    $display("%s", file_data[0]);
    $display("%s", file_data[1]);
    $display("%s", file_data[2]);

    expected_result = file_data[3][31:0];

    rst_n = 0; // Reset the system
    #5;
    rst_n = 1; // Release reset
    
    while (tb.t.mem.data_o !== 32'hxxxxxxxx && counter <= 50) begin
        counter <= counter + 1;
        #2;
    end

    #2;


    if (tb.t.mem.memory[16/4] !== expected_result ) begin
        $display("=== ERRO: Esperado %h na memória, obtido %h", expected_result, tb.t.mem.memory[16/4]);
    end else begin
        $display("=== OK: Obtido %h na memória", tb.t.mem.memory[16/4]);
    end

    $finish; // End simulation
end

endmodule