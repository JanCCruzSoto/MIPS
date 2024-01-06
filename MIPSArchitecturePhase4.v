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
wire controlMux;

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



// -------| INITIALIZING MODULES |------------------

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
  .ID_ALU_OP                (ID_ALU_OP),
  .ID_LOAD_INSTR            (ID_LOAD_INSTR),
  .ID_RF_ENABLE             (ID_RF_ENABLE),
  .ID_HI_ENABLE             (ID_HI_ENABLE),
  .ID_LO_ENABLE             (ID_LO_ENABLE),
  .ID_PC_PLUS8_INSTR        (ID_PC_PLUS8_INSTR),
  .ID_UB_INSTR              (ID_UB_INSTR),
  .ID_JALR_JR_INSTR         (ID_JALR_JR_INSTR),

  .ID_DESTINATION_REGISTER  (ID_DESTINATION_REGISTER),
  .ID_OP_H_S                (ID_OP_H_S),

  .ID_MEM_ENABLE            (ID_MEM_ENABLE),
  .ID_MEM_READWRITE         (ID_MEM_READWRITE),
  .ID_MEM_SIZE              (ID_MEM_SIZE),
  .ID_MEM_SIGNE             (ID_MEM_SIGNE),

  .instruction              (DataOut_InstructionMemory)
);

Mux_Control_Unit CU_MUX (

  // ---------| Spliced Instructions (OUTPUT) | -----------
  .OUT_ID_ALU_OP                (OUT_ID_ALU_OP),
  .OUT_ID_LOAD_INSTR            (OUT_ID_LOAD_INSTR),
  .OUT_ID_RF_ENABLE             (OUT_ID_RF_ENABLE),
  .OUT_ID_HI_ENABLE             (OUT_ID_HI_ENABLE),
  .OUT_ID_LO_ENABLE             (OUT_ID_LO_ENABLE),
  .OUT_ID_PC_PLUS8_INSTR        (OUT_ID_PC_PLUS8_INSTR),
  .OUT_ID_UB_INSTR              (OUT_ID_UB_INSTR),
  .OUT_ID_JALR_JR_INSTR         (OUT_ID_JALR_JR_INSTR),

  .OUT_ID_DESTINATION_REGISTER  (OUT_ID_DESTINATION_REGISTER),
  .OUT_ID_OP_H_S                (OUT_ID_OP_H_S),
  .OUT_ID_MEM_ENABLE            (OUT_ID_MEM_ENABLE),
  .OUT_ID_MEM_READWRITE         (OUT_ID_MEM_READWRITE),
  .OUT_ID_MEM_SIZE              (OUT_ID_MEM_SIZE),
  .OUT_ID_MEM_SIGNE             (OUT_ID_MEM_SIGNE),

  // CONTROLED BY THE HAZARD FORWARDING UNIT
  .controlMux                   (controlMux),

  // ---------| Spliced Instructions (INPUT) | -----------

  .ID_ALU_OP                    (ID_ALU_OP),
  .ID_LOAD_INSTR                (ID_LOAD_INSTR),
  .ID_RF_ENABLE                 (ID_RF_ENABLE),
  .ID_HI_ENABLE                 (ID_HI_ENABLE),
  .ID_LO_ENABLE                 (ID_LO_ENABLE),
  .ID_PC_PLUS8_INSTR            (ID_PC_PLUS8_INSTR),
  .ID_UB_INSTR                  (ID_UB_INSTR),
  .ID_JALR_JR_INSTR             (ID_JALR_JR_INSTR),

  .ID_DESTINATION_REGISTER      (ID_DESTINATION_REGISTER),
  .ID_OP_H_S                    (ID_OP_H_S),

  .ID_MEM_ENABLE                (ID_MEM_ENABLE),
  .ID_MEM_READWRITE             (ID_MEM_READWRITE),
  .ID_MEM_SIZE                  (ID_MEM_SIZE),
  .ID_MEM_SIGNE                 (ID_MEM_SIGNE),

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

// ------------------------------


// ----| BEGIN PIPELINE |------------


Hazard_Forwarding_Unit Hazard (
    // output
    .fwdA       (fwdA),
    .fwdB       (fwdB),

    .stallPC    (stall_PC),
    .stallNPC   (stall_NPC),
    .stallIFID  (stall_IFID),

    .controlMux (controlMux),

    // input
    .enableEX   (enableEX),
    .enableMEM  (enableMEM),
    .enableWB   (enableWB),

    .loadEX     (loadEX),

    .regEX      (regEX),
    .regMEM     (regMEM),
    .regWB      (regWB),

    .operandA   (operandA),
    .operandB   (operandB)
);

Pipeline_Register_32bit_IF_ID IF_ID (
    .Qs             (Qs),
    .PC_out         (PC_ID),
    .Out_IF_IMM16   (Out_IF_IMM16),

    IF_IMM16        (),
    .DS             (),
    .PC             (PC),
    .Clk            (Clk),
    .LE             (stall_IFID),
    .Reset          (Reset)
);

// Wacky Logic boxes Extravaganza // ------------------
HiRegister Hi (
    .LoSignal        (LoSignal),
    .clk             (Clk),
    .HiEnable        (HiEnable),
    .PW              (PW),
    .HiSignal        (HiSignal)
);

LowRegister Low (
    .LoEnable       (LoEnable),
    .clk            (Clk),
    .PW             (PW)
);

Times_Four_Logic_Box_Case_One X4_SE_Case_One ( /*USED FOR Imm16 FOR CONDITIONAL TA*/
    .Imm16          (),
    .Result         ()
);

Sum_Logic_Box PLUS_4_BOX_ID (
    .First_Value    (), // PC+4
    .Second_Value   (), // 4*imm16
    .Result         ()
);

ALU ALU_CTA (

);


Times_Four_Logic_Box_Case_Two X4_SE_Case_Two( /*USED FOR HANDLING Address26 FOR UNCONDITIONAL TA*/
    .Address26      (),
    .Result         ()
);

Bitwise_AND_Logic_Box Bitwise_AND_Logic ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
    .Result                     (),
    .PC                         (),
    .Second_Value               ()
);

Bitwise_OR_Logic_Box Bitwise_OR_Logic ( /*USED FOR CALCULATING UNCONDITIONAL TA*/
    .Result                     (),
    .AND_Output                 (),
    .Address26_x4_Output        ()
    
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
    .S          (fwdA), 
    .Out        (OUT_MX1)
);

Mux_RegisterFile_Ports MX2 (
    // PA
    .ID_Result  (PB),
    .EX_Result  (),
    .MEM_Result (),
    .WB_Result  (),
    .S          (fwdB), 
    .Out        (OUT_MX2)
);

// A bunch of other muxes that do uh... stuff


Plus_8_Logic_Box Plus_8 (
    .PC     (PC_ID),
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

.ID_HI_QS                   (HiSignal),
.ID_LO_QS                   (LoSignal),

.ID_PC                      (PC_ID),
.ID_IMM16                   (Out_IF_IMM16),

// Output
.Out_ID_ALU_OP              (Out_ID_ALU_OP),
.Out_ID_LOAD_INSTR          (Out_ID_LOAD_INSTR),
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
.Out_ID_IMM16               (Out_ID_IMM16)
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
  .Out_ID_MEM_SIGNE         ()
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
  .Out_ID_LO_ENABLE         () 
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