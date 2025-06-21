module test_1_MIPS ;

reg clk1,clk2 ;
integer i,j ;

MIPS_32 mips(clk1,clk2) ;

initial                           // Two phase non-overlapping clock
    begin                          
        clk1=1'b0 ;
        clk2=1'b0 ;
        repeat (20)
            begin
                #5 clk1 = 1'b1 ;
                #5 clk1 = 1'b0 ;
                #5 clk2 = 1'b1 ;
                #5 clk2 = 1'b0 ;
            end
    end

initial
    begin
        for (i=0;i<32;i=i+1)                 // INTIALIZING THE REGISTERS
            mips.Reg[i] = i ;

        mips.Mem[0] = 32'h2801000a ;        // INSTRUCTIONS LOADED IN MEMORY
        mips.Mem[1] = 32'h28020014 ;        
        mips.Mem[2] = 32'h28030019 ;        
        mips.Mem[3] = 32'h0ce77800 ;        // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[4] = 32'h0ce77800 ;        // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[5] = 32'h00222000 ;        
        mips.Mem[6] = 32'h0ce77800 ;        // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[7] = 32'h00832800 ;        
        mips.Mem[8] = 32'hfc000000 ;        
    end

initial
    begin
        $dumpfile ("mips_1.vcd") ;
        $dumpvars (0,test_1_MIPS) ;
        mips.HALTED = 0 ;
        mips.PC = 0 ;
        mips.TAKEN_BRANCH = 0 ;

        #280 
        for (j=0;j<6;j=j+1)
            $display ("R%1d = %2d ",j,mips.Reg[j]) ;

        #300 $finish ;    
    end
endmodule