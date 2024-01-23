module Control_Unit(
    input [31:0] instruction,

    output reg [3:0] ID_ALU_OP, //4 bit BUS (ALU CONTROL)
    output reg ID_LOAD_INSTR, //load instructions
    output reg ID_RF_ENABLE, //register file enable
    output reg ID_HI_ENABLE, //HI register enable
    output reg ID_LO_ENABLE, //LO register enable
    output reg ID_PC_PLUS8_INSTR, //storing PC+8
    output reg ID_UB_INSTR, //unconditional branch
    output reg ID_JALR_JR_INSTR, //JALR & JR

    output reg [1:0] ID_DESTINATION_REGISTER, // Destination Register Selection Signal /2'b00 default RD, 2'b01 for RT, and 2'b10 for R31/
    output reg [2:0] ID_OP_H_S, //Operation Handler Control Signals
                                /*3'b000: N = PB;
                                  3'b001: N = HI;
                                  3'b010: N = LO;
                                  3'b011: N = PC;
                                  3'b100: N = imm16_extended;
                                  3'b101: N = imm16_concat;*/
    output reg ID_MEM_ENABLE, //data memory enable
    output reg ID_MEM_READWRITE, //load(read) or store(write)
    output reg [1:0] ID_MEM_SIZE, //size of Store
    output reg ID_MEM_SIGNE //sign extension

    
);

// Define opcodes for the instructions
localparam [5:0] 
    OPCODE_RTYPE = 6'b000000,
    OPCODE_SPECIAL = 6'b011100, // For CLO and CLZ
    OPCODE_J    = 6'b000010,
    OPCODE_JAL  = 6'b000011,
    OPCODE_ADDI  = 6'b001000,
    OPCODE_ADDIU = 6'b001001,
    OPCODE_SLTI  = 6'b001010,
    OPCODE_SLTIU = 6'b001011,
    OPCODE_ANDI  = 6'b001100,
    OPCODE_ORI   = 6'b001101,
    OPCODE_XORI  = 6'b001110,
    OPCODE_LUI   = 6'b001111,
    OPCODE_LB    = 6'b100000,
    OPCODE_LH    = 6'b100001,
    OPCODE_LW    = 6'b100011,
    OPCODE_LBU   = 6'b100100,
    OPCODE_LHU   = 6'b100101,
    OPCODE_SB    = 6'b101000,
    OPCODE_SH    = 6'b101001,
    OPCODE_SW    = 6'b101011,
    OPCODE_BEQ   = 6'b000100,
    OPCODE_BNE   = 6'b000101,
    OPCODE_BLEZ  = 6'b000110,
    OPCODE_BGTZ  = 6'b000111,
    OPCODE_REGIMM = 6'b000001; // Opcode for BLTZ, BGEZ, BLTZAL, BGEZAL, and BAL

// Define function codes for R-type instructions
localparam [5:0]
    FUNC_ADD  = 6'b100000,
    FUNC_ADDU = 6'b100001,
    FUNC_SUB  = 6'b100010,
    FUNC_SUBU = 6'b100011,
    FUNC_JR   = 6'b001000,
    FUNC_JALR = 6'b001001,
    FUNC_MFHI = 6'b010000,
    FUNC_MFLO = 6'b010010,
    FUNC_MOVN = 6'b001011,
    FUNC_MOVZ = 6'b001010,
    FUNC_MTHI = 6'b010001,
    FUNC_MTLO = 6'b010011,
    FUNC_SLT  = 6'b101010,
    FUNC_SLTU = 6'b101011,
    FUNC_AND  = 6'b100100,
    FUNC_OR   = 6'b100101,
    FUNC_XOR  = 6'b100110,
    FUNC_NOR  = 6'b100111,
    FUNC_SLL  = 6'b000000,
    FUNC_SLLV = 6'b000100,
    FUNC_SRA  = 6'b000011,
    FUNC_SRAV = 6'b000111,
    FUNC_SRL  = 6'b000010,
    FUNC_SRLV = 6'b000110;

// Define 'rt' field for special REGIMM instructions
localparam [4:0]
    RT_BLTZ   = 5'b00000,
    RT_BGEZ   = 5'b00001,
    RT_BLTZAL = 5'b10000,
    RT_BGEZAL = 5'b10001,
    RT_BAL    = 5'b10001; // Same as BGEZAL

