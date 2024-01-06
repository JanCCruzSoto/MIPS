module Handler (
  input wire [31:0] PB,
  input wire [31:0] HI,
  input wire [31:0] LO,
  input wire [31:0] PC,
  input wire [15:0] imm16,
  input wire [2:0] Si,
  output reg [31:0] N
);

  // Intermediate wire declarations
  wire [31:0] imm16_extended;
  wire [31:0] imm16_concat;

  // Assign intermediate wire values
  assign imm16_extended = {{16{imm16[15]}}, imm16}; // Sign extension of imm16
  assign imm16_concat = {imm16, 16'h0000}; // imm16 || 0x0000

  always @(*) begin
    case (Si)
      3'b000: N = PB;
      3'b001: N = HI;
      3'b010: N = LO;
      3'b011: N = PC;
      3'b100: N = imm16_extended;
      3'b101: N = imm16_concat;
      default: N = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; // 
    endcase
  end

endmodule