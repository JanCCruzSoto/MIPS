`timescale 1ns / 1ns

// This is phase 4 of the project, the full implementation of the MIPS architecture
// Jan Carlos - 
// Victor


`include "Hazard_Forwarding_Unit.v"
`include "PC_nPC.v"
`include "Stages.v"
`include "Control_Unit.v"
// `include "Muxes.v"
`include "Logic_Boxes.v"
`include "Register_File.v"
// `include "Decoder.v"
`include "Memory.v"
`include "Handler.v"
`include "ALU.v"
`include "Condition_Handler.v"

module PPU (
  // input wire Reset, // also known as Clr
  // input wire Clk,
  // input wire S,             // This would be an internal wire in future design, because this should be handled by the Hazard Unit
  // input wire stallIFID     // This would be 1 for this phase, but this should come from the Hazard Unit as well
);

reg Reset;
reg Clk;
reg S;
reg StallFID;


// The following wires belong to the RAM
wire Enable; // Enable, allows the architecture to run 
wire SignExtend;
wire [1:0] Size;
wire [8:0] Address;     // This outputs from the ALU into the RAM Address TODO: Verify if the address is 8 or 7 bits for MIPS architecture
wire [31:0] DataIn;     // This outputs from the EX_MX2 mux into the DataIn from the RAM
wire [31:0] DataOut; // TODO: Find a way to receive instructions from the outside instead


// Counters
wire [31:0] PC;         // The actual Program Counter.
wire [31:0] nPC;        // The Next Program Counter 
wire [31:0] nPC_PLUS_4;
wire [31:0] nPC_MUX;

wire [31:0] TA; // Target Address

wire [31:0] DataOut_InstructionMemory;

// Controls when the flow will flow and when it should stop
// TODO: Change to wires after getting job done
reg stall_PC;
reg stall_NPC;
reg stall_IFID;

// Refer to instance CU
wire [3:0]  ID_ALU_OP;
wire        ID_LOAD_INSTR;
wire        ID_RF_ENABLE;
wire        ID_HI_ENABLE;
wire        ID_LO_ENABLE;
wire        ID_PC_PLUS8_INSTR;
wire        ID_UB_INSTR;
wire        ID_JALR_JR_INSTR;
wire [1:0]  ID_DESTINATION_REGISTER;
wire [2:0]  ID_OP_H_S;

wire        ID_MEM_ENABLE;
wire        ID_MEM_READWRITE;
wire [1:0]  ID_MEM_SIZE;
wire        ID_MEM_SIGNE;

// Controlled by Hazard


// OUTPUT SIGNALS COMMING FROM THE CONTROL UNIT
wire [3:0] OUT_ID_ALU_OP;
wire OUT_ID_LOAD_INSTR;
wire OUT_ID_RF_ENABLE;
wire OUT_ID_HI_ENABLE;
wire OUT_ID_LO_ENABLE;
wire OUT_ID_PC_PLUS8_INSTR;
wire OUT_ID_UB_INSTR;
wire OUT_ID_JALR_JR_INSTR;

wire [1:0] OUT_ID_DESTINATION_REGISTER;
wire [2:0] OUT_ID_OP_H_S;
wire OUT_ID_MEM_ENABLE;
wire OUT_ID_MEM_READWRITE;
wire [1:0] OUT_ID_MEM_SIZE;
wire OUT_ID_MEM_SIGNE;



// -------| INITIALIZING WIRES AND REGISTERS |------------------

// Pikachu here, signals are organized from the perspective of the pipeline
// registers and in the following order:
// IF/ID
// ID/EX
// EX/MEM
// MEM/WB
// 
// Engineers are mentally unstable, but we need around 10% of sanity to
// function. 15% for maximum efficiency, and maybe some cafeine or
// alcohol in the blood... or both, pick your drug.
//
// Anyway, wires also have a naming convention so its easier to read
// <WHERE_IT_CAME_FROM>WIRE_NAME<WHERE_ITS_GOING_TO

