module Core #(
    parameter BOOT_ADDRESS = 32'h00000000
) (
    // Control signal
    input wire clk,
    // input wire halt,
    input wire rst_n,

    // Memory BUS
    // input  wire ack_i,
    output wire rd_en_o,
    output wire wr_en_o,
    // output wire [3:0]  byte_enable,
    input  wire [31:0] data_i,
    output wire [31:0] addr_o,
    output wire [31:0] data_o
);

//insira seu código aqui

reg [31:0] PC, PC_old;
wire pc_write_en;

// control unit
wire    uc_pc_write_cond,
        uc_pc_write, 
        uc_lorD, 
        uc_mem_read, 
        uc_mem_write, 
        uc_mem_to_reg,
        uc_ir_write,
        uc_pc_source,
        uc_is_immediate,
        uc_reg_write;

wire [1:0]  uc_alu_op_co,
            uc_alu_src_b,
            uc_alu_src_a;

// alu
// alu control
wire [31:0] alu_rs1_in,
            alu_rs2_in;
wire [31:0] alu_rd_out;
wire        alu_zr_out;
wire [3:0]  alu_op_out;

// ALUOut
reg [31:0] ALUOut;

// registers
wire [31:0] reg_rs1_data_out, reg_rs2_data_out;

// immediate
wire [31:0] immediate_out;

// Mem reg
reg [31:0] MDR;

// IR
reg [31:0] IR;
wire [6:0] opcode   = IR[6:0];
wire [4:0] rd       = IR[11:7];
wire [2:0] funct3   = IR[14:12];
wire [4:0] rs1      = IR[19:15];
wire [4:0] rs2      = IR[24:20];
wire [6:0] funct7   = IR[31:25];

assign pc_cont4 = alu_rd_out;
wire [31:0] alu_pc_select_mux = uc_pc_source ? ALUOut : alu_rd_out;
assign pc_write_en = uc_pc_write | ( uc_pc_write_cond & alu_zr_out );

always @( posedge clk or negedge rst_n ) 
begin
    if( !rst_n ) 
    begin
        PC <= BOOT_ADDRESS;
    end
    else if( pc_write_en )
    begin
        PC <= alu_pc_select_mux;
    end
end

always @( posedge clk or negedge rst_n ) 
begin
    if( uc_ir_write )
    begin
        PC_old <= PC;   
    end 
end

always @( posedge clk ) 
begin
    if( uc_ir_write )
    begin
        IR <= data_i;
    end    
end

always @( posedge clk ) 
begin
    MDR <= data_i;   
end

always @( posedge clk ) 
begin
    ALUOut <= alu_rd_out;   
end


Control_Unit x_control_unit(
    .clk(clk),
    .rst_n(rst_n),
    .instruction_opcode(opcode),
    .pc_write(uc_pc_write),
    .ir_write(uc_ir_write),
    .pc_source(uc_pc_source),
    .reg_write(uc_reg_write),
    .memory_read(uc_mem_read),
    .is_immediate(uc_is_immediate),
    .memory_write(uc_mem_write),
    .pc_write_cond(uc_pc_write_cond),
    .lorD(uc_lorD),
    .memory_to_reg(uc_mem_to_reg),
    .aluop(uc_alu_op_co),
    .alu_src_a(uc_alu_src_a),
    .alu_src_b(uc_alu_src_b)
);

wire [31:0] data_in = uc_mem_to_reg ? MDR : ALUOut;

Registers regs(
    .clk(clk),
    .wr_en_i(uc_reg_write),
    .RS1_ADDR_i(rs1),
    .RS2_ADDR_i(rs2),
    .RD_ADDR_i(rd),
    .data_i(data_in),
    .RS1_data_o(reg_rs1_data_out),
    .RS2_data_o(reg_rs2_data_out)
);

Immediate_Generator imm_generator(
    .instr_i(IR),
    .imm_o(immediate_out)    
);

ALU_Control alu_ctrl(
    .is_immediate_i(uc_is_immediate),
    .ALU_CO_i(uc_alu_op_co),
    .FUNC7_i(funct7),
    .FUNC3_i(funct3),
    .ALU_OP_o(alu_op_out)
);

assign alu_rs1_in = (uc_alu_src_a == 2'b00) ? PC                :
                    (uc_alu_src_a == 2'b01) ? reg_rs1_data_out  :
                    (uc_alu_src_a == 2'b10) ? PC_old            :
                    32'b0;

assign alu_rs2_in = (uc_alu_src_b == 2'b00) ? reg_rs2_data_out  :
                    (uc_alu_src_b == 2'b01) ? 32'b0100             :
                    immediate_out;

Alu x_alu(
    .ALU_OP_i(alu_op_out),
    .ALU_RS1_i(alu_rs1_in),
    .ALU_RS2_i(alu_rs2_in),
    .ALU_RD_o(alu_rd_out),
    .ALU_ZR_o(alu_zr_out)
);


wire [31:0] pc_mux_out;
assign pc_mux_out = ( uc_lorD ) ? ALUOut : PC;

assign rd_en_o  = uc_mem_read;
assign wr_en_o  = uc_mem_write;
assign addr_o   = pc_mux_out;
assign data_o   = reg_rs2_data_out;

endmodule