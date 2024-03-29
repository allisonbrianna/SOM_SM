/*
--=================================================================
--Revision List
--Version	Author		    	Date	     Changes
--
--          Son Tran            24/01/03
--
--System :  
-------------------------------------------------------------------
--Description: This is the top level module for the SOM 460554_B
--             FPGA firmware.
--
--==================================================================
*/

module som_top(
    input  [8:0]EMIF1_A,
    inout  [15:0]EMIF1_D,
    input  EMIF1_RAS_A,
    input  EMIF1_CAS_A,
    input  EMIF1_CLK_A,
    input  EMIF1_WEN_A,
    input  EPWM3A_A,
    input  EPWM3B_A,
    input  EPWM4A_A,
    input  EPWM4B_A,
    input  EPWM5A_A,
    input  EPWM5B_A,
    input  EPWM6A_A,
    input  EPWM6B_A,
    input  [51:0]PL64,
    input  DSP_CLK,
    input  [6:0]PL65_1,
    input  [43:0]PL65_2,
    input  [11:0]PL66,
    input  [3:0]PL66_0,
    input  [3:0]PL66_1,
    input  [2:0]PL66_2,
    output [3:0]PL66_LED,
    output UART0_TX,
    input  UART0_RX,
    output UART1_TX,  // HSS1
    input  UART1_RX,
    output UART2_TX,  // HSS2
    input  UART2_RX,
    output UART3_TX,
    input  UART3_RX,
    output UART4_TX,
    input  UART4_RX,
    output UART5_TX,
    input  UART5_RX,
    input  VN,
    input  VP);

wire reset;
wire int0=1'b0;
wire clock;
wire [31:0]m_axi_araddr;
wire [1:0]m_axi_arburst;
wire [3:0]m_axi_arcache;
wire [7:0]m_axi_arlen;
wire [0:0]m_axi_arlock;
wire [2:0]m_axi_arprot;
wire [3:0]m_axi_arqos;
wire m_axi_arready;
wire [2:0]m_axi_arsize;
wire [15:0]m_axi_aruser;
wire m_axi_arvalid;
wire [31:0]m_axi_awaddr;
wire [1:0]m_axi_awburst;
wire [3:0]m_axi_awcache;
wire [7:0]m_axi_awlen;
wire [0:0]m_axi_awlock;
wire [2:0]m_axi_awprot;
wire [3:0]m_axi_awqos;
wire m_axi_awready;
wire [2:0]m_axi_awsize;
wire m_axi_awvalid;
wire m_axi_bready;
wire [1:0]m_axi_bresp;
wire m_axi_bvalid;
wire [31:0]m_axi_rdata;
wire m_axi_rlast;
wire m_axi_rready;
wire [1:0]m_axi_rresp;
wire m_axi_rvalid;
wire [31:0]m_axi_wdata;
wire m_axi_wlast;
wire m_axi_wready;
wire [3:0]m_axi_wstrb;
wire m_axi_wvalid;
wire m_axi_awuser;

wire [31:0]bram0_portb_din;
wire [31:0]bram0_portb_dout;
wire [31:0]bram0_portb_addr;
wire bram0_portb_en = 1'b1;
wire bram0_portb_rst = 1'b0;
wire bram0_portb_we;

wire [48:0]s_axi_araddr;
wire [1:0]s_axi_arburst;
wire [3:0]s_axi_arcache;
wire [5:0]s_axi_arid;
wire [7:0]s_axi_arlen;
wire s_axi_arlock;
wire [2:0]s_axi_arprot;
wire [3:0]s_axi_arqos;
wire s_axi_arready;
wire [2:0]s_axi_arsize;
wire s_axi_aruser;
wire s_axi_arvalid;
wire [48:0]s_axi_awaddr;
wire [1:0]s_axi_awburst;
wire [3:0]s_axi_awcache;
wire [5:0]s_axi_awid;
wire [7:0]s_axi_awlen;
wire s_axi_awlock;
wire [2:0]s_axi_awprot;
wire [3:0]s_axi_awqos;
wire s_axi_awready;
wire [2:0]s_axi_awsize;
wire s_axi_awuser;
wire s_axi_awvalid;
wire [5:0]s_axi_bid;
wire s_axi_bready;
wire [1:0]s_axi_bresp;
wire s_axi_bvalid;
wire [31:0]s_axi_rdata;
wire [5:0]s_axi_rid;
wire s_axi_rlast;
wire s_axi_rready;
wire [1:0]s_axi_rresp;
wire s_axi_rvalid;
wire [31:0]s_axi_wdata;
wire s_axi_wlast;
wire s_axi_wready;
wire [3:0]s_axi_wstrb;
wire s_axi_wvalid;
wire axi_clk;
wire [31:0]gpio_rtl_o; // output
wire [31:0]gpio_rtl_i; // input
wire [1:0]pl_led;
wire [1:0]ps_led;
wire pspl_irq;

