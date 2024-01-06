`include "Decoder.v"
`include "Muxes.v"
module Register_File(
    input wire [31:0]   PW_DS,
    input wire [4:0]    RW,
    input wire          Clk,
    input wire          E,
    input wire [4:0]    RA,
    input wire [4:0]    RB,
    output wire [31:0]  PA, //Three ports
    output wire [31:0]  PB
);
wire O_Ldzero;
wire O_Ldone;
wire O_Ldtwo;
wire O_Ldthree;
wire O_Ldfour;
wire O_Ldfive;
wire O_Ldsix;
wire O_Ldseven;
wire O_Ldeight;
wire O_Ldnine;
wire O_Ldten;
wire O_Ldeleven;
wire O_Ldtwelve;
wire O_Ldthirteen;
wire O_Ldfourteen;
wire O_Ldfifteen;
wire O_Ldsixteen;
wire O_Ldseventeen;
wire O_Ldeighteen;
wire O_Ldnineteen;
wire O_Ldtwenty;
wire O_Ldtwentyone;
wire O_Ldtwentytwo;
wire O_Ldtwentythree;
wire O_Ldtwentyfour;
wire O_Ldtwentyfive;
wire O_Ldtwentysix;
wire O_Ldtwentyseven;
wire O_Ldtwentyeight;
wire O_Ldtwentynine;
wire O_Ldthirty;
wire O_Ldthirtyone;

wire [31:0] Qs_register_inputs_zero;
wire [31:0] Qs_register_inputs_one; 
wire [31:0] Qs_register_inputs_two;
wire [31:0] Qs_register_inputs_three;
wire [31:0] Qs_register_inputs_four;
wire [31:0] Qs_register_inputs_five;
wire [31:0] Qs_register_inputs_six;
wire [31:0] Qs_register_inputs_seven;
wire [31:0] Qs_register_inputs_eight;
wire [31:0] Qs_register_inputs_nine;
wire [31:0] Qs_register_inputs_ten;
wire [31:0] Qs_register_inputs_eleven;
wire [31:0] Qs_register_inputs_twelve;
wire [31:0] Qs_register_inputs_thirteen;
wire [31:0] Qs_register_inputs_fourteen;
wire [31:0] Qs_register_inputs_fifteen;
wire [31:0] Qs_register_inputs_sixteen;
wire [31:0] Qs_register_inputs_seventeen;
wire [31:0] Qs_register_inputs_eighteen;
wire [31:0] Qs_register_inputs_nineteen;
wire [31:0] Qs_register_inputs_twenty;
wire [31:0] Qs_register_inputs_twentyone;
wire [31:0] Qs_register_inputs_twentytwo;
wire [31:0] Qs_register_inputs_twentythree;
wire [31:0] Qs_register_inputs_twentyfour;
wire [31:0] Qs_register_inputs_twentyfive;
wire [31:0] Qs_register_inputs_twentysix;
wire [31:0] Qs_register_inputs_twentyseven;
wire [31:0] Qs_register_inputs_twentyeight;
wire [31:0] Qs_register_inputs_twentynine;
wire [31:0] Qs_register_inputs_thirty;
wire [31:0] Qs_register_inputs_thirtyone;

Decoder_5to32 Decoder (RW, E, O_Ldzero, 
                                O_Ldone, 
                                O_Ldtwo, 
                                O_Ldthree, 
                                O_Ldfour,
                                O_Ldfive,
                                O_Ldsix,
                                O_Ldseven,
                                O_Ldeight,
                                O_Ldnine,
                                O_Ldten,
                                O_Ldeleven,
                                O_Ldtwelve,
                                O_Ldthirteen,
                                O_Ldfourteen,
                                O_Ldfifteen,
                                O_Ldsixteen,
                                O_Ldseventeen,
                                O_Ldeighteen,
                                O_Ldnineteen,
                                O_Ldtwenty,
                                O_Ldtwentyone,
                                O_Ldtwentytwo,
                                O_Ldtwentythree,
                                O_Ldtwentyfour,
                                O_Ldtwentyfive,
                                O_Ldtwentysix,
                                O_Ldtwentyseven,
                                O_Ldtwentyeight,
                                O_Ldtwentynine,
                                O_Ldthirty,
                                O_Ldthirtyone);


