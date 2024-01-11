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

    // Input Control Signals
    input wire [3:0]    ID_ALU_OP,        // 4 BIT BUS (ALU CONTROL)
    input wire          ID_LOAD_INSTR,    // LOAD INSTRUCTIONS
    input wire          ID_RF_ENABLE,     // REGISTER FILE ENABLE
    input wire          ID_HI_ENABLE,     // HI REGISTER ENABLE
    input wire          ID_LO_ENABLE,     // LO REGISTER ENABLE
    input wire          ID_PC_PLUS8_INSTR,// STORING PC+8
    input wire [2:0]    ID_OP_H_S,        // OPERATION HANDLER CONTROL SIGNAL
    input wire          ID_MEM_ENABLE,    // DATA MEMORY ENABLE
    input wire          ID_MEM_READWRITE, // LOAD(READ) OR STORE(WRITE)
    input wire [1:0]    ID_MEM_SIZE,      // SIZE OF STORE
    input wire          ID_MEM_SIGNE,     // SIGN EXTENSION
    input wire [31:0] ID_PC_PLUS8_RESULT,
    input wire [31:0] MX1_RESULT,
    input wire [31:0] MX2_RESULT,
    input wire [31:0] ID_HI_QS,
    input wire [31:0] ID_LO_QS,
    input wire [31:0] ID_PC,
    input wire [15:0] ID_IMM16,
    input wire [4:0] ID_RT,

    // Output Contræl Signals
    output reg [3:0]  OUT_ID_ALU_OP,          // 4 bit BUS (ALU CONTROL)
    output reg        OUT_ID_LOAD_INSTR,      // LOAD INSTRUCTIONS
    output reg        OUT_ID_RF_ENABLE,       // Register file enable
    output reg        OUT_ID_HI_ENABLE,       // HI register enable
    output reg        OUT_ID_LO_ENABLE,       // LO register enable
    output reg        OUT_ID_PC_PLUS8_INSTR,  // Storing PC+8
    output reg [2:0]  OUT_ID_OP_H_S,          // Operation Handler Control Signal
    output reg        OUT_ID_MEM_ENABLE,      // Data memory enable
    output reg        OUT_ID_MEM_READWRITE,   // Load(read) or store(write)
    output reg [1:0]  OUT_ID_MEM_SIZE,        // Size of Store
    output reg        OUT_ID_MEM_SIGNE,       // Sign extension
    output reg [31:0] OUT_ID_PC_PLUS8_RESULT, // maybe 8 bits
    output reg [31:0] OUT_ID_HI_QS,
    output reg [31:0] OUT_ID_LO_QS,
    output reg        OUT_EnableEX,
    output reg [4:0]  OUT_regEX,
    output reg [4:0]  OUT_regMEM,
    output reg [4:0]  OUT_regWB,
    output reg [4:0]  OUT_ID_RT
  );

  always @(posedge Clk)
  begin
    if (Reset)
    begin
      OUT_ID_ALU_OP           <= 4'b0;
      OUT_ID_LOAD_INSTR       <= 1'b0;
      OUT_ID_RF_ENABLE        <= 1'b0;
      OUT_ID_HI_ENABLE        <= 1'b0;
      OUT_ID_LO_ENABLE        <= 1'b0;
      OUT_ID_PC_PLUS8_INSTR   <= 1'b0;
      OUT_ID_OP_H_S           <= 3'b0;
      OUT_ID_MEM_ENABLE       <= 1'b0;
      OUT_ID_MEM_READWRITE    <= 1'b0;
      OUT_ID_MEM_SIZE         <= 2'b0;
      OUT_ID_MEM_SIGNE        <= 1'b0;
      OUT_ID_PC_PLUS8_RESULT  <= 32'b0;
      OUT_ID_HI_QS            <= 32'b0;
      OUT_ID_LO_QS            <= 32'b0;
      OUT_EnableEX            <= 1'b0;
      OUT_regEX               <= 5'b0;
      OUT_regMEM              <= 5'b0;
      OUT_regWB               <= 5'b0;
      OUT_ID_RT               <= 5'b0;
    end
    else
    begin
      OUT_ID_ALU_OP           <= ID_ALU_OP;
      OUT_ID_LOAD_INSTR       <= ID_LOAD_INSTR;
      OUT_ID_RF_ENABLE        <= ID_RF_ENABLE;
      OUT_ID_HI_ENABLE        <= ID_HI_ENABLE;
      OUT_ID_LO_ENABLE        <= ID_LO_ENABLE;
      OUT_ID_PC_PLUS8_INSTR   <= ID_PC_PLUS8_INSTR;
      OUT_ID_OP_H_S           <= ID_OP_H_S;
      OUT_ID_MEM_ENABLE       <= ID_MEM_ENABLE;
      OUT_ID_MEM_READWRITE    <= ID_MEM_READWRITE;
      OUT_ID_MEM_SIZE         <= ID_MEM_SIZE;
      OUT_ID_MEM_SIGNE        <= ID_MEM_SIGNE;
      OUT_ID_RT               <= ID_RT;                   // Added RT in module
      OUT_ID_PC_PLUS8_RESULT  <= ID_PC_PLUS8_RESULT;
      OUT_ID_HI_QS            <= MX1_RESULT;
      OUT_ID_LO_QS            <= MX2_RESULT;
      OUT_EnableEX            <= ID_HI_QS;
      OUT_regEX               <= ID_LO_QS;
      OUT_regMEM              <= ID_PC;
      OUT_regWB               <= ID_IMM16;
    end
  end
