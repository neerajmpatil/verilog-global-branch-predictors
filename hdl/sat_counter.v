module sat_counter (
    input  wire clk,
    input  wire rst,
    input  wire enable,
    input  wire taken,
    output wire predict_taken
);

    reg [1:0] count;

    always @(posedge clk) begin
        if (rst)
            count <= 2'b00;
        else if (enable) begin
            if (taken && count != 2'b11)
                count <= count + 1'b1;
            else if (!taken && count != 2'b00)
                count <= count - 1'b1;
        end
    end

    assign predict_taken = count[1];

endmodule
