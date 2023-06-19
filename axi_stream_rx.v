//This modules is to receive the user data as per the axi-stream tx protocol

module axi_stream_rx
    #(
        parameter P_DW  = 8
    )
    (
    input wire areset_n,
    input wire aclk,
//axi_stream_rx ports
    input wire [P_DW-1 : 0] rdata,
    input wire rvalid,
    input wire rlast,
    output wire rready,
//histogram block ports    
    input wire histo_ready,
    output wire [P_DW-1 : 0]histo_data_i,
    output wire rx_valid,
    output wire rx_done
    );

reg [P_DW-1 : 0] rdata_q;
reg rvalid_q;
reg rlast_q;
reg ready_q;

//For resetting the axi-stream received signals
// this blocks is just a wiring block

always @ (posedge aclk or negedge areset_n)
    begin
        if(areset_n == 1'b0)
            begin
               rdata_q    <= 'b0; ///Width can't be the more than 10bits 
               rvalid_q   <= 1'b0;
               rlast_q    <= 1'b0;
            end
            else
            begin
                rdata_q     <= rdata;
                rvalid_q  <= rvalid;
                rlast_q   <= rlast;
            end
    end
//output ports assignment
assign rready = histo_ready;
assign histo_data_i = rdata_q;
assign rx_valid = rvalid_q;
assign rx_done  = rlast_q;

endmodule


