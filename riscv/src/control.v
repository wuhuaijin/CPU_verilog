`include "defines.vh"
module control(
    input wire               clk,
    input wire               rst,

    input wire               stall_from_if_i,
    input wire               stall_from_mem_i,
    input wire               stall_from_id_i,
    
    output reg[`StallBus]    stall                 
);

always @(*) begin
    if (rst) begin
        stall <= 5'b00000;
    end else if (stall_from_mem_i) begin
        stall <= 5'b11111;
    end else if (stall_from_id_i) begin
        stall <= 5'b00111;
    end else if (stall_from_if_i) begin
        stall <= 5'b00011;
    end else begin
        stall <= 5'b00000;
    end
end

endmodule //