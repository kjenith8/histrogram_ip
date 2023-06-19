`timescale 1ns / 1ps

module histogram_top_tb();

localparam P_DW  = 4;
localparam P_NUM_BIN = 8;
localparam clk_period = 10;

reg areset_n = 1'b0;
reg aclk = 1'b0;
reg [P_DW-1 : 0]histo_data_i;
reg rx_valid;
reg rx_done;
reg tx_done = 1'b0;

wire interrupt_out;
wire [P_DW-1 : 0]tdata;
wire tvalid;
wire tlast;
reg tready = 1'b0;


//aclk_generation
initial
    begin
        #5;
        forever
            #(clk_period/2) aclk = ~aclk;
    end

// reset generation
initial
    begin
        #0 areset_n = 1'b0;
        #(clk_period*10)areset_n = 1'b1;
    end

//data_generation
always
    begin
       // @(posedge rx_valid)
       //@(posedge areset_n )
       //#0.45;
       forever
        #10 histo_data_i = $random;
     end

//rx_valid_gen
initial
        begin
            #0 rx_valid = 1'b0;
            #(clk_period*15) rx_valid = 1'b1;
            #(clk_period*10) rx_valid = 1'b0;
        end
initial
        begin
            #0 rx_done = 1'b0;
            #(clk_period*24) rx_done = 1'b1;
            #(clk_period) rx_done = 1'b0;
        end
initial
        begin
            #0 tready = 1'b0;
            #(clk_period*26) tready = 1'b1;
            #(clk_period*2) tready = 1'b0;
            #(clk_period*3) tready = 1'b1;
            #(clk_period*3) tready = 1'b0;
            #(clk_period*3) tready = 1'b1;
            
            //#clk_period 
        end
histogram_top 
//    #(
//    .P_DW(P_DW),
//    .P_NUM_BIN(P_NUM_BIN)
//    ) 
DUT
    (
    .areset_n(areset_n),
    .areset_n_sync(1'b1),                   
    .aclk(aclk),                       
    .rdata(histo_data_i),   
    .rvalid(rx_valid),                   
    .rlast(rx_done),                    
    .tready(tready),
    //.tready(1'b1),
    
    .rready(rready),                                                          
    .tdata(tdata),         
    .tvalid(tvalid),                    
    .tlast(tlast),
    .interrupt_out(interrupt_out)
    );                      
 
endmodule