always @(instruction) begin
    // Default control signals for NOP (no operation) and all other control signals
    ID_ALU_OP = 4'b0;
    ID_LOAD_INSTR = 0;
    ID_RF_ENABLE = 0;
    ID_HI_ENABLE = 0;
    ID_LO_ENABLE = 0;
    ID_PC_PLUS8_INSTR = 0;
    ID_UB_INSTR = 0;
    ID_JALR_JR_INSTR = 0;
    //ID_RTD_INSTR = 0;
    //ID_R31D_INSTR = 0;
    ID_DESTINATION_REGISTER = 2'b0;
    ID_OP_H_S = 3'b0;
    ID_MEM_ENABLE = 0;
    ID_MEM_READWRITE = 0;
    ID_MEM_SIZE = 2'b0;
    ID_MEM_SIGNE = 0;

    if (instruction == 32'b0) begin
        //Nothing will execute and signals will remain with value 0
        $display("This is NOP");
    end
    
    else begin
        case (instruction[31:26])
          OPCODE_RTYPE: begin //TYPE R (Except CLO & CLZ)
            case (instruction[5:0])
              FUNC_ADD: begin
                //ADD
                $display("This is ADD");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0000;
              end
              FUNC_ADDU: begin
                //ADDU
                $display("This is ADDU");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0000;
              end
              FUNC_SUB: begin
                //SUB
                $display("This is SUB");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0001;
              end
              FUNC_SUBU: begin
                //SUBU
                $display("This is SUBU");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0001;
              end
              FUNC_SLT: begin
                //SLT
                $display("This is SLT");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 1001;

              end
              FUNC_SLTU: begin
                //SLTU
                $display("This is SLTU");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 1001;
              end
              FUNC_AND: begin
                //AND
                $display("This is AND");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0010;
              end
              FUNC_OR: begin
                //OR
                $display("This is OR");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0011;
              end
              FUNC_XOR: begin
                //XOR
                $display("This is XOR");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0100;
              end
              FUNC_NOR: begin
                //NOR
                $display("This is NOR");
                ID_RF_ENABLE = 1;
                ID_ALU_OP = 0101;
              end
              FUNC_SLL: begin
                //SLL
                $display("This is SLL");
                ID_ALU_OP = 0110;
                ID_RF_ENABLE = 1;
              end
              FUNC_SLLV: begin
                //SLLV
                $display("This is SLLV");
                ID_ALU_OP = 0110;
                ID_RF_ENABLE = 1;
              end
              FUNC_SRA: begin
                //SRA
                $display("This is SRA");
                ID_ALU_OP = 1000;
                ID_RF_ENABLE = 1;
              end
              FUNC_SRAV: begin
                //SRAV
                $display("This is SRAV");
                ID_ALU_OP = 1000;
                ID_RF_ENABLE = 1;
              end
              FUNC_SRL: begin
                //SRL
                $display("This is SRL");
                ID_ALU_OP = 0111;
                ID_RF_ENABLE = 1;
              end
              FUNC_SRLV: begin
                //SRLV
                $display("This is SRLV");
                ID_ALU_OP = 0111;
                ID_RF_ENABLE = 1;
              end
              FUNC_MFHI: begin
                //MFHI
                $display("This is MFHI");
                ID_RF_ENABLE = 1;
                ID_HI_ENABLE = 1;
                ID_OP_H_S = 001;
              end
              FUNC_MFLO: begin
                //MFLO
                $display("This is MFLO");
                ID_RF_ENABLE = 1;
                ID_LO_ENABLE = 1;
                ID_OP_H_S = 010;
              end
            FUNC_MOVN: begin
                //MOVN
                $display("This is MOVN");
                ID_ALU_OP = 1010;
                ID_RF_ENABLE = 1;
              end
              FUNC_MOVZ: begin
                //MOVZ
                $display("This is MOVZ");
                ID_ALU_OP = 1010;
                ID_RF_ENABLE = 1;
              end
              FUNC_MTHI: begin
                //MTHI
                $display("This is MTHI");
                ID_HI_ENABLE = 1;
                ID_OP_H_S = 001;
              end
              FUNC_MTLO: begin
                //MTLO
                $display("This is MTLO");
                ID_LO_ENABLE = 1;
                ID_OP_H_S = 010;
              end
              FUNC_JALR: begin
                //JALR
                $display("This is JALR");
                ID_ALU_OP = 0000;
                ID_RF_ENABLE = 1;
                ID_JALR_JR_INSTR = 1;
                ID_UB_INSTR = 1;
                ID_PC_PLUS8_INSTR = 1;
                // destination reg?
              end
              FUNC_JR: begin
                //JR
                $display("This is JR");
                ID_JALR_JR_INSTR = 1;
                ID_UB_INSTR = 1;
              end
          endcase
          end
          OPCODE_ADDI: begin 
            //ADDI
            $display("This is ADDI");
            ID_DESTINATION_REGISTER = 2'b01;
            ID_ALU_OP = 0000;
            ID_RF_ENABLE = 1;
            ID_OP_H_S = 101;
          end
          OPCODE_ADDIU: begin 
            //ADDIU
            $display("This is ADDIU");
            ID_RF_ENABLE = 1;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_ALU_OP = 0000;
            ID_OP_H_S = 101;
          end
          OPCODE_SLTI: begin 
            //SLTI
            $display("This is SLTI");
            ID_ALU_OP = 1001;
            ID_RF_ENABLE = 1;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 101;
          end
          OPCODE_SLTIU: begin 
            //SLTIU
            $display("This is SLTIU");
            ID_ALU_OP = 1001;
            ID_RF_ENABLE = 1;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 101;
          end
          OPCODE_ANDI: begin 
            //ANDI
            $display("This is ANDI");
            ID_ALU_OP = 0010;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_RF_ENABLE = 1;
            ID_OP_H_S = 101;
          end
          OPCODE_ORI: begin 
            //ORI
            $display("This is ORI");
            ID_ALU_OP = 0011;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_RF_ENABLE = 1;
            ID_OP_H_S = 101;
          end
          OPCODE_XORI: begin 
            //XORI
            $display("This is XORI");
            ID_ALU_OP = 0100;
            ID_DESTINATION_REGISTER = 2'b00;
            ID_RF_ENABLE = 1;
            ID_OP_H_S = 101;
          end
          OPCODE_LUI: begin 
            //LUI
            $display("This is LUI");
            ID_RF_ENABLE = 1;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 101;
          end
          OPCODE_LW: begin 
            //LW: Load Word
            $display("This is LW");
            ID_ALU_OP = 0000;
            ID_LOAD_INSTR = 1;
            ID_RF_ENABLE = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 0;
            ID_MEM_SIZE = 2'b10;
            ID_MEM_SIGNE = 0; // maybe sea 1
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 101;
          end
          OPCODE_LH: begin 
            //LH: Load Halfword
            $display("This is LH");
            ID_ALU_OP = 0000;
            ID_LOAD_INSTR = 1;
            ID_RF_ENABLE = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 0;
            ID_MEM_SIZE = 2'b01;
            ID_MEM_SIGNE = 1;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 100; 
          end
          OPCODE_LHU: begin 
            //LHU: Load Halfword Unsigned
            $display("This is LHU");
            ID_ALU_OP = 0000;
            ID_LOAD_INSTR = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 0;
            ID_MEM_SIZE = 2'b01;
            ID_MEM_SIGNE = 0;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 101;
          end
          OPCODE_LB: begin 
            //LB: Load Byte
            $display("This is LB");
            ID_ALU_OP = 0000;
            ID_LOAD_INSTR = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 0;
            ID_MEM_SIZE = 2'b0;
            ID_MEM_SIGNE = 1;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 3'b101;  
            ID_RF_ENABLE = 1;
          
          end
          OPCODE_LBU: begin 
            //LBU: Load Byte Unsigned
            $display("This is LBU");
            ID_ALU_OP = 0000;
            ID_RF_ENABLE = 1;
            ID_LOAD_INSTR = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 0;
            ID_MEM_SIZE = 2'b0;
            ID_MEM_SIGNE = 0;
            ID_DESTINATION_REGISTER = 2'b01;
            ID_OP_H_S = 3'b101; //3'b101: N = imm16_concat; //Handler Ouput variable
          end
          6'b111111: begin 
            //SD
            $display("This is SD");
            ID_ALU_OP = 0000;
            ID_RF_ENABLE = 1;
          end
          OPCODE_SW: begin 
            //SW: Store Word
            $display("This is SW");
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 1;
            ID_MEM_SIZE = 2'b10;
            ID_OP_H_S = 101;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 1;
            ID_MEM_SIZE = 2'b11;
          end
          OPCODE_SH: begin 
            //SH: Store Halfword
            $display("This is SH");
            ID_ALU_OP = 0000;
            ID_RF_ENABLE = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 1;
            ID_MEM_SIZE = 2'b01;
            ID_OP_H_S = 101;
          end
          OPCODE_SB: begin 
            //SB: Store Byte
            $display("This is SB");
            ID_ALU_OP = 0000;
            ID_RF_ENABLE = 1;
            ID_MEM_ENABLE = 1;
            ID_MEM_READWRITE = 1;
            ID_MEM_SIZE = 2'b0;
            ID_OP_H_S = 101;
          end
          OPCODE_BEQ: begin 
            //B, BEQ
            $display("This is B/BEQ");
            //??? duda con b y beq
            ID_ALU_OP = 0000;
            ID_UB_INSTR = 1;
            ID_OP_H_S = 101;
          end
          OPCODE_REGIMM: begin 
            //BAL, BGEZ, BGEZAL, BLTZ, BLTZAL (rt)
            case (instruction[20:16])
              RT_BAL: begin
                //BAL, BGEZAL
                $display("This is BAL/BGEZAL");
                // ??? duda con caso bal y bgezal
                ID_ALU_OP = 0000;
                ID_RF_ENABLE = 1;
                ID_DESTINATION_REGISTER = 2'b10;
                ID_PC_PLUS8_INSTR = 1;
                ID_UB_INSTR = 1;
              end
              RT_BGEZ: begin
                //BGEZ
                $display("This is BGEZ");
                ID_ALU_OP = 1010; //si flg es N no hace
                ID_OP_H_S = 101; //immediate
              end
              RT_BLTZ: begin
                //BLTZ
                $display("This is BLTZ");
                ID_ALU_OP = 1010;
                ID_OP_H_S = 101;
              end
              RT_BLTZAL: begin
                //BLTZAL
                $display("This is BLTZAL");
                ID_ALU_OP = 1010;
                ID_PC_PLUS8_INSTR = 1;
                ID_RF_ENABLE = 1;
                ID_DESTINATION_REGISTER = 2'b10;
                ID_OP_H_S = 101;
              end
            endcase
          end
          OPCODE_BGTZ: begin 
            //BGTZ
            if (instruction[20:16] == 5'b00000) begin
              $display("This is BGTZ");
              ID_ALU_OP = 1010;
              ID_OP_H_S = 101;
            end
          end
          OPCODE_BLEZ: begin 
            //BLEZ
            if (instruction[20:16] == 5'b00000) begin
              $display("This is BLEZ");
              ID_ALU_OP = 1010;
              ID_OP_H_S = 101;
            end            
          end
          OPCODE_BNE: begin 
            //BNE
            $display("This is BNE");
            ID_ALU_OP = 0001; // si flg z prende no hace
            ID_OP_H_S = 101;
          end
          OPCODE_J: begin 
            //J
            $display("This is J");
            //??? no se q op de alu
            ID_ALU_OP = 0000;
            ID_UB_INSTR = 1;
          end
          OPCODE_JAL: begin 
            //JAL
            $display("This is JAL");
            //??? dudoso en el alu
            ID_ALU_OP = 0000;
            ID_RF_ENABLE = 1;
            ID_DESTINATION_REGISTER = 2'b10;
            ID_PC_PLUS8_INSTR = 1;
            ID_UB_INSTR = 1;
          end
          OPCODE_SPECIAL: begin 
            //CLO, CLZ (function)
            case (instruction[5:0])
              6'b100001: begin
                //CLO
                //???
                ID_RF_ENABLE = 1;
              end
              6'b100000: begin
                //CLZ
                //???
                ID_RF_ENABLE = 1;
              end
            endcase
          end
        endcase
    end
end
endmodule