// =====| COUNTERS (SET ASIDE FOR SANITY) |===== //
wire [31:0] IF_PC_ID; // GOES TO ID, BITWISE_AND, ALU+4
wire [31:0] ID_PC_EX;
wire [31:0] EX_PC_MEM;
wire [31:0] MEM_PC_WB;


// =====| CU/CU-MUX |===== //

wire CU_ALU_OP_CU_MUX;
wire CU_LOAD_INSTR_CU_MUX;
wire CU_RF_ENABLE_CU_MUX;
wire CU_HI_ENABLE_CU_MUX;
wire CU_LO_ENABLE_CU_MUX;
wire CU_PC_PLUS8_INSTR_CU_MUX;
wire CU_UB_INSTR_CU_MUX;
wire CU_JALR_JR_INSTR_CU_MUX;

wire CU_DESTINATION_REGISTER_CU_MUX;
wire CU_OP_H_S_CU_MUX;

wire CU_MEM_ENABLE_CU_MUX;
wire CU_MEM_READWRITE_CU_MUX;
wire CU_MEM_SIZE_CU_MUX;
wire CU_MEM_SIGNE_CU_MUX;

// =====| CU-MUX/IF |===== //

wire CU_MUX_ALU_OP_ID;
wire CU_MUX_LOAD_INSTR_ID;
wire CU_MUX_RF_ENABLE_ID;
wire CU_MUX_HI_ENABLE_ID;
wire CU_MUX_LO_ENABLE_ID;
wire CU_MUX_PC_PLUS8_INSTR_ID;
wire CU_MUX_UB_INSTR_ID;
wire CU_MUX_JALR_JR_INSTR_ID;

wire CU_MUX_ID_DESTINATION_REGISTER_ID;
wire CU_MUX_ID_OP_H_S_ID;

wire CU_MUX_MEM_ENABLE_ID;
wire CU_MUX_MEM_READWRITE_ID;
wire CU_MUX_MEM_SIZE_ID;
wire CU_MUX_MEM_SIGNE_ID;

// -+-+-+-| HAZARD/CU-MUX |-+-+-+-+ // 
wire HAZARD_CONTROL_CU_MUX;


// =====| HAZARD FORWARDING UNIT |===== //

wire HAZARD_FWDB_MX1;
wire HAZARD_FWDB_MX2;

// replace these
// stall_PC
// stall_NPC
// stall_IFID
reg HAZARD_STALLPC_NIPUTAIDEA;

wire EX_ENABLEEX_HAZARD;
wire MEM_ENABLEMEM_HAZARD;
wire WB_ENABLEWB_HAZARD;

wire EX_LOADEX_HAZARD;
wire EX_REGEX_HAZARD;
wire MEM_REGMEM_HAZARD;
wire WB_REGWB_HAZARD;

wire ID_OPERAND_A_REGISTER_FILE_AND_HAZARD;
wire ID_OPERAND_B_REGISTER_FILE_AND_HAZARD;

// =====| IF/ID |===== //

wire PC_FROM_PC_TO_ID;

wire ID_ALU_OP_EX;
wire ID_LOAD_INSTR_EX;
wire ID_RF_ENABLE_EX;
wire ID_HI_ENABLE_EX;
wire ID_LO_ENABLE_EX;
wire ID_PC_PLUS8_INSTR_EX;
wire ID_UB_INSTR_EX;
wire ID_JALR_JR_INSTR_EX;

wire [15:0] ID_IMM16_EX_AND_TIMES_4; 
wire [31:0] ID_INSTRUCTION_CU;

// =====| HI-REGISTER |===== //
wire [31:0] HI_HISIGNAL_EX;
wire [31:0] WB_PW_HI;
wire WB_HIENABLE_HI;

// ====| LO-REGISTER |==== //
wire [31:0] LO_LOSIGNAL_EX;
wire [31:0] WB_PW_LO;
wire WB_LOENABLE_LO;

// ====| TIMES 4 LOGIC BOX (CASE 1) |==== //
wire TIMES_4_IMM16_ID_ALU;

// ====| PLUS 4 LOGIC BOX |====
// uhh yeah i forgot to create this

