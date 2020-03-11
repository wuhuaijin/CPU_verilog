`include "defines.vh"

module id(
    input wire      rst,
    input wire[`InstAddrBus]        pc_i,
    input wire[`InstBus]            inst_i,

    input wire[`RegBus]             reg1_data_i,
    input wire[`RegBus]             reg2_data_i,

    output reg                      reg1_read_o,
    output reg                      reg2_read_o,
    output reg[`RegAddrBus]         reg1_addr_o,
    output reg[`RegAddrBus]         reg2_addr_o,

    //ex data forwarding
    input wire                      ex_wreg_i,
    input wire[`RegBus]             ex_wdata_i,
    input wire[`RegAddrBus]         ex_wd_i,
    //mem data forwarding
    input wire                      mem_wreg_i,
    input wire[`RegBus]             mem_wdata_i,
    input wire[`RegAddrBus]         mem_wd_i,

    //data hazard by LOAD
    input wire                      if_load,

    output reg[`InstAddrBus]        pc_o, 
    output reg[`OpcodeBus]          opcode_o,
    output reg[`Func3Bus]           func3_o,
    output reg[`Func7Bus]           func7_o,

    output reg[`RegBus]             reg1_o,
    output reg[`RegBus]             reg2_o,
    
    output reg[`RegAddrBus]         wd_o,
    output reg                      wreg_o,
    output reg[`RegBus]             imm_o,

    output reg[`InstAddrBus]        br_addr,
    output reg[`InstAddrBus]        br_offset,

    output reg                      id_stall_req_o
    
);

    wire[`OpcodeBus]                opcode = inst_i[6:0];
    wire[`Func3Bus]                 func3 = inst_i[14:12];
    wire[`Func7Bus]                 func7 = inst_i[31:25];


    reg           instvalid;


    always @(*) begin
        if (rst == `RstEnable) begin
            opcode_o <= `OP_NON;
            func3_o <= `NON_FUNCT3;
            func7_o <= `NON_FUNCT7;
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            instvalid <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm_o  <= `ZeroWord;
            pc_o <= `ZeroWord;
            br_addr <= `ZeroWord;
            br_offset <= `ZeroWord;
        end else begin
            opcode_o <= `OP_NON;
            func3_o <= `NON_FUNCT3;
            func7_o <= `NON_FUNCT7;
            wd_o <= inst_i[11:7];
            wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[19:15];
            reg2_addr_o <= inst_i[24:20];
            imm_o <= `ZeroWord;
            pc_o <= pc_i;
            br_addr <= `ZeroWord;
            br_offset <= `ZeroWord;
            case (opcode)
                `OP_JAL:   begin
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_JAL;
                    imm_o <= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                    instvalid <= `InstValid;
                    br_addr <= pc_i;
                    br_offset <= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                end
                `OP_JALR:   begin
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_JALR;
                    reg1_read_o <= 1'b1;
                    imm_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                    instvalid <= `InstValid;
                    br_addr <= reg1_o;
                    br_offset <= {{20{inst_i[31]}}, inst_i[31:20]};
                end
                `OP_OP_IMM:   begin
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_OP_IMM;
                    reg1_read_o <= 1'b1;
                    imm_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                    instvalid <= `InstValid;
                    func3_o <= func3;
                    func7_o <= func7;
                    case (func3)
                        `SLLI_FUNCT3:   begin
                            imm_o <= {27'b0, inst_i[24:20]};
                        end
                        `SRLI_SRAI_FUNCT3:   begin
                            imm_o <= {27'b0, inst_i[24:20]};
                        end
                        default: begin
                        end 
                    endcase
                end
                `OP_OP:   begin
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                    func3_o <= func3;
                    func7_o <= func7;
                end
                `OP_LUI:   begin
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_LUI;
                    imm_o <= {inst_i[31:12], 12'b0};
                    instvalid <= `InstValid;
                end
                `OP_AUIPC:   begin  
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_AUIPC;
                    imm_o  <= {inst_i[31:12], 12'b0};
                    instvalid <= `InstValid;
                end
                `OP_LOAD:   begin
                    wreg_o <= `WriteEnable;
                    opcode_o <= `OP_LOAD;
                    func3_o <= func3;
                    imm_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                    reg1_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `OP_STORE:   begin
                    opcode_o <= `OP_STORE;
                    func3_o <= func3;
                    imm_o <= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                end
                `OP_BRANCH:   begin
                    opcode_o <= `OP_BRANCH;
                    func3_o <= func3;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    instvalid <= `InstValid;
                    imm_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                    br_offset <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                    br_addr <= pc_i;
                    // case (func3)
                    //     `BEQ_FUNCT3:   begin
                    //         if (reg1_o == reg2_o) begin
                    //             ifjump <= 1'b1;
                    //             pc_jump <= pc_i + imm;
                    //         end
                    //     end
                    //     `BNE_FUNCT3:   begin
                    //         if (reg1_o != reg2_o) begin
                    //             ifjump <= 1'b1;
                    //             pc_jump <= pc_i + imm;
                    //         end
                    //     end
                    //     `BLT_FUNCT3:   begin
                    //         if ($signed(reg1_o) < $signed(reg2_o)) begin
                    //             ifjump <= 1'b1;
                    //             pc_jump <= pc_i + imm;
                    //         end
                    //     end
                    //     `BGE_FUNCT3:   begin
                    //         if ($signed(reg1_o) >= $signed(reg2_o)) begin
                    //             ifjump <= 1'b1;
                    //             pc_jump <= pc_i + imm;
                    //         end
                    //     end
                    //     `BLTU_FUNCT3:   begin
                    //         if (reg1_o < reg2_o) begin
                    //             ifjump <= 1'b1;
                    //             pc_jump <= pc_i + imm;
                    //         end
                    //     end
                    //     `BGEU_FUNCT3:   begin
                    //         if (reg1_o >= reg2_o) begin
                    //             ifjump <= 1'b1;
                    //             pc_jump <= pc_i + imm;
                    //         end
                    //     end
                    //  endcase
                end
                default:begin
                end 
            endcase
        end        
    end


    always @(*) begin
        id_stall_req_o <= 1'b0;
        if (rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if ((if_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o) && (ex_wd_i != `ZeroWord)) begin
            reg1_o <= `ZeroWord;
            id_stall_req_o <= 1'b1;
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o <= ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o <= mem_wdata_i;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else begin
            reg1_o <= `ZeroWord;
        end
        if (rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if ((if_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && (ex_wd_i != `ZeroWord)) begin
            reg2_o <= `ZeroWord;
            id_stall_req_o <= 1'b1;
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && (ex_wd_i != `ZeroWord)) begin
            reg2_o <= ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o) && (mem_wd_i != `ZeroWord)) begin
            reg2_o <= mem_wdata_i;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end

    // always @(*) begin
    //     id_stall_req_o <= 1'b0;
    //     if (rst == `RstEnable) begin
    //         reg2_o <= `ZeroWord;
    //     end else if ((if_load == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && (ex_wd_i != `ZeroWord)) begin
    //         id_stall_req_o <= 1'b1;
    //     end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o) && (ex_wd_i != `ZeroWord)) begin
    //         reg2_o <= ex_wdata_i;
    //     end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o) && (mem_wd_i != `ZeroWord)) begin
    //         reg2_o <= mem_wdata_i;
    //     end else if (reg2_read_o == 1'b1) begin
    //         reg2_o <= reg2_data_i;
    //     end else begin
    //         reg2_o <= `ZeroWord;
    //     end
    // end






endmodule // id