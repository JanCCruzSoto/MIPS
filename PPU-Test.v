`timescale 1ns / 1ns

// MIPS Architecture - Phase 4 Test Bench
// Jan Carlos - 
// Victor

`include "PartialPPU-V12.v"

module Testbench_PPU;

  // Inputs
  reg Reset;
  reg Clk;
  reg S;
  reg stallIFID;

  wire [8:0] Out_PC;
  wire [8:0] Out_nPC;
  wire [31:0] DataOut_InstructionMemory;
  wire [31:0] Out_IF_ID;

  wire [3:0] ID_ALU_OP;
  wire ID_LOAD_INSTR;
  wire ID_RF_ENABLE;
  wire ID_HI_ENABLE;
  wire ID_LO_ENABLE;
  wire ID_PC_PLUS8_INSTR;
  wire ID_UB_INSTR;
  wire ID_JALR_JR_INSTR;
  wire [1:0] ID_DESTINATION_REGISTER;
  wire [2:0] ID_OP_H_S;
  wire ID_MEM_ENABLE;
  wire ID_MEM_READWRITE;
  wire [1:0] ID_MEM_SIZE;
  wire ID_MEM_SIGNE;


  wire [3:0] Out_ID_ALU_OP_EX; //EX OUT
  wire Out_ID_LOAD_INSTR_EX; //EX OUT
  wire Out_ID_RF_ENABLE_EX; //EX OUT
  wire Out_ID_HI_ENABLE_EX;
  wire Out_ID_LO_ENABLE_EX;
  wire Out_ID_PC_PLUS8_INSTR_EX; //EX OUT
  wire [2:0] Out_ID_OP_H_S_EX;
  wire Out_ID_MEM_ENABLE_EX;
  wire Out_ID_MEM_READWRITE_EX;
  wire [1:0] Out_ID_MEM_SIZE_EX;
  wire Out_ID_MEM_SIGNE_EX;

  wire Out_ID_LOAD_INSTR_MEM; //MEM OUT
  wire Out_ID_RF_ENABLE_MEM; //MEM OUT
  wire Out_ID_HI_ENABLE_MEM;
  wire Out_ID_LO_ENABLE_MEM;
  wire Out_ID_PC_PLUS8_INSTR_MEM; //MEM OUT
  wire Out_ID_MEM_ENABLE_MEM; //MEM OUT
  wire Out_ID_MEM_READWRITE_MEM; //MEM OUT
  wire [1:0] Out_ID_MEM_SIZE_MEM; //MEM OUT
  wire Out_ID_MEM_SIGNE_MEM; //MEM OUT

  wire Out_ID_RF_ENABLE_WB; //WB OUT
  wire Out_ID_HI_ENABLE_WB; //WB OUT
  wire Out_ID_LO_ENABLE_WB;



  // Instantiate the PPU module
  PPU UUT (
    .stallPC(stallPC),
    .Reset(Reset),
    .Clk(Clk),
    .S(S),
    .stallIFID(stallIFID),
    .Out_PC(Out_PC),
    .Out_nPC(Out_nPC),
    .DataOut_InstructionMemory(DataOut_InstructionMemory),
    .Out_IF_ID(Out_IF_ID),
    .ID_ALU_OP(ID_ALU_OP),
    .ID_LOAD_INSTR(ID_LOAD_INSTR),
    .ID_RF_ENABLE(ID_RF_ENABLE),
    .ID_HI_ENABLE(ID_HI_ENABLE),
    .ID_LO_ENABLE(ID_LO_ENABLE),
    .ID_PC_PLUS8_INSTR(ID_PC_PLUS8_INSTR),
    .ID_UB_INSTR(ID_UB_INSTR),
    .ID_JALR_JR_INSTR(ID_JALR_JR_INSTR),
    .ID_DESTINATION_REGISTER(ID_DESTINATION_REGISTER),
    .ID_OP_H_S(ID_OP_H_S),
    .ID_MEM_ENABLE(ID_MEM_ENABLE),
    .ID_MEM_READWRITE(ID_MEM_READWRITE),
    .ID_MEM_SIZE(ID_MEM_SIZE),
    .ID_MEM_SIGNE(ID_MEM_SIGNE),
    .Out_ID_ALU_OP_EX(Out_ID_ALU_OP_EX),
    .Out_ID_LOAD_INSTR_EX(Out_ID_LOAD_INSTR_EX),
    .Out_ID_RF_ENABLE_EX(Out_ID_RF_ENABLE_EX),
    .Out_ID_HI_ENABLE_EX(Out_ID_HI_ENABLE_EX),
    .Out_ID_LO_ENABLE_EX(Out_ID_LO_ENABLE_EX),
    .Out_ID_PC_PLUS8_INSTR_EX(Out_ID_PC_PLUS8_INSTR_EX),
    .Out_ID_OP_H_S_EX(Out_ID_OP_H_S_EX),
    .Out_ID_MEM_ENABLE_EX(Out_ID_MEM_ENABLE_EX),
    .Out_ID_MEM_READWRITE_EX(Out_ID_MEM_READWRITE_EX),
    .Out_ID_MEM_SIZE_EX(Out_ID_MEM_SIZE_EX),
    .Out_ID_MEM_SIGNE_EX(Out_ID_MEM_SIGNE_EX),
    .Out_ID_LOAD_INSTR_MEM(Out_ID_LOAD_INSTR_MEM),
    .Out_ID_RF_ENABLE_MEM(Out_ID_RF_ENABLE_MEM),
    .Out_ID_HI_ENABLE_MEM(Out_ID_HI_ENABLE_MEM),
    .Out_ID_LO_ENABLE_MEM(Out_ID_LO_ENABLE_MEM),
    .Out_ID_PC_PLUS8_INSTR_MEM(Out_ID_PC_PLUS8_INSTR_MEM),
    .Out_ID_MEM_ENABLE_MEM(Out_ID_MEM_ENABLE_MEM),
    .Out_ID_MEM_READWRITE_MEM(Out_ID_MEM_READWRITE_MEM),
    .Out_ID_MEM_SIZE_MEM(Out_ID_MEM_SIZE_MEM),
    .Out_ID_MEM_SIGNE_MEM(Out_ID_MEM_SIGNE_MEM),
    .Out_ID_RF_ENABLE_WB(Out_ID_RF_ENABLE_WB),
    .Out_ID_HI_ENABLE_WB(Out_ID_HI_ENABLE_WB),
    .Out_ID_LO_ENABLE_WB(Out_ID_LO_ENABLE_WB)
  );


  // Clock generation (for simulation) (old)
  // always begin
  //   #2 Clk = ~Clk;
  // end

    // Clock generator
    initial begin
        Reset <= 1'b1;
        Clk <= 1'b0;
        #2 Clk <= ~Clk;
        #1 Reset <= 1'b0;
        #1 Clk <= ~Clk; 
       forever #2 Clk = ~Clk;
    end

  // Test vector application
  initial begin
    // Initialize signals
    S = 0;
    // stallIFID = 1;
    // $monitor("stallPC: %d, PC: %d" ,stallPC, Out_PC);
    $monitor("stallPC: %d, Clk: %d,    PC: %d,   nPC: %d,    Reset: %b,    S: %b,    Time: %d\n\
              DataOut_InstructionMemory: %b\n\n\
              Instruction being decoded: %b\n\
              Control Unit Output Signals:\n\
              ID_ALU_OP: %b,    ID_LOAD_INSTR: %b,    ID_RF_ENABLE: %b,   ID_HI_ENABLE: %b\n\
              ID_LO_ENABLE: %b,   ID_PC_PLUS8_INSTR: %b,    ID_UB_INSTR: %b,    ID_JALR_JR_INSTR: %b\n\
              ID_DESTINATION_REGISTER: %b,    ID_OP_H_S: %b,    ID_MEM_ENABLE: %b,   ID_MEM_READWRITE: %b\n\
              ID_MEM_SIZE: %b,    ID_MEM_SIGNE: %b,\n\n\
              EX STAGE CONTROL SIGNALS:\n\
              Out_ID_ALU_OP_EX: %b,   Out_ID_LOAD_INSTR_EX: %b,   Out_ID_RF_ENABLE_EX: %b,    Out_ID_HI_ENABLE_EX: %b\n\
              Out_ID_LO_ENABLE_EX: %b,    Out_ID_PC_PLUS8_INSTR_EX: %b,   Out_ID_OP_H_S_EX: %b,   Out_ID_MEM_ENABLE_EX: %b\n\
              Out_ID_MEM_READWRITE_EX: %b,   Out_ID_MEM_SIZE_EX: %b,   Out_ID_MEM_SIGNE_EX: %b\n\n\
              MEM STAGE CONTROL SIGNALS:\n\
              Out_ID_LOAD_INSTR_MEM: %b,    Out_ID_RF_ENABLE_MEM: %b,   Out_ID_HI_ENABLE_MEM: %b,   Out_ID_LO_ENABLE_MEM: %b\n\
              Out_ID_PC_PLUS8_INSTR_MEM: %b,    Out_ID_MEM_ENABLE_MEM: %b,    Out_ID_MEM_READWRITE_MEM: %b\n\
              Out_ID_MEM_SIZE_MEM: %b,    Out_ID_MEM_SIGNE_MEM: %b\n\n\
              WB STAGE CONTROL SIGNALS:\n\
              Out_ID_RF_ENABLE_WB: %b,    Out_ID_HI_ENABLE_WB: %b,    Out_ID_LO_ENABLE_WB: %b",
              stallPC, Clk, Out_PC, Out_nPC, Reset, S, $time, DataOut_InstructionMemory, Out_IF_ID,
              ID_ALU_OP, ID_LOAD_INSTR, ID_RF_ENABLE, ID_HI_ENABLE, ID_LO_ENABLE, ID_PC_PLUS8_INSTR, ID_UB_INSTR,
              ID_JALR_JR_INSTR, ID_DESTINATION_REGISTER, ID_OP_H_S, ID_MEM_ENABLE, ID_MEM_READWRITE, ID_MEM_SIZE, ID_MEM_SIGNE,
              Out_ID_ALU_OP_EX, Out_ID_LOAD_INSTR_EX, Out_ID_RF_ENABLE_EX, Out_ID_HI_ENABLE_EX, Out_ID_LO_ENABLE_EX, Out_ID_PC_PLUS8_INSTR_EX,
              Out_ID_OP_H_S_EX, Out_ID_MEM_ENABLE_EX, Out_ID_MEM_READWRITE_EX, Out_ID_MEM_SIZE_EX, Out_ID_MEM_SIGNE_EX,
              Out_ID_LOAD_INSTR_MEM, Out_ID_RF_ENABLE_MEM, Out_ID_HI_ENABLE_MEM, Out_ID_LO_ENABLE_MEM, Out_ID_PC_PLUS8_INSTR_MEM,
              Out_ID_MEM_ENABLE_MEM, Out_ID_MEM_READWRITE_MEM, Out_ID_MEM_SIZE_MEM, Out_ID_MEM_SIGNE_MEM,
              Out_ID_RF_ENABLE_WB, Out_ID_HI_ENABLE_WB, Out_ID_LO_ENABLE_WB);

    end
    
  initial begin
    #3 Reset = 0;
    #37 S = 1;
    #8 $finish;
  end

endmodule