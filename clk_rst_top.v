//This module circulates the reset and clock for the axi_stream_tx_block, histogram_calcilation, and axistream_rx_block
`timescale 1ns/1ps

module clk_rst_top (
    input   wire aclk_i,
    input   wire areset_n_i,
    input   wire areset_n_i_sync,
    output  wire aclk_o,
    output  wire areset_n_o
    //output  wire areset_n_o_sync
); 

//reg areset_n_q;
//reg areset_n_qq;
reg areset_n;
//reg areset_n_sync_qq;


//reset_bridge circuit
//always @ (posedge aclk_i or negedge areset_n_i)
//    begin
//        if(areset_n_i == 1'b0)
//            begin
//                areset_n_q <= 1'b0;
//                areset_n_qq <= 1'b0;
//            end
//        else
//            begin
//                areset_n_q  <= 1'b1;
//                areset_n_qq <= areset_n_q;
//            end
//    end

//routing to sync reset
always @ (posedge aclk_i or negedge areset_n_i)
        begin
            if(areset_n_i == 1'b0)
                begin
                    areset_n    <= 1'b0;
                end
            else
                begin
                    areset_n   <=  areset_n_i_sync;
                end
        end

 assign  aclk_o             = aclk_i;
 assign  areset_n_o         = areset_n;
 //assign  areset_n_o_sync    = areset_n_sync_qq;      



endmodule