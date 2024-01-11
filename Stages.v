module Pipeline_Register_32bit_IF_ID ( /*IF/ID REGISTER*/
    input wire [31:0] DS, PC,         // 32-bit Instruction
    input wire Clk, LE,               // CLOCK SIGNAL AND ENABLE SIGNAL
    input wire Reset,                 // RESET SIGNAL
    output reg [31:0] Qs, PC_out,     // 32-bit Instruction
    output reg [15:0] OUT_IF_IMM16,
    output reg [4:0]  OUT_IF_OPERAND_A,
    output reg [4:0]  OUT_IF_OPERAND_B
  );

  always @(posedge Clk)
  begin
    Qs <= DS;
    if (Reset)
    begin
      Qs                  <= 32'b0;   // setting the instruction set to 000000000000000000000000
      PC_out              <= 32'b0;
      OUT_IF_IMM16        <= 15'b0;
      OUT_IF_OPERAND_A    <= 5'b0;
      OUT_IF_OPERAND_B    <= 5'b0;
    end
    else if (LE)
    begin
      Qs                  <= DS;
      PC_out              <= PC;
      OUT_IF_IMM16        <= DS[15:0];
      OUT_IF_OPERAND_A    <= DS[25:21]; // ALSO KNOWN AS RS, ENTERS TO RA IN THE REG FILE
      OUT_IF_OPERAND_B    <= DS[20:16]; // ALSO KNOWN AS RT, ENTERS TO RB IN THE REG FILE
      Qs <= DS;
      PC_out <= PC;
    end
  end

endmodule

module Pipeline_Register_32bit_ID_EX ( /*ID/EX REGISTER*/ //WILL NEED CHANGES IN THE INPUTS NON RELATED TO CONTROL SIGNALS
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

    // TODO modification inputs

    input wire [31:0] ID_PC_PLUS8_RESULT, //  maybe 8 bits
    input wire [31:0] MX1_RESULT,
    input wire [31:0] MX2_RESULT,
    input wire [31:0] ID_HI_QS,
    input wire [31:0] ID_LO_QS,
    input wire [31:0] ID_PC,
    input wire [15:0] ID_IMM16,
    input wire [4:0] ID_REG,

    //TODO modifications inputs

    input wire [4:0] ID_RT,


    // Output Control Signals
    output reg [3:0]  OUT_ID_ALU_OP,     // 4 bit BUS (ALU CONTROL)
    output reg        OUT_ID_LOAD_INSTR, // LOAD INSTRUCTIONS
    output reg        OUT_ID_RF_ENABLE, //register file enable
    output reg        OUT_ID_HI_ENABLE, //HI register enable
    output reg        OUT_ID_LO_ENABLE, //LO register enable
    output reg        OUT_ID_PC_PLUS8_INSTR, //storing PC+8
    output reg [2:0]  OUT_ID_OP_H_S, //Operation Handler Control Signal
    output reg        OUT_ID_MEM_ENABLE, //data memory enable
    output reg        OUT_ID_MEM_READWRITE, //load(read) or store(write)
    output reg [1:0]  OUT_ID_MEM_SIZE, //size of Store
    output reg        OUT_ID_MEM_SIGNE, //sign extension

    // TODO modifications outputs
    output reg [31:0] OUT_ID_PC_PLUS8_RESULT, // maybe 8 bits
    output reg [31:0] OUT_ID_HI_QS,
    output reg [31:0] OUT_ID_LO_QS,
    output reg        OUT_EnableEX,
    output reg [4:0] OUT_regEX,
    output reg [4:0] OUT_regMEM,
    output reg [4:0] OUT_regWB,
    output reg [4:0] OUT_ID_RT


  );

  always @(posedge Clk)
  begin

    if (Reset)
    begin
      OUT_ID_ALU_OP <= 4'b0;
      OUT_ID_LOAD_INSTR <= 1'b0;
      OUT_ID_RF_ENABLE <= 1'b0;
      OUT_ID_HI_ENABLE <= 1'b0;
      OUT_ID_LO_ENABLE <= 1'b0;
      OUT_ID_PC_PLUS8_INSTR <= 1'b0;
      OUT_ID_OP_H_S <= 3'b0;
      OUT_ID_MEM_ENABLE <= 1'b0;
      OUT_ID_MEM_READWRITE <= 1'b0;
      OUT_ID_MEM_SIZE <= 2'b0;
      OUT_ID_MEM_SIGNE <= 1'b0;
    end
    else
    begin
      OUT_ID_ALU_OP <= ID_ALU_OP;
      OUT_ID_LOAD_INSTR <= ID_LOAD_INSTR;
      OUT_ID_RF_ENABLE <= ID_RF_ENABLE;
      OUT_ID_HI_ENABLE <= ID_HI_ENABLE;
      OUT_ID_LO_ENABLE <= ID_LO_ENABLE;
      OUT_ID_PC_PLUS8_INSTR <= ID_PC_PLUS8_INSTR;
      OUT_ID_OP_H_S <= ID_OP_H_S;
      OUT_ID_MEM_ENABLE <= ID_MEM_ENABLE;
      OUT_ID_MEM_READWRITE <= ID_MEM_READWRITE;
      OUT_ID_MEM_SIZE <= ID_MEM_SIZE;
      OUT_ID_MEM_SIGNE <= ID_MEM_SIGNE;
      OUT_ID_RT <= ID_RT;                          // Added RT in module
    end


  end

