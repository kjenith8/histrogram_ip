// This test bench code stimulate the required input for clk_rst_top.v file
`timescale 1ns/1ps

module clk_rst_top_tb();

//specifying the clk_period
localparam clk_period = 10;

//input ports
reg tb_aclk_i = 1'b0;
reg areset_n_i = 1'b0;
reg areset_n_i_sync = 1'b0;

// ouput ports
wire aclk_o;
wire areset_n_o;

// clk_generation

initial
    begin
        forever
            begin
               #(clk_period) tb_aclk_i = ~ tb_aclk_i;
            end
    end

// areset_n generation
initial
    begin
        areset_n_i  = 1'b0;
        areset_n_i_sync = 1'b0;
        if(areset_n_o == 1'b1)
            begin
                $display("For areset_n_i %b and areset_n_i_sync %b,Reset should be asserted,but it is de-asserted. Error",areset_n_i, areset_n_i_sync);
                $finish;
            end
        #(10*clk_period);
        areset_n_i  = 1'b1;
        areset_n_i_sync = 1'b0;
         if(areset_n_o == 1'b1)
            begin
                $display("For areset_n_i %b and areset_n_i_sync %b,Reset should be asserted,but it is de-asserted. Error",areset_n_i, areset_n_i_sync);
                $finish;
            end       
        #(10*clk_period);
        areset_n_i  = 1'b0;
        areset_n_i_sync = 1'b1;
        if(areset_n_o == 1'b1)
            begin
                $display("For areset_n_i %b and areset_n_i_sync %b,Reset should be asserted,but it is de-asserted. Error",areset_n_i, areset_n_i_sync);
                $finish;
            end
        #(10*clk_period);
        areset_n_i  = 1'b1;
        areset_n_i_sync = 1'b1;
        if(areset_n_o == 1'b0)
            begin
                $display("For areset_n_i %b and areset_n_i_sync %b,Reset should be de-asserted,but it is asserted. Error",areset_n_i, areset_n_i_sync);
                $finish;
            end
        else
            begin
                $display("Simulation is successful");
            end
    end

clk_rst_top DUT (
    .aclk_i(tb_aclk_i),
    .areset_n_i(areset_n_i),
    .areset_n_i_sync(areset_n_i_sync),
    .aclk_o(aclk_o),
    .areset_n_o(areset_n_o)
);

endmodule
