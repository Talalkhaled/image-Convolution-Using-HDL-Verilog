module top_tb;

    // Define parameters
    parameter WIDTH = 24;
    parameter SCALE = 12;
    
    // Inputs
    reg clk, rst, go;
    reg [7:0] expected_data_out;

    // Outputs
    wire done;
    wire rdy;
    wire [7:0] data_out;

    // Instantiate the unit under test (UUT)
    top dut (
        .clk(clk),
        .rst(rst),
        .go(go),
        .done(done),
        .rdy(rdy),
        .data_out(data_out)
    );

    // File handle for writing data_out
    integer file, output_file, error_count, r;

    // Clock generation
    always begin 
        #40 clk = ~clk;
    end

    always @(negedge clk) begin
        go = ~go;
    end

    // Testbench stimulus
    initial begin
        clk = 0;
        go = 0;
        rst = 1;
        #10 rst = 0;
        #10 rst = 1;
        #10 rst = 0;
        
        // Open file for writing
        file = $fopen("output.hex", "w");
        if (file == 0) begin
            $display("Error: Failed to open output.hex for writing");
            $finish;
        end

        output_file = $fopen("outputImg.txt", "r");
        if (output_file == 0) begin
            $display("Error: Failed to open outputImg for reading");
            $fclose(file);
            $finish;
        end

        error_count = 0;
        // Wait for some time and then finish
        #600000040 $finish;
    end

    // Write data_out to file in hexadecimal format
    always @(posedge clk) 
    if (done == 1) begin
        r = $fscanf(output_file, "%h", expected_data_out);
        if (r == 0) begin
            $display("Error: Failed to read from outputImg");
            $finish;
        end
        $fwrite(file, "%h\n", data_out); // Optional display for debugging
        if (data_out !== expected_data_out) begin
            error_count = error_count + 1;
        end
    end

    // Close the file when the simulation finishes
    initial begin
        #600000000 $fclose(file);
        $fclose(output_file);
        if (error_count == 0) begin
            $display("Success: The output file matched with golden output");
        end
        else begin
            $display("Mismached: the # Mismached is: $d", error_count);
        end
    end

endmodule
