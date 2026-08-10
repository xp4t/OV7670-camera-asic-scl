/*****************************************************************************
                        SEMICONDUCTOR COMPLEX LIMITED
*****************************************************************************
LIBRARY DATA    : Verilog Library  for scl 1.2u C1D library
REVISION        : I
AUTHOR          : Uday Khambete & Anuj Chawla.
Date            : 20/09/04

****************************************************************************/

`timescale 1ns/1ps
/***************************************************************************/

primitive DFF_UDP (Q, D, C, S, R, notifier);
  output Q;
  input D,C,S,R;
  input notifier;
  reg Q;

  table
  // D  C    S   R ntf : Qt: Qt+1
     0 (01)  1   ?  ?  : ? : 0 ; // rising clk d = 0
     1 (01)  ?   1  ?  : ? : 1 ; // rising clk d = 1
     0 (0?)  1   ?  ?  : 0 : 0 ; // rising clk d = q
     1 (0?)  ?   1  ?  : 1 : 1 ; // rising clk d = q
     0 (?1)  1   ?  ?  : 0 : 0 ; // rising clk d = q
     1 (?1)  ?   1  ?  : 1 : 1 ; // rising clk d = q
     ? (1?)  1   1  ?  : ? : - ; // falling clk
     ? (?0)  1   1  ?  : ? : - ; // falling clk
     *  ?    1   1  ?  : ? : - ; // data change
     ?  ?  (?1)  1  ?  : ? : - ; // set inactive
     ?  ?    1 (?1) ?  : ? : - ; // reset inactive
     ?  ?    1   0  ?  : ? : 0 ; // reset
     ?  ?    0   1  ?  : ? : 1 ; // set
     ?  ?    0   0  ?  : ? : 1 ; // set && reset
     ?  ?    x   ?  ?  : ? : x ; //
     ?  ?    ?   x  ?  : ? : x ; //
     ?  ?    ?   ?  *  : ? : x ; // timing violation
  endtable
endprimitive

primitive LATCH_UDP (Q, G, C, S, R, notifier);
  output Q;
  input G,C,S,R;
  input notifier;
  reg Q;
 
  table
  // D  G  S  R ntf : Qt: Qt+1
     0  1  1  ?  ?  : ? : 0 ; // open gate d = 0
     1  1  ?  1  ?  : ? : 1 ; // open gate d = 1
     0  ?  1  ?  ?  : 0 : 0 ; // any gate d = q
     1  ?  ?  1  ?  : 1 : 1 ; // any gate d = q
     ?  0  1  1  ?  : ? : - ; // closed gate
     ?  ?  1  0  ?  : ? : 0 ; // reset
     ?  ?  0  1  ?  : ? : 1 ; // set
     ?  ?  0  0  ?  : ? : 1 ; // set and reset(set)
     ?  ?  ?  ?  *  : ? : x ; // timing violation
  endtable
endprimitive

primitive MUX_UDP (Q, A, B, S);
  output Q;
  input A, B, S;
 
  table
  // A B S : Q
     0 0 ? : 0 ;
     1 1 ? : 1 ;
     0 ? 0 : 0 ;
     1 ? 0 : 1 ;
     ? 0 1 : 0 ;
     ? 1 1 : 1 ;
  endtable
endprimitive

primitive JK_UDP (JK, J, K, Q);
  output JK;
  input J,K,Q;
 
  table
  // J K Q : JK
     0 1 ? : 0 ; // reset
     1 0 ? : 1 ; // set
     0 ? 0 : 0 ; // no change
     1 ? 0 : 1 ; // toggle
     ? 1 1 : 0 ; // toggle
     ? 0 1 : 1 ; // no change
  endtable
endprimitive

primitive SMIT01_UDP ( OUT1 ,  IN1 );
  output  OUT1 ;
  reg OUT1 ;
  input  IN1 ;
    table
    //  IN1

        0       :       ?       :       0       ;
        1       :       ?       :       1       ;

    endtable
endprimitive

primitive IPAD_UDP ( OUT1 ,  IN1 );
  output  OUT1 ;
  reg OUT1 ;
  input  IN1 ;
    table
    //  IN1

        0       :       ?       :       0       ;
        1       :       ?       :       1       ;

    endtable
endprimitive


primitive TFF_UDP (Q, C, S, R, notifier);
  output Q;
  input C,S,R;
  input notifier;
  reg Q;

  table
  //  C    S   R ntf : Qt: Qt+1
     (01)  1   ?  ?  : 0 : 1 ; // rising clk
     (01)  1   ?  ?  : x : 1 ; // rising clk
     (01)  ?   1  ?  : 1 : 0 ; // rising clk
     (01)  ?   1  ?  : x : 1 ; // rising clk
     (0?)  1   ?  ?  : 0 : 1 ; // rising clk
     (0?)  1   ?  ?  : x : 1 ; // rising clk
     (0?)  ?   1  ?  : 1 : 0 ; // rising clk
     (0?)  ?   1  ?  : x : 1 ; // rising clk
     (?1)  1   ?  ?  : 0 : 1 ; // rising clk
     (?1)  1   ?  ?  : x : 1 ; // rising clk
     (?1)  ?   1  ?  : 1 : 0 ; // rising clk
     (?1)  ?   1  ?  : x : 1 ; // rising clk
     (1?)  1   1  ?  : ? : - ; // falling clk
     (?0)  1   1  ?  : ? : - ; // falling clk
      ?  (?1)  1  ?  : ? : - ; // set inactive
      ?    1 (?1) ?  : ? : - ; // reset inactive
      ?    1   0  ?  : ? : 0 ; // reset
      ?    0   1  ?  : ? : 1 ; // set
      ?    0   0  ?  : ? : 1 ; // set && reset
      ?    x   ?  ?  : ? : x ; //
      ?    ?   x  ?  : ? : x ; //
      ?    ?   ?  *  : ? : x ; // timing violation
  endtable
endprimitive

primitive NOR_UDP (Y, A, B);
  output Y;
  input A, B ;

  table
  // A B  : Y
     0 0  : 1 ;
     0 1  : 0 ;
     1 0  : x ;
     1 1  : 0 ;
     1 x  : 0 ;
     x 1  : 0 ;
  endtable
endprimitive

/***************************************************************************/
/*************************      CELLS   ***********************************/


`celldefine

  module ADDR01 ( SOUT , COUT , COUTB ,  A , B , CIN );

  output  SOUT , COUT ,COUTB ;
  input  A , B , CIN ;
  xor ( SOUT ,  A , B , CIN );
  xnor ( select_logic_net_0_O1 ,  A , B );
  xor ( select_logic_net_1_O1 ,  A , B );
  bufif1 (COUT , A , select_logic_net_0_O1 );
  bufif1 (COUT , CIN , select_logic_net_1_O1 );
  not (COUTB , COUT );
  `ifdef functional
   `else
        specify
                if ((!B&!CIN) | (B&CIN)) (A +=> SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((B&!CIN) | (!B&CIN)) (A -=> SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (A => SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((B&!CIN) | (!B&CIN)) (A +=> COUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (A +=> COUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((B&!CIN) | (!B&CIN)) (A -=> COUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (A +=> COUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((!A&!CIN) | (A&CIN)) (B +=> SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((A&!CIN) | (!A&CIN)) (B -=> SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (B => SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((A&!CIN) | (!A&CIN)) (B +=> COUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (B +=> COUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((A&!CIN) | (!A&CIN)) (B -=> COUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (B +=> COUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((!A&!B) | (A&B)) (CIN +=> SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((A&!B) | (!A&B)) (CIN -=> SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (CIN => SOUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((A&!B) | (!A&B)) (CIN +=> COUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (CIN +=> COUT ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                if ((A&!B) | (!A&B)) (CIN -=> COUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                ifnone (CIN +=> COUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module AND201 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  and ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
   `else
	specify
		if ((IN2)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module AND301 ( OUT1 ,  IN1 , IN2 , IN3 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 ;
  and ( OUT1 ,  IN1 , IN2 , IN3 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module AND401 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 ;
  and ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module AND501 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 ;
  and ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module AND601 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 ;
  and ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5&IN6)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5&IN6)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5&IN6)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5&IN6)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN6)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5)) (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module AND701 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 ;
  and ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 );
  `ifdef functional
  `else

	specify
		if ((IN2&IN3&IN4&IN5&IN6&IN7)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5&IN6&IN7)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5&IN6&IN7)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5&IN6&IN7)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN6&IN7)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN7)) (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN6)) (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module AND801 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 ;
  and ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5&IN6&IN7&IN8)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5&IN6&IN7&IN8)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5&IN6&IN7&IN8)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5&IN6&IN7&IN8)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN6&IN7&IN8)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN7&IN8)) (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN6&IN8)) (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN6&IN7)) (IN8 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN8 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NND201 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  nand ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
  `else
	specify
		if ((IN2)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NND300 ( OUT1 ,  IN1 , IN2 , IN3 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 ;
  nand ( OUT1 ,  IN1 , IN2 , IN3 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NND301 ( OUT1 ,  IN1 , IN2 , IN3 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 ;
  nand ( OUT1 ,  IN1 , IN2 , IN3 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NND401 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 ;
  nand ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NND501 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 ;
  nand ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NND601 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 ;
  not ( scl_net_not_0 ,  IN1 );
  not ( scl_net_not_1 ,  IN2 );
  not ( scl_net_not_2 ,  IN3 );
  not ( scl_net_not_3 ,  IN4 );
  not ( scl_net_not_4 ,  IN5 );
  not ( scl_net_not_5 ,  IN6 );
  or ( OUT1 ,  scl_net_not_0 , scl_net_not_1 , scl_net_not_2 , scl_net_not_3 , scl_net_not_4 , scl_net_not_5 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5&IN6)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5&IN6)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5&IN6)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5&IN6)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN6)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5)) (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NND701 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 ;
  not ( scl_net_not_0 ,  IN1 );
  not ( scl_net_not_1 ,  IN2 );
  not ( scl_net_not_2 ,  IN3 );
  not ( scl_net_not_3 ,  IN4 );
  not ( scl_net_not_4 ,  IN5 );
  not ( scl_net_not_5 ,  IN6 );
  not ( scl_net_not_6 ,  IN7 );
  or ( OUT1,scl_net_not_0,scl_net_not_1,scl_net_not_2,scl_net_not_3,scl_net_not_4,scl_net_not_5,scl_net_not_6 );
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5&IN6&IN7)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5&IN6&IN7)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5&IN6&IN7)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5&IN6&IN7)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN6&IN7)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN7)) (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN6)) (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NND801 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 ;
  not ( scl_net_not_0 ,  IN1 );
  not ( scl_net_not_1 ,  IN2 );
  not ( scl_net_not_2 ,  IN3 );
  not ( scl_net_not_3 ,  IN4 );
  not ( scl_net_not_4 ,  IN5 );
  not ( scl_net_not_5 ,  IN6 );
  not ( scl_net_not_6 ,  IN7 );
  not ( scl_net_not_7 ,  IN8 );
 or (OUT1,scl_net_not_0,scl_net_not_1,scl_net_not_2,scl_net_not_3,scl_net_not_4,scl_net_not_5,scl_net_not_6,scl_net_not_7);
  `ifdef functional
  `else
	specify
		if ((IN2&IN3&IN4&IN5&IN6&IN7&IN8)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN3&IN4&IN5&IN6&IN7&IN8)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN4&IN5&IN6&IN7&IN8)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN5&IN6&IN7&IN8)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN6&IN7&IN8)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN7&IN8)) (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN6&IN8)) (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1&IN2&IN3&IN4&IN5&IN6&IN7)) (IN8 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN8 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NOR200 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  nor ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
  `else
	specify
		if ((!IN2)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NOR201 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  nor ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
  `else
	specify
		if ((!IN2)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NOR300 ( OUT1 ,  IN1 , IN2 , IN3 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 ;
  nor ( OUT1 ,  IN1 , IN2 , IN3 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NOR301 ( OUT1 ,  IN1 , IN2 , IN3 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 ;
  nor ( OUT1 ,  IN1 , IN2 , IN3 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NOR401 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 ;
  nor ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NOR501 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 ;
  nor ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module NOR601 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 ;
  not ( scl_net_not_0 ,  IN1 );
  not ( scl_net_not_1 ,  IN2 );
  not ( scl_net_not_2 ,  IN3 );
  not ( scl_net_not_3 ,  IN4 );
  not ( scl_net_not_4 ,  IN5 );
  not ( scl_net_not_5 ,  IN6 );
  and ( OUT1 ,  scl_net_not_0 , scl_net_not_1 , scl_net_not_2 , scl_net_not_3 , scl_net_not_4 , scl_net_not_5 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5&!IN6)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5&!IN6)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5&!IN6)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5&!IN6)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN6)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5)) (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NOR701 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 ;
  not ( scl_net_not_0 ,  IN1 );
  not ( scl_net_not_1 ,  IN2 );
  not ( scl_net_not_2 ,  IN3 );
  not ( scl_net_not_3 ,  IN4 );
  not ( scl_net_not_4 ,  IN5 );
  not ( scl_net_not_5 ,  IN6 );
  not ( scl_net_not_6 ,  IN7 );
  and ( OUT1,scl_net_not_0,scl_net_not_1,scl_net_not_2,scl_net_not_3,scl_net_not_4,scl_net_not_5,scl_net_not_6 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5&!IN6&!IN7)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5&!IN6&!IN7)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5&!IN6&!IN7)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5&!IN6&!IN7)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN6&!IN7)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN7)) (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN6)) (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module NOR801 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 ;
  not ( scl_net_not_0 ,  IN1 );
  not ( scl_net_not_1 ,  IN2 );
  not ( scl_net_not_2 ,  IN3 );
  not ( scl_net_not_3 ,  IN4 );
  not ( scl_net_not_4 ,  IN5 );
  not ( scl_net_not_5 ,  IN6 );
  not ( scl_net_not_6 ,  IN7 );
  not ( scl_net_not_7 ,  IN8 );
 and(OUT1,scl_net_not_0,scl_net_not_1,scl_net_not_2,scl_net_not_3,scl_net_not_4,scl_net_not_5,scl_net_not_6,scl_net_not_7);
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5&!IN6&!IN7&!IN8)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5&!IN6&!IN7&!IN8)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5&!IN6&!IN7&!IN8)) (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5&!IN6&!IN7&!IN8)) (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN6&!IN7&!IN8)) (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN7&!IN8)) (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN6&!IN8)) (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN6&!IN7)) (IN8 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN8 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR2101 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  or ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
  `else
	specify
		if ((!IN2)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR3101 ( OUT1 ,  IN1 , IN2 , IN3 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 ;
  or ( OUT1 ,  IN1 , IN2 , IN3 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR4101 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 ;
  or ( OUT1 ,  IN1 , IN2 , IN3 , IN4 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR5101 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 ;
  or ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR6101 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 ;
  or ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5&!IN6)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5&!IN6)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5&!IN6)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5&!IN6)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN6)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5)) (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR7101 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 ;
  or ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5&!IN6&!IN7)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5&!IN6&!IN7)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5&!IN6&!IN7)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5&!IN6&!IN7)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN6&!IN7)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN7)) (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN6)) (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OR8101 ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 );
 
  output  OUT1 ;
  input  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 ;
  or ( OUT1 ,  IN1 , IN2 , IN3 , IN4 , IN5 , IN6 , IN7 , IN8 );
  `ifdef functional
  `else
	specify
		if ((!IN2&!IN3&!IN4&!IN5&!IN6&!IN7&!IN8)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN3&!IN4&!IN5&!IN6&!IN7&!IN8)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN4&!IN5&!IN6&!IN7&!IN8)) (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN5&!IN6&!IN7&!IN8)) (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN4 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN6&!IN7&!IN8)) (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN5 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN7&!IN8)) (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN6 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN6&!IN8)) (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN7 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1&!IN2&!IN3&!IN4&!IN5&!IN6&!IN7)) (IN8 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN8 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DEC24H ( Q1 , Q2 , Q3 , Q4 ,  EN , A1 , A2 );
 
  output  Q1 , Q2 , Q3 , Q4 ;
  input  EN , A1 , A2 ;
  not ( scl_net_not_1 ,  A1 );
  not ( scl_net_not_2 ,  A2 );
  and ( Q1 ,  EN , scl_net_not_1 , scl_net_not_2 );
  and ( Q2 ,  EN , A1 , scl_net_not_2 );
  and ( Q3 ,  EN , scl_net_not_1 , A2 );
  and ( Q4 ,  EN , A1 , A2 );
  `ifdef functional
  `else
	specify
		if ((!A1&!A2)) (EN +=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN +=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A1&!A2)) (EN +=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN +=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A1&A2)) (EN +=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN +=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A1&A2)) (EN +=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN +=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A2)) (A1 -=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 -=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A2)) (A1 +=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 +=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A2)) (A1 -=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 -=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A2)) (A1 +=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 +=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A1)) (A2 -=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 -=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A1)) (A2 -=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 -=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A1)) (A2 +=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 +=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A1)) (A2 +=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 +=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DEC24L ( Q1 , Q2 , Q3 , Q4 ,  EN , A1 , A2 );
 
  output  Q1 , Q2 , Q3 , Q4 ;
  input  EN , A1 , A2 ;
  not ( scl_net_not_0 ,  EN );
  or ( Q1 ,  scl_net_not_0 , A1 , A2 );
  not ( scl_net_not_1 ,  A1 );
  or ( Q2 ,  scl_net_not_0 , scl_net_not_1 , A2 );
  not ( scl_net_not_2 ,  A2 );
  or ( Q3 ,  scl_net_not_0 , A1 , scl_net_not_2 );
  nand ( Q4 ,  EN , A1 , A2 );
  `ifdef functional
  `else
	specify
		if ((!A1&!A2)) (EN -=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN -=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A1&!A2)) (EN -=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN -=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A1&A2)) (EN -=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN -=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A1&A2)) (EN -=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN -=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A2)) (A1 +=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 +=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A2)) (A1 -=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 -=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A2)) (A1 +=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 +=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A2)) (A1 -=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 -=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A1)) (A2 +=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 +=> Q1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A1)) (A2 +=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 +=> Q2 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&!A1)) (A2 -=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 -=> Q3 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((EN&A1)) (A2 -=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A2 -=> Q4 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module MX201B ( OUTB ,  A0 , D0 , D1 );
 
  output  OUTB ;
  input  A0 , D0 , D1 ;
  notif0 (OUTB , D0 , A0 );
  notif1 (OUTB , D1 , A0 );
  `ifdef functional
  `else
	specify
		if ((D0&!D1)) (A0 +=> OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!D0&D1)) (A0 -=> OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A0 => OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A0)) (D0 -=> OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D0 -=> OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A0)) (D1 -=> OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D1 -=> OUTB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module MX2101 ( OUT1 ,  A0 , D0 , D1 );
 
  output  OUT1 ;
  input  A0 , D0 , D1 ;
  bufif0 (OUT1 , D0 , A0 );
  bufif1 (OUT1 , D1 , A0 );
  `ifdef functional
  `else
	specify
		if ((!D0&D1)) (A0 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((D0&!D1)) (A0 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A0 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A0)) (D0 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D0 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A0)) (D1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 
  endmodule

`endcelldefine

`celldefine

  module MX4122 ( OUT1 ,  D0 , D1 , D2 , D3 , A0 , A1 );
 
  output  OUT1 ;
  input  D0 , D1 , D2 , D3 , A0 , A1 ;
  nor ( select_logic_net_0_O0 ,  A0 , A1 );
  not ( scl_net_not_5 ,  A1 );
  and ( select_logic_net_1_O0 ,  A0 , scl_net_not_5 );
  and ( select_logic_net_2_O0 ,  A0 , A1 );
  not ( scl_net_not_4 ,  A0 );
  and ( select_logic_net_3_O0 ,  scl_net_not_4 , A1 );
  bufif1 (OUT1 , D0 , select_logic_net_0_O0 );
  bufif1 (OUT1 , D1 , select_logic_net_1_O0 );
  bufif1 (OUT1 , D3 , select_logic_net_2_O0 );
  bufif1 (OUT1 , D2 , select_logic_net_3_O0 );
  `ifdef functional
  `else
	specify
		if ((!A0&!A1)) (D0 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D0 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A0&!A1)) (D1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A0&A1)) (D2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A0&A1)) (D3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D3 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!D0&D1&!A1) | (!D2&D3&A1)) (A0 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((D0&!D1&!A1) | (D2&!D3&A1)) (A0 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A0 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!D0&D2&!A0) | (!D1&D3&A0)) (A1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((D0&!D2&!A0) | (D1&!D3&A0)) (A1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A1 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module INVR01 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  not ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module INVR02 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  not ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module INVR03 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  not ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module INVR04 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  not ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module INVR05 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  not ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module INVR06 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  not ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module CDRI01 ( Q , QB ,  IN1 );
 
  output  Q , QB ;
  input  IN1 ;
  not (QB , Q );
  buf ( Q ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> Q ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (IN1 -=> QB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module CDRI02 ( Q , QB ,  IN1 );
 
  output  Q , QB ;
  input  IN1 ;
  not (QB , Q );
  buf ( Q ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> Q ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (IN1 -=> QB ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DELAY1 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DELBUF ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PDDR02 ( P_EN , N_EN ,  D , EN );
 
  output  P_EN , N_EN ;
  input  D , EN ;
  not ( scl_net_not_0 ,  D );
  or ( P_EN ,  scl_net_not_0 , EN );
  nor ( N_EN ,  D , EN );
  `ifdef functional
  `else
	specify
		if ((!EN)) (D -=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D -=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!EN)) (D -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((D)) (EN +=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN +=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!D)) (EN -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PDDR04 ( P_EN , N_EN ,  D , EN );
 
  output  P_EN , N_EN ;
  input  D , EN ;
  not ( scl_net_not_0 ,  D );
  or ( P_EN ,  scl_net_not_0 , EN );
  nor ( N_EN ,  D , EN );
  `ifdef functional
  `else
	specify
		if ((!EN)) (D -=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D -=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!EN)) (D -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((D)) (EN +=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN +=> P_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!D)) (EN -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (EN -=> N_EN ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module TBUF01 ( OUT1 ,  IN1 , EN );
 
  output  OUT1 ;
  input  IN1 , EN ;
  bufif1 (OUT1 , IN1 , EN );
  `ifdef functional
  `else
	specify
		if( !EN ) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		(EN => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module TINV01 ( OUT1 ,  IN1 , EN );
 
  output  OUT1 ;
  input  IN1 , EN ;
  notif1 (OUT1 , IN1 , EN );
  `ifdef functional
  `else
	specify
		if( !EN ) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		(EN => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module ADNR01 ( OUT1 ,  A , B , C );
 
  output  OUT1 ;
  input  A , B , C ;
  not ( scl_net_not_0 ,  A );
  not ( scl_net_not_2 ,  C );
  and ( \scl_net_and_-02b ,  scl_net_not_0 , scl_net_not_2 );
  not ( scl_net_not_1 ,  B );
  and ( scl_net_and_1b2b ,  scl_net_not_1 , scl_net_not_2 );
  or ( OUT1 ,  \scl_net_and_-02b , scl_net_and_1b2b );
  `ifdef functional
  `else
	specify
		if ((B&!C)) (A -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A&!C)) (B -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (B -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A) | (!B)) (C -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (C -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module ADOR16 ( OUT1 ,  A , B , C , D , E , F );
 
  output  OUT1 ;
  input  A , B , C , D , E , F ;
  and ( scl_net_and_45 ,  E , F );
  and ( scl_net_and_23 ,  C , D );
  and ( scl_net_and_01 ,  A , B );
  or ( OUT1 ,  scl_net_and_45 , scl_net_and_23 , scl_net_and_01 );
  `ifdef functional
  `else
	specify
		if ((B&!C&!E) | (B&!C&!F) | (B&!D&!E) | (B&!D&!F)) (A +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A&!C&!E) | (A&!C&!F) | (A&!D&!E) | (A&!D&!F)) (B +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (B +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&D&!E) | (!A&D&!F) | (!B&D&!E) | (!B&D&!F)) (C +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (C +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&C&!E) | (!A&C&!F) | (!B&C&!E) | (!B&C&!F)) (D +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&!C&F) | (!A&!D&F) | (!B&!C&F) | (!B&!D&F)) (E +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (E +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&!C&E) | (!A&!D&E) | (!B&!C&E) | (!B&!D&E)) (F +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (F +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module AOI401 ( OUT1 ,  A , B , C , D );
 
  output  OUT1 ;
  input  A , B , C , D ;
  not ( scl_net_not_0 ,  A );
  not ( scl_net_not_2 ,  C );
  and ( \scl_net_and_-02b ,  scl_net_not_0 , scl_net_not_2 );
  not ( scl_net_not_3 ,  D );
  and ( \scl_net_and_-03b ,  scl_net_not_0 , scl_net_not_3 );
  not ( scl_net_not_1 ,  B );
  and ( scl_net_and_1b2b ,  scl_net_not_1 , scl_net_not_2 );
  and ( scl_net_and_1b3b ,  scl_net_not_1 , scl_net_not_3 );
  or ( OUT1 ,  \scl_net_and_-02b , \scl_net_and_-03b , scl_net_and_1b2b , scl_net_and_1b3b );
  `ifdef functional
  `else
	specify
		if ((B&!C) | (B&!D)) (A -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A&!C) | (A&!D)) (B -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (B -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&D) | (!B&D)) (C -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (C -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&C) | (!B&C)) (D -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (D -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module ORND01 ( OUT1 ,  A , B , C );
 
  output  OUT1 ;
  input  A , B , C ;
  not ( scl_net_not_0 ,  A );
  not ( scl_net_not_1 ,  B );
  and ( \scl_net_and_-01b ,  scl_net_not_0 , scl_net_not_1 );
  not ( scl_net_not_2 ,  C );
  or ( OUT1 ,  \scl_net_and_-01b , scl_net_not_2 );
  `ifdef functional
  `else
	specify
		if ((!B&C)) (A -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (A -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!A&C)) (B -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (B -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((A) | (B)) (C -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (C -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module SMIT01 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
  SMIT01_UDP SMIT01_UDP ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif

  endmodule

`endcelldefine

`celldefine

  module TRAN01 ( OUT1 ,  IN1 , E0 );
 
  output  OUT1 ;
  input  IN1 , E0 ;
  bufif1 (OUT1 , IN1 , E0 );
  `ifdef functional
  `else
	specify
		if( !E0 ) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		(E0 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module TRAN02 ( T1 ,  T0 , E0 );
 
  output  T1 ;
  input  T0 , E0 ;
  bufif1 (T1 , T0 , E0 );
  `ifdef functional
  `else
	specify
		if( !E0 ) (T0 +=> T1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (T0 +=> T1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		(E0 => T1 ) = (0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module XNR201 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  xnor ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
  `else
	specify
		if ((IN2)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN2)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module XOR201 ( OUT1 ,  IN1 , IN2 );
 
  output  OUT1 ;
  input  IN1 , IN2 ;
  xor ( OUT1 ,  IN1 , IN2 );
  `ifdef functional
  `else
	specify
		if ((!IN2)) (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN2)) (IN1 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN1 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((!IN1)) (IN2 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		if ((IN1)) (IN2 -=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		ifnone (IN2 => OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DFCL00 ( Q , QB ,  D , CLRB , C );
 
  output  Q , QB ;
  input  D , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFCL01 ( Q , QB ,  D , CLRB , C );
 
  output  Q , QB ;
  input  D , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFCL11 ( Q , QB ,  D , CLRB , C );
 
  output  Q , QB ;
  input  D , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFFL00 ( Q , QB ,  D , C );
 
  output  Q , QB ;
  input  D , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , negedge D , 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 
 
 endmodule
`endcelldefine

`celldefine

  module DFFL01 ( Q , QB ,  D , C );
 
  output  Q , QB ;
  input  D , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , negedge D , 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DFFL11 ( Q , QB ,  D , C );
 
  output  Q , QB ;
  input  D , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , negedge D , 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFPC00 ( Q , QB ,  D , CLRB , PRB , C );
 
  output  Q , QB ;
  input  D , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  or (CP, CLRB,PRB);
  nand (QB, Q_buf,CP);
  and(scl_cnd_tchks0 , PRB , CLRB);
  DFF_UDP (Q_buf, D, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFPC01 ( Q , QB ,  D , CLRB , PRB , C );
 
  output  Q , QB ;
  input  D , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , PRB , CLRB);
  DFF_UDP (Q_buf, D, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module DFPC11 ( Q , QB ,  D , CLRB , PRB , C );
 
  output  Q , QB ;
  input  D , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , PRB , CLRB);
  DFF_UDP (Q_buf, D, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFPR00 ( Q , QB ,  D , PRB , C );
 
  output  Q , QB ;
  input  D , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, PRB, 1,scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module DFPR01 ( Q , QB ,  D , PRB , C );
 
  output  Q , QB ;
  input  D , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, PRB, 1,scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module DFPR11 ( Q , QB ,  D , PRB , C );
 
  output  Q , QB ;
  input  D , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  DFF_UDP (Q_buf, D, C, PRB, 1,scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module JKCL01 ( Q , QB ,  J , K , CLRB , C );

  output  Q , QB ;
  input  J , K , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $setup (posedge J , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge J , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& CLRB , posedge J , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& CLRB , negedge J , 0.000:0.000:0.000, scl_pointer);
                $setup (posedge K , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge K , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& CLRB , posedge K , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& CLRB , negedge K , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module JKCL11 ( Q , QB ,  J , K , CLRB , C );
 
  output  Q , QB ;
  input  J , K , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge J , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge J , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , posedge J , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , negedge J , 0.000:0.000:0.000, scl_pointer);
		$setup (posedge K , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge K , posedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , posedge K , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& CLRB , negedge K , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine
 
`celldefine

  module JKFL01 ( Q , QB ,  J , K , C );

  output  Q , QB ;
  input  J , K , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $setup (posedge J , posedge C , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge J , posedge C , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , posedge J , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , negedge J , 0.000:0.000:0.000, scl_pointer);
                $setup (posedge K , posedge C , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge K , posedge C , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , posedge K , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , negedge K , 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine

`celldefine

  module JKFL11 ( Q , QB ,  J , K , C );
 
  output  Q , QB ;
  input  J , K , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge J , posedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge J , posedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , posedge J , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , negedge J , 0.000:0.000:0.000, scl_pointer);
		$setup (posedge K , posedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge K , posedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , posedge K , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C , negedge K , 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

 endmodule
`endcelldefine

`celldefine

  module JKPC01 ( Q , QB ,  J , K , CLRB , PRB , C );

  output  Q , QB ;
  input  J , K , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $setup (posedge J , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge J , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& scl_cnd_tchks0 , posedge J , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& scl_cnd_tchks0 , negedge J , 0.000:0.000:0.000, scl_pointer);
                $setup (posedge K , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge K , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& scl_cnd_tchks0 , posedge K , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& scl_cnd_tchks0 , negedge K , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine


`celldefine

  module JKPC11 ( Q , QB ,  J , K , CLRB , PRB , C );
 
  output  Q , QB ;
  input  J , K , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge J , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge J , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , posedge J , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , negedge J , 0.000:0.000:0.000, scl_pointer);
		$setup (posedge K , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge K , posedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , posedge K , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& scl_cnd_tchks0 , negedge K , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 
 
 endmodule
`endcelldefine

`celldefine

  module JKPR01 ( Q , QB ,  J , K , PRB , C );

  output  Q , QB ;
  input  J , K , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $setup (posedge J , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge J , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& PRB , posedge J , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& PRB , negedge J , 0.000:0.000:0.000, scl_pointer);
                $setup (posedge K , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
                $setup (negedge K , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& PRB , posedge K , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C &&& PRB , negedge K , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine


`celldefine

  module JKPR11 ( Q , QB ,  J , K , PRB , C );
 
  output  Q , QB ;
  input  J , K , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  JK_UDP  (JK, J, K, Q_buf);
  DFF_UDP (Q_buf, JK, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge J , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge J , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , posedge J , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , negedge J , 0.000:0.000:0.000, scl_pointer);
		$setup (posedge K , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge K , posedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , posedge K , 0.000:0.000:0.000, scl_pointer);
		$hold (posedge C &&& PRB , negedge K , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif

  endmodule
`endcelldefine


`celldefine

  module TFCL00 ( Q , QB , CLRB , C );

  output  Q , QB ;
  input   CLRB , C ;
  reg scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C, posedge CLRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine


`celldefine

  module TFCL01 ( Q , QB , CLRB , C );

  output  Q , QB ;
  input   CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C, posedge CLRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine


`celldefine

  module TFCL11 ( Q , QB , CLRB , C );

  output  Q , QB ;
  input   CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C, posedge CLRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine


`celldefine

  module TFFL00 ( Q , QB , C );

  output  Q , QB ;
  input   C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine


`celldefine

  module TFFL01 ( Q , QB , C );

  output  Q , QB ;
  input   C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine


`celldefine

  module TFFL11 ( Q , QB , C );

  output  Q , QB ;
  input   C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine

`celldefine

  module TFPC00 ( Q , QB , CLRB , PRB , C );

  output  Q , QB ;
  input   CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  or (CP, CLRB,PRB);
  nand (QB, Q_buf,CP);
  and(scl_cnd_tchks0 , PRB , CLRB);
  TFF_UDP (Q_buf, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C , posedge CLRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , posedge PRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine


`celldefine

  module TFPC01 ( Q , QB , CLRB , PRB , C );

  output  Q , QB ;
  input   CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  TFF_UDP (Q_buf, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C , posedge CLRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , posedge PRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine


`celldefine

  module TFPC11 ( Q , QB , CLRB , PRB , C );

  output  Q , QB ;
  input   CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  TFF_UDP (Q_buf, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
        specify
                if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
                if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
                if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C , posedge CLRB , 0.000:0.000:0.000, scl_pointer);
                $hold (posedge C , posedge PRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

 endmodule
`endcelldefine


`celldefine

  module TFPR00 ( Q , QB , PRB , C );

  output  Q , QB ;
  input   PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C , posedge PRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module TFPR01 ( Q , QB , PRB , C );

  output  Q , QB ;
  input   PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C , posedge PRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module TFPR11 ( Q , QB , PRB , C );

  output  Q , QB ;
  input   PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  TFF_UDP (Q_buf, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
        specify
                 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
                 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
                if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
                $hold (posedge C , posedge PRB , 0.000:0.000:0.000, scl_pointer);
                $recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
                $width ( negedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
                $width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module LTCH00 ( Q , QB ,  D , C );
 
  output  Q , QB ;
  input  D , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		if( C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C , negedge D , 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTCH01 ( Q , QB ,  D , C );
 
  output  Q , QB ;
  input  D , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		if( C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C , negedge D , 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTCH11 ( Q , QB ,  D , C );
 
  output  Q , QB ;
  input  D , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, 1, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		if( C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C , negedge D , 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTCL00 ( Q , QB ,  D , CLRB , C );
 
  output  Q , QB ;
  input  D , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( CLRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& CLRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& CLRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTCL01 ( Q , QB ,  D , CLRB , C );
 
  output  Q , QB ;
  input  D , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( CLRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& CLRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& CLRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTCL11 ( Q , QB ,  D , CLRB , C );
 
  output  Q , QB ;
  input  D , CLRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, 1, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( CLRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		 (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& CLRB , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& CLRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& CLRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTPC00 ( Q , QB ,  D , CLRB , PRB , C );
 
  output  Q , QB ;
  input  D , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  LATCH_UDP (Q_buf, D, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( CLRB && PRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& scl_cnd_tchks0 , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& scl_cnd_tchks0 , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTPC01 ( Q , QB ,  D , CLRB , PRB , C );
 
  output  Q , QB ;
  input  D , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  LATCH_UDP (Q_buf, D, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( CLRB && PRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& scl_cnd_tchks0 , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& scl_cnd_tchks0 , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTPC11 ( Q , QB ,  D , CLRB , PRB , C );
 
  output  Q , QB ;
  input  D , CLRB , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  and(scl_cnd_tchks0 , CLRB , PRB);
  LATCH_UDP (Q_buf, D, C, PRB, CLRB, scl_pointer);
  `ifdef functional
  `else
	specify
		if( CLRB && PRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (negedge CLRB => (Q +: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only fall.
		if( PRB ) (negedge CLRB => (QB -: CLRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only rise.
		if( CLRB ) (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		if( CLRB ) (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( CLRB && PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( CLRB && PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& scl_cnd_tchks0 , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& scl_cnd_tchks0 , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& scl_cnd_tchks0 , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge CLRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge CLRB , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTPR00 ( Q , QB ,  D , PRB , C );
 
  output  Q , QB ;
  input  D , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& PRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& PRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTPR01 ( Q , QB ,  D , PRB , C );
 
  output  Q , QB ;
  input  D , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& PRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& PRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module LTPR11 ( Q , QB ,  D , PRB , C );
 
  output  Q , QB ;
  input  D , PRB , C ;
  reg  scl_pointer ;
  buf (Q, Q_buf);
  not (QB, Q_buf);
  LATCH_UDP (Q_buf, D, C, PRB, 1, scl_pointer);
  `ifdef functional
  `else
	specify
		if( PRB && C ) ( D => (Q +: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB && C ) ( D => (QB -: D ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		 (negedge PRB => (Q -: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // Q can only rise.
		 (negedge PRB => (QB +: PRB ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ; // QB can only fall.
		if( PRB ) (posedge C => (Q : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		if( PRB ) (posedge C => (QB : C ) ) = (0.000:0.000:0.000,0.000:0.000:0.000) ;
		$setup (posedge D , negedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$setup (negedge D , negedge C &&& PRB , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& PRB , posedge D , 0.000:0.000:0.000, scl_pointer);
		$hold (negedge C &&& PRB , negedge D , 0.000:0.000:0.000, scl_pointer);
		$recovery (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$removal (posedge PRB, posedge C, 0.000:0.000:0.000, scl_pointer);
		$width ( posedge C , 0.0:0.0:0.0 , 0 , scl_pointer);
		$width ( negedge PRB , 0.0:0.0:0.0 , 0 , scl_pointer);
	endspecify
  `endif 

 endmodule
`endcelldefine

/***************************************************************************/
/*************************      CORE-LIMITED PADS   ***********************************/



`celldefine

  module BPD120 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
   `else
	specify
		 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine


`celldefine

  module BPD121 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module BPD12D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD12U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine



`celldefine

  module BPD141 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module BPD14D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default: f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD14U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
   `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD220 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine
 

`celldefine

  module BPD221 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000); 
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module BPD22D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD22U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD240 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine


`celldefine

  module BPD241 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module BPD24D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD24U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD320 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module BPD340 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD00 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD10 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD1D ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b0;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD1U ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b1;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD20 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD2D ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b0;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD2U ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b1;
   default : a = 1'bx;
   endcase
  `ifdef functional
   `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module IPAD30 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   IPAD_UDP IPAD_UDP ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module IPAD3D ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b0;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module IPAD3U ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b1;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule
`endcelldefine

`celldefine

  module OPAD02 ( PAD ,  IN1 );
 
  output  PAD ;
  input  IN1 ;
  not ( PAD ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OPAD04 ( PAD ,  IN1 );
 
  output  PAD ;
  input  IN1 ;
  not ( PAD ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module OPAD12 ( PAD ,  IN1 );

  output  PAD ;
  input  IN1 ;
  supply0 GROUND ;
  nmos(PAD,GROUND,IN1);
  `ifdef functional
   `else
        specify
                 (IN1 +=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module OPAD14 ( PAD ,  IN1 );

  output  PAD ;
  input  IN1 ;
  supply0 GROUND ;
  nmos(PAD,GROUND,IN1);
  `ifdef functional
   `else
        specify
                 (IN1 +=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module TPAD02 ( PAD ,  P_EN , N_EN );
 
  output  PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (a , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  assign PAD = (c == 1) ? 1'bz : a ;

  `ifdef functional
  `else
	specify
		 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module TPAD04 ( PAD ,  P_EN , N_EN );
 
  output  PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (a , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  assign PAD = (c == 1) ? 1'bz : a ;
  `ifdef functional
  `else
	specify
		 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

/***************************************************************************/
/*************************     PAD-LIMITED PADS   ***********************************/



`celldefine

  module PAD_BPD120 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
   `else
	specify
		 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine


`celldefine

  module PAD_BPD121 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module PAD_BPD12D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD12U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine




`celldefine

  module PAD_BPD141 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module PAD_BPD14D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default: f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD14U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
   `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD220 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine
 

`celldefine

  module PAD_BPD221 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000); 
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module PAD_BPD22D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD22U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD240 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine


`celldefine

  module PAD_BPD241 ( TO_CORE , PAD , EN );

  output  TO_CORE ;
  inout PAD ;
  input  EN ;
  supply0 GROUND ;
  nmos(PAD , GROUND , EN);
   bufif0 (TO_CORE , PAD , EN );
   bufif1 (TO_CORE , 1'b0 , EN );
   bufif1 (PAD , 1'b0 , EN );
  `ifdef functional
   `else
        specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule

`endcelldefine


`celldefine

  module PAD_BPD24D ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b0;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD24U ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  reg f ;
  inout PAD ;
  input  P_EN , N_EN ;
  wire e ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  assign e = (c==1 ) ? PAD : a;
  assign TO_CORE = f;
  always @ (e)
   case(e)
   1'b0 : f = 1'b0;
   1'b1 : f = 1'b1;
   1'bz : f = 1'b1;
   default : f = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD320 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_BPD340 ( TO_CORE , PAD ,  P_EN , N_EN );
 
  output  TO_CORE ;
  inout PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (b , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  bufif0(a , b , c);
  assign PAD = a;
  MUX_UDP MUX_UDP (TO_CORE , a , PAD ,c );
  `ifdef functional
  `else
	specify
                 (PAD -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
                 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (P_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> TO_CORE ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD00 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD10 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD1D ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b0;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD1U ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b1;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD20 ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  input  IN1 ;
   buf ( OUT1 ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD2D ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg  a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b0;
   default : a = 1'bx;
   endcase
  `ifdef functional
  `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_IPAD2U ( OUT1 ,  IN1 );
 
  output  OUT1 ;
  reg a ;
  input  IN1 ;
  assign OUT1 = a;
  always @ (IN1)
   case(IN1)
   1'b0 : a = 1'b0;
   1'b1 : a = 1'b1;
   1'bz : a = 1'b1;
   default : a = 1'bx;
   endcase
  `ifdef functional
   `else
	specify
		 (IN1 +=> OUT1 ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine





`celldefine

  module PAD_OPAD02 ( PAD ,  IN1 );
 
  output  PAD ;
  input  IN1 ;
  not ( PAD ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_OPAD04 ( PAD ,  IN1 );
 
  output  PAD ;
  input  IN1 ;
  not ( PAD ,  IN1 );
  `ifdef functional
  `else
	specify
		 (IN1 -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_OPAD12 ( PAD ,  IN1 );

  output  PAD ;
  input  IN1 ;
  supply0 GROUND ;
  nmos(PAD,GROUND,IN1);
  `ifdef functional
   `else
        specify
                 (IN1 +=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module PAD_OPAD14 ( PAD ,  IN1 );

  output  PAD ;
  input  IN1 ;
  supply0 GROUND ;
  nmos(PAD,GROUND,IN1);
  `ifdef functional
   `else
        specify
                 (IN1 +=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
        endspecify
  `endif

  endmodule
`endcelldefine

`celldefine

  module PAD_TPAD02 ( PAD ,  P_EN , N_EN );
 
  output  PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (a , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  assign PAD = (c == 1) ? 1'bz : a ;

  `ifdef functional
  `else
	specify
		 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine

`celldefine

  module PAD_TPAD04 ( PAD ,  P_EN , N_EN );
 
  output  PAD ;
  input  P_EN , N_EN ;
  NOR_UDP NOR_UDP (a , N_EN , P_EN);
  not (d ,N_EN);
  and(c, d, P_EN);
  assign PAD = (c == 1) ? 1'bz : a ;
  `ifdef functional
  `else
	specify
		 (P_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
		 (N_EN -=> PAD ) = (0.000:0.000:0.000,0.000:0.000:0.000);
	endspecify
  `endif 

  endmodule

`endcelldefine


