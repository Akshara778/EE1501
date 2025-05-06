module priority_encoder(input [3:0] in, output reg [1:0] out, output reg valid);

    always @(*) begin
        valid = |in;
        casez(in)
            4'b1zzz : out = 2'd3;
            4'b01zz : out = 2'd2;
            4'b001z : out = 2'd1;
            4'b0001 : out = 2'd0;
            default : out = 2'd0;
        endcase
    end

endmodule


module up_counter(input clk, output reg [3:0] count, input enable, input reset);

    always @(posedge clk or posedge reset) begin
        if(reset)
            count <= 4'd0;
        else if(enable) begin
            if(count == 4'd15) begin
                count <= 4'd0;
            end
            else begin
                //using k maps for T flip flops
                count[0] <= ~count[0];
                count[1] <= count[1] ^ count[0];
                count[2] <= count[2] ^ (count[0] & count[1]);
                count[3] <= count[3] ^ (count[0] & count[1] & count[2]);
            end
        end
    end

endmodule


module even_parity_generator (input [7:0] data, output parity);

    assign parity = ^data;

endmodule