zub1cg_wrapper zub1cg_bd
   (.BRAM0_PORTB_addr       (bram0_portb_addr),
    .BRAM0_PORTB_clk        (EMIF1_CLK_A),
    .BRAM0_PORTB_din        (bram0_portb_din),
    .BRAM0_PORTB_dout       (bram0_portb_dout),
    .BRAM0_PORTB_en         (bram0_portb_en),
    .BRAM0_PORTB_rst        (bram0_portb_rst),
    .BRAM0_PORTB_we         (bram0_portb_we),
    .M01_AXI_araddr         (m_axi_araddr),
    .M01_AXI_arburst        (m_axi_arburst),
    .M01_AXI_arcache        (m_axi_arcache),
    .M01_AXI_arlen          (m_axi_arlen),
    .M01_AXI_arlock         (m_axi_arlock),
    .M01_AXI_arprot         (m_axi_arprot),
    .M01_AXI_arqos          (m_axi_arqos),
    .M01_AXI_arready        (m_axi_arready),
    .M01_AXI_arsize         (m_axi_arsize),
    .M01_AXI_aruser         (m_axi_aruser),
    .M01_AXI_arvalid        (m_axi_arvalid),
    .M01_AXI_awaddr         (m_axi_awaddr),
    .M01_AXI_awburst        (m_axi_awburst),
    .M01_AXI_awcache        (m_axi_awcache),
    .M01_AXI_awlen          (m_axi_awlen),
    .M01_AXI_awlock         (m_axi_awlock),
    .M01_AXI_awprot         (m_axi_awprot),
    .M01_AXI_awqos          (m_axi_awqos),
    .M01_AXI_awready        (m_axi_awready),
    .M01_AXI_awsize         (m_axi_awsize),
    .M01_AXI_awuser         (m_axi_awuser),
    .M01_AXI_awvalid        (m_axi_awvalid),
    .M01_AXI_bready         (m_axi_bready),
    .M01_AXI_bresp          (m_axi_bresp),
    .M01_AXI_bvalid         (m_axi_bvalid),
    .M01_AXI_rdata          (m_axi_rdata),
    .M01_AXI_rlast          (m_axi_rlast),
    .M01_AXI_rready         (m_axi_rready),
    .M01_AXI_rresp          (m_axi_rresp),
    .M01_AXI_rvalid         (m_axi_rvalid),
    .M01_AXI_wdata          (m_axi_wdata),
    .M01_AXI_wlast          (m_axi_wlast),
    .M01_AXI_wready         (m_axi_wready),
    .M01_AXI_wstrb          (m_axi_wstrb),
    .M01_AXI_wvalid         (m_axi_wvalid),
    .PL_INT0                (int0),
    .PSPL_IRQ               (pspl_irq),
    .Vp_Vn_v_n              (VN),
    .Vp_Vn_v_p              (VP),
    .axi_clk                (clock),
    .UART_0_rxd             (UART0_RX),
    .UART_0_txd             (UART0_TX),
    .UART_1_rxd             (UART1_RX),
    .UART_1_txd             (UART1_TX),
    .UART_2_rxd             (UART2_RX),
    .UART_2_txd             (UART2_TX),
    .UART_3_rxd             (UART3_RX),
    .UART_3_txd             (UART3_TX),
    .UART_4_rxd             (UART4_RX),
    .UART_4_txd             (UART4_TX),
    .UART_5_rxd             (UART5_RX),
    .UART_5_txd             (UART5_TX),    
    .gpio_rtl_0_tri_o       (gpio_rtl_o),
    .gpio_rtl_1_tri_i       (gpio_rtl_i),
    .reset                  (reset));

assign bram0_portb_addr = {23'd0, EMIF1_A};
assign bram0_portb_we = ~EMIF1_WEN_A;

// bi-direction bus
assign EMIF1_D = (EMIF1_WEN_A) ? bram0_portb_dout : 'bz;
assign bram0_portb_din = EMIF1_D;

blk_led led0(
    .CLOCK(clock),
    .RESETN(~reset),
    .RGB_LED(pl_led));

assign ps_led = gpio_rtl_o[1:0];
assign PL66_LED[2:0] = {ps_led, gpio_rtl_o[1]};
assign PL66_LED[3] = clock;

endmodule