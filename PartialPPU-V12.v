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

wire OUT_ID_ALU_OP
wire OUT_ID_LOAD_INSTR
wire OUT_ID_RF_ENABLE
wire OUT_ID_HI_ENABLE
wire OUT_ID_LO_ENABLE
wire OUT_ID_PC_PLUS8_INSTR
wire OUT_ID_UB_INSTR
wire OUT_ID_JALR_JR_INSTR


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
Mux_9Bit_OR_32BIT_Case_One PCselector (
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
  .ID_MEM_SIZE              (ID_MEM_SIZE)
  .ID_MEM_SIGNE             (ID_MEM_SIGNE),

  .instruction              (DataOut_InstructionMemory)
);

Mux_Control_Unit CU_MUX (

  // ---------| Spliced Instructions (OUTPUT) | -----------
  .OUT_ID_ALU_OP                (),
  .OUT_ID_LOAD_INSTR            (),
  .OUT_ID_RF_ENABLE             (),
  .OUT_ID_HI_ENABLE             (),
  .OUT_ID_LO_ENABLE             (),
  .OUT_ID_PC_PLUS8_INSTR        (),
  .OUT_ID_UB_INSTR              (),
  .OUT_ID_JALR_JR_INSTR         (),

  .OUT_ID_DESTINATION_REGISTER  (),
  .OUT_ID_OP_H_S                (),

  .OUT_ID_MEM_ENABLE            (),
  .OUT_ID_MEM_READWRITE         (),
  .OUT_ID_MEM_SIZE              (),
  .OUT_ID_MEM_SIGNE             (),

  .controlMux                   (),

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

  .ZERO_ID_ALU_OP               (),
  .ZERO_ID_LOAD_INSTR           (),
  .ZERO_ID_RF_ENABLE            (),
  .ZERO_ID_HI_ENABLE            (),
  .ZERO_ID_LO_ENABLE            (),
  .ZERO_ID_PC_PLUS8_INSTR       (),
  .ZERO_ID_UB_INSTR             (),
  .ZERO_ID_JALR_JR_INSTR        (),

  .ZERO_ID_DESTINATION_REGISTER (),
  .ZERO_ID_OP_H_S               (),

  .ZERO_ID_MEM_ENABLE           (),
  .ZERO_ID_MEM_READWRITE        (),
  .ZERO_ID_MEM_SIZE             (),
  .ZERO_ID_MEM_SIGNE            ()
);

// ------------------------------


// ----| BEGIN PIPELINE |------------




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