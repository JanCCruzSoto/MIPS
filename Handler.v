module Handler (
    input [31:0] PB, HI, LO, PC,
    input [15:0] imm16,
    input [2:0] Si,
    output reg [31:0] N
);

always @(*) begin  // Changed from @(S0_S2) to @(*) for sensitivity to all inputs
    case(Si)
        3'b000: N = PB;
        3'b001: N = HI;
        3'b010: N = LO;
        3'b011: N = PC;
        3'b100: N = {{16{imm16[15]}}, imm16};  // Sign extension
        3'b101: N = {16'b0000000000000000, imm16}; // Zero extension
        default: N = 32'b0;  // Default case
    endcase
end

endmodule
