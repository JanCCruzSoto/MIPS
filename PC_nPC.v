module Register_32bit_PC (
  input wire [31:0] DS,    // 8-bit input data
  input wire stallPC,          // Write enable signal
  input wire Clk,         // Clock signal
  input wire Reset,        // Reset signal
  output reg [31:0] Qs    // 8-bit output data
);

always @(posedge Clk) //alrevez 
begin
  if (Reset) //Ld is in charge of enabling operation not deleting values (if deleted the Program Counter would be lost without a way to execute the instruction sequence)
  begin

    Qs <= 9'b0; //pc 32
  end

  else if (stallPC)
  begin
    Qs <= DS;
  //Reset depends on the clock (reset sincronico)
  end
end

endmodule


module Register_32bit_nPC ( //Works different than PC, because it never decreases to 0
  input wire [31:0] DS,    // 8-bit input data
  input wire stallnPC,          // Write enable signal
  input wire Clk,         // Clock signal
  input wire Reset,        // Reset signal
  output reg [31:0] Qs    // 8-bit output data
);

always @(posedge Clk)
begin
  if (Reset) //Ld is in charge of enabling operation not deleting values (if deleted the Program Counter would be lost without a way to execute the instruction sequence)
  begin

    Qs <= 9'd4; //pc 32
  end

  else if (stallnPC)
  begin
    Qs <= DS;
  //Reset depends on the clock (reset sincronico)
  end
end

endmodule
