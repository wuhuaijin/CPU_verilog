`include "defines.vh"
module id_ex(
    input wire clk,
    input wire rst,
    //input from id
    input wire[`InstAddrBus]id_pc,

    input wire[`OpcodeBus]  id_opcode,
    input wire[`Func3Bus]   id_func3,
    input wire[`Func7Bus]   id_func7,
    
    input wire[`RegBus]     id_imm,
    input wire[`RegBus]     id_reg1,
    input wire[`RegBus]     id_reg2,
    input wire[`RegAddrBus] id_wd,
    input wire              id_wreg,
    input wire[31:0]        id_br_addr,
    input wire[31:0]        id_br_offset,

    input wire[`StallBus]   stall_i,
    //output to ex
    output reg[`InstAddrBus]ex_pc,
    output reg[`OpcodeBus]  ex_opcode,
    output reg[`Func3Bus]   ex_func3,
    output reg[`Func7Bus]   ex_func7,
    output reg[`InstAddrBus]ex_imm,
    output reg[`RegBus]     ex_reg1,
    output reg[`RegBus]     ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg              ex_wreg,
    output reg[31:0]        ex_br_addr,
    output reg[31:0]        ex_br_offset,

    input wire jump
    
);


    always @(posedge clk) begin
        if (rst == `RstEnable || jump || (stall_i[2] && !stall_i[3])) begin
            ex_pc<= `ZeroWord;
            ex_opcode <= `OP_NON;
            ex_func3 <= `NON_FUNCT3;
            ex_func7 <= `NON_FUNCT7;
            ex_imm <= `ZeroWord;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_br_offset <= `ZeroWord;
            ex_br_addr <= `ZeroWord;
        end else if (!stall_i[2]) begin
            ex_pc <= id_pc;
            ex_opcode <= id_opcode;
            ex_func3 <= id_func3;
            ex_func7 <= id_func7;
            ex_imm <= id_imm;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_br_offset <= id_br_offset;
            ex_br_addr <= id_br_addr;
        end
    end

endmodule // id_ex
