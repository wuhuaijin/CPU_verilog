`timescale 1ns/1ps
`include "defines.vh"
module pc_reg(
    input wire          clk,
    input wire          rst,

    input wire[`StallBus] stall_signal_i,

    input wire          ifjump_i,
    input wire[`InstAddrBus] pc_i,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    output reg[`InstAddrBus] pc_o,
    output reg               pc_enable
);

    reg[`InstAddrBus]   pc_tmp;
    
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            pc_tmp <= 1'b0;
            pc_enable <= 1'b0;
        end else begin
            pc_enable <= 1'b1;
            if (ifjump_i) begin
                pc_tmp <= pc_i + 4;
                pc_o <= pc_i;
            end else if (!stall_signal_i[0]) begin
                pc_tmp <= pc_tmp + 4;
                pc_o <= pc_tmp;
            end
        end
    end


endmodule // pc_reg