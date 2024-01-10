module Pipeline_Register_32bit_IF_ID ( /*IF/ID REGISTER*/
  input wire [31:0] DS, PC,     // 32-bit Instruction
  input wire Clk, LE,        // Clock signal
  input wire Reset,        // Reset signal
  //PC y LE
  
  output reg [31:0] Qs, PC_out,    // 32-bit Instruction
  //falta conectar el out

  // TODO modifications
  
  output reg [15:0] OUT_IF_IMM16,
  output reg [31:0] OUT_ID_OPERAND_A,
  output reg [31:0] OUT_ID_OPERAND_B
  
);

always @(posedge Clk)
begin
// instancias mas declaracion
    Qs <= DS;

    if (Reset)
    begin
        Qs <= 32'b0; //Resets to decimal 4
        PC_out <= 32'b0;
    end
    else if (LE) begin
        Qs <= DS;
        PC_out <= PC;
    end
end

endmodule

module Pipeline_Register_32bit_ID_EX ( /*ID/EX REGISTER*/ //WILL NEED CHANGES IN THE INPUTS NON RELATED TO CONTROL SIGNALS
  //input wire [31:0] DS,    // 32-bit input data
  input wire Clk,         // Clock signal
  input wire Reset,        // Reset signal
  //output reg [31:0] Qs    // 32-bit output data

  // Input Control Signals
  input wire [3:0]    ID_ALU_OP, //4 bit BUS (ALU CONTROL)
  input wire          ID_LOAD_INSTR, //load instructions
  input wire          ID_RF_ENABLE, //register file enable
  input wire          ID_HI_ENABLE, //HI register enable
  input wire          ID_LO_ENABLE, //LO register enable
  input wire          ID_PC_PLUS8_INSTR, //storing PC+8
  input wire [2:0]    ID_OP_H_S, //Operation Handler Control Signal
  input wire          ID_MEM_ENABLE, //data memory enable
  input wire          ID_MEM_READWRITE, //load(read) or store(write)
  input wire [1:0]    ID_MEM_SIZE, //size of Store
  input wire          ID_MEM_SIGNE, //sign extension


  // Output Control Signals
  output reg [3:0]  Out_ID_ALU_OP, //4 bit BUS (ALU CONTROL)
  output reg        Out_ID_LOAD_INSTR, //load instructions
  output reg        Out_ID_RF_ENABLE, //register file enable
  output reg        Out_ID_HI_ENABLE, //HI register enable
  output reg        Out_ID_LO_ENABLE, //LO register enable
  output reg        Out_ID_PC_PLUS8_INSTR, //storing PC+8
  output reg [2:0]  Out_ID_OP_H_S, //Operation Handler Control Signal
  output reg        Out_ID_MEM_ENABLE, //data memory enable
  output reg        Out_ID_MEM_READWRITE, //load(read) or store(write)
  output reg [1:0]  Out_ID_MEM_SIZE, //size of Store
  output reg        Out_ID_MEM_SIGNE //sign extension


);

always @(posedge Clk)
begin

    if (Reset)
    begin
      Out_ID_ALU_OP <= 4'b0;
      Out_ID_LOAD_INSTR <= 1'b0;
      Out_ID_RF_ENABLE <= 1'b0;
      Out_ID_HI_ENABLE <= 1'b0;
      Out_ID_LO_ENABLE <= 1'b0;
      Out_ID_PC_PLUS8_INSTR <= 1'b0;
      Out_ID_OP_H_S <= 3'b0;
      Out_ID_MEM_ENABLE <= 1'b0;
      Out_ID_MEM_READWRITE <= 1'b0;
      Out_ID_MEM_SIZE <= 2'b0;
      Out_ID_MEM_SIGNE <= 1'b0;
    end
    else begin
    Out_ID_ALU_OP <= ID_ALU_OP;
    Out_ID_LOAD_INSTR <= ID_LOAD_INSTR;
    Out_ID_RF_ENABLE <= ID_RF_ENABLE;
    Out_ID_HI_ENABLE <= ID_HI_ENABLE;
    Out_ID_LO_ENABLE <= ID_LO_ENABLE;
    Out_ID_PC_PLUS8_INSTR <= ID_PC_PLUS8_INSTR;
    Out_ID_OP_H_S <= ID_OP_H_S;
    Out_ID_MEM_ENABLE <= ID_MEM_ENABLE;
    Out_ID_MEM_READWRITE <= ID_MEM_READWRITE;
    Out_ID_MEM_SIZE <= ID_MEM_SIZE;
    Out_ID_MEM_SIGNE <= ID_MEM_SIGNE;
    end

    
