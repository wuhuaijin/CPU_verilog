`include "defines.vh"

module i_cache(
    input wire rst,
    input wire clk,

    //input from memory_control
    input wire    inst_busy,
    input wire    inst_enable_i,
    input wire[31:0]  inst_data_i,

    //output to memory_control
    output reg        inst_read_o,
    output wire [`InstAddrBus]   inst_addr_o,

    //input from if
    input wire      inst_read_i,
    input wire[`InstAddrBus]    inst_addr_i,

    //output to if
    output reg                  inst_enable_o,
    output reg[`InstBus]        inst_data_o     

);


        
        
assign  inst_addr_o = inst_addr_i;

reg[31:0]       i_cache_data[`IcacheNum-1:0];
reg[`IcacheTagBus]  i_cache_tag[`IcacheNum-1:0];
reg[`IcacheNum-1:0] i_cache_valid;

integer i;


    initial begin
        for (i = 0; i < `IcacheNum; i = i + 1) begin
            i_cache_valid[i] <= 0;
        end
    end


    always @(*) begin
        if (rst == `RstEnable || !inst_read_i) begin
            inst_enable_o <= 1'b0;
            inst_data_o <= `ZeroWord;
            inst_read_o <= 1'b0;
        end else begin
            if (i_cache_tag[inst_addr_i[`IcacheBus]] == inst_addr_i[`TagBytes] && i_cache_valid[inst_addr_i[`IcacheBus]]) begin
                inst_enable_o <= 1'b1;
                inst_data_o <= i_cache_data[inst_addr_i[`IcacheBus]];
                inst_read_o <= 1'b0;
            end else if (inst_enable_i == 1'b1) begin
                inst_enable_o <= 1'b1;
                inst_data_o <= inst_data_i;
                inst_read_o <= 1'b0;
            end else if (!inst_busy) begin
                inst_enable_o <= 1'b0;
                inst_data_o <= `ZeroWord;
                inst_read_o <= 1'b1;
            end else begin
                inst_enable_o <= 1'b0;
                inst_data_o <= `ZeroWord;
                inst_read_o <= 1'b0;
            end
        end
    end


    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            i_cache_valid <= 0;
        end else if (inst_enable_i == 1'b1) begin
            i_cache_valid[inst_addr_i[`IcacheBus]] <= 1'b1;
            i_cache_tag[inst_addr_i[`IcacheBus]] <= inst_addr_i[`TagBytes];
            i_cache_data[inst_addr_i[`IcacheBus]] <= inst_data_i;
        end
    end


    // always @(*) begin
    //     inst_read_o <= !inst_busy && miss && !rst;
    // end

    //  always @(*) begin
    //     inst_read_o <= !inst_busy;
    // end



    // always @(posedge clk) begin
    //     if (rst == `RstEnable) begin
    //         for (i = 0; i < `IcacheNum; i = i + 1) begin
    //             i_cache_tag[i] = -1;
    //         end
    //     end
    // end

    // always @(*) begin
    //     if (rst == `RstEnable) begin
    //         inst_enable_o <= 1'b0;
    //         inst_data_o <= `ZeroWord;
    //         inst_read_o <= 1'b0;
    //         inst_addr_o <= `ZeroWord;
    //     end else begin
    //         if (i_cache_tag[inst_addr_i[`IcacheBus]] == inst_addr_i[`TagBytes]) begin
    //             a <= 100;
    //             inst_enable_o <= 1'b1;
    //             inst_data_o <= i_cache_data[inst_addr_i[`IcacheBus]];
    //             inst_read_o = 1'b0;
    //             inst_addr_o <= `ZeroWord;
    //         end else begin
    //             a <= 0;
    //             if (inst_read_i == 1'b1) begin
    //                 if (inst_enable_i == 1'b1) begin
    //                     i_cache_data[inst_addr_i[`IcacheBus]] <= inst_data_i;
    //                     i_cache_tag[inst_addr_i[`IcacheBus]] <= inst_addr_i[`TagBytes];
    //                     inst_read_o <= 1'b0;
    //                     inst_addr_o <= `ZeroWord;
    //                     inst_data_o <= inst_data_i;
    //                     inst_enable_o <= 1'b1;
    //                 end else begin
    //                     inst_enable_o <= 1'b0;
    //                     inst_data_o <= `ZeroWord;
    //                     if (inst_busy == 1'b0) begin
    //                         inst_read_o <= 1'b1;
    //                         inst_addr_o <= inst_addr_i;
    //                     end else begin
    //                         inst_read_o <= 1'b0;
    //                         inst_addr_o <= `ZeroWord;
    //                     end
    //                 end
    //             end else begin
    //                 inst_enable_o <= 1'b0;
    //             end
    //         end
    //     end
    // end









endmodule // 
