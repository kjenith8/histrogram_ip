`timescale 1ns / 1ps


module histogram_top
    #(
        parameter P_DW = 4,
        parameter P_NUM_BIN = 8
     )
    (
//Control ports
    input areset_n,
    input areset_n_sync,
    input aclk,
 //axi_stream_rx_ports
    input [P_DW-1 : 0]rdata,
    input rvalid,
    input rlast,
    output rready,
 //axi_stream_tx_ports
    output [P_DW-1 : 0]tdata,
    output tvalid,
    output tlast,
    input tready,
 //interrupt ports
    output interrupt_out
    );
    
 wire aclk_net;
 wire areset_n_net;
 wire [P_DW-1 : 0]histo_data_i;
 wire [P_DW-1 : 0]histo_data_o;
 wire histo_ready;
 wire histo_data_valid;
 wire histo_data_last;
 wire rx_valid;
 wire rx_done;
 wire tready_net;
 wire [P_DW-1 : 0]tdata_net;
 wire tvalid_net;
 wire tlast_net;
 wire interrupt_net;
 
    
//clk_rst_top_inst
    clk_rst_top u_clk_rst_top (
       .aclk_i(aclk),
       .areset_n_i(areset_n),
       .areset_n_i_sync(areset_n_sync),
        .aclk_o(aclk_net),
        .areset_n_o(areset_n_net)
        );
//axi_stream_rx inst
    axi_stream_rx #(
           .P_DW(P_DW)
          ) 
         u_axi_stream_rx (
        .areset_n(areset_n_net),
        .aclk(aclk_net),
        .rdata(rdata),
        .rvalid(rvalid),
        .rlast(rlast),
        .histo_ready(histo_ready),
        .rready(rready_net),
        .histo_data_i(histo_data_i),
        .rx_valid(rx_valid),
        .rx_done(rx_done)
    );
 //histogram_block inst
     histogram_calc #(
        .P_DW(P_DW),
        .P_NUM_BIN(P_NUM_BIN)
    ) u_histogram_calc (
        .areset_n(areset_n_net),
        .aclk(aclk_net),
        .histo_data_i(histo_data_i),
        .rx_valid(rx_valid),
        .rx_done(rx_done),
        .tready(tready_net),
        .histo_ready(histo_ready),
        .histo_data_o(histo_data_o),
        .histo_data_valid(histo_data_valid),
        .histo_data_last(histo_data_last)
    );
    //axi_stream_tx_inst
 axi_stream_tx #(
        .P_DW(P_DW)
    ) u_axi_stream_tx (
        .areset_n(areset_n_net),
        .aclk(aclk_net),
        .histo_data_i(histo_data_o),
        .histo_data_valid(histo_data_valid),
        .histo_data_last(histo_data_last),
        .tready(tready),
        .tdata(tdata_net),
        .tvalid(tvalid_net),
        .tlast(tlast_net),
        .tready_o(tready_net),
        .interrupt_out(interrupt_net)
    );
    
assign  rready = rready_net;
assign  tdata = tdata_net;
assign  tvalid = tvalid_net;      
assign  tlast = tlast_net;      
assign  interrupt_out = interrupt_net;
    
endmodule