endmodule

module Pipeline_Register_32bit_EX_MEM ( /*EX/MEM REGISTER*/
    //input wire [31:0] DS,    // 32-bit input data
    input wire Clk,         // Clock signal
    input wire Reset,        // Reset signal
    //output reg [31:0] Qs    // 32-bit output data

    // Input Control Signals
    input wire EX_LOAD_INSTR, //load instructions
    input wire EX_RF_ENABLE, //register file enable
    input wire EX_HI_ENABLE, //HI register enable
    input wire EX_LO_ENABLE, //LO register enable
    input wire EX_PC_PLUS8_INSTR, //storing PC+8
    input wire EX_MEM_ENABLE, //data memory enable
    input wire EX_MEM_READWRITE, //load(read) or store(write)
    input wire [1:0] EX_MEM_SIZE, //size of Store
    input wire EX_MEM_SIGNE, //sign extension

    //TODO modification input

    input wire [8:0] EX_ADDRESS,

    // Output ContrEX Signals
    output reg OUT_EX_LOAD_INSTR, //load instructions
    output reg OUT_EX_RF_ENABLE, //register file enable
    output reg OUT_EX_HI_ENABLE, //HI register enable
    output reg OUT_EX_LO_ENABLE, //LO register enable
    output reg OUT_EX_PC_PLUS8_INSTR, //storing PC+8
    output reg OUT_EX_MEM_ENABLE, //data memory enable
    output reg OUT_EX_MEM_READWRITE, //load(read) or store(write)
    output reg [1:0] OUT_EX_MEM_SIZE, //size of Store
    output reg OUT_EX_MEM_SIGNE, //sign extension

    //TODO modification output

    output reg OUT_EnableMEM
  );

  always @(posedge Clk)
  begin

    if (Reset)
    begin
      OUT_EX_LOAD_INSTR <= 1'b0;
      OUT_EX_RF_ENABLE <= 1'b0;
      OUT_EX_HI_ENABLE <= 1'b0;
      OUT_EX_LO_ENABLE <= 1'b0;
      OUT_EX_PC_PLUS8_INSTR <= 1'b0;
      OUT_EX_MEM_ENABLE <= 1'b0;
      OUT_EX_MEM_READWRITE <= 1'b0;
      OUT_EX_MEM_SIZE <= 2'b0;
      OUT_EX_MEM_SIGNE <= 1'b0;
    end
    else
    begin
      OUT_EX_LOAD_INSTR <= EX_LOAD_INSTR;
      OUT_EX_RF_ENABLE <= EX_RF_ENABLE;
      OUT_EX_HI_ENABLE <= EX_HI_ENABLE;
      OUT_EX_LO_ENABLE <= EX_LO_ENABLE;
      OUT_EX_PC_PLUS8_INSTR <= EX_PC_PLUS8_INSTR;
      OUT_EX_MEM_ENABLE <= EX_MEM_ENABLE;
      OUT_EX_MEM_READWRITE <= EX_MEM_READWRITE;
      OUT_EX_MEM_SIZE <= EX_MEM_SIZE;
      OUT_EX_MEM_SIGNE <= EX_MEM_SIGNE;
    end

  end

endmodule

module Pipeline_Register_32bit_MEM_WB ( /*MEM/WB REGISTER*/
    //input wire [31:0] DS,    // 32-bit input data
    input wire Clk,         // Clock signal
    input wire Reset,        // Reset signal
    //output reg [31:0] Qs    // 32-bit output data

    // Input Control Signals
    input wire MEM_RF_ENABLE, // Register file enable
    input wire MEM_HI_ENABLE, // HI register enable
    input wire MEM_LO_ENABLE, // LO register enable


    // Output Control Signals
    output reg OUT_MEM_RF_ENABLE, //register file enable
    output reg OUT_MEM_HI_ENABLE, //HI register enable
    output reg OUT_MEM_LO_ENABLE, //LO register enable


    // HI AND LO REGISTER OUTPUTS
    output reg OUT_WB_LO_ENABLE,     // LO register enable
    output reg OUT_WB_HI_ENABLE,     // HI register enable

    output reg OUT_RW_REGISTER_FILE, // maybe have more or less bits lol
    output reg OUT_EnableMEM
  );

  always @(posedge Clk)
    //COMENTARIO BOBO
  begin
    if (Reset)
    begin
      OUT_MEM_RF_ENABLE <= 1'b0;
      OUT_MEM_HI_ENABLE <= 1'b0;
      OUT_MEM_LO_ENABLE <= 1'b0;
    end
    else
    begin
      OUT_MEM_RF_ENABLE <= MEM_RF_ENABLE;
      OUT_MEM_HI_ENABLE <= MEM_HI_ENABLE;
      OUT_MEM_LO_ENABLE <= MEM_LO_ENABLE;
    end
  end

endmodule






