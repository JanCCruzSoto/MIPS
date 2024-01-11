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
  // Change to wires after getting job done
  wire stall_PC;
  wire stall_NPC;
  wire stall_IFID;


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

  wire [3:0] CU_ALU_OP_CU_MUX;
  wire CU_LOAD_INSTR_CU_MUX;
  wire CU_RF_ENABLE_CU_MUX;
  wire CU_HI_ENABLE_CU_MUX;
  wire CU_LO_ENABLE_CU_MUX;
  wire CU_PC_PLUS8_INSTR_CU_MUX;
  wire CU_UB_INSTR_CU_MUX;
  wire CU_JALR_JR_INSTR_CU_MUX;

  wire [1:0] CU_DESTINATION_REGISTER_CU_MUX;
  wire [2:0] CU_OP_H_S_CU_MUX;

  wire CU_MEM_ENABLE_CU_MUX;
  wire CU_MEM_READWRITE_CU_MUX;
  wire [1:0] CU_MEM_SIZE_CU_MUX;
  wire CU_MEM_SIGNE_CU_MUX;

  // =====| CU-MUX/ID |===== //

  wire [3:0] CU_MUX_ALU_OP_EX;
  wire CU_MUX_LOAD_INSTR_EX;
  wire CU_MUX_RF_ENABLE_EX;
  wire CU_MUX_HI_ENABLE_EX;
  wire CU_MUX_LO_ENABLE_EX;
  wire CU_MUX_PC_PLUS8_INSTR_ID;
  wire CU_MUX_UB_INSTR_UB_MUX;
  wire CU_MUX_JALR_JR_INSTR_ID;

  wire [1:0] CU_MUX_ID_DESTINATION_REGISTER_MUX_DESTINATION;
  wire [2:0] CU_MUX_ID_OP_H_S_EX;

  wire CU_MUX_MEM_ENABLE_EX;
  wire CU_MUX_MEM_READWRITE_EX;
  wire [1:0] CU_MUX_MEM_SIZE_EX;
  wire CU_MUX_MEM_SIGNE_EX;

  // =====| HAZARD FORWARDING UNIT |===== //
  wire HAZARD_CONTROL_CU_MUX;
  wire [1:0] HAZARD_FWDB_MX1;
  wire [1:0] HAZARD_FWDB_MX2;

  // replace these
  // stall_PC
  // stall_NPC
  // stall_IFID
  reg HAZARD_STALLPC_PC;

  wire EX_ENABLEEX_HAZARD;
  wire MEM_ENABLEMEM_HAZARD;
  wire WB_ENABLEWB_HAZARD;

  wire [4:0] EX_REGEX_HAZARD;
  wire [4:0] MEM_REGMEM_HAZARD;
  wire [4:0] WB_REGWB_HAZARD_AND_REGISTER_FILE;

  wire [4:0] ID_OPERAND_A_REGISTER_FILE_AND_HAZARD;
  wire [4:0] ID_OPERAND_B_REGISTER_FILE_AND_HAZARD;

  // =====| IF/ID |===== //
  wire CU_MUX_JALR_JR_INSTR_UTA_MUX_AND_CTA_MUX;

  wire [15:0] ID_IMM16_EX_AND_TIMES_4;
  wire [31:0] ID_INSTRUCTION_CU;

  // =====| HI-REGISTER |===== //
  wire [31:0] HI_HISIGNAL_EX;
  wire WB_HIENABLE_HI;

  // ====| LO-REGISTER |==== //
  wire [31:0] LO_LOSIGNAL_EX;
  wire WB_LOENABLE_LO;

  // ====| TIMES 4 LOGIC BOX (CASE 1) |==== //
  wire [31:0] TIMES_4_IMM16_ID_ALU;

  // ====| PLUS 4 LOGIC BOX |====
  // uhh yeah i forgot to create this

  // ====| ALU FROM ID |====
  wire [31:0] PLUS_4_BOX_P4_EX;

  // ====| TIMES 4 LOGIC BOX (CASE 2) |==== //
  wire [31:0] TIMES_4_ADDRESS26_EX;

  // ====| BITWISE AND |=== //
  wire [31:0] BITWISE_AND_RESULT_BITWISE_OR;

  // ====| BITWISE OR |==== //
  wire [31:0] BITWISE_OR_UTA_UTAMUX;

  // ====| UTA MUX |==== //
  wire [31:0] UTA_MUX_UTA_MUX_RESULT_CTA_MUX;

  // ====| CTA MUX |==== //
  wire [31:0] EX_CTA_CTA_MUX;
  wire [31:0] CTA_MUX_TA_nPC_SELECTOR;

  // ====| UB MUX |
  wire UB_MUX_SELECTION_NPC_SELECTOR; // TODO: SE CAMBIO DE 32 A 1 BIT VERIFICAR CREAR NUEVO MUX O VERIFICAR SI YA HAY UNO

  // ====| MX1 |===== //
  wire [31:0] MX1_MX1RESULT_UTAMUX_AND_EX;

  // ====| MX2 |===== //
  wire [31:0] MX2_MX2_RESULT_EX;

  // ====| MUX DESTINATION
  wire [4:0] MUX_DESTINATION_REG_EX;

  // ====| PLUS-8-LOGIC-BOX |==== //
  wire [31:0] PLUS_8_PC_8_EX;

  // =====| ID/EX |===== //
  wire [31:0] EX_PWDS_MX1_AND_MX2;
  wire EX_LOADEX_HAZARD;
  wire EX_RF_ENABLE_MEM;
  wire EX_HI_ENABLE_MEM;
  wire EX_LO_ENABLE_MEM;

  wire [2:0] EX_OP_H_S_OPERAND;
  wire EX_MEM_ENABLE_MEM;
  wire EX_MEM_READWRITE_MEM;
  wire [1:0] EX_MEM_SIZE_MEM;
  wire EX_MEM_SIGNE_MEM;

  wire [3:0] EX_ALU_OP_ALU;
  wire EX_PC_PLUS8_INSTR_MEM_AND_PC_SELECTOR_MUX;
  wire EX_IMM16_OPERAND;
  wire EX_PC_8_PC_EX;
  wire EX_PC_8_MEM_AND_PC_SELECTOR_MUX;
  wire EX_MX1_ALU;
  wire EX_MX2_OPERAND;
  wire EX_HISIGNAL_OPERAND;
  wire EX_LOSIGNAL_OPERAND;

  // =====| OPERAND HANDLER |===== //
  wire [31:0] HANDLER_N_ALU;

  // =====| ALU |===== //
  wire [31:0] ALU_ALU_Result_MEM_AND_PC_SELECTOR_MUX;
  wire ALU_Z_FLAG_MEM_AND_CONDITION_HANDLER;
  wire ALU_N_FLAG_MEM_AND_CONDITION_HANDLER;

  // =====| PC SELECTOR MUX |===== //


  // =====| CONDITION HANDLER |===== //
  wire CONDITION_HANDLER_IFRESET_IF;
  wire [31:0] COND_HANDLER_UB_UB_MUX; //TODO: SE CAMBIO DE 1 A 32 BITS
  wire [31:0] REGISTER_FILE_PA_MX1;
  wire [31:0] REGISTER_FILE_PB_MX2;

  // =====| EX/MEM |===== //
  wire [31:0] MEM_PWDS_MX1_AND_MX2;

  wire MEM_LOAD_INSTR_MEMORY_MUX_CASE_ONE;
  wire MEM_RF_ENABLE_;
  wire MEM_HI_ENABLE_WB;
  wire MEM_LO_ENABLE_WB;
  wire MEM_PC_PLUS8_INSTR_;
  wire MEM_MEM_ENABLE_DATA_MEMORY;
  wire MEM_MEM_READWRITE_DATA_MEMORY;
  wire [1:0] MEM_MEM_SIZE_DATA_MEMORY;
  wire MEM_MEM_SIGNE_DATA_MEMORY;
  wire [31:0] MEM_ADDRESS_DATA_MEMORY;

  // ====| MEM/WB
  wire [31:0] WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2;
  wire WB_REG_FILE_ENABLE_REGISTER_FILE;


  // -|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|- //
  // --------------------------------------------------- //
  // -------| INITIALIZING MODULES |-------------------- //
  // --------------------------------------------------- //
  // -|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|- //

  // ---- | Memories, utilized for precharging |----
  rom_512x8 Instruction_Memory (
              .Address (PC[8:0]),                     // IN
              .DataOut (DataOut_InstructionMemory)   // OUT
            );  // ROM

  // -----------------------------------------------

  // ----| Counter Modules |----

  // These three modules are related and are design give
  // feedback to one another in order to count

  // TODO: Confirm new NPC SELECTOR MUX   (Line 551)  before deletion

  // // USED FOR SELECTING BETWEEN JUMP TA OR nPC IN IF STAGE
  // Mux_9Bit_OR_32BIT_Case_One nPCselector (
  //                              .nPC      (nPC[8:0]),
  //                              .TA       (CTA_MUX_TA_nPC_SELECTOR),        // SIGNAL EXISTS
  //                              .S        (UB_MUX_SELECTION_NPC_SELECTOR),  // SIGNAL EXISTS
  //                              .Address  (nPC_MUX)
  //                            );

  nPCLogicBox AddPlusFour(
                .nPC      (nPC_MUX[8:0]),         // IN
                .result   (nPC_PLUS_4[8:0])       // OUT
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
  initial
  begin
    fi = $fopen("PF4_PreCharge.txt","r");
    Addr = 9'b000000000;
    while (!$feof(fi))
    begin
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
                 .instruction              (ID_INSTRUCTION_CU)                   // SIGNAL EXISTS
               );

  Mux_Control_Unit CU_MUX (
                     // ---------| Spliced Instructions (OUTPUT) | -----------
                     .OUT_ID_ALU_OP                (CU_MUX_ALU_OP_EX),                     // SIGNAL EXISTS
                     .OUT_ID_LOAD_INSTR            (CU_MUX_LOAD_INSTR_EX),                 // SIGNAL EXISTS
                     .OUT_ID_RF_ENABLE             (CU_MUX_RF_ENABLE_EX),                  // SIGNAL EXISTS
                     .OUT_ID_HI_ENABLE             (CU_MUX_HI_ENABLE_EX),                  // SIGNAL EXISTS
                     .OUT_ID_LO_ENABLE             (CU_MUX_LO_ENABLE_EX),                  // SIGNAL EXISTS
                     .OUT_ID_PC_PLUS8_INSTR        (CU_MUX_PC_PLUS8_INSTR_ID),             // SIGNAL EXISTS
                     .OUT_ID_UB_INSTR              (CU_MUX_UB_INSTR_UB_MUX),               // SIGNAL EXISTS
                     .OUT_ID_JALR_JR_INSTR         (CU_MUX_JALR_JR_INSTR_ID),              // SIGNAL EXISTS

                     .OUT_ID_DESTINATION_REGISTER  (CU_MUX_ID_DESTINATION_REGISTER_MUX_DESTINATION),     // SIGNAL EXISTS
                     .OUT_ID_OP_H_S                (CU_MUX_ID_OP_H_S_EX),                   // SIGNAL EXISTS

                     .OUT_ID_MEM_ENABLE            (CU_MUX_MEM_ENABLE_EX),                 // SIGNAL EXISTS
                     .OUT_ID_MEM_READWRITE         (CU_MUX_MEM_READWRITE_EX),              // SIGNAL EXISTS
                     .OUT_ID_MEM_SIZE              (CU_MUX_MEM_SIZE_EX),                   // SIGNAL EXISTS
                     .OUT_ID_MEM_SIGNE             (CU_MUX_MEM_SIGNE_EX),                  // SIGNAL EXISTS

                     // CONTROLED BY THE HAZARD FORWARDING UNIT
                     .controlMux                   (HAZARD_CONTROL_CU_MUX),

                     // ---------| Spliced Instructions (INPUT) | -----------
                     .ID_ALU_OP                    (CU_ALU_OP_CU_MUX),                          // SIGNAL EXISTS
                     .ID_LOAD_INSTR                (CU_LOAD_INSTR_CU_MUX),                      // SIGNAL EXISTS
                     .ID_RF_ENABLE                 (CU_RF_ENABLE_CU_MUX),                       // SIGNAL EXISTS
                     .ID_HI_ENABLE                 (CU_HI_ENABLE_CU_MUX),                       // SIGNAL EXISTS
                     .ID_LO_ENABLE                 (CU_LO_ENABLE_CU_MUX),                       // SIGNAL EXISTS
                     .ID_PC_PLUS8_INSTR            (CU_PC_PLUS8_INSTR_CU_MUX),                  // SIGNAL EXISTS
                     .ID_UB_INSTR                  (CU_UB_INSTR_CU_MUX),                        // SIGNAL EXISTS
                     .ID_JALR_JR_INSTR             (CU_JALR_JR_INSTR_CU_MUX),                   // SIGNAL EXISTS
                     // here
                     .ID_DESTINATION_REGISTER      (CU_DESTINATION_REGISTER_CU_MUX),  // SIGNAL EXISTS
                     .ID_OP_H_S                    (CU_OP_H_S_CU_MUX),                // SIGNAL EXISTS

                     .ID_MEM_ENABLE                (CU_MEM_ENABLE_CU_MUX),               // SIGNAL EXISTS
                     .ID_MEM_READWRITE             (CU_MEM_READWRITE_CU_MUX),            // SIGNAL EXISTS
                     .ID_MEM_SIZE                  (CU_MEM_SIZE_CU_MUX),                 // SIGNAL EXISTS
                     .ID_MEM_SIGNE                 (CU_MEM_SIGNE_CU_MUX),                // SIGNAL EXISTS

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
                           .enableEX   (EX_ENABLEEX_HAZARD),                 // SIGNAL EXISTS
                           .enableMEM  (MEM_ENABLEMEM_HAZARD),               // SIGNAL EXISTS
                           .enableWB   (WB_ENABLEWB_HAZARD),                 // SIGNAL EXISTS

                           .loadEX     (EX_LOADEX_HAZARD),                   // SIGNAL EXISTS

                           .regEX      (EX_REGEX_HAZARD),                    // SIGNAL EXISTS
                           .regMEM     (MEM_REGMEM_HAZARD),                  // SIGNAL EXISTS
                           .regWB      (WB_REGWB_HAZARD_AND_REGISTER_FILE),  // SIGNAL EXISTS | RW signal

                           .operandA   (ID_OPERAND_A_REGISTER_FILE_AND_HAZARD),    // SIGNAL EXISTS
                           .operandB   (ID_OPERAND_B_REGISTER_FILE_AND_HAZARD) // SIGNAL EXISTS
                         );

  Pipeline_Register_32bit_IF_ID IF_ID (
                                  // OUTPUT
                                  .Qs                 (ID_INSTRUCTION_CU),                        // OUTPUT OF THE INSTRUCTION | SIGNAL EXISTS
                                  .PC_out             (IF_PC_ID),                                 // SIGNAL EXISTS
                                  .OUT_IF_IMM16       (ID_IMM16_EX_AND_TIMES_4),                              //   Create this signal in module

    .OUT_IF_OPERAND_A   (ID_OPERAND_A_REGISTER_FILE_AND_HAZARD),    // SIGNAL EXISTS | Create this signal in module
    .OUT_IF_OPERAND_B   (ID_OPERAND_B_REGISTER_FILE_AND_HAZARD),    // SIGNAL EXISTS | Create this signal in module

                                  // INPUT
                                  .DS                 (DataOut_InstructionMemory),                // SIGNAL EXISTS | INPUT OF THE INSTRUCTION
                                  .PC                 (PC),                                       // ALDREADY EXISTTS
                                  .Clk                (Clk),                                      // ALDREADY EXISTTS
                                  .LE                 (stall_IFID),                               // ALDREADY EXISTTS
                                  .Reset              (CONDITION_HANDLER_IFRESET_IF)                                     // ALDREADY EXISTTS
                                );

  // Wacky Logic boxes Extravaganza // ------------------
  HiRegister Hi (
               // OUTPUT
               .HiSignal        (HI_HISIGNAL_EX),   // SIGNAL EXISTS

               // INPUT
               .PW              (WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2),         // SIGNAL EXISTS
               .HiEnable        (WB_HIENABLE_HI),   // SIGNAL EXISTS
               .clk             (Clk)               // ALREADY EXISTS
             );

  LoRegister Low (
                // OUTPUT
                .LoSignal       (LO_LOSIGNAL_EX),        // SIGNAL EXISTS
                // INPUT
                .LoEnable       (WB_LOENABLE_LO),        // SIGNAL EXISTS
                .clk            (Clk),                   // ALREADY EXISTS
                .PW             (WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2)               // SIGNAL EXISTS
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
                  .Second_Value   (TIMES_4_IMM16_ID_ALU)      // 4*imm16
                );

  // DO NOT CONFUSE WITH CASE 1
  Times_Four_Logic_Box_Case_Two X4_SE_Case_Two( /* USED FOR HANDLING Address26 FOR UNCONDITIONAL TA*/
                                  // OUTPUT
                                  .Result         (TIMES_4_ADDRESS26_EX),

                                  // INPUT
                                  .Address26      (ID_INSTRUCTION_CU[25:0]) // ADDRESS 26 | TODO: Create an explicit wire for this
                                );

  Bitwise_OR_Logic_Box Bitwise_OR_Logic ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
                         // OUTPUT
                         .Address26_x4_Output        (TIMES_4_ADDRESS26_EX),

                         // INPUT
                         .Result                     (BITWISE_OR_UTA_UTAMUX),        // SIGNAL EXISTS | UTA IS UNCONDINTIONAL TARGET ADDRESS
                         .AND_Output                 (BITWISE_AND_RESULT_BITWISE_OR) // This is actually an input btw
                       );

  Bitwise_AND_Logic_Box Bitwise_AND_Logic ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
                          // OUTPUT
                          .Result                     (BITWISE_AND_RESULT_BITWISE_OR), // SIGNAL EXISTS

                          // INPUT
                          .PC                         (IF_PC_ID),                      // SIGNAL EXISTS
                          .Second_Value               (32'hf0000000)                   // SIGNAL EXISTS
                        );

  // Wacky multiplexers Extravaganza // ----------------

  Mux_32Bit_OR_32BIT UTA_MUX ( // ID_MUX_Case_one
                       // OUTPUT
                       .Out                        (UTA_MUX_UTA_MUX_RESULT_CTA_MUX), // SIGNAL EXISTS

                       // INPUT
                       .Input_One                  (BITWISE_OR_UTA_UTAMUX), // SIGNAL EXISTS
                       .Input_Two                  (MX1_MX1RESULT_UTAMUX_AND_EX), // SIGNAL EXISTS
                       .S                          (CU_MUX_JALR_JR_INSTR_UTA_MUX_AND_CTA_MUX) // SIGNAL EXISTS
                     );
  Mux_32Bit_OR_32BIT CTA_MUX ( // ID_MUX_Case_two | Target Address
                       // OUTPUT
                       .Out                        (CTA_MUX_TA_nPC_SELECTOR),                  // SIGNAL EXISTS

                       // INPUT
                       .Input_One                  (UTA_MUX_UTA_MUX_RESULT_CTA_MUX),           // SIGNAL EXISTS
                       .Input_Two                  (EX_CTA_CTA_MUX),                           // SIGNAL EXISTS
                       .S                          (CU_MUX_JALR_JR_INSTR_UTA_MUX_AND_CTA_MUX)      // SIGNAL EXISTS | TODO: ASK NESTOR ABOUT THIS, FR
                     );
                     
  Mux_32Bit_OR_32BIT NPC_SELECTOR_MUX ( // IF Stage | NPC Selector 
                       .Out                        (NPC),                                 // TODO: Confirm output signal

                       .Input_One                  (CTA_MUX_TA_nPC_SELECTOR),             // SIGNAL EXISTS
                       .Input_Two                  (nPC_MUX),                             // SIGNAL EXISTS
                       .S                          ()                                     // TODO: Add output signal of UB_MUX
                     );

  Mux_32Bit_OR_32BIT PC_PLUS_8_MUX ( // EX Stage | PC+8 Selector
                       .Out                        (PC_PLUS_8_MUX_PC_MX1_AND_MX2),                //TODO: Signal does not exist                            // TODO: Find or create output signal

                       .Input_One                  (EX_PC_8_MEM_AND_PC_SELECTOR_MUX),             // SIGNAL EXISTS
                       .Input_Two                  (ALU_ALU_Result_MEM_AND_PC_SELECTOR_MUX),      // SIGNAL EXISTS
                       .S                          (EX_PC_PLUS8_INSTR_MEM_AND_PC_SELECTOR_MUX)    // SIGNAL EXISTS 
                     );

  Mux_Destination_Registers ID_MUX_Destination (
                              // OUTPUT
                              .Out                          (MUX_DESTINATION_REG_EX),                         // SIGNAL EXISTS
                              // INPUT
                              .RD                           (ID_INSTRUCTION_CU[15:11]),                       // SIGNAL EXISTS
                              .RT                           (ID_INSTRUCTION_CU[20:16]),                       // SIGNAL EXISTS
                              .R31                          (5'b11111),                                       // YES
                              .S                            (CU_MUX_ID_DESTINATION_REGISTER_MUX_DESTINATION)  // SIGNAL EXISTS
                            );

  // End of Wacky multiplexer extravaganza // ----------


  // End of the Wacky Logic Boxes Extravaganza // ------
  Register_File Reg_File (
                  // OUTPUT
                  .PA     (REGISTER_FILE_PA_MX1),                                         // SIGNAL EXISTS
                  .PB     (REGISTER_FILE_PB_MX2),                                         // SIGNAL EXISTS

                  // INPUT
                  .Clk    (Clk),
                  .RW     (WB_REGWB_HAZARD_AND_REGISTER_FILE),                            // SIGNAL EXISTS
                  .E      (WB_REG_FILE_ENABLE_REGISTER_FILE),                             // SIGNAL EXISTS
                  .PW_DS  (WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2),         // SIGNAL EXISTS
                  .RA     (ID_OPERAND_A_REGISTER_FILE_AND_HAZARD),                        // SIGNAL EXISTS
                  .RB     (ID_OPERAND_B_REGISTER_FILE_AND_HAZARD)                         // SIGNAL EXISTS
                );

  Mux_RegisterFile_Ports MX1 (
                           // PA
                           .ID_Result  (REGISTER_FILE_PA_MX1),                                     // SIGNAL EXISTS                                // SIGNAL EXISTS
                           .EX_Result  (EX_PWDS_MX1_AND_MX2),                                      // SIGNAL EXISTS
                           .MEM_Result (MEM_PWDS_MX1_AND_MX2),                                     // SIGNAL EXISTS
                           .WB_Result  (WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2),     // SIGNAL EXISTS
                           .S          (HAZARD_FWDB_MX1),                                          // SIGNAL EXISTS
                           .Out        (MX1_MX1RESULT_UTAMUX_AND_EX)                               // SIGNAL EXISTS
                         );

  Mux_RegisterFile_Ports MX2 (
                           // PB
                           .ID_Result  (REGISTER_FILE_PB_MX2),                                     // SIGNAL EXISTS
                           .EX_Result  (EX_PWDS_MX1_AND_MX2),                                      // SIGNAL EXISTS
                           .MEM_Result (MEM_PWDS_MX1_AND_MX2),                                     // SIGNAL EXISTS
                           .WB_Result  (WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2),     // SIGNAL EXISTS
                           .S          (HAZARD_FWDB_MX2),                                          // SIGNAL EXISTS
                           .Out        (MX2_MX2_RESULT_EX)                                         // SIGNAL EXISTS
                         );

  // A bunch of other muxes that do uh... stuff


  Plus_8_Logic_Box Plus_8 (
                     .PC     (IF_PC_ID),                 // SIGNAL EXISTS
                     .Result (PLUS_8_PC_8_EX)            // SIGNAL EXISTS
                   );

Pipeline_Register_32bit_ID_EX ID_EX (
    .Clk                        (Clk),
    .Reset                      (Reset),
    
    // INPUT
    .ID_HI_ENABLE               (CU_MUX_HI_ENABLE_EX),                          // SIGNAL EXISTS
    .ID_LO_ENABLE               (CU_MUX_LO_ENABLE_EX),                          // SIGNAL EXISTS
    .ID_RF_ENABLE               (CU_MUX_RF_ENABLE_EX),                          // SIGNAL EXISTS
    .ID_ALU_OP                  (CU_MUX_ALU_OP_EX),                             // SIGNAL EXISTS
    .ID_LOAD_INSTR              (CU_MUX_LOAD_INSTR_EX),                         // SIGNAL EXISTS
    .ID_OP_H_S                  (CU_MUX_ID_OP_H_S_EX),                          // SIGNAL EXISTS
    .ID_MEM_ENABLE              (CU_MUX_MEM_ENABLE_EX),                         // SIGNAL EXISTS
    .ID_MEM_READWRITE           (CU_MUX_MEM_READWRITE_EX),                      // SIGNAL EXISTS
    .ID_MEM_SIZE                (CU_MUX_MEM_SIZE_EX),                           // SIGNAL EXISTS
    .ID_MEM_SIGNE               (CU_MUX_MEM_SIGNE_EX),                          // SIGNAL EXISTS
    .ID_PC_PLUS8_INSTR          (CU_MUX_PC_PLUS8_INSTR_ID),                     // SIGNAL EXISTS
    .ID_PC_PLUS8_RESULT         (PLUS_8_PC_8_EX),                               // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .MX1_RESULT                 (MX1_MX1RESULT_UTAMUX_AND_EX),                  // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .MX2_RESULT                 (MX2_MX2_RESULT_EX),                            // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .ID_HI_QS                   (HI_HISIGNAL_EX),                               // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .ID_LO_QS                   (LO_LOSIGNAL_EX),                               // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .ID_PC                      (IF_PC_ID),                                     // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .ID_IMM16                   (ID_IMM16_EX_AND_TIMES_4),                      // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .ID_REG                     (MUX_DESTINATION_REG_EX),                       // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    .ID_RT                      (),    //  ADD SIGNAL TO MODULE
    
    // Output
    .OUT_ID_ALU_OP              (EX_ALU_OP_ALU),                                // SIGNAL EXISTS
    .OUT_ID_LOAD_INSTR          (EX_LOADEX_HAZARD),                             // SIGNAL EXISTS
    .OUT_ID_RF_ENABLE           (EX_RF_ENABLE_MEM),                             // SIGNAL EXISTS
    .OUT_ID_HI_ENABLE           (EX_HI_ENABLE_MEM),                             // SIGNAL EXISTS
    .OUT_ID_LO_ENABLE           (EX_LO_ENABLE_MEM),                             // SIGNAL EXISTS
    .OUT_ID_PC_PLUS8_INSTR      (EX_PC_PLUS8_INSTR_MEM_AND_PC_SELECTOR_MUX),    // SIGNAL EXISTS
    .OUT_ID_OP_H_S              (EX_OP_H_S_OPERAND),                            // SIGNAL EXISTS
    .OUT_ID_MEM_ENABLE          (EX_MEM_ENABLE_MEM),                            // SIGNAL EXISTS
    .OUT_ID_MEM_READWRITE       (EX_MEM_READWRITE_MEM),                         // SIGNAL EXISTS
    .OUT_ID_MEM_SIZE            (EX_MEM_SIZE_MEM),                              // SIGNAL EXISTS
    .OUT_ID_MEM_SIGNE           (EX_MEM_SIGNE_MEM),                             // SIGNAL EXISTS
    .OUT_ID_PC_PLUS8_RESULT     (EX_PC_8_MEM_AND_PC_SELECTOR_MUX),              // SIGNAL EXISTS | Create this signal in module
    .OUT_ID_MX1_Result          (EX_MX1_ALU),                                   // SIGNAL EXISTS
    .OUT_ID_MX2_Result          (EX_MX2_OPERAND),                               // SIGNAL EXISTS
    .OUT_ID_HI_QS               (EX_HISIGNAL_OPERAND),                          // SIGNAL EXISTS  CREATE THIS SIGNAL IN MODULE
    .OUT_ID_LO_QS               (EX_LOSIGNAL_OPERAND),                          // SIGNAL EXISTS  CREATE THIS SIGNAL IN MODULE
    .OUT_ID_PC                  (EX_PC),                                        // TODO: VERIFY WITH GTK WAVE
    .OUT_ID_IMM16               (EX_IMM16_OPERAND),                             // SIGNAL EXISTS
    .OUT_EnableEX               (EX_ENABLEEX_HAZARD),                           // SIGNAL EXISTS | Create this signal in module
    .OUT_regEX                  (EX_REGEX_HAZARD),                              // SIGNAL EXISTS | Create this signal in module
    .OUT_regMEM                 (MEM_REGMEM_HAZARD),                            // SIGNAL EXISTS | Create this signal in module
    .OUT_regWB                  (WB_REGWB_HAZARD),                              // SIGNAL EXISTS | Create this signal in module
    .OUT_ID_RT                  ()              // ADD SIGNAL TO MODULE
);

  Handler Operand_Handler (
            // Output
            .N          (HANDLER_N_ALU),        // SIGNAL EXISTS

            // Inputs
            .PB         (EX_MX2_OPERAND),       // SIGNAL EXISTS
            .HI         (EX_HISIGNAL_OPERAND),  // SIGNAL EXISTS
            .LO         (EX_LOSIGNAL_OPERAND),  // SIGNAL EXISTS
            .PC         (Out_ID_PC),
            .imm16      (EX_IMM16_OPERAND),     // SIGNAL EXISTS
            .Si         (EX_OP_H_S_OPERAND)     // SIGNAL EXISTS
          );

  ALU ALU (
        // INPUT
        .operand_A      (EX_MX1_ALU),                               // SIGNAL EXISTS
        .operand_B      (HANDLER_N_ALU),                            // SIGNAL EXISTS
        .alu_control    (EX_ALU_OP_ALU),                            // SIGNAL EXISTS
        // OUTPUT
        .result         (ALU_ALU_Result_MEM_AND_PC_SELECTOR_MUX),   // SIGNAL EXISTS
        .z_flag         (ALU_Z_FLAG_MEM_AND_CONDITION_HANDLER),     // SIGNAL EXISTS
        .n_flag         (ALU_N_FLAG_MEM_AND_CONDITION_HANDLER)      // SIGNAL EXISTS
      );

  // TODO: Confirm newest edition of PC_SELECTOR_MUX  (Line 557)  before deletion

  // Mux_9Bit_OR_32BIT_Case_Two PC_Selector_MUX (
  //                              // OUTPUT
  //                              .Out          (),                                              

  //                              // INPUT
  //                              .PC_Plus_8    (EX_PC_8_MEM_AND_PC_SELECTOR_MUX),              
  //                              .Result       (ALU_ALU_Result_MEM_AND_PC_SELECTOR_MUX),       
  //                              .S            (EX_PC_PLUS8_INSTR_MEM_AND_PC_SELECTOR_MUX)     
  //                            );

  Condition_Handler Condition_Handler (
                      // OUTPUT
                      .if_id_reset    (CONDITION_HANDLER_IFRESET_IF),
                      .CH_Out         (COND_HANDLER_UB_UB_MUX),                   // SIGNAL EXISTS
                       
                      // INPUT
                      .RT             (),
                      .z_flag         (ALU_Z_FLAG_MEM_AND_CONDITION_HANDLER),     // SIGNAL EXISTS
                      .n_flag         (ALU_N_FLAG_MEM_AND_CONDITION_HANDLER),      // SIGNAL EXISTS
                      .CH_opcode()
                    );

Pipeline_Register_32bit_EX_MEM EX_MEM (
    // INPUT
    .Clk,         // Clock signal
    .Reset,        // Reset signal
    .EX_LOAD_INSTR             (EX_LOADEX_HAZARD),                              // SIGNAL EXISTS | TODO: ????
    .EX_HI_ENABLE              (EX_HI_ENABLE_MEM),                              // SIGNAL EXISTS
    .EX_LO_ENABLE              (EX_LO_ENABLE_MEM),                              // SIGNAL EXISTS
    .EX_RF_ENABLE              (EX_RF_ENABLE_MEM),                              // SIGNAL EXISTS
    .EX_PC_PLUS8_INSTR         (EX_PC_PLUS8_INSTR_MEM_AND_PC_SELECTOR_MUX),     // SIGNAL EXISTS
    .EX_MEM_ENABLE             (EX_MEM_ENABLE_MEM),                             // SIGNAL EXISTS
    .EX_MEM_READWRITE          (EX_MEM_READWRITE_MEM),                          // SIGNAL EXISTS
    .EX_MEM_SIZE               (EX_MEM_SIZE_MEM),                               // SIGNAL EXISTS
    .EX_MEM_SIGNE              (EX_MEM_SIGNE_MEM),                              // SIGNAL EXISTS
    .EX_ADDRESS                (ALU_ALU_Result_MEM_AND_PC_SELECTOR_MUX),        // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    // OUTPUT
    .OUT_EX_LOAD_INSTR        (MEM_LOAD_INSTR_MEMORY_MUX_CASE_ONE),            // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_RF_ENABLE         (MEM_MEM_RF_),                                   // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_HI_ENABLE         (MEM_HI_ENABLE_WB),                              // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_LO_ENABLE         (MEM_LO_ENABLE_WB),                              // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_PC_PLUS8_INSTR    (MEM_PC_PLUS8_INSTR),                            // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_MEM_ENABLE        (MEM_MEM_ENABLE_DATA_MEMORY),                    // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_MEM_READWRITE     (MEM_MEM_READWRITE_DATA_MEMORY),                 // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_MEM_SIZE          (MEM_MEM_SIZE_DATA_MEMORY),                      // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_MEM_SIGNE         (MEM_MEM_SIGNE_DATA_MEMORY),                     // CHANGE THESE SIGNALS IN MODULE
    .OUT_EX_ADDRESS           (MEM_ADDRESS_DATA_MEMORY),                       // 
    .OUT_EnableMEM             (MEM_ENABLEMEM_HAZARD)                           // SIGNAL EXISTS | Create signal on module
);
ram_512x8 Data_Memory (
    // OUTPUT
    .DataOut                (DATA_MEMORY),
    // INPUT
    .Enable                 (MEM_MEM_ENABLE_DATA_MEMORY),
    .ReadWrite              (MEM_MEM_READWRITE_DATA_MEMORY),
    .SignExtend             (MEM_MEM_SIGNE_DATA_MEMORY),
    .Address                (MEM_ADDRESS_DATA_MEMORY),
    .DataIn                 (MEM_DATAIN_DATA_MEMORY),
    .Size                   (MEM_MEM_SIZE_DATA_MEMORY)
);

  Mux_32Bit_OR_32BIT MEM_Memory_MUX_Case_One (
                       // OUTPUT
                       .Out                        (),
                       // INPUT
                       .Input_One                  (),
                       .Input_Two                  (),
                       .S                          (MEM_LOAD_INSTR_MEMORY_MUX_CASE_ONE)
                     );

  Mux_32Bit_OR_32BIT MEM_Memory_MUX_Case_Two (
                       .Input_One                  (),
                       .Input_Two                  (),
                       .Out                        ()
                     );


Pipeline_Register_32bit_MEM_WB MEM_WB (
  // Output Control Signals
    .OUT_MEM_RF_ENABLE         (),

    .OUT_MEM_HI_ENABLE         (MEM_HI_ENABLE_WB), // CHANGE SIGNAL IN MODULE SO IT MAKE SENSE
    .OUT_MEM_LO_ENABLE         (MEM_LO_ENABLE_WB), // CHANGE SIGNAL IN MODULE SO IT MAKE SENSE

                                   .OUT_RW_REGISTER_FILE     (WB_PWDS_HI_AND_LOW_AND_REGISTER_FILE_AND_MX1_AND_MX2), // SIGNAL EXISTS | CREATE SIGNAL IN MODULE

    .OUT_EnableMEM             (WB_ENABLEWB_HAZARD), // SIGNAL EXISTS | CREATE SIGNAL IN MODULE
    
    // Input Control Signals
    .MEM_RF_ENABLE             (WB_REG_FILE_ENABLE_REGISTER_FILE), // SIGNAL EXISTS | REGISTER FILE
    .MEM_HI_ENABLE             (WB_HIENABLE_HI),                   // SIGNAL EXISTS
    .MEM_LO_ENABLE             (WB_LOENABLE_LO),                   // SIGNAL EXISTS
    .Clk                      (Clk),
    .Reset                    (Reset)
);


  // Clock generator
  initial
  begin
    Reset <= 1'b1;
    stall_NPC <= 1'b1;
    stall_PC <= 1'b1;
    S <= 1'b0;
    Clk <= 1'b0;
    #2 Clk <= ~Clk;
    #1 Reset <= 1'b0;
    #1 Clk <= ~Clk;
    forever
      #2 Clk = ~Clk;
  end

  initial
  begin
    #52;
    $display("\n----------------------------------------------------------\nDONE :D");
    $finish;
  end

initial begin
  $monitor("Instruction: %b | CLK: %b | PC: %d | nPC: %d", DataOut_InstructionMemory, Clk, PC[8:0], nPC[8:0]);
end


endmodule;
