module topcontroller(   input clk,
                        input rst,
                        input rxd,
                        output txd );
    
    wire [15:0] prescale=100000000/(115200*8);
    
    
    wire [7:0] senddata;
    reg sendvalid=0;
    
    wire [7:0] readdata;
    wire readvalid;
    
    reg [2:0] state=3'b000;
    
    reg [7:0] data1=8'b0,data2=8'b0;

    reg [31:0]addra;
    wire [31:0]douta;
    reg [31:0]dina;
    reg ena;
    reg rsta;
    reg [3:0]wea;
    

    uart uartuut(
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(senddata),
    .s_axis_tvalid(sendvalid),
    .m_axis_tdata(readdata),
    .m_axis_tvalid(readvalid),
    .m_axis_tready(1),
    .rxd(rxd),
    .txd(txd),
    .prescale(prescale));
  
    design_1_wrapper bram(
    .a_clk(clk),
    .a_addr(addra),
    .a_din(dina),
    .a_we(wea),
    .a_rst(rsta),
    .a_dout(douta),
    .a_en(ena));
    adder adderuut (.clk(clk),
                    .data1(data1),
                    .data2(data2),
                    .dataout(senddata));
    
always @(posedge clk) begin
    if(rst==1) begin
        state <= 0;
        sendvalid <= 0;
        data1 <= 0;
        data2 <= 0;
    end
    case(state)
        3'b000: begin
            sendvalid <= 0;
            if(readvalid) begin
                state <= 3'b001;
                rsta <= 0;
                ena <= 1;
                wea <= 4'b1111;
                addra <= 0;
                dina[7:0] <= readdata;
            end
        end
        3'b001: begin
            sendvalid <= 0;
            if(readvalid) begin
                state <= 3'b010;
                rsta <= 0;
                ena <= 1;
                wea <= 4'b1111;
                addra <= 1;
                dina[7:0] <= readdata;
            end
        end
        3'b010: begin
            state <= 3'b011;
            addra <= 0;
            wea <= 4'b0000;
            ena <= 1;
            rsta <= 0;
            sendvalid <= 0;
        end
        3'b011: begin
            state <= 3'b100;
            addra <= 0;
            wea <= 4'b0000;
            ena <= 1;
            rsta <= 0;
            data1 <= douta[7:0];
            sendvalid <= 0;
        end
        3'b100: begin
            state <= 3'b101;
            addra <= 1;
            wea <= 4'b0000;
            ena <= 1;
            rsta <= 0;
            sendvalid <= 0;
        end
        3'b101: begin
            state <= 3'b110;
            addra <= 0;
            wea <= 4'b0000;
            ena <= 1;
            rsta <= 0;
            data2 <= douta[7:0];
            sendvalid <= 0;
        end
        3'b110: begin
            sendvalid <= 1;
            state <= 3'b000;
        end
    endcase
end
endmodule
