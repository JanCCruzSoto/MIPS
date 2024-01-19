// module ALU (
//     input wire [31:0] operand_A,
//     input wire [31:0] operand_B,
//     input wire [3:0]  alu_control,
//     output reg [31:0] result,
//     output reg       z_flag,
//     output reg       n_flag
// );
// // comentario en el alu
// // Initialize outputs
// // assign z_flag = (result == 32'b0);
// // assign n_flag = (result[31] == 1);

// always @(*) begin

//     z_flag <= (result == 32'b0);
//     n_flag <= (result[31] == 1);
//     case (alu_control)
    
//         4'b0000: result <= operand_A + operand_B;            // Suma
//         4'b0001: result <= operand_A - operand_B;            // Resta
//         4'b0010: result <= operand_A & operand_B;            // AND
//         4'b0011: result <= operand_A | operand_B;            // OR
//         4'b0100: result <= operand_A ^ operand_B;            // XOR
//         4'b0101: result <= ~(operand_A | operand_B);         // NOR
//         4'b0110: result <= operand_B << operand_A;           // Shift Left Lógico
//         4'b0111: result <= operand_B >> operand_A;           // Shift Right Lógico
//         4'b1000: begin
//             if (operand_B[31] == 1) 
//                 result <= ({{31{1'b1}}, operand_B[31:0]} >> operand_A);
//             else 
//                 result <= ({{31{1'b0}}, operand_B[31:1]} >> operand_A);
//         end
//         4'b1001: result <= (operand_A < operand_B) ? 32'b1 : 32'b0;  // Comparación (result=1 si operand_A < operand_B, sino result=0)
//         4'b1010: result <= operand_A;                       // Copiar operand_A
//         4'b1011: result <= operand_B;             // Copiar operand_B
//         4'b1100: result <= operand_B + 32'h8;               // operand_B + 8
//         default: result <= 32'b0;

//     endcase

// end
// endmodule





module ALU (
    input [31:0] operand_A,
    input [31:0] operand_B,
    input [3:0] alu_control,
    output reg [31:0] result,
    output reg z_flag,
    output reg n_flag
);

always @ (*) begin
    case(alu_control)
        4'b0000: begin // operand_A + operand_B, z_flag n_flag
            result = operand_A + operand_B;
            z_flag = (result == 32'b0);
            n_flag = (result[31] == 1);
        end
        4'b0001: begin // operand_A - operand_B, z_flag n_flag
            result = operand_A - operand_B;
            z_flag = (result == 32'b0);
            n_flag = (result[31] == 1);
        end
        4'b0010: begin // operand_A and operand_B ,none
            result = operand_A & operand_B;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b0011: begin // operand_A or operand_B ,none
            result = operand_A | operand_B;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b0100: begin // operand_A xor operand_B,none
            result = operand_A ^ operand_B;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b0101: begin // operand_A nor operand_B ,none
            result = ~(operand_A | operand_B);
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b0110: begin // shift left logical (operand_B) operand_A positions 
            result = operand_B << operand_A;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b0111: begin // shift right logical (operand_B) operand_A positions 
            result = operand_B >> operand_A;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b1000: begin // shift right arithmetic (operand_B) operand_A positions 
            result = $signed(operand_B) >>> operand_A;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
        4'b1001: begin // If (operand_A < operand_B) then result=1, else result=0 ,z_flag n_flag
            result = (operand_A < operand_B) ? 1 : 0;
            z_flag = (result == 0); 
            n_flag = 1'b0;     
        end
        4'b1010: begin // operand_A 
            result = operand_A;
            z_flag = (result == 32'b0);
            n_flag = (result[31] == 1);
        end
        4'b1011: begin // operand_B 
            result = operand_B;
            z_flag = (result == 32'b0);
            n_flag = (result[31] == 1);
        end
        4'b1100: begin // operand_B + 8 
            result = operand_B + 8;
            z_flag = (result == 32'b0);
            n_flag = (result[31] == 1);
        end
        default: begin
            result = 32'b0;
            z_flag = 1'b0;
            n_flag = 1'b0;
        end
    endcase
end

endmodule
