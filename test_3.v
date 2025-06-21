module test_3_MIPS ;

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

        mips.Mem[0] = 32'h280a00c8 ;        // INSTRUCTIONS LOADED IN MEMORY
        mips.Mem[1] = 32'h28020001 ;        
        mips.Mem[2] = 32'h0e94a000 ;       // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[3] = 32'h21430000 ;        
        mips.Mem[4] = 32'h0e94a000 ;       // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[5] = 32'h14431000 ;       
        mips.Mem[6] = 32'h2c630001 ;        
        mips.Mem[7] = 32'h0e94a000 ;       // dummy instruction [ To avoid DATA HAZARD ]
        mips.Mem[8] = 32'h3460fffc ;       
        mips.Mem[9] = 32'h2542fffe ;       
        mips.Mem[10] = 32'hfc000000 ;       

        mips.Mem[200] = 32'd7 ;        
    end

initial
    begin
        $dumpfile ("mips_3.vcd") ;
        $dumpvars (0,test_3_MIPS) ;
        $monitor ("R2 = %4d",mips.Reg[2]) ;

        mips.HALTED = 0 ;
        mips.PC = 0 ;
        mips.TAKEN_BRANCH = 0 ;

        #4000 
        $display ("Mem[200] = %2d | Mem[198] =%6d ",mips.Mem[200],mips.Mem[198]) ;

        #3000 $finish ;    
    end
endmodule