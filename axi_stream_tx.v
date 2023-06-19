//This modules is to transmit the histogram calculated values as per the axi-stream rx protocol

module axi_stream_tx
    #(
        parameter P_DW  = 8
    )
    (
    input wire areset_n,
    input wire aclk,
// histogram_block ports
    input wire [P_DW-1 : 0] histo_data_i,
    input wire histo_data_valid,
    input wire histo_data_last,
    output wire tready_o,
 //axi_sream tx ports,
    input wire tready,
    output wire [P_DW-1 : 0]tdata,
    output wire tvalid,
    output wire tlast,
// interrupt ports
    output wire interrupt_out
    );

reg [P_DW-1 : 0] tdata_q;
reg tvalid_q;
reg tlast_q;
reg tready_q;
reg tx_done_q;
reg interrupt_out_q;
wire tx_done_nxt;

//For reseting the axi-stream transmit signals
// It is just connecting the histogram data into corresponding axi-stream protocol ports

always @ (posedge aclk or negedge areset_n)
    begin
        if(areset_n == 1'b0)
            begin
               tdata_q    <= 'b0; ///Width can't be the more than 10bits 
               tvalid_q   <= 1'b0;
               tlast_q    <= 1'b0;
               interrupt_out_q  <= 1'b0;
            end
            else
            begin
                tdata_q     <= histo_data_i;
                tvalid_q  <= histo_data_valid;
                tlast_q   <= histo_data_last;
                interrupt_out_q <= tlast_q;
            end
    end

//output port assignements

assign tdata = tdata_q;
assign tvalid = tvalid_q;
assign tlast  = tlast_q;
assign tready_o = tready;
assign interrupt_out = interrupt_out_q;

endmodule


