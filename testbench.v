`timescale 1s / 1ms

module tb_traffic_controller;

    reg clk = 0;
    reg rst = 1;
    reg Emergency_Left = 0;
    reg Emergency_Right = 0;

    wire [1:0] T1_light;
    wire [1:0] T2_light;
    wire Buzzer_T1, Buzzer_T2;

    traffic_controller uut (
        .clk(clk),
        .rst(rst),
        .Emergency_Left(Emergency_Left),
        .Emergency_Right(Emergency_Right),
        .T1_light(T1_light),
        .T2_light(T2_light),
        .Buzzer_T1(Buzzer_T1),
        .Buzzer_T2(Buzzer_T2)
    );

    // Clock generation: 1 Hz
    initial forever #0.5 clk = ~clk;

    // Display helper
    task print_state;
        input integer t;
        begin
            $display("Time: %0d | T1: %s | T2: %s | Walk_1: %b | Walk_2: %b | E_L: %b | E_R: %b",
                t,
                (T1_light == 2'b00) ? "RED   " :
                (T1_light == 2'b01) ? "GREEN " :
                (T1_light == 2'b10) ? "YELLOW" : "UNK   ",
                (T2_light == 2'b00) ? "RED   " :
                (T2_light == 2'b01) ? "GREEN " :
                (T2_light == 2'b10) ? "YELLOW" : "UNK   ",
                Buzzer_T1,
                Buzzer_T2,
                Emergency_Left,
                Emergency_Right
            );
        end
    endtask

    // Reset and test sequence
    initial begin
        $dumpfile("traffic_controller.vcd");
        $dumpvars(0, tb_traffic_controller);
        $display("=== Traffic Controller Testbench Start ===");
        rst = 0; // Deassert reset after 1s
    end

    integer i = 1;
    always @(posedge clk) begin
        // Trigger Emergency Left during T1 GREEN (starts at time ~1s)
        if (i == 2) Emergency_Left = 1;
        if (i == 6) begin
            Emergency_Right = 1;
            Emergency_Left = 1;
        end
        if( i == 7) begin
            Emergency_Right = 0;
            Emergency_Left = 0;
        end

        if(i == 36) begin
            Emergency_Right = 1;
        end
        if(i == 37) begin
            Emergency_Right = 0;
        end

        if(i == 51) begin
            Emergency_Left = 1;
        end
        if(i == 52) begin
            Emergency_Left = 0;
        end
        if(i == 108) begin
            Emergency_Right = 1;
        end
        if(i == 109) begin
            Emergency_Right = 0;
        end

        if(i == 119) begin
            Emergency_Left = 1;
        end
        if(i == 120) begin
            Emergency_Left = 0;
        end

        print_state(i);

        // Stop after 150 seconds
        if (i == 150) begin
            $display("=== Traffic Controller Testbench Complete ===");
            $finish;
        end
        i = i + 1;
    end

endmodule
