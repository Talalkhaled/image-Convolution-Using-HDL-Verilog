module single_port_ram #(
    parameter ADDR_WIDTH = 19, // default 18-bit address
    parameter DATA_WIDTH = 24, // default 3-byte data width
    parameter HEX_FILE = "inputimg.txt",
    parameter START_ADDR = 0,
    parameter END_ADDR = 262143
)(
    input [7:0] data_in,
    input [ADDR_WIDTH-1:0] addr, // parameterized address width
    input [1:0] we, // 2-bit signal for read/write/null
    input clk,
    output reg [DATA_WIDTH-1:0] data_out, // parameterized data width
    output reg ready // indicates when data is ready to be read
);

    // Memory array
    reg [7:0] ram [(2**ADDR_WIDTH)-1:0];

    // Load memory content
    initial begin
        if (HEX_FILE != "none")
            $readmemh(HEX_FILE, ram, START_ADDR, END_ADDR);
    end

    // FSM states
    localparam s0 = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4, s5 = 5;
    reg [2:0] state;

    always @(posedge clk) begin
        if (we == 2'b10) begin
            ram[addr] <= data_in;
            ready <= 1'b0;
        end else if (we == 2'b01) begin
            case (state)
                s0: begin
                    ready <= 1'b0;
                    state <= s1;
                end
                s1: begin
                    data_out[7:0] <= ram[addr]; // Read first byte
                    state <= s2;
                end
                s2: begin
                    data_out[15:8] <= ram[addr + 1]; // Read second byte
                    state <= s3;
                end
                s3: begin
                    data_out[23:16] <= ram[addr + 2]; // Read third byte
                    state <= s4;
                end
                s4: begin
                    ready <= 1'b1;
                    state <= s5;
                end
                s5: begin
                    ready <= 1'b0;
                    state <= s0;
                end
                default: state <= s0;
            endcase
        end
    end
endmodule
