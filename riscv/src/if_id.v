`include "defines.vh"

module if_id(
    input wire          clk,
    input wire          rst,

    input wire[`StallBus]       stall_i,
    input wire                  jump,

    input wire[`InstAddrBus]       if_pc,
    input wire[`InstBus]           if_inst,

    output reg[`InstAddrBus]      id_pc,
    output reg[`InstBus]          id_inst
);


// reg[`InstAddrBus] pc_tmp;
// reg[`InstBus]   inst_tmp;
 
//     always @(*) begin
//         if (rst == `RstEnable) begin
//             pc_tmp <= `ZeroWord;
//             inst_tmp <= `ZeroWord;
//         end else if (inst_enable_i == 1'b1) begin
//             pc_tmp <= if_pc;
//             inst_tmp <= if_inst;
//         end
//     end
    
    always @(posedge clk) begin
        if (rst == `RstEnable || jump ||  (stall_i[1] && !stall_i[2])) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (!stall_i[1]) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
        
    end

endmodule // if_id