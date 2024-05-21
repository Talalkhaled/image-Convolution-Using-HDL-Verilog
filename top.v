module top #(
    parameter WIDTH = 24,
    parameter SCALE = 12,
    parameter DATA_WIDTH = 24,
    parameter ADDR_WIDTH = 19,
    parameter HEX_FILE = "inputimg.txt"
)(
    input clk, rst, go,
    output reg done, rdy,
    output reg [7:0] data_out
);

    localparam s0 = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4, s5 = 5, s6 = 6, s7 = 7, s8 = 8, s9 = 9;
    reg [ADDR_WIDTH-1:0] addr_ram_read, addr_ram_write, addr_ram;
    reg [WIDTH-1:0] Rj1, Rj2, Rj3;
    reg [3:0] state;
    reg signed [11:0] Rm1, Rm2, Rm3, Rm4, Rm5, Rm6, Rm7, Rm8, Rm9;
    reg [9:0] i, k;
    reg [1:0] wei;
    wire [DATA_WIDTH-1:0] data_ram_read;
    wire ram_ready;

    // Single port RAM for both reading and writing
    single_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .HEX_FILE(HEX_FILE)
    ) bram (
        .data_in(data_out),
        .addr(addr_ram),
        .we(wei),
        .clk(clk),
        .data_out(data_ram_read),
        .ready(ram_ready)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= s0;
            done <= 0;
            i <= 0;
            k <= 0;
            addr_ram_write <= 262144;
            addr_ram_read <= 0;
            addr_ram <= 0;
            rdy <= 1;
            wei <= 2'b00; // Null operation
        end else begin
            case (state)
                s0: begin
                    if (rdy == 1) begin
                        if (~go) begin
                        state <= s1;
                        end
                    end
                end
                s1: begin if (~go) begin
                    state <= s2;
                    end
                end
                s2: begin
                    if (go)
                        // Initialize RAM read address
                        addr_ram_read <= i + (k * 512);
                        state <= s3;
                end
                s3: begin
                    
                    if (addr_ram_write == 392194) begin
                        addr_ram_write <= 262144;
                    end
                    addr_ram <= addr_ram_read;
                    
                    
                    state <= s4;
                end
                s4: begin
                    wei <= 2'b01; // Read mode
                    if (ram_ready) begin
                        // Capture RAM data
                        Rj1 <= data_ram_read;
                        addr_ram_read <= addr_ram_read + 512;
                        state <= s5;
                    end
                end
                s5: begin
                    addr_ram <= addr_ram_read;
                    if (ram_ready) begin
                        Rj2 <= data_ram_read;
                        addr_ram_read <= addr_ram_read + 512;
                        state <= s6;
                    end
                end
                s6: begin
                    addr_ram <= addr_ram_read;
                    if (ram_ready) begin
                        Rj3 <= data_ram_read;

                        // Increment indices
                        if (k == 509 && i == 509) begin
                            rdy <= 0;
                            state <= s0;
                        end else if (i == 509) begin
                            i <= 0;
                            k <= k + 1;
                        end else begin
                            i <= i + 1;
                        end
                        state <= s7;
                    end
                end
                s7: begin
                    wei <= 2'b00;    // null operation
                    // Perform multiplications
                    Rm1 <= Rj1[7:0] * 1;
                    Rm2 <= Rj1[15:8] * 1;
                    Rm3 <= Rj1[23:16] * 1;
                    Rm4 <= Rj2[7:0] * 1;
                    Rm5 <= Rj2[15:8] * -8;
                    Rm6 <= Rj2[23:16] * 1;
                    Rm7 <= Rj3[7:0] * 1;
                    Rm8 <= Rj3[15:8] * 1;
                    Rm9 <= Rj3[23:16] * 1;
                    state <= s8;
                end
                s8: begin
                    data_out <= Rm1 + Rm2 + Rm3 + Rm4 + Rm5 + Rm6 + Rm7 + Rm8 + Rm9;
                    addr_ram <= addr_ram_write;
                    wei <= 2'b10; // Write mode
                    done <= 1;
                    
                    state <= s9;
                end
                s9:begin
                    addr_ram_write <= addr_ram_write + 1;
                    wei <= 2'b00; // Null operation
                    done <= 0;
                    state <= s0;
                end
                default: state <= s0;
            endcase
        end
    end
endmodule
