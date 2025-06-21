// *** MIPS32 PROCESSOR USING 5-STAGE PIPELINING RISC-V 

module MIPS_32 (clk1,clk2) ;

input clk1,clk2 ; // Two phase non-overlapping clock

reg [31:0] PC , IF_ID_IR , IF_ID_NPC ;    // IF_ID pipeline latch
reg [31:0] ID_EX_NPC , ID_EX_A , ID_EX_B , ID_EX_Imm , ID_EX_IR ; // ID_EX pipeline latch
reg [2:0] ID_EX_type , EX_MEM_type , MEM_WB_type ;
reg [31:0] EX_MEM_cond , EX_MEM_ALUout , EX_MEM_B , EX_MEM_IR ; // EX_MEM pipeline latch 
reg [31:0] MEM_WB_LMD , MEM_WB_ALUout , MEM_WB_IR ;  // MEM_WB pipeline latch

reg [31:0] Reg [0:31] ;  // Register Bank [ 32 registers X 32 bits ]
reg [31:0] Mem [0:1023] ; // Memory [ 1024 words X 32 bits ]

parameter ADD=6'b000000 , SUB=6'b000001 , AND=6'b000010 , OR=6'b000011 , SLT=6'b000100 , MUL=6'b000101 , // Arithemetic and Logical Instructions
          HLT=6'b111111 , // Halt Instruction 
          LW=6'b001000 , SW=6'b001001 , // Load and Store Instructions
          ADDI=6'b001010 , SUBI=6'b001011 , SLTI=6'b001100 , // Immediate Instructions
          BNEQZ=6'b001101 , BEQZ=6'b001110 ;  // Branch Instructions

parameter RR_ALU=3'b000 , RM_ALU=3'b001 , LOAD=3'b010 , 
          STORE=3'b011 , BRANCH=3'b100 , HALT=3'b101 ;          
          
reg HALTED ; // Set after HLT instruction is completed ( in WB stage ) 
reg TAKEN_BRANCH ;  // Required to disable instructions after branch

wire [4:0] rs,rt ; // rs --> Source Register 1 (rs <- IR[25:21]) || rt --> Source Register 2 (rt <- IR[20:16])
wire [5:0] op_code ;  // op_code <-- IR[31:26]
wire [15:0] immediate ;  // immediate <-- IR[15:0]

assign op_code = IF_ID_IR[31:26] ;
assign rs = IF_ID_IR[25:21] ;
assign rt = IF_ID_IR[20:16] ;
assign immediate = IF_ID_IR[15:0] ;


// ***** IF STAGE *****
always @ (posedge clk1) 
    
    if ( HALTED==0 )
            begin
                if ( ( (EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1) ) || 
                     ( (EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0) ) )   // FOR BRANCH INSTRUCTIONS

                    begin
                        IF_ID_IR <= #2 Mem[EX_MEM_ALUout] ;
                        TAKEN_BRANCH <= #2 1'b1 ;
                        IF_ID_NPC <= #2 EX_MEM_ALUout ;
                        PC <= #2 EX_MEM_ALUout ;
                    end

                else
                    begin                            // FOR NORMAL ARITHMETIC AND LOGIC INSTRUCTIONS
                        IF_ID_IR <= #2 Mem[PC] ;
                        IF_ID_NPC <= #2 PC+1 ;
                        PC <= #2 PC+1 ;
                    end    

            end

// ***** ID STAGE ***** 
always @ (posedge clk2)

    if (HALTED==0)
        begin
            case (op_code)   // Operation_Code
                ADD,SUB,MUL,AND,OR,SLT : ID_EX_type <= #2 RR_ALU ;
                ADDI,SUBI,SLTI : ID_EX_type <= #2 RM_ALU ;
                LW : ID_EX_type <= #2 LOAD ;
                SW : ID_EX_type <= #2 STORE ;
                BNEQZ,BEQZ : ID_EX_type <= #2 BRANCH ;
                HLT : ID_EX_type <= #2 HALT ;

                default : ID_EX_type <= #2 HALT ; // invalid op_code
            endcase

            if ( rs == 5'b00000 ) ID_EX_A <= #2 0 ;
            else ID_EX_A <= #2 Reg[rs] ;   // Source Register 1

            if ( rt == 5'b00000 ) ID_EX_B <= #2 0 ;
            else ID_EX_B <= #2 Reg[rt] ;   // Source Register 2

            ID_EX_Imm <= #2 {{16{immediate[15]}}, immediate} ;  // Sign extension

            ID_EX_IR <= #2 IF_ID_IR ;
            ID_EX_NPC <= #2 IF_ID_NPC ;
        end

// ***** EX STAGE *****
always @ (posedge clk1)

    if ( HALTED==0 )
        begin
            EX_MEM_IR <= #2 ID_EX_IR ;
            EX_MEM_type <= #2 ID_EX_type ;
            TAKEN_BRANCH <= #2 1'b0 ; // Reset the "TAKEN_BRANCH"

            case (ID_EX_type)

            RR_ALU : begin  
                        case (ID_EX_IR[31:26])  // opcode
                        ADD : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_B ;
                        SUB : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_B ;
                        MUL : EX_MEM_ALUout <= #2 ID_EX_A * ID_EX_B ;
                        AND : EX_MEM_ALUout <= #2 ID_EX_A & ID_EX_B ;
                        OR  : EX_MEM_ALUout <= #2 ID_EX_A | ID_EX_B ;
                        SLT : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_B ;
                        default :EX_MEM_ALUout <= #2 32'hxxxxxxxx ;
                        endcase
                     end

            RM_ALU : begin 
                        case (ID_EX_IR[31:26]) // opcode
                        ADDI : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm ;
                        SUBI : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_Imm ;
                        SLTI : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_Imm ;
                        default :EX_MEM_ALUout <= #2 32'hxxxxxxxx ;
                        endcase
                     end     

            LOAD,STORE :begin   
                            EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm ;
                            EX_MEM_B <= #2 ID_EX_B ;   // required for store instructions
                        end       

            BRANCH : begin
                        EX_MEM_ALUout <= #2 ID_EX_NPC + ID_EX_Imm ;
                        EX_MEM_cond <= #2 (ID_EX_A == 0) ;
                     end         

            endcase 
        end

// ***** MEM STAGE *****
always @ (posedge clk2)

    if ( HALTED == 0 )
        begin
            MEM_WB_IR <= #2 EX_MEM_IR ;
            MEM_WB_type <= #2 EX_MEM_type ;

            case (EX_MEM_type)
            RR_ALU,RM_ALU : MEM_WB_ALUout <= #2 EX_MEM_ALUout ;

            LOAD : MEM_WB_LMD <= #2 Mem[EX_MEM_ALUout] ;

            STORE : if ( TAKEN_BRANCH == 0 )
                        Mem[EX_MEM_ALUout] <= #2 EX_MEM_B ;
            endcase
        end

// ***** WB STAGE *****
always @(posedge clk1)

        begin
            if ( TAKEN_BRANCH == 0 ) // Disable write if someone is taking branch

                case (MEM_WB_type)
                RR_ALU : Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUout ; 

                RM_ALU : Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUout ;

                LOAD : Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD ;

                HALT : HALTED <= #2 1'b1 ;
                endcase 
        end


endmodule