`include "defines.vh"
module ex(
    input wire      rst,

    input wire[`InstAddrBus]    pc_i,
    input wire[`OpcodeBus]      opcode_i,
    input wire[`Func3Bus]       func3_i,
    input wire[`Func7Bus]       func7_i,
    input wire[`RegBus]         imm_i,
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,
    input wire[`InstAddrBus]    br_addr_i,
    input wire[`InstAddrBus]    br_offset,

    output reg                  ifload_o,
    output reg[`OpcodeBus]      opcode_o,
    output reg[`Func3Bus]       func3_o,
    output reg[`InstAddrBus]    mem_addr_o,
    output reg[`RegBus]         store_data_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,

    output reg  ifjump,
    output reg[`InstAddrBus]    pc_jump_o
    
);


    reg[`RegBus]            ans;


    always @(*) begin
        if (rst == `RstEnable) begin
            opcode_o <= `OP_NON;
            func3_o <= `NON_FUNCT3;
            ans <= `ZeroWord;
            mem_addr_o <= `ZeroWord;
            store_data_o <= `ZeroWord;
            pc_jump_o <= `ZeroWord;
            ifjump <= 1'b0;
            ifload_o <= 1'b0;
        end else begin
            opcode_o <= opcode_i;
            func3_o <= func3_i;
            ans <= `ZeroWord;  
            mem_addr_o <= `ZeroWord;
            store_data_o <= `ZeroWord;
            ifload_o <= 1'b0;
            pc_jump_o <= `ZeroWord;
            ifjump <= 1'b0;
            case (opcode_i)
                `OP_JAL:   begin
                    ans <= pc_i + 4;
                    ifjump <= 1'b1;
                    pc_jump_o <= br_addr_i + br_offset;
                end
                `OP_JALR: begin
                    ans <= pc_i + 4;
                    ifjump <= 1'b1;
                    pc_jump_o <= br_addr_i + br_offset;
                end
                `OP_BRANCH: begin
                    pc_jump_o <= br_addr_i + br_offset;
                    case (func3_i)
                        `BEQ_FUNCT3:   begin
                            if (reg1_i == reg2_i) begin
                                ifjump <= 1'b1;
                            end
                        end
                        `BNE_FUNCT3:   begin
                            if (reg1_i != reg2_i) begin
                                ifjump <= 1'b1;
                            end
                        end
                        `BLT_FUNCT3:   begin
                            if ($signed(reg1_i) < $signed(reg2_i)) begin
                                ifjump <= 1'b1;
                            end
                        end
                        `BGE_FUNCT3:   begin
                            if ($signed(reg1_i) >= $signed(reg2_i)) begin
                                ifjump <= 1'b1;
                            end
                        end
                        `BLTU_FUNCT3:   begin
                            if (reg1_i < reg2_i) begin
                                ifjump <= 1'b1;
                            end
                        end
                        `BGEU_FUNCT3:   begin
                            if (reg1_i >= reg2_i) begin
                                ifjump <= 1'b1;
                            end
                        end
                     endcase
                 end
                `OP_LUI: begin
                    ans <= imm_i;
                end
                `OP_AUIPC: begin
                    ans <= imm_i + pc_i;
                end
                `OP_OP_IMM: begin
                    case (func3_i)
                        `ADDI_FUNCT3: begin
                            ans <= reg1_i + imm_i;
                        end
                        `SLTI_FUNCT3: begin
                            ans <= $signed(reg1_i) < $signed(imm_i) ? 32'b1 : 32'b0;
                        end
                        `SLTIU_FUNCT3: begin
                            ans <= reg1_i < imm_i ? 32'b1 : 32'b0;
                        end
                        `XORI_FUNCT3: begin
                            ans <= reg1_i ^ imm_i;
                        end
                        `ANDI_FUNCT3: begin
                            ans <= reg1_i & imm_i;
                        end
                        `ORI_FUNCT3: begin
                            ans <= reg1_i | imm_i;
                        end
                        `SLLI_FUNCT3: begin
                            ans <= reg1_i << imm_i[4:0];
                        end
                        `SRLI_SRAI_FUNCT3: begin
                            if (func7_i == `SRL_FUNCT7) begin
                                ans <= reg1_i >> imm_i[4:0];
                            end else begin
                                ans <= $signed(reg1_i) >> imm_i[4:0];
                            end
                        end                            
                        default: begin
                        end
                    endcase
                end
                `OP_OP: begin
                    case (func3_i)
                        `ADD_SUB_FUNCT3: begin
                            if (func7_i == `ADD_FUNCT7) begin
                                ans <= reg1_i + reg2_i;
                            end else begin
                                ans <= reg1_i - reg2_i;
                            end
                        end
                        `SLL_FUNCT3: begin
                            ans <= reg1_i << reg2_i[4:0];
                        end
                        `SLT_FUNCT3: begin
                            ans <= $signed(reg1_i) < $signed(reg2_i) ? 32'b1 : 32'b0;
                        end
                        `SLTU_FUNCT3: begin
                            ans <= reg1_i < reg2_i ? 32'b1 : 32'b0;
                        end
                        `XOR_FUNCT3: begin
                            ans <= reg1_i ^ reg2_i;
                        end
                        `OR_FUNCT3: begin
                            ans <= reg1_i | reg2_i;
                        end
                        `SRL_SRA_FUNCT3: begin
                            if (func7_i == `SRL_FUNCT7) begin
                                ans <= reg1_i >> reg2_i[4:0];
                            end else begin
                                ans <= $signed(reg1_i) >> reg2_i[4:0];
                            end
                        end
                        `AND_FUNCT3: begin
                            ans <= reg1_i & reg2_i;
                        end
                    endcase
                end
                `OP_LOAD: begin
                    ifload_o <= 1'b1;
                    mem_addr_o <= reg1_i + imm_i;
                    ans <= reg1_i + imm_i;
                end
                `OP_STORE: begin
                    mem_addr_o <= reg1_i + imm_i;
                    ans <= reg1_i + imm_i;
                    store_data_o <= reg2_i;  
                end        
                default:    begin
                end 
            endcase
        end
    end



    always @(*) begin
        if (rst == `RstEnable) begin
            wd_o <= `ZeroWord;
            wreg_o <= 1'b0;
            wdata_o <= `ZeroWord;
        end else begin
            wd_o <= wd_i;
            wdata_o <= ans;
            wreg_o <= wreg_i;
        end
    end

endmodule // ex
