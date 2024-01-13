module Mux_Control_Unit (
    input wire [3:0] ID_ALU_OP, //4 bit BUS (ALU CONTROL)
    input wire ID_LOAD_INSTR,
    input wire ID_RF_ENABLE,
    input wire ID_HI_ENABLE,
    input wire ID_LO_ENABLE,
    input wire ID_PC_PLUS8_INSTR,
    input wire ID_UB_INSTR,
    input wire ID_JALR_JR_INSTR,
    input wire [1:0] ID_DESTINATION_REGISTER,
    input wire [2:0] ID_OP_H_S,
    input wire ID_MEM_ENABLE,
    input wire ID_MEM_READWRITE,
    input wire [1:0] ID_MEM_SIZE, //2 bit BUS size for store function
    input wire ID_MEM_SIGNE,

    //Line inputs as zero for NOP
    input wire [3:0] ZERO_ID_ALU_OP, //4 bit BUS (ALU CONTROL)
    input wire ZERO_ID_LOAD_INSTR,
    input wire ZERO_ID_RF_ENABLE,
    input wire ZERO_ID_HI_ENABLE,
    input wire ZERO_ID_LO_ENABLE,
    input wire ZERO_ID_PC_PLUS8_INSTR,
    input wire ZERO_ID_UB_INSTR,
    input wire ZERO_ID_JALR_JR_INSTR,
    input wire [1:0] ZERO_ID_DESTINATION_REGISTER,
    input wire [2:0] ZERO_ID_OP_H_S,
    input wire ZERO_ID_MEM_ENABLE,
    input wire ZERO_ID_MEM_READWRITE,
    input wire [1:0] ZERO_ID_MEM_SIZE, //2 bit BUS size for store function
    input wire ZERO_ID_MEM_SIGNE,

    input wire controlMux,              // 1 bit selector coming from hazard unit

    //THE OUTPUTS ARE HALF THE INPUT. ZEROS OR ACTUAL INPUT VALUES
    output reg [3:0] OUT_ID_ALU_OP, //4 bit BUS (ALU CONTROL)
    output reg OUT_ID_LOAD_INSTR,
    output reg OUT_ID_RF_ENABLE,
    output reg OUT_ID_HI_ENABLE,
    output reg OUT_ID_LO_ENABLE,
    output reg OUT_ID_PC_PLUS8_INSTR,
    output reg OUT_ID_UB_INSTR,
    output reg OUT_ID_JALR_JR_INSTR,
    output reg [1:0] OUT_ID_DESTINATION_REGISTER,
    output reg [2:0] OUT_ID_OP_H_S,
    output reg OUT_ID_MEM_ENABLE,
    output reg OUT_ID_MEM_READWRITE,
    output reg [1:0] OUT_ID_MEM_SIZE, //2 bit BUS size for store function
    output reg OUT_ID_MEM_SIGNE
  );

  always @(*)
  begin
    case(controlMux)
      1'b0:
      begin
        OUT_ID_ALU_OP                 <= ID_ALU_OP;
        OUT_ID_LOAD_INSTR             <= ID_LOAD_INSTR;
        OUT_ID_RF_ENABLE              <= ID_RF_ENABLE;
        OUT_ID_HI_ENABLE              <= ID_HI_ENABLE;
        OUT_ID_LO_ENABLE              <= ID_LO_ENABLE;
        OUT_ID_PC_PLUS8_INSTR         <= ID_PC_PLUS8_INSTR;
        OUT_ID_UB_INSTR               <= ID_UB_INSTR;
        OUT_ID_JALR_JR_INSTR          <= ID_JALR_JR_INSTR;
        OUT_ID_DESTINATION_REGISTER   <= ID_DESTINATION_REGISTER;
        OUT_ID_OP_H_S                 <= ID_OP_H_S;
        OUT_ID_MEM_ENABLE             <= ID_MEM_ENABLE;
        OUT_ID_MEM_READWRITE          <= ID_MEM_READWRITE;
        OUT_ID_MEM_SIZE               <= ID_MEM_SIZE;
        OUT_ID_MEM_SIGNE              <= ID_MEM_SIGNE;
      end
      1'b1:
      begin
        OUT_ID_ALU_OP               <= ZERO_ID_ALU_OP;
        OUT_ID_LOAD_INSTR           <= ZERO_ID_LOAD_INSTR;
        OUT_ID_RF_ENABLE            <= ZERO_ID_RF_ENABLE;
        OUT_ID_HI_ENABLE            <= ZERO_ID_HI_ENABLE;
        OUT_ID_LO_ENABLE            <= ZERO_ID_LO_ENABLE;
        OUT_ID_PC_PLUS8_INSTR       <= ZERO_ID_PC_PLUS8_INSTR;
        OUT_ID_UB_INSTR             <= ZERO_ID_UB_INSTR;
        OUT_ID_JALR_JR_INSTR        <= ZERO_ID_JALR_JR_INSTR;
        OUT_ID_DESTINATION_REGISTER <= ZERO_ID_DESTINATION_REGISTER;
        OUT_ID_OP_H_S               <= ZERO_ID_OP_H_S;
        OUT_ID_MEM_ENABLE           <= ZERO_ID_MEM_ENABLE;
        OUT_ID_MEM_READWRITE        <= ZERO_ID_MEM_READWRITE;
        OUT_ID_MEM_SIZE             <= ZERO_ID_MEM_SIZE;
        OUT_ID_MEM_SIGNE            <= ZERO_ID_MEM_SIGNE;
      end
    endcase
  end
