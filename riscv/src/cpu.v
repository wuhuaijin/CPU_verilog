// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "defines.vh"
module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	  input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, re

// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

    //control
    wire rst = rst_in || !rdy_in;
    wire      stall_if;
    wire      stall_mem;
    wire      stall_id;
    wire[`StallBus] stall_o;
    
    wire[`InstAddrBus]      pc;
   
    wire[`InstAddrBus]      pc_jump;

    //pc_reg to if
    wire                    pc_enable;
    
    //if to if_id
    wire[`InstAddrBus]      if_pc;
    wire                    if_inst_enable;
    wire[`InstBus]          if_inst;


    wire                    mc_mem_busy;
    wire                    mc_inst_busy;

    //memory control to i_cache
    wire                    mc_inst_enable;
    wire[`InstBus]          mc_inst_data;

    //i_cache to memory_control
    wire                    i_cache_inst_read_o;
    wire[`InstAddrBus]      i_cache_inst_addr_o;

    // i_cache to if
    wire                    i_cache_inst_enable_o;
    wire[`InstBus]          i_cache_inst_data_o;                    

    
    //if to i_cache
    wire                    mc_inst_enable_o;
    wire[`InstAddrBus]      mc_inst_addr;


    //if_id to id
    wire[`InstAddrBus]      id_pc_i;
    wire[`InstBus]          id_inst_i;

    //regfile to id
    wire[`RegBus]           reg1_data;
    wire[`RegBus]           reg2_data;

    //id to regfile
    wire                    reg1_read;
    wire                    reg2_read;
    wire[`RegAddrBus]       reg1_addr;
    wire[`RegAddrBus]       reg2_addr;

    //ex to id
    wire                    if_load;

    //id to id_ex
    wire[`InstAddrBus]      id_pc_o;
    wire[`OpcodeBus]        id_opcode_o;
    wire[`Func3Bus]         id_func3_o;
    wire[`Func7Bus]         id_func7_o;
    wire[`RegBus]           id_reg1_o;
    wire[`RegBus]           id_reg2_o;
    wire[`RegAddrBus]       id_wd_o;
    wire                    id_wreg_o;
    wire[`RegBus]           id_imm_o;
    wire[31:0]              id_br_addr_o;
    wire[31:0]              id_br_offset_o;



    wire ex_jump;       
    wire ifjump = ex_jump && !stall_o[3]; 

    assign dbgreg_dout = rst_in || !rdy_in;              



    //id_ex to ex
    wire[`InstAddrBus]      ex_pc_i;
    wire[`OpcodeBus]        ex_opcode_i;
    wire[`Func3Bus]         ex_func3_i;
    wire[`Func7Bus]         ex_func7_i;
    wire[`RegBus]           ex_reg1_i;
    wire[`RegBus]           ex_reg2_i;
    wire[`RegBus]           ex_imm_i;
    wire[`RegAddrBus]       ex_wd_i;
    wire                    ex_wreg_i;
    wire[31:0]              ex_br_addr_i;
    wire[31:0]              ex_br_offset_i;

    //ex to ex_mem
    wire[`OpcodeBus]        ex_opcode_o;
    wire[`Func3Bus]         ex_func3_o;
    wire[`InstAddrBus]      ex_mem_addr_o;
    wire[`RegBus]           ex_store_data_o;
    wire[`RegAddrBus]       ex_wd_o;
    wire                    ex_wreg_o;
    wire[`RegBus]           ex_wdata_o;

    //ex_mem to mem
    wire[`OpcodeBus]        mem_opcode_i;
    wire[`Func3Bus]         mem_func3_i;
    wire[`InstAddrBus]      mem_mem_addr_i;
    wire[`RegBus]           mem_store_data_i;
    wire[`RegAddrBus]       mem_wd_i;
    wire                    mem_wreg_i;
    wire[`RegBus]           mem_wdata_i;

    //mem to memory_control
    wire                    mem_mc_enable_o;
    wire                    mem_mc_wr_o;
    wire[`RegBus]           mem_mc_addr_o;
    wire[2:0]               mem_mc_width_o;
    wire[`RegBus]           mem_mc_data_o;

    //memory_control to mem
    wire                    mc_mem_enable;
    wire[`RegBus]           mc_mem_data;

    //mem to mem_wb
    wire[`RegAddrBus]       mem_wd_o;
    wire                    mem_wreg_o;
    wire[`RegBus]           mem_wdata_o;

    //mem_wb to regfile
    wire[`RegAddrBus]       wb_wd_o;
    wire                    wb_wreg_o;
    wire[`RegBus]           wb_wdata_o;



    control control0(
        .clk(clk_in),
        .rst(rst),

        .stall_from_if_i(stall_if),
        .stall_from_mem_i(stall_mem),
        .stall_from_id_i(stall_id),

        .stall(stall_o)

    );

    i_cache i_cache0(
        .rst(rst),
        .clk(clk_in),
        .inst_busy(mc_inst_busy),
        .inst_enable_i(mc_inst_enable),
        .inst_data_i(mc_inst_data),

        .inst_read_o(i_cache_inst_read_o),
        .inst_addr_o(i_cache_inst_addr_o),

        .inst_read_i(mc_inst_enable_o),
        .inst_addr_i(mc_inst_addr),

        .inst_enable_o(i_cache_inst_enable_o),
        .inst_data_o(i_cache_inst_data_o)
    );

    pc_reg pc_reg0(
        .clk(clk_in),
        .rst(rst),

        .stall_signal_i(stall_o),

        .ifjump_i(ifjump),
        .pc_i(pc_jump),
        .pc_o(pc),
        .pc_enable(pc_enable)
    );


    If if0(
        .rst(rst),

        .stall_i(stall_o),

        .pc_i(pc),
        .pc_enable_i(pc_enable),

        .pc_o(if_pc),
        .inst_o(if_inst),
            
        .mc_inst_data_i(i_cache_inst_data_o),
        .mc_inst_enable_i(i_cache_inst_enable_o),

        .mc_inst_enable_o(mc_inst_enable_o),
        .mc_inst_addr_o(mc_inst_addr),

        .if_stall_req_o(stall_if)

    );

    if_id if_id0(
        .clk(clk_in),
        .rst(rst),

        .jump(ifjump),
        .stall_i(stall_o),

        .if_pc(if_pc),
        .if_inst(if_inst),

        .id_pc(id_pc_i),
        .id_inst(id_inst_i)

    );


    id id0(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),

        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),

        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),

        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o),

        .if_load(if_load),

        .pc_o(id_pc_o),
        .opcode_o(id_opcode_o),
        .func3_o(id_func3_o),
        .func7_o(id_func7_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o),
        .imm_o(id_imm_o),

        .br_addr(id_br_addr_o),
        .br_offset(id_br_offset_o),

        .id_stall_req_o(stall_id)

    );

    id_ex id_ex0(
        .clk(clk_in),
        .rst(rst),

        .id_pc(id_pc_o),
        
        .id_opcode(id_opcode_o),
        .id_func3(id_func3_o),
        .id_func7(id_func7_o),
        .id_imm(id_imm_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),
        .id_br_addr(id_br_addr_o),
        .id_br_offset(id_br_offset_o),

        .stall_i(stall_o),

        .ex_pc(ex_pc_i),
        .ex_opcode(ex_opcode_i),
        .ex_func3(ex_func3_i),
        .ex_func7(ex_func7_i),
        .ex_imm(ex_imm_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i),
        .ex_br_addr(ex_br_addr_i),
        .ex_br_offset(ex_br_offset_i),

        .jump(ifjump)

        
    );

    ex ex0(
        .rst(rst),

        .pc_i(ex_pc_i),
        .opcode_i(ex_opcode_i),
        .func3_i(ex_func3_i),
        .func7_i(ex_func7_i),
        .imm_i(ex_imm_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
        .br_addr_i(ex_br_addr_i),
        .br_offset(ex_br_offset_i),

        .ifload_o(if_load),
        .opcode_o(ex_opcode_o),
        .func3_o(ex_func3_o),
        .mem_addr_o(ex_mem_addr_o),
        .store_data_o(ex_store_data_o),
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),
        .ifjump(ex_jump),
        .pc_jump_o(pc_jump)
    );

    ex_mem ex_mem0(
        .clk(clk_in),
        .rst(rst),
        .stall_i(stall_o),

        .ex_opcode(ex_opcode_o),
        .ex_func3(ex_func3_o),
        .ex_mem_addr(ex_mem_addr_o),
        .ex_store_data(ex_store_data_o),

        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .mem_opcode(mem_opcode_i),
        .mem_func3(mem_func3_i),
        .mem_mem_addr(mem_mem_addr_i),
        .mem_store_data(mem_store_data_i),
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i)

    );
    
    mem mem0(
        .rst(rst),

        .opcode_i(mem_opcode_i),
        .func3_i(mem_func3_i),
        .mem_addr_i(mem_mem_addr_i),
        .store_data_i(mem_store_data_i),
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        .mc_mem_busy_i(mc_mem_busy),
        .mc_inst_busy_i(mc_inst_busy),
        .mc_mem_enable_i(mc_mem_enable),
        .mc_mem_data_i(mc_mem_data),

        .mc_mem_enable_o(mem_mc_enable_o),
        .mc_mem_wr_o(mem_mc_wr_o),
        .mc_mem_addr_o(mem_mc_addr_o),
        .mc_mem_width_o(mem_mc_width_o),
        .mc_mem_data_o(mem_mc_data_o),

        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),

        .mem_stall_req_o(stall_mem)
    );

    mem_wb mem_wb0(
        .clk(clk_in),
        .rst(rst),

        .stall_i(stall_o),

        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        .wb_wd(wb_wd_o),
        .wb_wreg(wb_wreg_o),
        .wb_wdata(wb_wdata_o)

    );
    
    memory_control memory_control0(
        .clk(clk_in),
        .rst(rst),

        .inst_enable_i(i_cache_inst_read_o),
        .inst_addr(i_cache_inst_addr_o),

        .inst_data(mc_inst_data),
        .inst_enable(mc_inst_enable),
        .inst_busy(mc_inst_busy),
        
        .mem_enable_i(mem_mc_enable_o),
        .mem_wr(mem_mc_wr_o),
        .mem_addr(mem_mc_addr_o),
        .mem_width(mem_mc_width_o),
        .mem_wdata(mem_mc_data_o),

        .mem_enable(mc_mem_enable),
        .mem_rdata(mc_mem_data),
        .mem_busy(mc_mem_busy),

        .ram_in(mem_din),
        .ram_out(mem_dout),
        .ram_addr(mem_a),
        .ram_wr(mem_wr),

        .jump(ifjump)



    );

    regfile regfile0(
        .clk(clk_in),
        .rst(rst),

        .we(wb_wreg_o),
        .waddr(wb_wd_o),
        .wdata(wb_wdata_o),

        .re1(reg1_read),
        .raddr1(reg1_addr),
        .rdata1(reg1_data),

        .re2(reg2_read),
        .raddr2(reg2_addr),
        .rdata2(reg2_data)

    );





endmodule