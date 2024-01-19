module Condition_Handler (
    output reg          if_id_reset,
    output reg          CH_Out,

    input wire [5:0]    CH_opcode,
    input wire [4:0]    RT,
    input wire          Z_FLAG,
    input wire          N_FLAG
); 

always @* begin
    if_id_reset <= 1'b0;
    case (CH_opcode)
        6'b000101: begin //not equal
            if(Z_FLAG == 0) CH_Out <= 1'b1;
            else CH_Out <= 1'b0;
        end
        6'b000100: begin //equal
            if(Z_FLAG == 1) CH_Out <= 1'b1;
            else CH_Out <= 1'b0;
        end
        6'b000111: begin //greater than zero
            if(RT == 5'b00000) begin
                if((Z_FLAG == 0) && (N_FLAG == 0)) CH_Out <= 1'b1;
                else CH_Out <= 1'b0;
            end
        end 
        6'b000110: begin //lesser or equal than zero
            if(RT == 5'b00000) begin
                if((Z_FLAG == 1) || (N_FLAG == 1)) CH_Out <= 1'b1;
                else CH_Out <= 1'b0;
            end
        end
        6'b000001: begin
            case (RT)
              5'b10001: begin //BAL (BGEZAL) //branch and link
                    CH_Out <= 1'b1;
              end
             5'b00001 : begin //greater or equal than zero
                    if((Z_FLAG == 1) || (N_FLAG == 0)) CH_Out <= 1'b1;
                    else CH_Out <= 1'b0;
              end
              5'b00000: begin //lesser than zero
                    if((Z_FLAG == 0) && (N_FLAG == 1)) CH_Out <= 1'b1;
                    else CH_Out <= 1'b0;
              end
              5'b10000: begin //lesser than zero and link
                    if(N_FLAG == 1) CH_Out <= 1'b1;
                    else CH_Out <= 1'b0;
              end
            endcase
        end
    endcase

end

endmodule