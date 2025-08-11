module core_top #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire        clk,
    input  wire        rst_n
);

// insira seu código aqui

wire rd_en, wr_en;
wire [31:0] addr_in, data_in, data_out;


Memory #(
    .MEMORY_FILE(MEMORY_FILE),
    .MEMORY_SIZE(MEMORY_SIZE)
) mem (
    .clk(clk),
    .rd_en_i(rd_en),    // Indica uma solicitação de leitura
    .wr_en_i(wr_en),    // Indica uma solicitação de escrita
    .addr_i(addr_in),     // Endereço
    .data_i(data_out),     // Dados de entrada (para escrita)
    .data_o(data_in),     // Dados de saída (para leitura)
  
     .ack_o()       // Confirmação da transação
);

Core #(
    .BOOT_ADDRESS( 32'h00000000 )
) cor (
     // Control signal
    .clk(clk),
    // input wire halt,
    .rst_n(rst_n),
    // Memory BUS
    // input  wire ack_i,
    .rd_en_o(rd_en),
    .wr_en_o(wr_en),
    // output wire [3:0]  byte_enable,
    .data_i(data_in),
    .addr_o(addr_in),
    .data_o(data_out)
);

endmodule