module Decoder_5to32 (
    input [4:0] RW,    // 5-bit input
    input E,
    //output reg O [31:0]output reg [31:0] Ozero,
    output reg Ozero,
    output reg Oone,
    output reg Otwo,
    output reg Othree,
    output reg Ofour,
    output reg Ofive,
    output reg Osix,
    output reg Oseven,
    output reg Oeight,
    output reg Onine,
    output reg Oten,
    output reg Oeleven,
    output reg Otwelve,
    output reg Othirteen,
    output reg Ofourteen,
    output reg Ofifteen,
    output reg Osixteen,
    output reg Oseventeen,
    output reg Oeighteen,
    output reg Onineteen,
    output reg Otwenty,
    output reg Otwentyone,
    output reg Otwentytwo,
    output reg Otwentythree,
    output reg Otwentyfour,
    output reg Otwentyfive,
    output reg Otwentysix,
    output reg Otwentyseven,
    output reg Otwentyeight,
    output reg Otwentynine,
    output reg Othirty,
    output reg Othirtyone  // 32-bit output
);

always @(RW, E)
begin
Ozero = 0;
Oone = 0;
Otwo = 0;
Othree = 0;
Ofour = 0;
Ofive = 0;
Osix = 0;
Oseven = 0;
Oeight = 0;
Onine = 0;
Oten = 0;
Oeleven = 0;
Otwelve = 0;
Othirteen = 0;
Ofourteen = 0;
Ofifteen = 0;
Osixteen = 0;
Oseventeen = 0;
Oeighteen = 0;
Onineteen = 0;
Otwenty = 0;
Otwentyone = 0;
Otwentytwo = 0;
Otwentythree = 0;
Otwentyfour = 0;
Otwentyfive = 0;
Otwentysix = 0;
Otwentyseven = 0;
Otwentyeight = 0;
Otwentynine = 0;
Othirty = 0;
Othirtyone = 0;
    if(E) begin
        case (RW)
            5'b00000: Ozero = 1'b1; //Register Zero Value
            5'b00001: Oone = 1'b1;
            5'b00010: Otwo = 1'b1;
            5'b00011: Othree = 1'b1;
            5'b00100: Ofour = 1'b1;
            5'b00101: Ofive = 1'b1;
            5'b00110: Osix = 1'b1;
            5'b00111: Oseven = 1'b1;
            5'b01000: Oeight = 1'b1;
            5'b01001: Onine = 1'b1;
            5'b01010: Oten = 1'b1;
            5'b01011: Oeleven = 1'b1;
            5'b01100: Otwelve = 1'b1;
            5'b01101: Othirteen = 1'b1;
            5'b01110: Ofourteen = 1'b1;
            5'b01111: Ofifteen = 1'b1;
            5'b10000: Osixteen = 1'b1;
            5'b10001: Oseventeen = 1'b1;
            5'b10010: Oeighteen = 1'b1;
            5'b10011: Onineteen = 1'b1;
            5'b10100: Otwenty = 1'b1;
            5'b10101: Otwentyone = 1'b1;
            5'b10110: Otwentytwo = 1'b1;
            5'b10111: Otwentythree = 1'b1;
            5'b11000: Otwentyfour = 1'b1;
            5'b11001: Otwentyfive = 1'b1;
            5'b11010: Otwentysix = 1'b1;
            5'b11011: Otwentyseven = 1'b1;
            5'b11100: Otwentyeight = 1'b1;
            5'b11101: Otwentynine = 1'b1;
            5'b11110: Othirty = 1'b1;
            5'b11111: Othirtyone = 1'b1;
        endcase
    end else begin 
        Ozero        = 1'b0;
        Oone         = 1'b0;
        Otwo         = 1'b0;
        Othree       = 1'b0; 
        Ofour        = 1'b0;
        Ofive        = 1'b0;
        Osix         = 1'b0;
        Oseven       = 1'b0;
        Oeight       = 1'b0;
        Onine        = 1'b0;
        Oten         = 1'b0;
        Oeleven      = 1'b0;
        Otwelve      = 1'b0;
        Othirteen    = 1'b0;
        Ofourteen    = 1'b0;
        Ofifteen     = 1'b0;
        Osixteen     = 1'b0;
        Oseventeen   = 1'b0;
        Oeighteen    = 1'b0;
        Onineteen    = 1'b0;
        Otwenty      = 1'b0;
        Otwentyone   = 1'b0;
        Otwentytwo   = 1'b0;
        Otwentythree = 1'b0;
        Otwentyfour  = 1'b0;
        Otwentyfive  = 1'b0;
        Otwentysix   = 1'b0;
        Otwentyseven = 1'b0;
        Otwentyeight = 1'b0;
        Otwentynine  = 1'b0;
        Othirty      = 1'b0;
        Othirtyone   = 1'b0;
    end
end

endmodule