//------------------------------------------------------
//
// Module: clock_en
// Description: enable one clock by div_value 
//
//------------------------------------------------------
module clock_en
    #(parameter DIV_VALUE=75000)(
    input  RESET,
    input  EN,
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
        cnt    <= 'b0;
    end
    else begin
        div_en <= 1'b0;
        if (EN) begin
            if (cnt < DIV_VALUE) begin
                cnt <= cnt + 'b1;
            end
            else begin
                div_en <= 1'b1;
                cnt    <= 7'b0;
            end
        end
    end
end
endmodule
