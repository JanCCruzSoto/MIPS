module Condition_Handler (
    output reg          if_id_reset,
    output reg          CH_Out,

    input wire  [5:0]   RT,
    input wire          z_flag,
    input wire          n_flag
); 


always @* begin
    
    case (RT)
        6'b000101: begin //not equal
            if(z_flag == 0) CH_Out <= 1'b1;
            else CH_Out <= 1'b0;
        end
        6'b000100: begin //equal
            if(z_flag == 1) CH_Out <= 1'b1;
            else CH_Out <= 1'b0;
        end
        6'b000111: begin //greater than zero
            if(instruction[20:16] == 5'b00000) begin
                if((z_flag == 0) && (n_flag == 0)) CH_Out <= 1'b1;
                else CH_Out <= 1'b0;
            end
        end 
        6'b000110: begin //lesser or equal than zero
            if(instruction[20:16] == 5'b00000) begin
                if((z_flag == 1) || (n_flag == 1)) CH_Out <= 1'b1;
                else CH_Out <= 1'b0;
            end
        end
        6'b000001: begin
            case (instruction[20:16])
              5'b10001: begin //BAL (BGEZAL) //branch and link
                    CH_Out <= 1'b1;
              end
             5'b00001 : begin //greater or equal than zero
                    if((z_flag == 1) || (n_flag == 0)) CH_Out <= 1'b1;
                    else CH_Out <= 1'b0;
              end
              5'b00000: begin //lesser than zero
                    if((z_flag == 0) && (n_flag == 1)) CH_Out <= 1'b1;
                    else CH_Out <= 1'b0;
              end
              5'b10000: begin //lesser than zero and link
                    if(n_flag == 1) CH_Out <= 1'b1;
                    else CH_Out <= 1'b0;
              end
            endcase
        end
    endcase

end

endmodule