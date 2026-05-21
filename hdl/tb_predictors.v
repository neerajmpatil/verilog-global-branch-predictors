`timescale 1ns/1ps

module tb_predictors;

    reg        clk;
    reg        rst;
    reg        update;
    reg  [7:0] pc;
    reg        actual_taken;

    wire pred_g, pred_gs, pred_gh;

    gpredict u_g  (.clk(clk), .rst(rst), .update(update),
                   .pc(pc), .actual_taken(actual_taken),
                   .predict_taken(pred_g));

    gselect  u_gs (.clk(clk), .rst(rst), .update(update),
                   .pc(pc), .actual_taken(actual_taken),
                   .predict_taken(pred_gs));

    gshare   u_gh (.clk(clk), .rst(rst), .update(update),
                   .pc(pc), .actual_taken(actual_taken),
                   .predict_taken(pred_gh));

    always #5 clk = ~clk;

    reg [8:0] trace [0:7999];
    integer   N;

    integer miss_g, miss_gs, miss_gh;
    integer i;
    reg [7:0] entry_pc;
    reg       entry_taken;

    initial begin
        $readmemb("trace.mem", trace);

        N = 0;
        while (N < 8000 && trace[N] !== 9'bx) N = N + 1;
        $display("[TB] Loaded %0d branches from trace.mem", N);

        clk          = 0;
        rst          = 1;
        update       = 0;
        pc           = 8'h00;
        actual_taken = 1'b0;
        miss_g       = 0;
        miss_gs      = 0;
        miss_gh      = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 1'b0;
        @(negedge clk);

        for (i = 0; i < N; i = i + 1) begin
            entry_pc    = trace[i][8:1];
            entry_taken = trace[i][0];

            pc           = entry_pc;
            actual_taken = entry_taken;
            update       = 1'b0;

            #1;

            if (pred_g  !== entry_taken) miss_g  = miss_g  + 1;
            if (pred_gs !== entry_taken) miss_gs = miss_gs + 1;
            if (pred_gh !== entry_taken) miss_gh = miss_gh + 1;

            update = 1'b1;
            @(posedge clk);
            update = 1'b0;
        end

        $display("");
        $display("===============================================================");
        $display("                 Branch Prediction Results");
        $display("===============================================================");
        $display("Total branches simulated: %0d", N);
        $display("");
        $display("Predictor    Mispredicts    Mispredict Rate    Hit Rate");
        $display("---------    -----------    ---------------    --------");
        $display("gpredict     %7d        %7.2f%%          %7.2f%%",
                 miss_g,  100.0*miss_g/N,  100.0*(N-miss_g)/N);
        $display("gselect      %7d        %7.2f%%          %7.2f%%",
                 miss_gs, 100.0*miss_gs/N, 100.0*(N-miss_gs)/N);
        $display("gshare       %7d        %7.2f%%          %7.2f%%",
                 miss_gh, 100.0*miss_gh/N, 100.0*(N-miss_gh)/N);
        $display("===============================================================");
        $finish;
    end

endmodule
