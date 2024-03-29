module blk_led(
    input       CLOCK,
    input       RESETN,
    output [1:0]RGB_LED);

wire clk0s;
wire clk1s;
wire clk2s;

reg led1;
reg led2;

clock_div #(.DIV_VALUE(`ONEM_DIV)) div0(
    .RESET(~RESETN),
    .CLOCK(CLOCK),
    .DIV(clk0s));

clock_en #(.DIV_VALUE(23)) div1(
    .RESET(~RESETN),
    .EN(clk0s),
    .CLOCK(CLOCK),
    .DIV(clk1s));

clock_en #(.DIV_VALUE(26)) div2(
    .RESET(~RESETN),
    .EN(clk0s),
    .CLOCK(CLOCK),
    .DIV(clk2s));

always @(posedge CLOCK)
begin
    if (~RESETN) begin
        led1 <= 1'b0;
        led2 <= 1'b0;
    end
    else begin
        if (clk1s)
                led1 <= ~led1;    
        if (clk2s)
                led2 <= ~led2;
    end
end

assign RGB_LED = {led2, led1};

endmodule