// ====| ALU FROM ID |====
wire [31:0] PLUS_4_BOX_P4_EX;

// ====| TIMES 4 LOGIC BOX (CASE 2) |==== //
wire TIMES_4_ADDRESS26_EX;

// ====| BITWISE OR |==== //



// ====| BITWISE AND |=== //

// =====| ID/EX |===== //


// -|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|--
// --------------------------------------------------
// -------| INITIALIZING MODULES |------------------
// --------------------------------------------------
// -|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|--

// ---- | Memories, utilized for precharging |----
rom_512x8 Instruction_Memory (
    .Address (PC[8:0]),                     // IN
    .DataOut (DataOut_InstructionMemory)   // OUT
);  // ROM

ram_512x8 Data_Memory (
    .DataOut    (DataOut),  
    .Enable     (Enable),  
    .ReadWrite  (ReadWrite),  
    .SignExtend (SignExtend),
    .Address    (Address),  
    .DataIn     (DataIn),
    .Size       (Size)
);  // RAM (DAT MEMORY)
// -----------------------------------------------

// ----| Counter Modules |----

// These three modules are related and are design give
// feedback to one another in order to count


// USED FOR SELECTING BETWEEN JUMP TA OR nPC IN IF STAGE
Mux_9Bit_OR_32BIT_Case_One nPCselector (
    .nPC      (nPC[8:0]),
    .TA       (TA),
    .S        (S),
    .Address  (nPC_MUX)
);

nPCLogicBox AddPlusFour(
  .nPC      (nPC_MUX[8:0]),         // IN
  .result   (nPC_PLUS_4[8:0])   // OUT
);

// not exactly 32 bits :\
Register_32bit_nPC nPC_reg (
  .DS           (nPC_PLUS_4[8:0]),   // IN
  .Qs           (nPC[8:0]),          // OUT
  .stallnPC     (stall_NPC), 
  .Clk          (Clk), 
  .Reset        (Reset)
);

// Refer to Memory.v for differences between this and the nPC
Register_32bit_PC PC_reg (
  .DS         (nPC_MUX[8:0]),       // IN
  .Qs         (PC[8:0]),          // OUT
  .stallPC    (stall_PC), 
  .Clk        (Clk), 
  .Reset      (Reset)
);

// -------------------------------------------------------


// ----| PRECHARGING STAGE |-----

integer fi, fo, code, i; 
reg [7:0] data;
reg [36:0] dataR; // for data register
reg [7:0] Addr; 
wire [31:0] instruction;
wire [31:0] instruction_out;

// Precharging the Instruction Memory and Data Memory
initial begin
    fi = $fopen("PF4_PreCharge.txt","r");
    Addr = 9'b000000000;
    while (!$feof(fi)) begin
        code = $fscanf(fi, "%b", data);
        Instruction_Memory.Mem[Addr] = data;
        Data_Memory.Mem[Addr] = data;
        Addr = Addr + 1;
    end
    $fclose(fi);
    Addr = 9'b000000000;
end
// ----------------------------------------

// ----| CONTROL UNIT |------------
// Refer to Control_Unit.v
Control_Unit CU (
    // OUTPUT
    .ID_ALU_OP                (CU_ALU_OP_CU_MUX),          // SIGNALS EXIST
    .ID_LOAD_INSTR            (CU_LOAD_INSTR_CU_MUX),      // SIGNALS EXIST
    .ID_RF_ENABLE             (CU_RF_ENABLE_CU_MUX),       // SIGNALS EXIST
    .ID_HI_ENABLE             (CU_HI_ENABLE_CU_MUX),       // SIGNALS EXIST
    .ID_LO_ENABLE             (CU_LO_ENABLE_CU_MUX),       // SIGNALS EXIST
    .ID_PC_PLUS8_INSTR        (CU_PC_PLUS8_INSTR_CU_MUX),  // SIGNALS EXIST
    .ID_UB_INSTR              (CU_UB_INSTR_CU_MUX),        // SIGNALS EXIST
    .ID_JALR_JR_INSTR         (CU_JALR_JR_INSTR_CU_MUX),   // SIGNALS EXIST

    .ID_DESTINATION_REGISTER  (CU_DESTINATION_REGISTER_CU_MUX),     // SIGNAL EXISTS
    .ID_OP_H_S                (CU_OP_H_S_CU_MUX),                   // SIGNAL EXISTS

    .ID_MEM_ENABLE            (CU_MEM_ENABLE_CU_MUX),               // SIGNAL EXISTS
    .ID_MEM_READWRITE         (CU_MEM_READWRITE_CU_MUX),            // SIGNAL EXISTS
    .ID_MEM_SIZE              (CU_MEM_SIZE_CU_MUX),                 // SIGNAL EXISTS
    .ID_MEM_SIGNE             (CU_MEM_SIGNE_CU_MUX),                // SIGNAL EXISTS
    // INPUT
    .instruction              (DataOut_InstructionMemory)           // ALREADY EXISTS
);

