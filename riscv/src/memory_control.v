`include "defines.vh"
module memory_control(
    input  wire             clk,
    input  wire             rst,

    input wire              jump,
    //input from i_cache
    input wire              inst_enable_i,
    input wire[`InstAddrBus] inst_addr,

    //output to i_cache
    output reg[`InstAddrBus]inst_data,
    output reg              inst_enable,
    output reg              inst_busy,

    //input from MEM
    input wire              mem_enable_i,
    input wire              mem_wr,
    input wire[`RegBus]     mem_addr,
    input wire[2:0]         mem_width,           //
    input wire[`RegBus]     mem_wdata,

    //output to MEM
    output reg              mem_enable,
    output reg[`RegBus]     mem_rdata,
    output reg              mem_busy,

    //input from RAM
    input wire[7:0] ram_in,

    //output to RAM
    output wire[7:0] ram_out,
    output wire[`InstAddrBus]ram_addr,  //////// 
    output wire              ram_wr   //read write signal, use 1 for write
    
);


// always @ (posedge clk) begin
//     if (ram_wr) begin
//         $display("mem_write %h %h", ram_addr, ram_out);
//     end
// end



wire[`InstAddrBus] addr;

reg[7:0] l_data[3:0];
wire[7:0] s_data[3:0];

reg[2:0] flag;
wire[2:0] num;

assign s_data[0] = mem_wdata[7:0];
assign s_data[1] = mem_wdata[15:8];
assign s_data[2] = mem_wdata[23:16];
assign s_data[3] = mem_wdata[31:24];

assign num = mem_enable_i == 1'b1 ? mem_width[2:0] : (inst_enable_i== 1'b1 ? 4 : 0);
assign addr = mem_enable_i == 1'b1 ? mem_addr[`InstAddrBus] : inst_addr[`InstAddrBus];
assign ram_wr = mem_enable_i == 1'b1 ? (flag == num ?  1'b0 : mem_wr) : 1'b0;
// assign addr = 1004;
assign ram_addr = addr + flag;
assign ram_out = flag == 3'b100 ? `ZeroWord : s_data[flag];


always @(posedge clk) begin
    if (rst == `RstEnable || (jump && !mem_enable_i) ) begin
        flag <= 0;
        mem_busy <= 1'b0;
        inst_busy <= 1'b0;
        inst_enable <= `WriteDisable;
        mem_enable <= `WriteDisable;
        l_data[0] <= 0;
        l_data[2] <= 0;
        l_data[1] <= 0;
        l_data[3] <= 0;
    end else if (num && !ram_wr) begin
        if (flag == 0) begin
            mem_enable <= `WriteDisable;
            inst_enable <= `WriteDisable;
            flag <= flag + 1;
            mem_busy <= !mem_enable_i;
            inst_busy <= mem_enable_i;
        end else if (flag < num) begin
            flag <= flag + 1;
            l_data[flag - 1] <= ram_in;
        end else begin
            if (mem_enable_i == 1'b1) begin
                mem_enable <= `WriteEnable;
                if (mem_width == 3'b001) begin
                    mem_rdata <= ram_in;
                end else if (mem_width == 3'b010) begin
                    mem_rdata <= {ram_in, l_data[0]};
                end else if (mem_width == 3'b100) begin
                    mem_rdata <= {ram_in, l_data[2], l_data[1], l_data[0]};
                end
            end else begin
                inst_data <= {ram_in, l_data[2], l_data[1], l_data[0]};
                inst_enable <= `WriteEnable;
            end
            flag <= 0;
        end
    end else if (num && ram_wr) begin
        if (flag == 0) begin
            inst_busy <= 1'b1;
            mem_busy <= 1'b0;
            mem_enable <= 1'b0;
            inst_enable <= 1'b0;
        end
        if (flag + 1 == num) begin
            mem_enable <= 1'b1;
            flag <= 1'b0;
        end else begin
            flag <= flag + 1;
        end
    end else begin
        mem_busy <= 1'b0;
        inst_busy <= 1'b0;
        inst_enable <= `WriteDisable;
        mem_enable <= `WriteDisable;       
    end
end
        
endmodule  //
