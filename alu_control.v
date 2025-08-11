module ALU_Control (
    input wire is_immediate_i,
    input wire [1:0] ALU_CO_i,
    input wire [6:0] FUNC7_i,
    input wire [2:0] FUNC3_i,
    output reg [3:0] ALU_OP_o
);

// insira seu código aqui

localparam LOAD_STORE   = 2'b00;
localparam BRANCH       = 2'b01;
localparam ALU          = 2'b10;
// localparam INVALIDO     = 2'b11;


localparam AND              = 4'b0000;
localparam OR               = 4'b0001;
localparam XOR              = 4'b1000;
localparam NOR              = 4'b1001;
localparam SUM              = 4'b0010;  //ADD
localparam SUB              = 4'b1010;
localparam EQUAL            = 4'b0011;
localparam GREATER_EQUAL    = 4'b1100;
localparam GREATER_EQUAL_U  = 4'b1101;
localparam SLT              = 4'b1110;
localparam SLT_U            = 4'b1111;
localparam SHIFT_LEFT       = 4'b0100;
localparam SHIFT_RIGHT      = 4'b0101;
localparam SHIFT_RIGHT_A    = 4'b0111;

// localparam FUNCT7_SUM       = 7'b0;
// localparam FUNCT7_SUB       = 7'b0100000;
// localparam FUNCT7_SHIFT_R   


always @( * ) 
begin
    case( ALU_CO_i )

        LOAD_STORE: 
        begin
            ALU_OP_o = SUM;
        end
        
        BRANCH: 
        begin
            case( FUNC3_i )
                3'b000: ALU_OP_o    = SUB;
                3'b001: ALU_OP_o    = EQUAL;
                3'b010: ALU_OP_o    = SUB;
                3'b011: ALU_OP_o    = SUB;
                3'b100: ALU_OP_o    = GREATER_EQUAL;
                3'b110: ALU_OP_o    = GREATER_EQUAL_U;
                3'b101: ALU_OP_o    = SLT;
                3'b111: ALU_OP_o    = SLT_U;

                default: ALU_OP_o   = 4'b0; 
            endcase       
        end
        
        ALU: 
        begin
            case( FUNC3_i )

                3'b000: 
                begin
                    if( is_immediate_i ) 
                    begin
                        ALU_OP_o = SUM;
                    end
                    else
                    begin
                        if( FUNC7_i == 7'b0 )
                        begin
                            ALU_OP_o = SUM;
                        end
                        else if( FUNC7_i == 7'b0100000 )
                        begin
                            ALU_OP_o = SUB;
                        end
                        else
                        begin
                            ALU_OP_o = 4'b0;
                        end
                    end
                end

                3'b111: ALU_OP_o = AND;
                3'b110: ALU_OP_o = OR;
                3'b100: ALU_OP_o = XOR;
                3'b010: ALU_OP_o = SLT;
                3'b011: ALU_OP_o = SLT_U;
                3'b001: ALU_OP_o = SHIFT_LEFT;

                3'b101: 
                begin
                    if( FUNC7_i == 7'b0 )
                    begin
                        ALU_OP_o = SHIFT_RIGHT;
                    end
                    else if( FUNC7_i == 7'b0100000 )
                    begin
                        ALU_OP_o = SHIFT_RIGHT_A;
                    end
                    else
                    begin
                        ALU_OP_o = 4'b0;
                    end
                end

                default: ALU_OP_o = 4'b0;
            endcase
        end
   
        default: ALU_OP_o = 4'b0;
    endcase
end

endmodule