Mux_Control_Unit CU_MUX (
    // ---------| Spliced Instructions (OUTPUT) | -----------
    .OUT_ID_ALU_OP                (CU_MUX_ALU_OP_ID),                     // SIGNAL EXISTS
    .OUT_ID_LOAD_INSTR            (CU_MUX_LOAD_INSTR_ID),                 // SIGNAL EXISTS
    .OUT_ID_RF_ENABLE             (CU_MUX_RF_ENABLE_ID),                  // SIGNAL EXISTS
    .OUT_ID_HI_ENABLE             (CU_MUX_HI_ENABLE_ID),                  // SIGNAL EXISTS
    .OUT_ID_LO_ENABLE             (CU_MUX_LO_ENABLE_ID),                  // SIGNAL EXISTS
    .OUT_ID_PC_PLUS8_INSTR        (CU_MUX_PC_PLUS8_INSTR_ID),             // SIGNAL EXISTS
    .OUT_ID_UB_INSTR              (CU_MUX_UB_INSTR_ID),                   // SIGNAL EXISTS
    .OUT_ID_JALR_JR_INSTR         (CU_MUX_JALR_JR_INSTR_ID),              // SIGNAL EXISTS

    .OUT_ID_DESTINATION_REGISTER  (CU_MUX_ID_DESTINATION_REGISTER_ID),     // SIGNAL EXISTS
    .OUT_ID_OP_H_S                (CU_MUX_ID_OP_H_S_ID),                   // SIGNAL EXISTS

    .OUT_ID_MEM_ENABLE            (CU_MUX_MEM_ENABLE_ID),                 // SIGNAL EXISTS
    .OUT_ID_MEM_READWRITE         (CU_MUX_MEM_READWRITE_ID),              // SIGNAL EXISTS
    .OUT_ID_MEM_SIZE              (CU_MUX_MEM_SIZE_ID),                   // SIGNAL EXISTS
    .OUT_ID_MEM_SIGNE             (CU_MUX_MEM_SIGNE_ID),                  // SIGNAL EXISTS

    // CONTROLED BY THE HAZARD FORWARDING UNIT
    .controlMux                   (HAZARD_CONTROL_CU_MUX),

    // ---------| Spliced Instructions (INPUT) | -----------
    .ID_ALU_OP                    (ID_ALU_OP),                          // SIGNAL EXISTS
    .ID_LOAD_INSTR                (ID_LOAD_INSTR),                      // SIGNAL EXISTS
    .ID_RF_ENABLE                 (ID_RF_ENABLE),                       // SIGNAL EXISTS
    .ID_HI_ENABLE                 (ID_HI_ENABLE),                       // SIGNAL EXISTS
    .ID_LO_ENABLE                 (ID_LO_ENABLE),                       // SIGNAL EXISTS
    .ID_PC_PLUS8_INSTR            (ID_PC_PLUS8_INSTR),                  // SIGNAL EXISTS
    .ID_UB_INSTR                  (ID_UB_INSTR),                        // SIGNAL EXISTS
    .ID_JALR_JR_INSTR             (ID_JALR_JR_INSTR),                   // SIGNAL EXISTS
    // here
    .ID_DESTINATION_REGISTER      (CU_MUX_ID_DESTINATION_REGISTER_ID),  // SIGNAL EXISTS
    .ID_OP_H_S                    (CU_MUX_ID_OP_H_S_ID),                // SIGNAL EXISTS

    .ID_MEM_ENABLE                (CU_MUX_MEM_ENABLE_ID),               // SIGNAL EXISTS
    .ID_MEM_READWRITE             (CU_MUX_MEM_READWRITE_ID),            // SIGNAL EXISTS
    .ID_MEM_SIZE                  (CU_MUX_MEM_SIZE_ID),                 // SIGNAL EXISTS
    .ID_MEM_SIGNE                 (CU_MUX_MEM_SIGNE_ID),                // SIGNAL EXISTS

     // ----| NOP |--------------------------------------

    .ZERO_ID_ALU_OP               (4'b0),
    .ZERO_ID_LOAD_INSTR           (1'b0),
    .ZERO_ID_RF_ENABLE            (1'b0),
    .ZERO_ID_HI_ENABLE            (1'b0),
    .ZERO_ID_LO_ENABLE            (1'b0),
    .ZERO_ID_PC_PLUS8_INSTR       (1'b0),
    .ZERO_ID_UB_INSTR             (1'b0),
    .ZERO_ID_JALR_JR_INSTR        (1'b0),
    .ZERO_ID_DESTINATION_REGISTER (2'b0),
    .ZERO_ID_OP_H_S               (3'b0),
    .ZERO_ID_MEM_ENABLE           (1'b0),
    .ZERO_ID_MEM_READWRITE        (1'b0),
    .ZERO_ID_MEM_SIZE             (2'b0),
    .ZERO_ID_MEM_SIGNE            (1'b0)
);

// --------| BEGIN PIPELINE |------------ //

Hazard_Forwarding_Unit Hazard (
    // output
    .fwdA       (HAZARD_FWDB_MX1),      // SIGNAL EXISTS
    .fwdB       (HAZARD_FWDB_MX2),      // SIGNAL EXISTS

    .stallPC    (stall_PC),             // StallPC is a register for now
    .stallNPC   (stall_NPC),            // Same thing
    .stallIFID  (stall_IFID),           // Also the same thing

    .controlMux (HAZARD_CONTROL_CU_MUX), // SIGNAL EXISTS

    // input
    .enableEX   (EX_ENABLEEX_HAZARD),       // SIGNAL EXISTS
    .enableMEM  (MEM_ENABLEMEM_HAZARD),     // SIGNAL EXISTS
    .enableWB   (WB_ENABLEWB_HAZARD),     // SIGNAL EXISTS

    .loadEX     (EX_LOADEX_HAZARD),     // SIGNAL EXISTS

    .regEX      (EX_REGEX_HAZARD),      // SIGNAL EXISTS
    .regMEM     (MEM_REGMEM_HAZARD),        // SIGNAL EXISTS
    .regWB      (WB_REGWB_HAZARD),      // SIGNAL EXISTS

    .operandA   (ID_OPERAND_A_REGISTER_FILE_AND_HAZARD),    // SIGNAL EXISTS
    .operandB   (ID_OPERAND_B_REGISTER_FILE_AND_HAZARD) // SIGNAL EXISTS
);

Pipeline_Register_32bit_IF_ID IF_ID (
    // OUTPUT
    .Qs                 (ID_INSTRUCTION_CU),                        // OUTPUT OF THE INSTRUCTION | SIGNAL EXISTS
    .PC_out             (IF_PC_ID),                                 // SIGNAL EXISTS
    .OUT_IF_IMM16       (ID_IMM16_EX_AND_TIMES_4),                              //  TODO: Create this signal in module

    .OUT_ID_OPERAND_A   (ID_OPERAND_A_REGISTER_FILE_AND_HAZARD),    // SIGNAL EXISTS | TODO: Create this signal in module
    .OUT_ID_OPERAND_B   (ID_OPERAND_B_REGISTER_FILE_AND_HAZARD),    // SIGNAL EXISTS | TODO: Create this signal in module

    // INPUT
    .DS                 (DataOut_InstructionMemory),                // SIGNAL EXISTS | INPUT OF THE INSTRUCTION
    .PC                 (PC),                                       // ALDREADY EXISTTS
    .Clk                (Clk),                                      // ALDREADY EXISTTS
    .LE                 (stall_IFID),                               // ALDREADY EXISTTS
    .Reset              (Reset)                                     // ALDREADY EXISTTS
);

// Wacky Logic boxes Extravaganza // ------------------
HiRegister Hi (
    // OUTPUT
    .HiSignal        (HI_HISIGNAL_EX),   // SIGNAL EXISTS

    // INPUT
    .PW              (WB_PW_HI),         // SIGNAL EXISTS
    .HiEnable        (WB_HIENABLE_HI),   // SIGNAL EXISTS
    .clk             (Clk)               // ALREADY EXISTS
);

LowRegister Low (
    // OUTPUT
    .LoSignal       (LO_LOSIGNAL_EX),        // SIGNAL EXISTS
    // INPUT
    .LoEnable       (WB_LOENABLE_LO),        // SIGNAL EXISTS
    .clk            (Clk),                   // ALREADY EXISTS
    .PW             (WB_PW_LO)               // SIGNAL EXISTS
);

Times_Four_Logic_Box_Case_One X4_SE_Case_One ( /*USED FOR Imm16 FOR CONDITIONAL TA*/
    .Imm16          (ID_IMM16_EX_AND_TIMES_4),
    .Result         (TIMES_4_IMM16_ID_ALU)
);

Sum_Logic_Box PLUS_4_BOX_ID (
    // OUTPUT
    .Result         (PLUS_4_BOX_P4_EX),

    // INPUT
    .First_Value    (IF_PC_ID + 4),                 // PC+4
    .Second_Value   (TIMES_4_IMM16_ID_ALU),      // 4*imm16    
);

// DO NOT CONFUSE WITH CASE 1
Times_Four_Logic_Box_Case_Two X4_SE_Case_Two( /* USED FOR HANDLING Address26 FOR UNCONDITIONAL TA*/
    // OUTPUT
    .Result         (TIMES_4_ADDRESS26_EX),

    // INPUT
    .Address26      (ID_INSTRUCTION_CU[25:0]) // ADDRESS 26 | TODO: Create an explicit wire for this
);

Bitwise_OR_Logic_Box Bitwise_OR_Logic ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
    .Result                     (),
    .AND_Output                 (),
    .Address26_x4_Output        (TIMES_4_ADDRESS26_EX)
    
);

Bitwise_AND_Logic_Box Bitwise_AND_Logic ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
    .Result                     (),
    .PC                         (IF_PC_ID),
    .Second_Value               ()
);

// Wacky multiplexers Extravaganza // ----------------

Mux_32Bit_OR_32BIT ID_MUX_Case_one (
    .Input_One                  (),
    .Input_Two                  (),
    .Out                        ()
);
Mux_32Bit_OR_32BIT ID_MUX_Case_two (
    .Input_One                  (),
    .Input_Two                  (),
    .Out                        ()
);
Mux_32Bit_OR_32BIT ID_MUX_Case_three (
    .Input_One                  (),
    .Input_Two                  (),
    .Out                        ()
);

Mux_Destination_Registers ID_MUX_Destination (
  .RD                           (), 
  .RT                           (), 
  .R31                          (),
  .S                            (),
  .Out                          ()
);

// End of Wacky multiplexer extravaganza // ----------


// End of the Wacky Logic Boxes Extravaganza // ------
Register_File Reg_File (
    .PA     (PA),
    .PB     (PB),

    .PW_DS  (),
    .RW     (),
    .Clk    (Clk),
    .E      (),
    .RA     (operandA),
    .RB     (operandB)
);

Mux_RegisterFile_Ports MX1 (
    // PA
    .ID_Result  (PA), 
    .EX_Result  (),
    .MEM_Result (),
    .WB_Result  (),
    .S          (HAZARD_FWDB_MX1), 
    .Out        (OUT_MX1)
);

Mux_RegisterFile_Ports MX2 (
    // PA
    .ID_Result  (PB),
    .EX_Result  (),
    .MEM_Result (),
    .WB_Result  (),
    .S          (HAZARD_FWDB_MX2), 
    .Out        (OUT_MX2)
);

// A bunch of other muxes that do uh... stuff


Plus_8_Logic_Box Plus_8 (
    .PC     (IF_PC_ID),                 // SIGNAL EXISTS
    .Result (Plus_8_Result)
);

Pipeline_Register_32bit_ID_EX ID_EX (
.Clk                        (Clk),
.Reset                      (Reset),

// Input
.ID_HI_ENABLE               (OUT_ID_HI_ENABLE),
.ID_LO_ENABLE               (OUT_ID_LO_ENABLE),
.ID_RF_ENABLE               (OUT_ID_RF_ENABLE),
.ID_ALU_OP                  (OUT_ID_ALU_OP),
.ID_LOAD_INSTR              (OUT_ID_LOAD_INSTR),
.ID_OP_H_S                  (OUT_ID_OP_H_S),
.ID_MEM_ENABLE              (OUT_ID_MEM_ENABLE),
.ID_MEM_READWRITE           (OUT_ID_MEM_READWRITE),
.ID_MEM_SIZE                (OUT_ID_MEM_SIZE),
.ID_MEM_SIGNE               (OUT_ID_MEM_SIGNE),
.ID_PC_PLUS8_INSTR          (OUT_ID_PC_PLUS8_INSTR),

.ID_Plus_8_Result           (Plus_8_Result),
.MX1_Result                 (OUT_MX1),
.MX2_Result                 (OUT_MX2),

.ID_HI_QS                   (HI_HISIGNAL_EX),
.ID_LO_QS                   (LoSignal),

.ID_PC                      (IF_PC_ID),                 // SIGNAL EXISTS     
.ID_IMM16                   (ID_IMM16_EX),             // SIGNAL EXISTS | TODO: CREATE SIGNAL IN MODULE

// Output
.Out_ID_ALU_OP              (Out_ID_ALU_OP),
.Out_ID_LOAD_INSTR          (EX_LOADEX_HAZARD),         // SIGNAL EXISTS
.Out_ID_RF_ENABLE           (Out_ID_RF_ENABLE),
.Out_ID_HI_ENABLE           (Out_ID_HI_ENABLE),
.Out_ID_LO_ENABLE           (Out_ID_LO_ENABLE),
.Out_ID_PC_PLUS8_INSTR      (Out_ID_PC_PLUS8_INSTR),
.Out_ID_OP_H_S              (Out_ID_OP_H_S),
.Out_ID_MEM_ENABLE          (Out_ID_MEM_ENABLE),
.Out_ID_MEM_READWRITE       (Out_ID_MEM_READWRITE),
.Out_ID_MEM_SIZE            (Out_ID_MEM_SIZE),
.Out_ID_MEM_SIGNE           (Out_ID_MEM_SIGNE),

.Out_ID_Plus_8_Result       (Out_ID_Plus_8_Result),
.Out_ID_MX1_Result          (OUT_ID_MX1),
.Out_ID_MX2_Result          (OUT_ID_MX2),

.Out_ID_HI_QS               (Out_ID_HI_QS),
.Out_ID_LO_QS               (Out_ID_LO_QS),

.Out_ID_PC                  (Out_ID_PC),
.Out_ID_IMM16               (Out_ID_IMM16),

    .OUT_EnableEX               (EX_ENABLEEX_HAZARD), // SIGNAL EXISTS | TODO: Create this signal in module
    .OUT_regEX                  (EX_REGEX_HAZARD)     // SIGNAL EXISTS | TODO: Create this signal in module
    .OUT_regMEM                 (MEM_REGMEM_HAZARD)   // SIGNAL EXISTS | TODO: Create this signal in module
    .OUT_regWB                  (WB_REGWB_HAZARD)     // SIGNAL EXISTS | TODO: Create this signal in module
);

Handler Operand_Handler (
    // Output
    .N          (OUT_Operand_Handler),

    // Inputs
    .PB         (OUT_ID_MX2),
    .HI         (Out_ID_HI_QS),
    .LO         (Out_ID_LO_QS),
    .PC         (Out_ID_PC),
    .imm16      (Out_ID_IMM16),
    .Si         (Out_ID_OP_H_S)
);

ALU ALU (
    .operand_A      (OUT_ID_MX1),
    .operand_B      (OUT_Operand_Handler),
    .alu_control    (Out_ID_ALU_OP),
    .result         (Out_ALU_Result),
    .z_flag         (Out_z_flag),
    .n_flag         (Out_n_flag)
);

Mux_9Bit_OR_32BIT_Case_Two PCselector (
  .PC_Plus_8    (),
  .Result       (),
  .S            (),
  .Out          ()
);

Condition_Handler Condition_Handler (
    .if_id_reset    (),
    .CH_Out         (),
    .instruction    (),
    .z_flag         (),
    .n_flag         ()
);

Pipeline_Register_32bit_EX_MEM EX_MEM (
  .Clk,         // Clock signal
  .Reset,        // Reset signal

  // Input Control Signals
  .ID_LOAD_INSTR            (),
  .ID_HI_ENABLE             (),
  .ID_LO_ENABLE             (),
  .ID_PC_PLUS8_INSTR        (),
  .ID_MEM_ENABLE            (),
  .ID_MEM_READWRITE         (),
  .ID_MEM_SIZE              (),
  .ID_MEM_SIGNE             (),

  // Output Control Signals
  .Out_ID_LOAD_INSTR        (),
  .Out_ID_RF_ENABLE         (),
  .Out_ID_HI_ENABLE         (),
  .Out_ID_LO_ENABLE         (),
  .Out_ID_PC_PLUS8_INSTR    (),
  .Out_ID_MEM_ENABLE        (),
  .Out_ID_MEM_READWRITE     (),
  .Out_ID_MEM_SIZE          (),
  .Out_ID_MEM_SIGNE         (),

    .OUT_EnableMEM              (MEM_ENABLEMEM_HAZARD) // SIGNAL EXISTS | TODO: Create signal on module
);

ram_512x8 Data_Memory (
    .DataOut                (),
    .Enable                 (),
    .ReadWrite              (),
    .SignExtend             (),
    .Address                (),
    .DataIn                 (),
    .Size                   ()
);

Mux_32Bit_OR_32BIT MEM_Memory_MUX_Case_One (
    .Input_One                  (),
    .Input_Two                  (),
    .Out                        ()
);

Mux_32Bit_OR_32BIT MEM_Memory_MUX_Case_Two (
    .Input_One                  (),
    .Input_Two                  (),
    .Out                        ()
);


Pipeline_Register_32bit_MEM_WB MEM_WB (
  .Clk,                     (Clk),
  .Reset,                   (Reset),

  // Input Control Signals
  .ID_RF_ENABLE             (),
  .ID_HI_ENABLE             (),
  .ID_LO_ENABLE             (),

  // Output Control Signals
  .Out_ID_RF_ENABLE         (),
  .Out_ID_HI_ENABLE         (),
  .Out_ID_LO_ENABLE         (),

  OUT_EnableMEM             (WB_ENABLEWB_HAZARD) // SIGNAL EXISTS | TODO: CREATE SIGNAL IN MODULE
);


// -----------------------------------


// Clock generator
initial begin
    Reset <= 1'b1;
    stall_NPC <= 1'b1;
    stall_PC <= 1'b1;
    S <= 1'b0;
    Clk <= 1'b0;
    #2 Clk <= ~Clk;
    #1 Reset <= 1'b0;
    #1 Clk <= ~Clk; 
    forever #2 Clk = ~Clk;
end

initial begin
  #52;
  $display("\n----------------------------------------------------------\nDONE :D");
  $finish;
end 

initial begin
  $monitor("Instruction: %b | CLK: %b | PC: %d | nPC: %d", DataOut_InstructionMemory, Clk, PC[8:0], nPC[8:0]);
end


endmodule;
