module gselect (
    input  wire       clk,
    input  wire       rst,
    input  wire       update,
    input  wire [7:0] pc,
    input  wire       actual_taken,
    output wire       predict_taken
);

    reg  [3:0]  ghr;
    wire [3:0]  index;
    wire [15:0] counter_predict;
    wire [15:0] counter_enable;

    assign index = { pc[1:0], ghr[1:0] };

    assign counter_enable = update ? (16'h0001 << index) : 16'h0000;

    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : bht
            sat_counter sc (
                .clk           (clk),
                .rst           (rst),
                .enable        (counter_enable[k]),
                .taken         (actual_taken),
                .predict_taken (counter_predict[k])
            );
        end
    endgenerate

    assign predict_taken = counter_predict[index];

    always @(posedge clk) begin
        if (rst)
            ghr <= 4'b0000;
        else if (update)
            ghr <= {ghr[2:0], actual_taken};
    end

endmodule
