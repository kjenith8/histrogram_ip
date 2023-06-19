`timescale 1ns / 1ps

module histogram_calc_tb();

localparam P_DW  = 3;
localparam P_NUM_BIN = 8;
localparam clk_period = 10;

reg areset_n = 1'b0;
reg aclk = 1'b0;
reg [P_DW-1 : 0]histo_data_i;
reg rx_valid;
reg rx_done;
reg tx_done = 1'b0;

wire histo_ready;
wire [P_DW-1 : 0]tdata;
wire tvalid;
wire tlast;
reg tready;

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
       #0.45;
       forever
        #10 histo_data_i = $random;
     end

//rx_valid_gen
initial
        begin
            #0 rx_valid = 1'b0;
            #(clk_period*11) rx_valid = 1'b1;
            #(clk_period*10) rx_valid = 1'b0;
        end
initial
        begin
            #0 rx_done = 1'b0;
            #(clk_period*20) rx_done = 1'b1;
            #(clk_period) rx_done = 1'b0;
        end
initial
        begin
            #0 tready = 1'b0;
            #(clk_period*23) tready = 1'b1;
            #(clk_period*2) tready = 1'b0;
            #(clk_period*2) tready = 1'b1;
            //#clk_period 
        end

histogram_calc 
    #(
    .P_DW(P_DW),
    .P_NUM_BIN(P_NUM_BIN)
    ) 
DUT
    (
    .areset_n(areset_n),                   
    .aclk(aclk),                       
    .histo_data_i(histo_data_i),   
    .rx_valid(rx_valid),                   
    .rx_done(rx_done),                    
    .tready(tready),                    
                    
    .histo_ready(histo_ready),               
                        
    .histo_data_o(tdata),         
    .histo_data_valid(tvalid),                    
    .histo_data_last(tlast)
    );                      
 
endmodule
