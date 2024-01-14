module Register_32bit_nPC (
    input             Clk,
    input             Reset,
    input             stallnPC,
    input [31:0]      DS,
    output reg [31:0] QS
  );
  always @(posedge Clk)
  begin
    if (Reset)
      QS <= 32'd4;
    else if (stallnPC)
      QS <= DS;
  end
endmodule

module Register_32bit_PC (
    input             Clk,
    input             Reset,
    input             stallPC,
    input [31:0]      DS,
    output reg [31:0] QS
  );
  always @(posedge Clk)
  begin
    if (Reset)
      QS <= 32'd0;
    else if (stallPC)
      QS <= DS;
  end
endmodule


