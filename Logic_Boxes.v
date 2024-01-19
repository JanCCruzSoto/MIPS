module Sum_Logic_Box ( /*USED FOR CONDITIONAL TARGET ADDRESS CALCULATION*/
    input wire [31:0] First_Value, //PC+4 TODO: SE CAMBIO DE 9 BIT A 32
    input wire [31:0] Second_Value, //4*imm16 // TODO: SE CAMBIO DE 16 A 32 BIT

    output reg [31:0] Result        // TODO: SE CAMBIO DE 16 A 32 BIT
  );
  always @(*) begin
    Result <= First_Value + Second_Value;
  end
endmodule

module Plus_8_Logic_Box ( /*USED FOR CALCULATING PC + 8 ON ID STAGE*/
    input wire [31:0] PC,
    output reg [31:0] Result
  );
  always@(PC)
  begin
    Result = PC + 4'd8;
  end
endmodule

module Bitwise_AND_Logic_Box ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
    input wire [31:0] PC,   // TODO: SE CAMBIO DE 9 A 32
    input wire [31:0] Second_Value, //Would be a Direct 32'hf0000000

    output reg [31:0] Result
  );
  always@(PC)
  begin
    Result = PC & Second_Value;
  end
endmodule

module Bitwise_OR_Logic_Box ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
    input wire [31:0] AND_Output,
    input wire [31:0] Address26_x4_Output,

    output reg [31:0] Result
  );
  always@(AND_Output || Address26_x4_Output)
  begin
    Result = AND_Output | Address26_x4_Output;
  end
endmodule

module Times_Four_Logic_Box_Case_One( /*USED FOR Imm16 FOR CONDITIONAL TA*/
    input wire [15:0] Imm16,

    output reg [31:0] Result
  );

  wire [31:0] Imm16_extended;
  assign Imm16_extended = {{16{Imm16[15]}}, Imm16}; // Sign extension of imm16

  always@(*)
  begin
    Result = Imm16_extended * 3'd4;
  end
endmodule

module Times_Four_Logic_Box_Case_Two( /*USED FOR HANDLING Address26 FOR UNCONDITIONAL TA*/
    input wire [25:0] Address26,
    output reg [31:0] Result // Changed to 32-bit to hold the multiplication result
  );

  wire [31:0] Address26_extended;
  assign Address26_extended = {{6{Address26[25]}}, Address26}; // Sign extension of Address26

  always@(*)
  begin
    Result = Address26_extended * 4; // Multiplies by 4
  end
endmodule



module nPCLogicBox (
    input wire [31:0] nPC,
    output reg [31:0] result
  );
  always@(nPC)
  begin
    result = nPC + 9'd4;
  end
endmodule


module HiRegister (
    input clk,
    input HiEnable,
    input [31:0] PW,
    output reg [31:0] HiSignal
  );

  // Update HiSignal with PW on the rising edge of clk if HiEnable is high
  always @(posedge clk)
  begin
    if (HiEnable) HiSignal <= PW;
    else HiSignal <= 32'b0;
  end

endmodule

module LoRegister (
    input clk,
    input LoEnable,
    input [31:0] PW,
    output reg [31:0] LoSignal
  );

  // Update LoSignal with PW on the rising edge of clk if LoEnable is high
  always @(posedge clk)
  begin
    if (LoEnable) LoSignal <= PW;
    else LoSignal <= 32'b0;
  end

endmodule
