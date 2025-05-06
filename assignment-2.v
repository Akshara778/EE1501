`timescale 1ns/1ps

module convolve(input [3:0] x [7:0], input [3:0] h [7:0], output reg [3:0] result [14:0]);
    integer i, j;
    always @(*) begin
        for(i=0;i<15;i=i+1) begin
            result[i] = 0;
        end
        for(i=0;i<8;i=i+1) begin
            for(j=0;j<8;j=j+1) begin
                result[i+j] = result[i+j] + (x[i] * h[j]);
            end
        end
    end
endmodule

module ripple_carry_adder_8_bit(input [7:0] a, input [7:0] b, input cin, output reg [7:0] sum, output reg cout);
    integer i;
    always @(*) begin
        cout = cin;
        for(i=0;i<8;i=i+1) begin
            sum[i] = a[i] ^ b[i] ^ cout;
            cout = (a[i] & b[i]) | (cout & a[i]) | (cout & b[i]);
        end
    end
endmodule

module and_gate(input a, input b, output res);
    wire temp1, temp2;
    nand #1(temp1, a, b);
    nand #1(res, temp1, temp1);
endmodule

module or_gate(input a, input b, output res);
    wire temp1, temp2;
    nand #1(temp1, a, a);
    nand #1(temp2, b, b);
    nand #1(res, temp1, temp2);
endmodule

module not_gate(input a, output res);
    nand #1(res, a, a);
endmodule

module xor_gate(input a, input b, output res);
    wire temp1, temp2, temp3;
    nand #1(temp1, a, b);
    nand #1(temp2, a, temp1);
    nand #1(temp3, b, temp1);
    nand #1(res, temp2, temp3);
endmodule

module adder(input a, input b, input cin, output sum, output cout);
    wire temp, temp1, temp2, temp3, temp4;
    xor_gate x1(a, b, temp);
    xor_gate x2(temp, cin, sum);
    and_gate a1(a, b, temp1);
    and_gate a2(b, cin, temp2);
    and_gate a3(a, cin, temp3);
    or_gate o1(temp1, temp2, temp4);
    or_gate o2(temp3, temp4, cout);
endmodule

module ripple_carry_adder_4_bit(input [3:0] a, input [3:0] b, input cin, output [3:0] sum, output cout);
    wire c1, c2, c3;
    adder a1(a[0], b[0], cin, sum[0], c1);
    adder a2(a[1], b[1], c1, sum[1], c2);
    adder a3(a[2], b[2], c2, sum[2], c3);
    adder a4(a[3], b[3], c3, sum[3], cout);
endmodule