end

endmodule

module Pipeline_Register_32bit_EX_MEM ( /*EX/MEM REGISTER*/
  //input wire [31:0] DS,    // 32-bit input data
  input wire Clk,         // Clock signal
  input wire Reset,        // Reset signal
  //output reg [31:0] Qs    // 32-bit output data

  // Input Control Signals
  input wire ID_LOAD_INSTR, //load instructions
  input wire ID_RF_ENABLE, //register file enable
  input wire ID_HI_ENABLE, //HI register enable
  input wire ID_LO_ENABLE, //LO register enable
  input wire ID_PC_PLUS8_INSTR, //storing PC+8
  input wire ID_MEM_ENABLE, //data memory enable
  input wire ID_MEM_READWRITE, //load(read) or store(write)
  input wire [1:0] ID_MEM_SIZE, //size of Store
  input wire ID_MEM_SIGNE, //sign extension


  // Output Control Signals
  output reg Out_ID_LOAD_INSTR, //load instructions
  output reg Out_ID_RF_ENABLE, //register file enable
  output reg Out_ID_HI_ENABLE, //HI register enable
  output reg Out_ID_LO_ENABLE, //LO register enable
  output reg Out_ID_PC_PLUS8_INSTR, //storing PC+8
  output reg Out_ID_MEM_ENABLE, //data memory enable
  output reg Out_ID_MEM_READWRITE, //load(read) or store(write)
  output reg [1:0] Out_ID_MEM_SIZE, //size of Store
  output reg Out_ID_MEM_SIGNE //sign extension
);

always @(posedge Clk)
begin

    if (Reset)
    begin
      Out_ID_LOAD_INSTR <= 1'b0;
      Out_ID_RF_ENABLE <= 1'b0;
      Out_ID_HI_ENABLE <= 1'b0;
      Out_ID_LO_ENABLE <= 1'b0;
      Out_ID_PC_PLUS8_INSTR <= 1'b0;
      Out_ID_MEM_ENABLE <= 1'b0;
      Out_ID_MEM_READWRITE <= 1'b0;
      Out_ID_MEM_SIZE <= 2'b0;
      Out_ID_MEM_SIGNE <= 1'b0;
    end
    else begin
    Out_ID_LOAD_INSTR <= ID_LOAD_INSTR;
    Out_ID_RF_ENABLE <= ID_RF_ENABLE;
    Out_ID_HI_ENABLE <= ID_HI_ENABLE;
    Out_ID_LO_ENABLE <= ID_LO_ENABLE;
    Out_ID_PC_PLUS8_INSTR <= ID_PC_PLUS8_INSTR;
    Out_ID_MEM_ENABLE <= ID_MEM_ENABLE;
    Out_ID_MEM_READWRITE <= ID_MEM_READWRITE;
    Out_ID_MEM_SIZE <= ID_MEM_SIZE;
    Out_ID_MEM_SIGNE <= ID_MEM_SIGNE;
    end
    
end

endmodule

module Pipeline_Register_32bit_MEM_WB ( /*MEM/WB REGISTER*/
  //input wire [31:0] DS,    // 32-bit input data
  input wire Clk,         // Clock signal
  input wire Reset,        // Reset signal
  //output reg [31:0] Qs    // 32-bit output data

  // Input Control Signals
  input wire ID_RF_ENABLE, //register file enable
  input wire ID_HI_ENABLE, //HI register enable
  input wire ID_LO_ENABLE, //LO register enable


  // Output Control Signals
  output reg Out_ID_RF_ENABLE, //register file enable
  output reg Out_ID_HI_ENABLE, //HI register enable
  output reg Out_ID_LO_ENABLE //LO register enable
);

always @(posedge Clk)

begin
    if (Reset)
    begin
      Out_ID_RF_ENABLE <= 1'b0;
      Out_ID_HI_ENABLE <= 1'b0;
      Out_ID_LO_ENABLE <= 1'b0;
    end
    else begin
    Out_ID_RF_ENABLE <= ID_RF_ENABLE;
    Out_ID_HI_ENABLE <= ID_HI_ENABLE;
    Out_ID_LO_ENABLE <= ID_LO_ENABLE;
    end
end

endmodule
