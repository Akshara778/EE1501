`timescale 1s / 1ms

module traffic_controller(
    input clk,
    input rst,
    input Emergency_Left,
    input Emergency_Right,
    output reg [1:0] T1_light,
    output reg [1:0] T2_light,
    output reg Buzzer_T1,
    output reg Buzzer_T2
);

    parameter RED    = 2'b00;
    parameter GREEN  = 2'b01;
    parameter YELLOW = 2'b10;

    reg [1:0] T1_state = GREEN;
    reg [1:0] T2_state = GREEN;
    reg [7:0] T1_timer = 0;
    reg [7:0] T2_timer = 0;

    reg [15:0] current_time = 0;
    reg [15:0] pause_until_T1 = 0;
    reg [15:0] pause_until_T2 = 0;

    wire pause_T1 = (current_time < pause_until_T1);
    wire pause_T2 = (current_time < pause_until_T2);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            T1_state <= GREEN;
            T2_state <= GREEN;
            T1_timer <= 0;
            T2_timer <= 0;
            pause_until_T1 <= 0;
            pause_until_T2 <= 0;
            current_time <= 0;
        end else begin
            current_time <= current_time + 1;

            if (Emergency_Left) begin
                if (pause_until_T1 < current_time + 11)
                    pause_until_T1 <= current_time + 11;
            end

            if (Emergency_Right) begin
                if (pause_until_T1 < current_time + 11)
                    pause_until_T1 <= current_time + 11;
                if (pause_until_T2 < current_time + 11)
                    pause_until_T2 <= current_time + 11;
            end

            if (!pause_T1) begin
                case (T1_state)
                    RED: begin
                        if (T1_timer < 59) T1_timer <= T1_timer + 1;
                        else begin
                            T1_state <= GREEN;
                            T1_timer <= 0;
                        end
                    end
                    GREEN: begin
                        if (T1_timer < 24) T1_timer <= T1_timer + 1;
                        else begin
                            T1_state <= YELLOW;
                            T1_timer <= 0;
                        end
                    end
                    YELLOW: begin
                        if (T1_timer < 4) T1_timer <= T1_timer + 1;
                        else begin
                            T1_state <= RED;
                            T1_timer <= 0;
                        end
                    end
                endcase
            end

            if (!pause_T2) begin
                case (T2_state)
                    RED: begin
                        if (T2_timer < 59) T2_timer <= T2_timer + 1;
                        else begin
                            T2_state <= GREEN;
                            T2_timer <= 0;
                        end
                    end
                    GREEN: begin
                        if (T2_timer < 24) T2_timer <= T2_timer + 1;
                        else begin
                            T2_state <= YELLOW;
                            T2_timer <= 0;
                        end
                    end
                    YELLOW: begin
                        if (T2_timer < 4) T2_timer <= T2_timer + 1;
                        else begin
                            T2_state <= RED;
                            T2_timer <= 0;
                        end
                    end
                endcase
            end
        end
    end

    always @(*) begin
        T1_light = pause_T1 ? RED : T1_state;
        T2_light = pause_T2 ? RED : T2_state;

        Buzzer_T1 = (!pause_T1 && T1_state == RED && T1_timer >= 55);
        Buzzer_T2 = (!pause_T2 && T2_state == RED && T2_timer >= 55);
    end

endmodule
