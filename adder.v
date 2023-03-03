module adder(   input clk,
                input [7:0] data1,
                input [7:0] data2,
                output reg [7:0] dataout);
        
always @(posedge clk ) begin
        dataout = data1 + data2;
end
endmodule