`timescale 1ns / 1ps
`default_nettype none

module top
    (   input wire i_top_clk,
        input wire i_top_rst,
        input wire w_clk25m,

        input wire  i_top_cam_start, 
        output wire o_top_cam_done, 
        
        input wire       i_top_pclk, 
        input wire [7:0] i_top_pix_byte,
        input wire       i_top_pix_vsync,
        input wire       i_top_pix_href,
        output wire      o_top_reset,
        output wire      o_top_pwdn,
        output wire      o_top_xclk,
	output wire      o_top_sda_out,
	output wire      o_top_sda_oe,
	input wire      i_top_sda_in,
        output wire      o_top_sioc,
        
        output wire [3:0] o_top_vga_red,
        output wire [3:0] o_top_vga_green,
        output wire [3:0] o_top_vga_blue,
        output wire       o_top_vga_vsync,
        output wire       o_top_vga_hsync,

        // External BRAM die interface — directly drives off-chip SRAM macro
        output wire                      o_bram_clka,
        output wire                      o_bram_ena,
        output wire                      o_bram_wea,
        output wire [18:0]               o_bram_addra,
        output wire [11:0]               o_bram_dina,
        output wire                      o_bram_clkb,
        output wire                      o_bram_enb,
        output wire                      o_bram_web,
        output wire [18:0]               o_bram_addrb,
        input  wire [11:0]               i_bram_doutb
    );
    
    wire [11:0] i_bram_pix_data, o_bram_pix_data;
    wire [18:0] i_bram_pix_addr, o_bram_pix_addr; 
    wire        w_pix_wr;
           
    reg r1_rstn_top_clk, r2_rstn_top_clk;
    reg r1_rstn_pclk,    r2_rstn_pclk;
    reg r1_rstn_clk25m,  r2_rstn_clk25m; 

    // FIX 1: removed duplicate 'wire w_clk25m' that was here
    // FIX 2: drive o_top_xclk from 25MHz input
    assign o_top_xclk = w_clk25m;
    
    wire w_rst_btn_db; 
    
    localparam DELAY_TOP_TB = 240_000;
    debouncer 
    #(  .DELAY(DELAY_TOP_TB)    )
    top_btn_db
    (
        .i_clk(i_top_clk        ),
        .i_rst(1'b0             ),   // FIX 3: connect i_rst (active-high, tie low)
        .i_btn_in(~i_top_rst    ),
        .o_btn_db(w_rst_btn_db  )
    ); 
    
    always @(posedge i_top_clk or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_top_clk, r1_rstn_top_clk} <= 0; 
            else              {r2_rstn_top_clk, r1_rstn_top_clk} <= {r1_rstn_top_clk, 1'b1}; 
        end 
    always @(posedge w_clk25m or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_clk25m, r1_rstn_clk25m} <= 0; 
            else              {r2_rstn_clk25m, r1_rstn_clk25m} <= {r1_rstn_clk25m, 1'b1}; 
        end
    always @(posedge i_top_pclk or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_pclk, r1_rstn_pclk} <= 0; 
            else              {r2_rstn_pclk, r1_rstn_pclk} <= {r1_rstn_pclk, 1'b1}; 
        end 
    
    cam_top 
    #(  .CAM_CONFIG_CLK(100_000_000)    )
    OV7670_cam
    (
        .i_clk(i_top_clk                ),
        .i_rstn_clk(r2_rstn_top_clk     ),
        .i_rstn_pclk(r2_rstn_pclk       ),
        
        .i_cam_start(i_top_cam_start    ),
        .o_cam_done(o_top_cam_done      ), 
        
        .i_pclk(i_top_pclk              ),
        .i_pix_byte(i_top_pix_byte      ), 
        .i_vsync(i_top_pix_vsync        ), 
        .i_href(i_top_pix_href          ),
        .o_reset(o_top_reset            ),
        .o_pwdn(o_top_pwdn              ),
	.i_sda_in(i_top_sda_in		),
	.o_sda_out(o_top_sda_out	),
	.o_sda_oe(o_top_sda_oe		),
        .o_sioc(o_top_sioc              ), 
        
        // FIX 4: connect o_pix_wr to wire instead of leaving open
        .o_pix_wr(w_pix_wr              ),
        .o_pix_data(i_bram_pix_data     ),
        .o_pix_addr(i_bram_pix_addr     )
    );
    
    mem_bram
    #(  .WIDTH(12                       ), 
        .DEPTH(640*480)                 )
     pixel_memory
     (
        .i_wclk(i_top_pclk              ),
        .i_wr(w_pix_wr                  ),   // FIX 4: was hardwired 1'b1
        .i_wr_addr(i_bram_pix_addr      ),
        .i_bram_data(i_bram_pix_data    ),
        .i_bram_en(1'b1                 ),
         
        .i_rclk(w_clk25m                ),
        .i_rd(1'b1                      ),
        .i_rd_addr(o_bram_pix_addr      ), 
        .o_bram_data(o_bram_pix_data    ),

        // External BRAM die ports — wired to top-level I/O
        .o_bram_clka(o_bram_clka        ),
        .o_bram_ena(o_bram_ena          ),
        .o_bram_wea(o_bram_wea          ),
        .o_bram_addra(o_bram_addra      ),
        .o_bram_dina(o_bram_dina        ),
        .o_bram_clkb(o_bram_clkb        ),
        .o_bram_enb(o_bram_enb          ),
        .o_bram_web(o_bram_web          ),
        .o_bram_addrb(o_bram_addrb      ),
        .i_bram_doutb(i_bram_doutb      )
     );
     
    // FIX 5: X and Y must match vga_top port widths (10-bit for 640x480)
    wire [9:0] w_VGA_x; 
    wire [9:0] w_VGA_y;
    
    vga_top
    display_interface
    (
        .i_clk25m(w_clk25m              ),
        .i_rstn_clk25m(r2_rstn_clk25m   ), 
        
        .o_VGA_x(w_VGA_x               ),   // FIX 5: was 1-bit wire X
        .o_VGA_y(w_VGA_y               ),   // FIX 5: was 1-bit wire Y
        .o_VGA_vsync(o_top_vga_vsync    ),
        .o_VGA_hsync(o_top_vga_hsync    ), 
        .o_VGA_video(                   ),
        
        .o_VGA_red(o_top_vga_red        ),
        .o_VGA_green(o_top_vga_green    ),
        .o_VGA_blue(o_top_vga_blue      ), 
        
        .i_pix_data(o_bram_pix_data     ), 
        .o_pix_addr(o_bram_pix_addr     )
    );
    
endmodule
`default_nettype wire