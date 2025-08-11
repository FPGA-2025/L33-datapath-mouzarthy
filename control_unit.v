module Control_Unit (
    input wire clk,
    input wire rst_n,
    input wire [6:0] instruction_opcode,
    output reg pc_write,
    output reg ir_write,
    output reg pc_source,
    output reg reg_write,
    output reg memory_read,
    output reg is_immediate,
    output reg memory_write,
    output reg pc_write_cond,
    output reg lorD,
    output reg memory_to_reg,
    output reg [1:0] aluop,
    output reg [1:0] alu_src_a,
    output reg [1:0] alu_src_b
);

// machine states
localparam FETCH              = 4'b0000;
localparam DECODE             = 4'b0001;
localparam MEMADR             = 4'b0010;
localparam MEMREAD            = 4'b0011;
localparam MEMWB              = 4'b0100;
localparam MEMWRITE           = 4'b0101;
localparam EXECUTER           = 4'b0110;
localparam ALUWB              = 4'b0111;
localparam EXECUTEI           = 4'b1000;
localparam JAL                = 4'b1001;
localparam BRANCH             = 4'b1010;
localparam JALR               = 4'b1011;
localparam AUIPC              = 4'b1100;
localparam LUI                = 4'b1101;
localparam JALR_PC            = 4'b1110;

// Instruction Opcodes 1100111
localparam LW      = 7'b0000011;
localparam SW      = 7'b0100011;
localparam RTYPE   = 7'b0110011;
localparam ITYPE   = 7'b0010011;
localparam JALI    = 7'b1101111;
localparam BRANCHI = 7'b1100011;
localparam JALRI   = 7'b1100111;
localparam AUIPCI  = 7'b0010111;
localparam LUII    = 7'b0110111;

// insira aqui o seu código
reg [3:0] currState, nextState;

//Lógica de próximo estado.
	always @(currState, instruction_opcode)
	begin
		case( currState )
		FETCH: 
			begin
				nextState <= DECODE;
			end
		DECODE: 
			begin
			case( instruction_opcode )
                LW:         nextState <= MEMADR;
                SW:         nextState <= MEMADR;
                RTYPE:      nextState <= EXECUTER;
                ITYPE:      nextState <= EXECUTEI;
                JALI:       nextState <= JAL;
                BRANCHI:    nextState <= BRANCH;
                JALRI:      nextState <= JALR_PC;
                AUIPCI:     nextState <= AUIPC;
                LUII:       nextState <= LUI;
                // default:    nextState <= FETCH;
            endcase
			end
		MEMADR:
			begin
				if( instruction_opcode == LW )
					nextState <= MEMREAD;
				else
					nextState <= MEMWRITE;
			end
		MEMREAD:
			begin
				nextState <= MEMWB;
			end
		MEMWB:
			begin
				nextState <= FETCH;
			end
		MEMWRITE:
			begin
				nextState <= FETCH;
			end
		EXECUTER:
			begin
				nextState <= ALUWB;
			end
		ALUWB:
			begin
				nextState <= FETCH;
			end
		BRANCH:
			begin
				nextState <= FETCH;
			end
        EXECUTEI:
            begin
                nextState <= ALUWB;
            end
        JAL:
            begin
                nextState <= ALUWB;        
            end
        JALR:
            begin
                nextState <= ALUWB;
            end
        JALR_PC:
            begin
                nextState <= JALR;
            end
        LUI:
            begin
                nextState <= ALUWB;
            end
        AUIPC:
            begin
                nextState <= ALUWB;        
            end
		default:
			begin
				nextState <= FETCH;
			end
		endcase
	end

always @( currState ) begin

    case( currState )
        
    FETCH   :
        begin
        pc_write      = 1'b1;
        ir_write      = 1'b1;
        pc_source     = 1'b0;
        memory_read   = 1'b1;
        lorD          = 1'b0;
        aluop         = 2'b00;
        alu_src_a     = 2'b00;
        alu_src_b     = 2'b01;   

        reg_write     = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        memory_to_reg = 1'b0;
        end
    DECODE  :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        aluop         = 2'b00;
        alu_src_a     = 2'b10;
        alu_src_b     = 2'b10;     
        end
    MEMADR  :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        aluop         = 2'b00;
        alu_src_a     = 2'b01;
        alu_src_b     = 2'b10;     
        end
    MEMREAD :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        memory_to_reg = 1'b0;
        aluop         = 1'b0;
        alu_src_a     = 1'b0;
        alu_src_b     = 1'b0;     

        memory_read   = 1'b1;
        lorD          = 1'b1;
        end
    MEMWB   :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        aluop         = 1'b0;
        alu_src_a     = 1'b0;
        alu_src_b     = 1'b0;  

        reg_write     = 1'b1;
        memory_to_reg = 1'b1;   
        end
    MEMWRITE:
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        pc_write_cond = 1'b0;
        memory_to_reg = 1'b0;
        aluop         = 1'b0;
        alu_src_a     = 1'b0;
        alu_src_b     = 1'b0;  

        memory_write  = 1'b1;
        lorD          = 1'b1;   
        end
    EXECUTER:
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        aluop         = 2'b10;
        alu_src_a     = 2'b01;
        alu_src_b     = 2'b00;     
        end
    EXECUTEI:
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        is_immediate  = 1'b1;
        aluop         = 2'b10;
        alu_src_a     = 2'b01;
        alu_src_b     = 2'b10;     
        end
    ALUWB   :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        aluop         = 1'b0;
        alu_src_a     = 1'b0;
        alu_src_b     = 1'b0;    

        reg_write     = 1'b1;
        memory_to_reg = 1'b0; 
        end
    JAL     :
        begin
       
        ir_write      = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        pc_write      = 1'b1;
        pc_source     = 1'b1;
        aluop         = 2'b00;
        alu_src_a     = 2'b10;
        alu_src_b     = 2'b01;     
        end
    BRANCH  :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        pc_source     = 1'b1;
        pc_write_cond = 1'b1;
        aluop         = 2'b01;
        alu_src_a     = 2'b01;
        alu_src_b     = 2'b00;     
        end
    JALR    :
        begin
        ir_write      = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b1;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        pc_source     = 1'b1;
        pc_write      = 1'b1;
        aluop         = 2'b00;
        alu_src_a     = 2'b10;
        alu_src_b     = 2'b01;     
        end
    AUIPC   :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        aluop         = 2'b00;
        alu_src_a     = 2'b10;
        alu_src_b     = 2'b10;     
        end
    LUI     :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        aluop         = 2'b00;
        alu_src_a     = 2'b11;
        alu_src_b     = 2'b10;     
        end
    JALR_PC :
        begin
        pc_write      = 1'b0;
        ir_write      = 1'b0;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b0;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;

        aluop         = 2'b00;
        alu_src_a     = 2'b01;
        alu_src_b     = 2'b10;     
        end 
    default:
        begin
        pc_write      = 1'b1;
        ir_write      = 1'b1;
        pc_source     = 1'b0;
        reg_write     = 1'b0;
        memory_read   = 1'b1;
        is_immediate  = 1'b0;
        memory_write  = 1'b0;
        pc_write_cond = 1'b0;
        lorD          = 1'b0;
        memory_to_reg = 1'b0;
        aluop         = 2'b00;
        alu_src_a     = 2'b00;
        alu_src_b     = 2'b01;   
        end
    endcase

end

always @( negedge rst_n, posedge clk ) begin
    if( rst_n == 0 ) currState <= FETCH;
    else currState <= nextState;
end

endmodule
