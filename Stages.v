module Pipeline_Register_32bit_IF_ID (
    input wire Clk,
    input wire LE,
    input wire Reset,   // not used
    input wire [31:0] DS, // 32-bit Instruction
    input wire [31:0] PC, // counter
    output reg [31:0] Qs, // 32-bit Instruction OUT
    output reg [31:0] PC_out,
    output reg [15:0] OUT_IF_IMM16,               // Imm16
    output reg [4:0]  OUT_IF_OPERAND_A,           // ALSO KNOWN AS RS, ENTERS TO RA IN THE REG FILE
    output reg [4:0]  OUT_IF_OPERAND_B            // ALSO KNOWN AS RT, ENTERS TO RB IN THE REG FILE
);
//es reset sincronico
    always @(posedge Clk, LE) 
        if (!LE) begin
            // Reset the registers when reset signal is asserted
            Qs <= 32'b0;       
            PC_out <= 32'b0; 
            OUT_IF_IMM16 <= 16'b0;
            OUT_IF_OPERAND_A <= 5'b0;
            OUT_IF_OPERAND_B <= 5'b0;
        end else if (LE) begin
            Qs <= DS;
            PC_out <= PC;
            OUT_IF_IMM16 <= DS[15:0];
            OUT_IF_OPERAND_A <= DS[25:21]; //rs
            OUT_IF_OPERAND_B <= DS[20:16]; //rt
    end
endmodule


