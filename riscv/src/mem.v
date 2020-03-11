`include "defines.vh"
module mem(
    
    input wire      rst,

    //from ex_mem 
    input wire[`OpcodeBus]      opcode_i,
    input wire[`Func3Bus]       func3_i,
    
    input wire[`InstAddrBus]    mem_addr_i,
    input wire[`RegBus]         store_data_i,


    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,
    input wire[`RegBus]         wdata_i,
    
    //input from memory_control
    input wire                  mc_mem_busy_i,
    input wire                  mc_inst_busy_i,
    input wire                  mc_mem_enable_i,
    input wire[`RegBus]         mc_mem_data_i,

    //output to memory_control
    output reg                  mc_mem_enable_o,
    output reg                  mc_mem_wr_o,
    output reg[`RegBus]         mc_mem_addr_o,
    output reg[2:0]             mc_mem_width_o,
    output reg[`RegBus]         mc_mem_data_o,             
    

    //to writeback 
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,

    //control
    output reg                  mem_stall_req_o            
    
);


always @(*) begin
    mc_mem_enable_o <= 1'b0;
    mc_mem_wr_o <= 1'b0;
    mc_mem_data_o <= `ZeroWord;
    mc_mem_addr_o <= `ZeroWord;
    mc_mem_width_o <= 0;
    mem_stall_req_o <= 1'b0;
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    wdata_o <= `ZeroWord;
    if (rst == `RstEnable) begin
        wreg_o <= `WriteDisable;
        wd_o <= `NOPRegAddr;
    end else if (opcode_i == `OP_LOAD) begin
        if (mc_mem_enable_i) begin
            if (func3_i == `LW_FUNCT3) begin
                wdata_o <= mc_mem_data_i;
            end else if (func3_i == `LHU_FUNCT3) begin
                wdata_o <= {16'b0, mc_mem_data_i[15:0]};
            end else if (func3_i == `LH_FUNCT3) begin
                wdata_o <= {{16{mc_mem_data_i[15]}}, mc_mem_data_i[15:0]};
            end else if (func3_i == `LBU_FUNCT3) begin
                wdata_o <= {16'b0, mc_mem_data_i[7:0]};
            end else if (func3_i == `LB_FUNCT3) begin
                wdata_o <= {{24{mc_mem_data_i[7]}}, mc_mem_data_i[7:0]};
            end
        end else begin
            mem_stall_req_o <= 1'b1;
            if (!mc_mem_busy_i) begin
                mc_mem_enable_o <= 1'b1;
                mc_mem_addr_o <= mem_addr_i;
                if (func3_i == `LW_FUNCT3) begin
                    mc_mem_width_o <= 3'b100;
                end else if (func3_i == `LH_FUNCT3 || func3_i == `LHU_FUNCT3) begin
                    mc_mem_width_o <= 3'b010;
                end else if (func3_i == `LB_FUNCT3 || func3_i == `LBU_FUNCT3) begin
                    mc_mem_width_o <= 3'b001;
                end
            end
        end
    end else if (opcode_i == `OP_STORE) begin
        if (!mc_mem_enable_i) begin
            mem_stall_req_o <= 1'b1;
            if (!mc_mem_busy_i) begin
                mc_mem_enable_o <= 1'b1;
                mc_mem_wr_o <= 1'b1;
                mc_mem_addr_o <= mem_addr_i;
                if (func3_i == `SW_FUNCT3) begin
                    mc_mem_data_o <= store_data_i;
                    mc_mem_width_o <= 3'b100;
                end else if (func3_i == `SH_FUNCT3) begin
                    mc_mem_data_o <= store_data_i[15:0];
                    mc_mem_width_o <= 3'b010;
                end else if (func3_i == `SB_FUNCT3) begin
                    mc_mem_data_o <= store_data_i[7:0];
                    mc_mem_width_o <= 3'b001;
                end
            end
        end
    end else begin
        wdata_o <= wdata_i;
    end
end



//         if (mc_mem_busy_i) begin
//             mc_mem_enable_o <= 1'b0;
//             mc_mem_wr_o <= 1'b0;
//             mc_mem_addr_o <= `ZeroWord;
//             mc_mem_width_o <= 0;
//             mc_mem_data_o <= `ZeroWord;
//             mem_stall_req_o <= 1'b1;
//             wd_o <= `NOPRegAddr;
//             wreg_o <= `WriteDisable;
//             wdata_o <= `ZeroWord;
//         end else if (opcode_i == `OP_LOAD) begin
//             mc_mem_data_o <= `ZeroWord;
//             wd_o <= wd_i;
//             mc_mem_wr_o <= 1'b0;
//             if (mc_mem_enable_i == 1'b1) begin
//                 mc_mem_enable_o <= 1'b0;
//                 mc_mem_addr_o <= `ZeroWord;
//                 mc_mem_width_o <= 0;
//                 mem_stall_req_o <= 1'b0;
//                 wreg_o <= wreg_i;
//                 if (func3_i == `LW_FUNCT3) begin
//                     wdata_o <= mc_mem_data_i;
//                 end else if (func3_i == `LHU_FUNCT3) begin
//                     wdata_o <= {16'b0, mc_mem_data_i[15:0]};
//                 end else if (func3_i == `LH_FUNCT3) begin
//                     wdata_o <= {{16{mc_mem_data_i[15]}}, mc_mem_data_i[15:0]};
//                 end else if (func3_i == `LBU_FUNCT3) begin
//                     wdata_o <= {16'b0, mc_mem_data_i[7:0]};
//                 end else if (func3_i == `LB_FUNCT3) begin
//                     wdata_o <= {{24{mc_mem_data_i[7]}}, mc_mem_data_i[7:0]};
//                 end
//             end else begin
//                 wreg_o  <= 1'b0;
//                 mem_stall_req_o <= 1'b1;
//                 wdata_o <= `ZeroWord;
//                 mc_mem_enable_o <= 1'b1;
//                 mc_mem_addr_o <= mem_addr_i;
//                 if (func3_i == `LW_FUNCT3) begin
//                     mc_mem_width_o <= 3'b100;
//                 end else if (func3_i == `LH_FUNCT3 || func3_i == `LHU_FUNCT3) begin
//                     mc_mem_width_o <= 3'b010;
//                 end else if (func3_i == `LB_FUNCT3 || func3_i == `LBU_FUNCT3) begin
//                     mc_mem_width_o <= 3'b001;
//                 end
//             end
//         end else if (opcode_i == `OP_STORE) begin
//             wd_o <= `NOPRegAddr;
//             wreg_o <= wreg_i;
//             wdata_o <= `ZeroWord;
//             if (mc_mem_enable_i == 1'b1) begin
//                 mc_mem_enable_o <= 1'b0;
//                 mc_mem_wr_o <= 1'b0;
//                 mc_mem_addr_o <= `ZeroWord;
//                 mc_mem_width_o <= 0;
//                 mc_mem_data_o <= `ZeroWord;
//                 mem_stall_req_o <= 1'b0;
//             end else begin
//                 mem_stall_req_o <= 1'b1;
//                 mc_mem_enable_o <= 1'b1;
//                 mc_mem_wr_o <= 1'b1;
//                 mc_mem_addr_o <= mem_addr_i;
//                 if (func3_i == `SW_FUNCT3) begin
//                     mc_mem_data_o <= store_data_i;
//                     mc_mem_width_o <= 3'b100;
//                 end else if (func3_i == `SH_FUNCT3) begin
//                     mc_mem_data_o <= store_data_i[15:0];
//                     mc_mem_width_o <= 3'b010;
//                 end else if (func3_i == `SB_FUNCT3) begin
//                     mc_mem_data_o <= store_data_i[7:0];
//                     mc_mem_width_o <= 3'b001;
//                 end
//             end
//         end
//     end else begin
//         wdata_o <= wdata_i;
//     end

// end

endmodule // me
