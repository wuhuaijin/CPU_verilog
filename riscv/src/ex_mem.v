`include "defines.vh"
module ex_mem(

    input wire      clk,
    input wire      rst,

    input wire[`StallBus]       stall_i,


    input wire[`OpcodeBus]      ex_opcode,
    input wire[`Func3Bus]       ex_func3,
    input wire[`InstAddrBus]    ex_mem_addr,
    input wire[`RegBus]         ex_store_data,


    input wire[`RegAddrBus]     ex_wd,
    input wire                  ex_wreg,
    input wire[`RegBus]         ex_wdata,

    output reg[`OpcodeBus]      mem_opcode,
    output reg[`Func3Bus]       mem_func3,
    output reg[`InstAddrBus]    mem_mem_addr,
    output reg[`RegBus]         mem_store_data,
    output reg[`RegAddrBus]     mem_wd,
    output reg                  mem_wreg,
    output reg[`RegBus]         mem_wdata
    
);

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            mem_opcode <= `OP_NON;
            mem_func3 <= `NON_FUNCT3;
            mem_mem_addr <= `ZeroWord;
            mem_store_data <= `ZeroWord;
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
        end else if (!stall_i[3]) begin
            mem_opcode <= ex_opcode;
            mem_func3 <= ex_func3;
            mem_mem_addr <= ex_mem_addr;
            mem_store_data <= ex_store_data;
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
        end
    end

endmodule // ex_mem