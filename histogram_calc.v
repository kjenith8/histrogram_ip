`timescale 1ns / 1ps

//This module performs the histogram calculation and put it in a array, and sent it to a axi_stream_tx block as per axi_stream protocol

module histogram_calc
    #(
        parameter P_DW  = 2,
        parameter [P_DW:0]P_NUM_BIN = 4 
    )
    (
    input wire areset_n,
    input wire aclk,
//axi_stream_rx ports
    input wire [P_DW-1 : 0]histo_data_i,
    input wire rx_valid,
    input wire rx_done,
    output wire histo_ready,
//axi_stream_rx ports    
    input wire tready,
    output wire [P_DW-1 : 0]histo_data_o,
    output wire histo_data_valid,
    output wire histo_data_last
    );

//div_factor is used to store the resultant value into array
    localparam  div_factor = P_DW ** 2 / P_NUM_BIN ; 
//state assignement   
    localparam  not_ready_st   = 1'b0;
    localparam  ready_st   = 1'b1;
    
// these are fsm signals   
    reg addr_pointer_cstate = not_ready_st;
    reg addr_pointer_nstate = not_ready_st;    
    reg histo_ready_cstate  = ready_st;
    reg histo_ready_nstate  = ready_st;
      
//array declaration for storig the histogram calculated data
    reg [P_DW-1 : 0] tdata_array_nxt [P_NUM_BIN-1 : 0] ;
    reg [P_DW-1 : 0] tdata_array_q [P_NUM_BIN-1 : 0] ;   
    reg [$clog2(P_NUM_BIN):0] i;
//address_pinter signals
    reg [$clog2(P_NUM_BIN)-1:0] addr_pointer_nxt;
    reg [$clog2(P_NUM_BIN)-1:0] addr_pointer_q = P_NUM_BIN-1;
    wire histo_data_valid_nxt;
    wire histo_data_last_nxt;
    
//to reset the array once tx_done is asserted
    wire tx_done;
    reg rx_done_r = 1'b0;
//axi_stream_rx rready signals
    reg histo_ready_q;
    wire histo_ready_nxt;
    
//-----------------------------Histogram_calculation_block---------------------------------------
//histogram calculation procedural block
// this block performs the histogram calculation, and it stores the value in tdata_array_q
// when tx_done is asserted, this block will clear the all content of the array.
// whenever r_valid is high, It would start performing the histogram calculation
 
    always@(*)
        begin
            for (i = 'b0 ; i < P_NUM_BIN; i= i + 1'b1)
                   tdata_array_nxt[i] = tdata_array_q[i];

            if(tx_done == 1'b1)
                begin
                    for (i = 'b0 ; i < P_NUM_BIN; i= i + 1'b1)
                            tdata_array_nxt[i] <='b0;
                end
            else if (rx_valid == 1'b1 && histo_ready_q == 1'b1)
                begin
                        for (i = 'b0 ;i < P_NUM_BIN; i= i+ 1'b1) 
                            begin
                                if(i == histo_data_i / div_factor)
                                        tdata_array_nxt[i] <= tdata_array_q[i] + 1'b1;
                            end
                end

        end
          
//The histogram resultant value will be registered/stored by this block

    always @(posedge aclk or negedge areset_n)
        begin
            if(!areset_n)
                begin
                    for (i = 'b0; i < P_NUM_BIN ; i= i+ 1'b1)
                            tdata_array_q[i] <='b0;
                end
            else
                begin
                    for (i = 'b0 ; i < P_NUM_BIN; i= i + 1'b1)
                        tdata_array_q[i] <=tdata_array_nxt[i];
                end
        end
//-----------------------------Histogram_calculation_block----------------------------------------

//-----------------------------address_pointer generation block---------------------------------------
// this  blocks is used to pump out the data based on address pointer generated from the  tdata_array_q     
// during ready state, pointer will be incremented based on rx_done == 1'b1 and tready == 1'b1 signal

    always @(*)
        begin
            case (addr_pointer_cstate) 
                not_ready_st :
                    begin
                        if(rx_done_r == 1'b1 && tready == 1'b1) 
                                addr_pointer_nstate = ready_st;
                        else
                                addr_pointer_nstate = addr_pointer_cstate;
                    end
               ready_st :
                       begin
                            if(addr_pointer_q == P_NUM_BIN-1)
                                   addr_pointer_nstate = not_ready_st;
                            else
                                 addr_pointer_nstate = addr_pointer_cstate;
                       end
               default : addr_pointer_nstate = 1'bx;
             endcase
       end       
 // this blocks generates the correct address pointer to pumb-out the data
 // based on these pointer values, histo_data_valid, histo_data_last are being generated
       
         always @(posedge aclk or negedge areset_n)
                begin
                    if(!areset_n)
                        begin
                            addr_pointer_cstate = not_ready_st;
                            addr_pointer_q  <= P_NUM_BIN-1;
                        end
                    else
                        begin
                            addr_pointer_cstate = addr_pointer_nstate;
                             if(tready == 1'b0)
                                addr_pointer_q <= addr_pointer_q;
                             else if(addr_pointer_cstate == ready_st)
                                addr_pointer_q <= addr_pointer_q + 1'b1;
                             else
                                 addr_pointer_q = P_NUM_BIN-1;
                        end
                 end
                 
 assign histo_data_valid_nxt  = addr_pointer_cstate == ready_st  ? 1'b1 : 1'b0;
assign histo_data_last_nxt  = ((addr_pointer_cstate == ready_st) && (addr_pointer_q == P_NUM_BIN -1)) ? 1'b1 : 1'b0;

//-----------------------------address_pointer generation block---------------------------------------

//-----------------------------histo_ready generation block---------------------------------------
                                                       
assign tx_done = ((addr_pointer_cstate == ready_st) && (addr_pointer_q == P_NUM_BIN -1)) ? 1'b1 : 1'b0;

//based on rx_done and tx_done, state will swing from ready_st to not_ready_st or not_ready_st to ready_st 

always @(*)
    begin
        case (histo_ready_cstate)
            ready_st :
                    begin
                        if (rx_done == 1'b1)
                            begin
                               histo_ready_nstate = not_ready_st;
                               rx_done_r        = 1'b1;
                           end
                        else
                            begin
                               histo_ready_nstate = histo_ready_cstate;
                               rx_done_r       = 1'b0;
                            end
                     end
             not_ready_st :
                        begin
                            if (tx_done == 1'b1)
                                begin
                                    histo_ready_nstate = ready_st;
                                    rx_done_r = 1'b0;
                                end
                            else
                                begin
                                    histo_ready_nstate = histo_ready_cstate;
                                    rx_done_r = 1'b1;
                                end
                        end
             default : histo_ready_nstate = 1'bx;
        endcase
     end
     
assign histo_ready_nxt = (histo_ready_cstate == ready_st) ? 1'b1 : 1'b0;
               
always @(posedge aclk or negedge areset_n)
        begin
            if (! areset_n)
                begin
                    histo_ready_cstate  = ready_st;
                    histo_ready_q       = 1'b0;
                end
            else
                begin
                    histo_ready_cstate = histo_ready_nstate;
                    histo_ready_q   = histo_ready_nxt;
                end
            end
         
//-----------------------------histo_ready generation block---------------------------------------

///output ports assignment

assign histo_data_valid  = histo_data_valid_nxt;
assign histo_data_last  = histo_data_last_nxt;
assign histo_data_o   = addr_pointer_cstate == ready_st  ? tdata_array_q[addr_pointer_q] : 'b0;
assign histo_ready = histo_ready_q;

endmodule



   