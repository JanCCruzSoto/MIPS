module ALU (
    input wire [31:0] operand_A,
    input wire [31:0] operand_B,
    input wire [3:0]  alu_control,
    output reg [31:0] result,
    output wire       z_flag,
    output wire       n_flag
);
// comentario en el alu
// Initialize outputs
assign z_flag = (result == 32'b0);
assign n_flag = (result[31] == 1);

always @(*) begin

    case (alu_control)
    
        4'b0000: result = operand_A + operand_B;            // Suma
        4'b0001: result = operand_A - operand_B;            // Resta
        4'b0010: result = operand_A & operand_B;            // AND
        4'b0011: result = operand_A | operand_B;            // OR
        4'b0100: result = operand_A ^ operand_B;            // XOR
        4'b0101: result = ~(operand_A | operand_B);         // NOR
        4'b0110: result = operand_B << operand_A;           // Shift Left Lógico
        4'b0111: result = operand_B >> operand_A;           // Shift Right Lógico
        4'b1000: begin
            if (operand_B[31] == 1) 
                result = ({{31{1'b1}}, operand_B[31:0]} >> operand_A);
            else 
                result = ({{31{1'b0}}, operand_B[31:1]} >> operand_A);
        end
        4'b1001: result = (operand_A < operand_B) ? 32'b1 : 32'b0;  // Comparación (Out=1 si A < B, sino Out=0)
        4'b1010: result = operand_A;                       // Copiar A
        4'b1011: result = operand_B;             // Copiar B
        4'b1100: result = operand_B + 32'h8;               // B + 8
        default: result = 32'bxxxxxxxx;

    endcase

end

endmodule