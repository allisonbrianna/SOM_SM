//------------------------------------------------------
//
// Module: clock_div
// Description: divide clock by div_value 
//
//------------------------------------------------------
module clock_div
    #(parameter DIV_VALUE=75000)(
    input  RESET,
    input  CLOCK,
    output DIV);

localparam DIV_WIDTH = $clog2(DIV_VALUE);
reg [DIV_WIDTH-1:0]cnt;
reg div_en;

assign DIV = div_en;

always @ (posedge CLOCK)
begin
    if (RESET) begin
        div_en <= 1'b0;
        cnt    <= 1'b0;
    end
    else if (cnt < DIV_VALUE) begin
        div_en <= 1'b0;
        cnt    <= cnt + 1'b1;
    end
    else begin
        div_en <= 1'b1;
        cnt    <= 7'b0;
    end
end
endmodule
