//********************全局的宏定义*********************
`define RstEnable           1'b1
`define RstDisable          1'b0
`define ZeroWord            32'h00000000
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            7:0
`define AluSelBus           2:0
`define InstValid           1'b0
`define InstInvalid         1'b1
`define True_v              1'b1
`define False_v             1'b0
`define OpcodeBus           6:0
`define Func3Bus            2:0
`define Func7Bus            6:0
`define StallBus            4:0

//*********************与具体指令有关的宏定义****************

//opcode
`define OP_LUI              7'b0110111
`define OP_AUIPC            7'b0010111
`define OP_JAL              7'b1101111
`define OP_JALR             7'b1100111
`define OP_BRANCH           7'b1100011
`define OP_LOAD             7'b0000011
`define OP_STORE            7'b0100011
`define OP_OP_IMM           7'b0010011
`define OP_OP               7'b0110011
`define OP_MISC_MEM         7'b0001111
`define OP_NON              7'b0000000


//func3
`define NON_FUNCT3          3'b000
`define ADDI_FUNCT3         3'b000
`define SLTI_FUNCT3         3'b010
`define SLTIU_FUNCT3        3'b011
`define XORI_FUNCT3         3'b100
`define ORI_FUNCT3          3'b110
`define ANDI_FUNCT3         3'b111
`define SLLI_FUNCT3         3'b001
`define SRLI_SRAI_FUNCT3    3'b101
`define ADD_SUB_FUNCT3      3'b000
`define SLL_FUNCT3          3'b001
`define SLT_FUNCT3          3'b010
`define SLTU_FUNCT3         3'b011
`define XOR_FUNCT3          3'b100
`define SRL_SRA_FUNCT3      3'b101
`define OR_FUNCT3           3'b110
`define AND_FUNCT3          3'b111
`define BEQ_FUNCT3          3'b000
`define BNE_FUNCT3          3'b001
`define BLT_FUNCT3          3'b100
`define BGE_FUNCT3          3'b101
`define BLTU_FUNCT3         3'b110
`define BGEU_FUNCT3         3'b111
`define LB_FUNCT3           3'b000
`define LH_FUNCT3           3'b001
`define LW_FUNCT3           3'b010
`define LBU_FUNCT3          3'b100
`define LHU_FUNCT3          3'b101
`define SB_FUNCT3           3'b000
`define SH_FUNCT3           3'b001
`define SW_FUNCT3           3'b010

//func7
`define NON_FUNCT7          7'b0000000
`define ADD_FUNCT7          7'b0000000
`define SUB_FUNCT7          7'b0100000
`define SRL_FUNCT7          7'b0000000
`define SRA_FUNCT7          7'b0100000



//*********************与指令存储器ROM有关的宏定义**********
`define InstAddrBus         31:0
`define InstBus             31:0
`define InstMemNum          131071
`define InstMemNumLog2      17
`define DataMemNumLog2      17
`define MemAddrBus          16:0
`define MemDataBus          31:0
`define IcacheNum           128
`define IcacheBus           6:0
`define IcacheTagBus        9:0
`define TagBytes            16:7



//*********************与通用寄存器Regfile有关的宏定义********
`define RegAddrBus          4:0
`define RegBus              31:0
`define RegWidth            32
`define DoubleRegwidth      64
`define DoubleRegBus        63:0
`define RegNum              32
`define RegNumLog2          5
`define NOPRegAddr          4'b00000

