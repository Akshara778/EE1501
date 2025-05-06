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

    // Light states
    parameter RED    = 2'b00;
    parameter GREEN  = 2'b01;
    parameter YELLOW = 2'b10;

    reg [1:0] T1_state = GREEN;
    reg [1:0] T2_state = RED;
    reg [7:0] T1_timer = 0;
    reg [7:0] T2_timer = 0;

    reg [7:0] pause_timer = 0;
    reg fsm_paused = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            T1_state <= GREEN;
            T2_state <= RED;
            T1_timer <= 0;
            T2_timer <= 0;
            pause_timer <= 0;
            fsm_paused <= 0;
        end 
        else begin
            // Emergency triggers
            if ((Emergency_Right && !fsm_paused) || (Emergency_Left && !fsm_paused)) begin
                fsm_paused <= 1;
                pause_timer <= 0;
            end

            // Pause logic
            if (fsm_paused) begin
                pause_timer <= pause_timer + 1;
                if (pause_timer == 9) begin
                    fsm_paused <= 0;
                    pause_timer <= 0;
                end
            end else begin
                // T1 FSM
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

                // T2 FSM
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
        T1_light = fsm_paused ? RED : T1_state;
        T2_light = fsm_paused ? RED : T2_state;

        Buzzer_T1 = (!fsm_paused && T1_state == RED && T1_timer >= 55);
        Buzzer_T2 = (!fsm_paused && T2_state == RED && T2_timer >= 55);
    end

endmodule