endmodule

module Pipeline_Register_32bit_EX_MEM ( /*EX/MEM REGISTER*/
    input wire Clk,                       // CLOCK SIGNAL
    input wire Reset,                     // RESET SIGNAL

    // Input Control Signals
    input wire        EX_LOAD_INSTR,       // LOAD INSTRUCTIONS
    input wire        EX_RF_ENABLE,        // REGISTER FILE ENABLE
    input wire        EX_HI_ENABLE,        // HI REGISTER ENABLE
    input wire        EX_LO_ENABLE,        // LO REGISTER ENABLE
    input wire        EX_PC_PLUS8_INSTR,   // STORING PC+8
    input wire        EX_MEM_ENABLE,       // DATA MEMORY ENABLE
    input wire        EX_MEM_READWRITE,    // LOAD(READ) OR STORE(WRITE)
    input wire [1:0]  EX_MEM_SIZE,         // SIZE OF STORE
    input wire        EX_MEM_SIGNE,        // SIGN EXTENSION
    input wire [31:0] EX_ADDRESS,          // OUTPUT FROM THE ALU
    input wire        EX_ENABLE_MEM,

    // Output ContrEX Signals
    output reg        OUT_EX_LOAD_INSTR,     // LOAD INSTRUCTIONS
    output reg        OUT_EX_RF_ENABLE,      // REGISTER FILE ENABLE
    output reg        OUT_EX_HI_ENABLE,      // HI REGISTER ENABLE
    output reg        OUT_EX_LO_ENABLE,      // LO REGISTER ENABLE
    output reg        OUT_EX_PC_PLUS8_INSTR, // STORING PC+8
    output reg        OUT_EX_MEM_ENABLE,     // DATA MEMORY ENABLE
    output reg        OUT_EX_MEM_READWRITE,  // LOAD(READ) OR STORE(WRITE)
    output reg [1:0]  OUT_EX_MEM_SIZE,       // SIZE OF STORE
    output reg        OUT_EX_MEM_SIGNE,      // SIGN EXTENSION
    output reg        OUT_EnableMEM,
    output reg [8:0]  OUT_EX_ADDRESS
  );
  always @(posedge Clk)
  begin

    if (Reset)
    begin
      OUT_EX_LOAD_INSTR       <= 1'b0;
      OUT_EX_RF_ENABLE        <= 1'b0;
      OUT_EX_HI_ENABLE        <= 1'b0;
      OUT_EX_LO_ENABLE        <= 1'b0;
      OUT_EX_PC_PLUS8_INSTR   <= 1'b0;
      OUT_EX_MEM_ENABLE       <= 1'b0;
      OUT_EX_MEM_READWRITE    <= 1'b0;
      OUT_EX_MEM_SIZE         <= 2'b0;
      OUT_EX_MEM_SIGNE        <= 1'b0;
      OUT_EnableMEM           <= 1'b0;
    end
    else
    begin
      OUT_EX_LOAD_INSTR       <= EX_LOAD_INSTR;
      OUT_EX_RF_ENABLE        <= EX_RF_ENABLE;
      OUT_EX_HI_ENABLE        <= EX_HI_ENABLE;
      OUT_EX_LO_ENABLE        <= EX_LO_ENABLE;
      OUT_EX_PC_PLUS8_INSTR   <= EX_PC_PLUS8_INSTR;
      OUT_EX_MEM_ENABLE       <= EX_MEM_ENABLE;
      OUT_EX_MEM_READWRITE    <= EX_MEM_READWRITE;
      OUT_EX_MEM_SIZE         <= EX_MEM_SIZE;
      OUT_EX_MEM_SIGNE        <= EX_MEM_SIGNE;
      OUT_EnableMEM           <= EX_ENABLE_MEM;
      OUT_EX_ADDRESS          <= EX_ADDRESS[8:0];
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





