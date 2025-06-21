module test_2_MIPS ;

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

        mips.Mem[0] = 32'h28010078 ;        // INSTRUCTIONS LOADED IN MEMORY
        mips.Mem[1] = 32'h0c631800 ;        // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[2] = 32'h20220000 ;        
        mips.Mem[3] = 32'h0c631800 ;        // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[4] = 32'h2842002d ;       
        mips.Mem[5] = 32'h0c631800 ;        // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[6] = 32'h24220001 ;        
        mips.Mem[7] = 32'hfc000000 ;       

        mips.Mem[120] = 32'd85 ;        
    end

initial
    begin
        $dumpfile ("mips_2.vcd") ;
        $dumpvars (0,test_2_MIPS) ;
        mips.HALTED = 0 ;
        mips.PC = 0 ;
        mips.TAKEN_BRANCH = 0 ;

        #500 
        $display ("Mem[120] = %4d | Mem[121] =%4d ",mips.Mem[120],mips.Mem[121]) ;

        #600 $finish ;    
    end
endmodule