module mem_bram
#(parameter WIDTH = 11,
    parameter DEPTH = 640*480)
    (   // Internal control signals
        input wire                      i_wclk,
        input wire                      i_wr,
        input wire [$clog2(DEPTH)-1:0]  i_wr_addr,

        input wire                      i_rclk,
        input wire                      i_rd,
        input wire [$clog2(DEPTH)-1:0]  i_rd_addr,

        input wire                      i_bram_en,
        input wire [WIDTH-1:0]          i_bram_data,
        output reg [WIDTH-1:0]          o_bram_data,

        // External BRAM die — Port A (Write)
        output wire                      o_bram_clka,
        output wire                      o_bram_ena,
        output wire                      o_bram_wea,
        output wire [$clog2(DEPTH)-1:0]  o_bram_addra,
        output wire [WIDTH-1:0]          o_bram_dina,

        // External BRAM die — Port B (Read)
        output wire                      o_bram_clkb,
        output wire                      o_bram_enb,
        output wire                      o_bram_web,
        output wire [$clog2(DEPTH)-1:0]  o_bram_addrb,
        input  wire [WIDTH-1:0]          i_bram_doutb
    );

    // Port A — Write path
    assign o_bram_clka  = i_wclk;
    assign o_bram_ena   = i_bram_en;
    assign o_bram_wea   = i_wr;
    assign o_bram_addra = i_wr_addr;
    assign o_bram_dina  = i_bram_data;

    // Port B — Read path
    assign o_bram_clkb  = i_rclk;
    assign o_bram_enb   = i_rd;
    assign o_bram_web   = 1'b0;         // Port B is read-only
    assign o_bram_addrb = i_rd_addr;

    // Register the external read data to match original synchronous read behaviour
    always @(posedge i_rclk)
        if (i_rd)
            o_bram_data <= i_bram_doutb;

endmodule
`default_nettype wire