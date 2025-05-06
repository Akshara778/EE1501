`timescale 1s/1ms

module digital_clock(
    input clk,
    input reset,
    input [4:0] set_hour,
    input [5:0] set_min,
    input [5:0] set_sec,
    input [4:0] set_day,
    input [3:0] set_month,
    input [11:0] set_year,

    input [4:0] alarm_hour,
    input [5:0] alarm_min,
    input [5:0] alarm_sec,
    input alarm_enable,

    input [5:0] timer_min,
    input [5:0] timer_sec,
    input timer_start,

    output reg [4:0] hour,
    output reg [5:0] min,
    output reg [5:0] sec,
    output reg [4:0] day,
    output reg [3:0] month,
    output reg [11:0] year,

    output reg [5:0] timer_count_min,
    output reg [5:0] timer_count_sec,
    output reg alarm_buzzer,
    output reg timer_buzzer
);

reg timer_running = 0;
reg alarm_triggered = 0;
reg [3:0] alarm_buzzer_counter = 0;

initial begin
    hour = 0; min = 0; sec = 0;
    day = 1; month = 1; year = 2020;
    alarm_buzzer = 0;
    timer_buzzer = 0;
end

function [5:0] days_in_month;
    input [3:0] m;
    input [11:0] y;
    begin
        case (m)
            1,3,5,7,8,10,12: days_in_month = 31;
            4,6,9,11: days_in_month = 30;
            2: days_in_month = ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)) ? 29 : 28;
            default: days_in_month = 30;
        endcase
    end
endfunction

always @(posedge clk or posedge reset) begin
    if (reset) begin
        hour <= set_hour;
        min <= set_min;
        sec <= set_sec;
        day <= set_day;
        month <= set_month;
        year <= set_year;

        alarm_triggered <= 0;
        alarm_buzzer <= 0;
        alarm_buzzer_counter <= 0;

        timer_buzzer <= 0;
        timer_running <= 0;
    end else begin
        // Tick clock
        sec <= sec + 1;
        if (sec == 59) begin
            sec <= 0;
            min <= min + 1;
            if (min == 59) begin
                min <= 0;
                hour <= hour + 1;
                if (hour == 23) begin
                    hour <= 0;
                    day <= day + 1;
                    if (day > days_in_month(month, year) - 1) begin
                        day <= 1;
                        month <= month + 1;
                        if (month > 11) begin
                            month <= 1;
                            year <= year + 1;
                            if (year > 2025)
                                year <= 2020;
                        end
                    end
                end
            end
        end

        // Alarm trigger (trigger once when time >= alarm time)
        if (alarm_enable && !alarm_triggered &&
            ((hour > alarm_hour) ||
            (hour == alarm_hour && min > alarm_min) ||
            (hour == alarm_hour && min == alarm_min && sec >= alarm_sec))) begin
            alarm_buzzer <= 1;
            alarm_triggered <= 1;
            alarm_buzzer_counter <= 0;
        end

        // Optional: Alarm buzzer auto-off after 10 seconds
        if (alarm_buzzer) begin
            alarm_buzzer_counter <= alarm_buzzer_counter + 1;
            if (alarm_buzzer_counter >= 10) begin
                alarm_buzzer <= 0;
                alarm_buzzer_counter <= 0;
            end
        end

        // Timer start
        if (timer_start && !timer_running) begin
            timer_count_min <= timer_min;
            timer_count_sec <= timer_sec;
            timer_running <= 1;
            timer_buzzer <= 0;
        end

        // Timer countdown
        if (timer_running) begin
            if (timer_count_min == 0 && timer_count_sec == 0) begin
                timer_buzzer <= 1;
                timer_running <= 0;
            end else begin
                if (timer_count_sec == 0) begin
                    if (timer_count_min > 0) begin
                        timer_count_min <= timer_count_min - 1;
                        timer_count_sec <= 59;
                    end
                end else begin
                    timer_count_sec <= timer_count_sec - 1;
                end
            end
        end
    end
end

endmodule