module Pipeline_Register_32bit_ID_EX ( /*ID/EX REGISTER*/ //WILL NEED CHANGES IN THE INPUTS NON RELATED TO CONTROL SIGNALS
    input wire Clk,                        // Clock signal
    input wire Reset,                      // Reset signal

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
    input wire [31:0]   ID_PC_PLUS8_RESULT,
    input wire [31:0]   MX1_RESULT,
    input wire [31:0]   MX2_RESULT,
    input wire [31:0]   ID_HI_QS,
    input wire [31:0]   ID_LO_QS,
    input wire [31:0]   ID_PC,
    input wire [15:0]   ID_IMM16,
    input wire [4:0]    ID_REG,
    input wire [4:0]    ID_RT,
    input wire [5:0]    ID_CH_OPCODE,

    // Output Control Signals
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
    output reg [31:0] OUT_ID_MX1_RESULT,
    output reg [31:0] OUT_ID_MX2_RESULT,
    output reg [4:0]  OUT_regEX,
    output reg [31:0] OUT_ID_PC,
    output reg [15:0] OUT_ID_IMM16,
    output reg [4:0]  OUT_ID_RT,
    output reg [5:0]  OUT_ID_CH_OPCODE    
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
      OUT_regEX               <= 5'b0;
      OUT_ID_IMM16            <= 5'b0;
      OUT_ID_RT               <= 5'b0;
      OUT_ID_PC               <= 32'b0;
      OUT_ID_CH_OPCODE        <= 5'b0;
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
      OUT_ID_HI_QS            <= ID_HI_QS;
      OUT_ID_LO_QS            <= ID_LO_QS;
      OUT_ID_MX1_RESULT       <= MX1_RESULT;
      OUT_ID_MX2_RESULT       <= MX2_RESULT;
      OUT_regEX               <= ID_REG;
      OUT_ID_IMM16            <= ID_IMM16;
      OUT_ID_PC               <= ID_PC;
      OUT_ID_CH_OPCODE        <= ID_CH_OPCODE;
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
    input wire        EX_PC_PLUS8_INSTR,   // STORING PC+8 INSTRUCCTION
    input wire [31:0] EX_PC_PLUS_8,        // THE ACTUAL PC+8 THAT IS BEING PROPAGATED
    input wire        EX_MEM_ENABLE,       // DATA MEMORY ENABLE
    input wire        EX_MEM_READWRITE,    // LOAD(READ) OR STORE(WRITE)
    input wire [1:0]  EX_MEM_SIZE,         // SIZE OF STORE
    input wire        EX_MEM_SIGNE,        // SIGN EXTENSION
    input wire [31:0] EX_ADDRESS,          // OUTPUT FROM THE ALU
    input wire        EX_ENABLE_MEM,
    input wire [4:0]  EX_REGEX,

    // Output ContrEX Signals
    output reg        OUT_EX_LOAD_INSTR,     // LOAD INSTRUCTIONS
    output reg        OUT_EX_RF_ENABLE,      // REGISTER FILE ENABLE
    output reg        OUT_EX_HI_ENABLE,      // HI REGISTER ENABLE
    output reg        OUT_EX_LO_ENABLE,      // LO REGISTER ENABLE
    output reg        OUT_EX_PC_PLUS8_INSTR, // STORING PC+8
    output reg [31:0] OUT_EX_PC_PLUS_8,      // yes
    output reg        OUT_EX_MEM_ENABLE,     // DATA MEMORY ENABLE
    output reg        OUT_EX_MEM_READWRITE,  // LOAD(READ) OR STORE(WRITE)
    output reg [1:0]  OUT_EX_MEM_SIZE,       // SIZE OF STORE
    output reg        OUT_EX_MEM_SIGNE,      // SIGN EXTENSION
    output reg [31:0] OUT_EX_ADDRESS,
    output reg [4:0]  OUT_REGEX
    // TODO: SEEMS REGMEM IS NOT HERE, WE ALSO NEED TO ADD IT, FOR INPUT AND OUTPUT
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
      OUT_EX_PC_PLUS_8        <= 32'b0;
      OUT_EX_MEM_ENABLE       <= 1'b0;
      OUT_EX_MEM_READWRITE    <= 1'b0;
      OUT_EX_MEM_SIZE         <= 2'b0;
      OUT_EX_MEM_SIGNE        <= 1'b0;
      OUT_REGEX               <= 5'b0;
    end
    else
    begin
      OUT_EX_LOAD_INSTR       <= EX_LOAD_INSTR;
      OUT_EX_RF_ENABLE        <= EX_RF_ENABLE;
      OUT_EX_HI_ENABLE        <= EX_HI_ENABLE;
      OUT_EX_LO_ENABLE        <= EX_LO_ENABLE;
      OUT_EX_PC_PLUS8_INSTR   <= EX_PC_PLUS8_INSTR;
      OUT_EX_PC_PLUS_8        <= EX_PC_PLUS_8;
      OUT_EX_MEM_ENABLE       <= EX_MEM_ENABLE;
      OUT_EX_MEM_READWRITE    <= EX_MEM_READWRITE;
      OUT_EX_MEM_SIZE         <= EX_MEM_SIZE;
      OUT_EX_MEM_SIGNE        <= EX_MEM_SIGNE;
      // The address is 9 bits but we taking all 32 because weĺl 
      // need em when selecting between this and the data out
      OUT_EX_ADDRESS          <= EX_ADDRESS;    
      OUT_REGEX               <= EX_REGEX;
    end
  end
endmodule

// 14 siggnals in
module Pipeline_Register_32bit_MEM_WB ( /*MEM/WB REGISTER*/
    input wire Clk,         // Clock signal
    input wire Reset,        // Reset signal

    // Input Control Signals
    input wire MEM_RF_ENABLE, // Register file enable
    input wire MEM_HI_ENABLE, // HI register enable
    input wire MEM_LO_ENABLE, // LO register enable
    input wire [4:0] EX_REGEX,
    input wire [31:0] PW_REGISTER_FILE,

    // Output Control Signals
    output reg OUT_MEM_RF_ENABLE, //register file enable
    output reg OUT_MEM_HI_ENABLE, //HI register enable
    output reg OUT_MEM_LO_ENABLE, //LO register enable
    output reg [4:0] OUT_RW_REGISTER_FILE, // REGEX  basically
    output reg [31:0] OUT_PW_REGISTER_FILE,
    output reg OUT_EnableMEM
  );

  always @(posedge Clk)
  begin
    if (Reset)
    begin
      OUT_MEM_RF_ENABLE     <= 1'b0;
      OUT_MEM_HI_ENABLE     <= 1'b0;
      OUT_MEM_LO_ENABLE     <= 1'b0;
      OUT_RW_REGISTER_FILE  <= 5'b0;
      OUT_PW_REGISTER_FILE  <= 31'b0;
    end
    else
    begin
      OUT_MEM_RF_ENABLE     <= MEM_RF_ENABLE;
      OUT_MEM_HI_ENABLE     <= MEM_HI_ENABLE;
      OUT_MEM_LO_ENABLE     <= MEM_LO_ENABLE;
      OUT_RW_REGISTER_FILE  <= EX_REGEX;
      OUT_PW_REGISTER_FILE  <= PW_REGISTER_FILE;
    end
  end

endmodule