endmodule

// module Mux_9Bit_OR_32BIT_Case_One ( /*USED FOR SELECTING BETWEEN JUMP TA OR nPC IN IF STAGE*/
//     input wire [8:0] nPC,
//     input wire [31:0] TA,

//     input wire S, //Selection signal

//     output reg [31:0] Address
//   );

//   always@(*)
//   begin

//     case(S)
//       1'b0:
//         Address = nPC;

//       1'b1:
//         Address = TA;
//     endcase

//   end

// endmodule

// module Mux_9Bit_OR_32BIT_Case_Two ( /*USED FOR SELECTING PC + 8 WHEN REQUIRED BY AN INSTRUCTION*/
//     input wire [8:0] PC_Plus_8,
//     input wire [31:0] Result,

//     input wire S, //Selection signal

//     output reg [31:0] Out
//   );

//   always@(*)
//   begin

//     case(S)
//       1'b0:
//         Out = Result;

//       1'b1:
//         Out = PC_Plus_8;
//     endcase

//   end

// endmodule


module Mux_1BitTwoToOne (
    input wire INPUT_ONE,
    input wire INPUT_TWO,
    input wire S,
    output reg OUT
  );
  always@(*)
  begin
    case(S)
      1'b0:
        OUT <= INPUT_ONE;
      1'b1:
        OUT <= INPUT_TWO;
    endcase
  end
endmodule

module MUX32BitTwoToOne ( /*USED FOR 32 BIT INPUTS*/ /*TWO USED IN ID AND ONE USED IN MEM*/
    input wire [31:0] Input_One,
    input wire [31:0] Input_Two,

    input wire S, //Selection signal

    output reg [31:0] Out
  );

  always@(*)
  begin

    case(S)
      1'b0:
        Out <= Input_One;

      1'b1:
        Out <= Input_Two;
    endcase
  end

endmodule

module Mux_Jump_OR_Condition ( /*USED FOR 1 BIT INPUTS*/ /*ONLY ONE USED IN ID*/
    input wire Jump, //Jump if Unconditional //WOULD BE A DIRECT 1
    input wire Condition, //Condition Handler Signal

    input wire S, //Selection signal

    output reg Out
  );

  always@(*)
  begin

    case(S)
      1'b0:
        Out = Condition;

      1'b1:
        Out = Jump;
    endcase

  end

endmodule

module Mux_RegisterFile_Ports (
    input wire [31:0] ID_Result,
    input wire [31:0] EX_Result,
    input wire [31:0] MEM_Result,
    input wire [31:0] WB_Result,
    input wire [1:0] S,
    output reg [31:0] Out
  );

  always@(*)
  begin
    case(S)
      2'b00:
        Out = ID_Result;
      2'b01:
        Out = EX_Result;
      2'b10:
        Out = MEM_Result;
      2'b11:
        Out = WB_Result;
    endcase
  end

