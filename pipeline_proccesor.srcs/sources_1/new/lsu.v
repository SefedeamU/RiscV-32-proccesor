// =============================================================
// lsu.v -- Load/Store Unit (Verilog-2005)
// =============================================================
module lsu (
    input  wire         clk,
    input  wire         mem_read,
    input  wire         mem_write,
    input  wire [2:0]   funct3,
    input  wire [31:0]  addr,
    input  wire [31:0]  wdata,

    // RAM interface
    output wire         ram_we,
    output reg  [3:0]   ram_be,
    output wire [31:0]  ram_addr,
    output reg  [31:0]  ram_wdata,
    input  wire [31:0]  ram_rdata,

    // Data hacia el pipeline
    output reg  [31:0]  load_data
);

    assign ram_we   = mem_write;
    assign ram_addr = addr;

    always @(*) begin
        ram_be    = 4'b0000;
        ram_wdata = wdata;

        if (mem_write) begin
            case (funct3)
                3'b000: begin // SB
                    ram_be = 4'b0001 << addr[1:0];
                    case (addr[1:0])
                        2'b00: ram_wdata = {ram_rdata[31:8],  wdata[7:0]};
                        2'b01: ram_wdata = {ram_rdata[31:16], wdata[7:0], ram_rdata[7:0]};
                        2'b10: ram_wdata = {ram_rdata[31:24], wdata[7:0], ram_rdata[15:0]};
                        2'b11: ram_wdata = {wdata[7:0],       ram_rdata[23:0]};
                    endcase
                end
                3'b001: begin // SH
                    ram_be = addr[1] ? 4'b1100 : 4'b0011;
                end
                3'b010: begin // SW
                    ram_be = 4'b1111;
                end
                default: begin
                    ram_be = 4'b0000;
                end
            endcase
        end
    end

    // LOADS
    always @(*) begin
        load_data = 32'd0;

        if (mem_read) begin
            case (funct3)
                3'b000: begin // LB
                    case (addr[1:0])
                        2'b00: load_data = {{24{ram_rdata[7]}},   ram_rdata[7:0]};
                        2'b01: load_data = {{24{ram_rdata[15]}},  ram_rdata[15:8]};
                        2'b10: load_data = {{24{ram_rdata[23]}},  ram_rdata[23:16]};
                        2'b11: load_data = {{24{ram_rdata[31]}},  ram_rdata[31:24]};
                    endcase
                end
                3'b001: begin // LH
                    if (addr[1] == 1'b0)
                        load_data = {{16{ram_rdata[15]}}, ram_rdata[15:0]};
                    else
                        load_data = {{16{ram_rdata[31]}}, ram_rdata[31:16]};
                end
                3'b010: begin // LW
                    load_data = ram_rdata;
                end
                3'b100: begin // LBU
                    case (addr[1:0])
                        2'b00: load_data = {24'd0, ram_rdata[7:0]};
                        2'b01: load_data = {24'd0, ram_rdata[15:8]};
                        2'b10: load_data = {24'd0, ram_rdata[23:16]};
                        2'b11: load_data = {24'd0, ram_rdata[31:24]};
                    endcase
                end
                3'b101: begin // LHU
                    if (addr[1] == 1'b0)
                        load_data = {16'd0, ram_rdata[15:0]};
                    else
                        load_data = {16'd0, ram_rdata[31:16]};
                end
                default: begin
                    load_data = 32'd0;
                end
            endcase
        end
    end

endmodule
