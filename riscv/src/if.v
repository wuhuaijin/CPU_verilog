`include "defines.vh"
module If(
    input wire               rst,

    input wire[`StallBus]       stall_i,

    //input from pc_reg
    input wire[`InstAddrBus] pc_i,
    input wire               pc_enable_i, 

    //output to if_id
    output reg[`InstAddrBus] pc_o,
    output reg[`InstBus]     inst_o,
    
    //input from i_cache
    input wire              mc_inst_enable_i,
    input wire[`InstBus]    mc_inst_data_i,                                                                           

    //output to i_cache
    output reg               mc_inst_enable_o,
    output reg[`InstAddrBus] mc_inst_addr_o,

    output wire                if_stall_req_o
);

assign if_stall_req_o = pc_enable_i && !mc_inst_enable_i;

always @(*) begin
    if (rst == `RstEnable || !pc_enable_i) begin
        pc_o <= `ZeroWord;
        mc_inst_addr_o <= `ZeroWord;
        mc_inst_enable_o <= 1'b0;
    end else begin
        pc_o <= pc_i;
        mc_inst_enable_o <= 1'b1;
        mc_inst_addr_o <= pc_i;
    end
    if (!rst && mc_inst_enable_i) begin
        inst_o <= mc_inst_data_i;
    end else begin
        inst_o <= `ZeroWord;
    end

end






// always @(*) begin
//     if (rst == `RstEnable || ifjump_i == 1'b1 || (mem_if_signal_i == 1'b0 && mc_mem_busy_i == 1'b1)) begin
//         pc_o <= `ZeroWord;
//         inst_o <= `ZeroWord;
//         inst_enable_o <= 1'b0;
//         mc_inst_enable_o <= 1'b0;
//         mc_inst_addr_o <= `ZeroWord;
//         if_stall_req_o <= 1'b0;
//     end else if (mem_if_signal_i) begin
//         pc_o <= `ZeroWord;
//         inst_o <= `ZeroWord;
//         inst_enable_o <= 1'b0;
//         mc_inst_enable_o <= 1'b0;
//         mc_inst_addr_o <= `ZeroWord;
//         if_stall_req_o <= 1'b1;
//     end else if (mc_inst_enable_i) begin
//         pc_o <= pc_i;
//         inst_o <= mc_inst_data_i;
//         inst_enable_o <= 1'b1;
//         mc_inst_enable_o <= 1'b0;
//         mc_inst_addr_o <= pc_i;
//         if_stall_req_o <= 1'b0;
//     end else begin
//         pc_o <= `ZeroWord;
//         inst_o <= `ZeroWord;
//         inst_enable_o <= 1'b0;
//         mc_inst_enable_o <= 1'b1;
//         mc_inst_addr_o <= pc_i;
//         if_stall_req_o <= 1'b1;   
//     end

// end



endmodule // IF