endmodule


module Mux_Destination_Registers ( /*USED FOR 5 BIT INPUTS*/ /*ONE USED IN ID*/
    //Destination Registers used by instructions
    input wire [4:0] RD,  // 5-bit input for RD
    input wire [4:0] RT,  // 5-bit input for RT
    input wire [4:0] R31, // 5-bit input for Register 31

    input wire [1:0] S, //Selection signal /*COMES FROM FORWARDING UNIT*/

    output reg [4:0] Out // Corrected to 5-bit output
  );


  always@(*)
  begin
    case(S)
      2'b00:
        Out = RD;
      2'b01:
        Out = RT;
      2'b10:
        Out = R31;
      default:
        Out = 5'bxxxxx; // Undefined state
    endcase
  end

endmodule



module Mux_32to1 (

    input wire [31:0] Rzero,
    input wire [31:0] Rone,
    input wire [31:0] Rtwo,
    input wire [31:0] Rthree,
    input wire [31:0] Rfour,
    input wire [31:0] Rfive,
    input wire [31:0] Rsix,
    input wire [31:0] Rseven,
    input wire [31:0] Reight,
    input wire [31:0] Rnine,
    input wire [31:0] Rten,
    input wire [31:0] Releven,
    input wire [31:0] Rtwelve,
    input wire [31:0] Rthirteen,
    input wire [31:0] Rfourteen,
    input wire [31:0] Rfifteen,
    input wire [31:0] Rsixteen,
    input wire [31:0] Rseventeen,
    input wire [31:0] Reighteen,
    input wire [31:0] Rnineteen,
    input wire [31:0] Rtwenty,
    input wire [31:0] Rtwentyone,
    input wire [31:0] Rtwentytwo,
    input wire [31:0] Rtwentythree,
    input wire [31:0] Rtwentyfour,
    input wire [31:0] Rtwentyfive,
    input wire [31:0] Rtwentysix,
    input wire [31:0] Rtwentyseven,
    input wire [31:0] Rtwentyeight,
    input wire [31:0] Rtwentynine,
    input wire [31:0] Rthirty,
    input wire [31:0] Rthirtyone,  // 32 32-bit input data lines
    input wire [4:0] R,              // 5-bit select signal
    output reg [31:0] P         // 32-bit output data
  );

  always @(*)
  begin
    case(R)
      5'b00000:
        P = 5'b0;
      5'b00001:
        P = Rone;
      5'b00010:
        P = Rtwo;
      5'b00011:
        P = Rthree;
      5'b00100:
        P = Rfour;
      5'b00101:
        P = Rfive;
      5'b00110:
        P = Rsix;
      5'b00111:
        P = Rseven;
      5'b01000:
        P = Reight;
      5'b01001:
        P = Rnine;
      5'b01010:
        P = Rten;
      5'b01011:
        P = Releven;
      5'b01100:
        P = Rtwelve;
      5'b01101:
        P = Rthirteen;
      5'b01110:
        P = Rfourteen;
      5'b01111:
        P = Rfifteen;
      5'b10000:
        P = Rsixteen;
      5'b10001:
        P = Rseventeen;
      5'b10010:
        P = Reighteen;
      5'b10011:
        P = Rnineteen;
      5'b10100:
        P = Rtwenty;
      5'b10101:
        P = Rtwentyone;
      5'b10110:
        P = Rtwentytwo;
      5'b10111:
        P = Rtwentythree;
      5'b11000:
        P = Rtwentyfour;
      5'b11001:
        P = Rtwentyfive;
      5'b11010:
        P = Rtwentysix;
      5'b11011:
        P = Rtwentyseven;
      5'b11100:
        P = Rtwentyeight;
      5'b11101:
        P = Rtwentynine;
      5'b11110:
        P = Rthirty;
      5'b11111:
        P = Rthirtyone;
    endcase
    //P = register_inputs[R];
  end
endmodule