Register_32bit RegisterZero (PW_DS, O_Ldzero, Clk, Qs_register_inputs_zero);
Register_32bit RegisterOne (PW_DS, O_Ldone, Clk, Qs_register_inputs_one);
Register_32bit RegisterTwo (PW_DS, O_Ldtwo, Clk, Qs_register_inputs_two);
Register_32bit RegisterThree (PW_DS, O_Ldthree, Clk, Qs_register_inputs_three);
Register_32bit RegisterFour (PW_DS, O_Ldfour, Clk, Qs_register_inputs_four);
Register_32bit RegisterFive (PW_DS, O_Ldfive, Clk, Qs_register_inputs_five);
Register_32bit RegisterSix (PW_DS, O_Ldsix, Clk, Qs_register_inputs_six);
Register_32bit RegisterSeven (PW_DS, O_Ldseven, Clk, Qs_register_inputs_seven);
Register_32bit RegisterEight (PW_DS, O_Ldeight, Clk, Qs_register_inputs_eight);
Register_32bit RegisterNine (PW_DS, O_Ldnine, Clk, Qs_register_inputs_nine);
Register_32bit RegisterTen (PW_DS, O_Ldten, Clk, Qs_register_inputs_ten);
Register_32bit RegisterEleven (PW_DS, O_Ldeleven, Clk, Qs_register_inputs_eleven);
Register_32bit RegisterTwelve (PW_DS, O_Ldtwelve, Clk, Qs_register_inputs_twelve);
Register_32bit RegisterThirteen (PW_DS, O_Ldthirteen, Clk, Qs_register_inputs_thirteen);
Register_32bit RegisterFourteen (PW_DS, O_Ldfourteen, Clk, Qs_register_inputs_fourteen);
Register_32bit RegisterFifteen (PW_DS, O_Ldfifteen, Clk, Qs_register_inputs_fifteen);
Register_32bit RegisterSixteen (PW_DS, O_Ldsixteen, Clk, Qs_register_inputs_sixteen);
Register_32bit RegisterSeventeen (PW_DS, O_Ldseventeen, Clk, Qs_register_inputs_seventeen);
Register_32bit RegisterEighteen (PW_DS, O_Ldeighteen, Clk, Qs_register_inputs_eighteen);
Register_32bit RegisterNineteen (PW_DS, O_Ldnineteen, Clk, Qs_register_inputs_nineteen);
Register_32bit RegisterTwenty (PW_DS, O_Ldtwenty, Clk, Qs_register_inputs_twenty);
Register_32bit RegisterTwentyone (PW_DS, O_Ldtwentyone, Clk, Qs_register_inputs_twentyone);
Register_32bit RegisterTwentytwo (PW_DS, O_Ldtwentytwo, Clk, Qs_register_inputs_twentytwo);
Register_32bit RegisterTwentythree (PW_DS, O_Ldtwentythree, Clk, Qs_register_inputs_twentythree);
Register_32bit RegisterTwentyfour (PW_DS, O_Ldtwentyfour, Clk, Qs_register_inputs_twentyfour);
Register_32bit RegisterTwentyfive (PW_DS, O_Ldtwentyfive, Clk, Qs_register_inputs_twentyfive);
Register_32bit RegisterTwentysix (PW_DS, O_Ldtwentysix, Clk, Qs_register_inputs_twentysix);
Register_32bit RegisterTwentyseven (PW_DS, O_Ldtwentyseven, Clk, Qs_register_inputs_twentyseven);
Register_32bit RegisterTwentyeight (PW_DS, O_Ldtwentyeight, Clk, Qs_register_inputs_twentyeight);
Register_32bit RegisterTwentynine (PW_DS, O_Ldtwentynine, Clk, Qs_register_inputs_twentynine);
Register_32bit RegisterThirty (PW_DS, O_Ldthirty, Clk, Qs_register_inputs_thirty);
Register_32bit RegisterThirtyone (PW_DS, O_Ldthirtyone, Clk, Qs_register_inputs_thirtyone);

Mux_32to1 MultiplexerOne (Qs_register_inputs_zero,
                            Qs_register_inputs_one,
                            Qs_register_inputs_two,
                            Qs_register_inputs_three,
                            Qs_register_inputs_four,
                            Qs_register_inputs_five,
                            Qs_register_inputs_six,
                            Qs_register_inputs_seven,
                            Qs_register_inputs_eight,
                            Qs_register_inputs_nine,
                            Qs_register_inputs_ten,
                            Qs_register_inputs_eleven,
                            Qs_register_inputs_twelve,
                            Qs_register_inputs_thirteen,
                            Qs_register_inputs_fourteen,
                            Qs_register_inputs_fifteen,
                            Qs_register_inputs_sixteen,
                            Qs_register_inputs_seventeen,
                            Qs_register_inputs_eighteen,
                            Qs_register_inputs_nineteen,
                            Qs_register_inputs_twenty,
                            Qs_register_inputs_twentyone,
                            Qs_register_inputs_twentytwo,
                            Qs_register_inputs_twentythree,
                            Qs_register_inputs_twentyfour,
                            Qs_register_inputs_twentyfive,
                            Qs_register_inputs_twentysix,
                            Qs_register_inputs_twentyseven,
                            Qs_register_inputs_twentyeight,
                            Qs_register_inputs_twentynine,
                            Qs_register_inputs_thirty,
                            Qs_register_inputs_thirtyone, RA, PA);

Mux_32to1 MultiplexerTwo (Qs_register_inputs_zero,
                            Qs_register_inputs_one,
                            Qs_register_inputs_two,
                            Qs_register_inputs_three,
                            Qs_register_inputs_four,
                            Qs_register_inputs_five,
                            Qs_register_inputs_six,
                            Qs_register_inputs_seven,
                            Qs_register_inputs_eight,
                            Qs_register_inputs_nine,
                            Qs_register_inputs_ten,
                            Qs_register_inputs_eleven,
                            Qs_register_inputs_twelve,
                            Qs_register_inputs_thirteen,
                            Qs_register_inputs_fourteen,
                            Qs_register_inputs_fifteen,
                            Qs_register_inputs_sixteen,
                            Qs_register_inputs_seventeen,
                            Qs_register_inputs_eighteen,
                            Qs_register_inputs_nineteen,
                            Qs_register_inputs_twenty,
                            Qs_register_inputs_twentyone,
                            Qs_register_inputs_twentytwo,
                            Qs_register_inputs_twentythree,
                            Qs_register_inputs_twentyfour,
                            Qs_register_inputs_twentyfive,
                            Qs_register_inputs_twentysix,
                            Qs_register_inputs_twentyseven,
                            Qs_register_inputs_twentyeight,
                            Qs_register_inputs_twentynine,
                            Qs_register_inputs_thirty,
                            Qs_register_inputs_thirtyone, RB, PB);

endmodule

module Register_32bit (
  input wire [31:0] DS,    // 32-bit input data
  input wire Ld,          // Write enable signal
  input wire Clk,         // Clock signal
  output reg [31:0] Qs    // 32-bit output data
);

always @(posedge Clk)
begin
  if (Ld)
    Qs <= DS;
end

endmodule