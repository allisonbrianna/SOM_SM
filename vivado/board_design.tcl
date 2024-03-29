##################################################################
#   BOARD DESIGN
##################################################################

    set parentObj [get_bd_cells ../]
    set script_folder [_tcl::get_script_folder]
    
    # Save current instance; Restore later
    set oldCurInst [current_bd_instance .]
    # Set parent object as current
    current_bd_instance $parentObj

    set bCheckIPsPassed 1
    # #################################################################
    #   CHECK IPs
    # #################################################################
    set bCheckIPs 1
    if { $bCheckIPs == 1 } {
        set list_check_ips "\
            xilinx.com:ip:axi_bram_ctrl:4.1\
            xilinx.com:ip:blk_mem_gen:8.4\
            xilinx.com:ip:axi_gpio:2.0\
            xilinx.com:ip:axi_uartlite:2.0\
            xilinx.com:ip:proc_sys_reset:5.0\
            xilinx.com:ip:system_management_wiz:1.3\
            xilinx.com:ip:xlconcat:2.1\
            xilinx.com:ip:zynq_ultra_ps_e:3.4\
            "
        set list_ips_missing ""
        common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."
        foreach ip_vlnv $list_check_ips {
            set ip_obj [get_ipdefs -all $ip_vlnv]
            if { $ip_obj eq "" } {
                lappend list_ips_missing $ip_vlnv
            }
        }

        if { $list_ips_missing ne "" } {
            catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
            set bCheckIPsPassed 0
        }
    }

    if { $bCheckIPsPassed != 1 } {
        common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
        return 3
    }

    # Create interface ports
    set BRAM0_PORTB [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM0_PORTB ]
    set_property -dict [ list \
        CONFIG.MASTER_TYPE {BRAM_CTRL} \
        CONFIG.READ_WRITE_MODE {READ_WRITE} \
    ] $BRAM0_PORTB

    set M01_AXI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI ]
    set_property -dict [ list \
        CONFIG.ADDR_WIDTH {40} \
        CONFIG.DATA_WIDTH {32} \
        CONFIG.HAS_REGION {0} \
        CONFIG.PROTOCOL {AXI4} \
    ] $M01_AXI

    set UART_0 [ create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:uart_rtl:1.0 UART_0 ]
    set UART_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_1 ]
    set UART_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_2 ]
    set UART_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_3 ]
    set UART_4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_4 ]
    set UART_5 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_5 ]
    set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]
    set gpio_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl_0 ]
    set gpio_rtl_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl_1 ]

    # Create ports
    set PL_INT0 [ create_bd_port -dir I -type intr PL_INT0 ]
    set_property -dict [ list \
        CONFIG.SENSITIVITY {EDGE_RISING} \
    ] $PL_INT0
    set PSPL_IRQ [ create_bd_port -dir O -type intr PSPL_IRQ ]
    set axi_clk [ create_bd_port -dir O -type clk axi_clk ]
    set_property -dict [ list \
        CONFIG.ASSOCIATED_BUSIF {M01_AXI} \
    ] $axi_clk
    set reset [ create_bd_port -dir O -from 0 -to 0 -type rst reset ]

    # Create instance: axi_bram_ctrl_0, and set properties
    set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
    set_property -dict [list \
        CONFIG.PROTOCOL {AXI4} \
        CONFIG.SINGLE_PORT_BRAM {1} \
    ] $axi_bram_ctrl_0

    # Create instance: axi_bram_ctrl_0_bram, and set properties
    set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_0_bram ]
    set_property -dict [list \
        CONFIG.EN_SAFETY_CKT {false} \
        CONFIG.Memory_Type {True_Dual_Port_RAM} \
    ] $axi_bram_ctrl_0_bram

    # Create instance: axi_gpio_0, and set properties
    set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
    set_property -dict [list \
        CONFIG.C_ALL_INPUTS_2 {1} \
        CONFIG.C_ALL_OUTPUTS {1} \
        CONFIG.C_GPIO2_WIDTH {32} \
        CONFIG.C_GPIO_WIDTH {32} \
        CONFIG.C_INTERRUPT_PRESENT {1} \
        CONFIG.C_IS_DUAL {1} \
    ] $axi_gpio_0

    # Create instance: axi_uartlite_1, and set properties
    set axi_uartlite_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_1 ]
    set_property CONFIG.C_BAUDRATE {115200} $axi_uartlite_1

    # Create instance: axi_uartlite_2, and set properties
    set axi_uartlite_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_2 ]
    set_property CONFIG.C_BAUDRATE {115200} $axi_uartlite_2

    # Create instance: axi_uartlite_3, and set properties
    set axi_uartlite_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_3 ]
    set_property CONFIG.C_BAUDRATE {115200} $axi_uartlite_3

    # Create instance: axi_uartlite_4, and set properties
    set axi_uartlite_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_4 ]
    set_property CONFIG.C_BAUDRATE {115200} $axi_uartlite_4

    # Create instance: axi_uartlite_5, and set properties
    set axi_uartlite_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_5 ]
    set_property CONFIG.C_BAUDRATE {115200} $axi_uartlite_5

    # Create instance: proc_sys_reset_0, and set properties
    set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

    # Create instance: smartconnect_0, and set properties
    set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
    set_property -dict [list \
        CONFIG.NUM_MI {9} \
        CONFIG.NUM_SI {1} \
    ] $smartconnect_0

    # Create instance: system_management_wiz_0, and set properties
    set system_management_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz:1.3 system_management_wiz_0 ]

    # Create instance: xlconcat_0, and set properties
    set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
    set_property CONFIG.NUM_PORTS {5} $xlconcat_0


    # Create instance: zynq_ultra_ps_e_0, and set properties
    set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 zynq_ultra_ps_e_0 ]
    set_property -dict [list \
        CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
        CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
        CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
        CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
        CONFIG.PSU_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
        CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x00000002} \
        CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x40000000} \
        CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#SPI 1#SPI 1#SPI 1#SPI 1#SPI 1#SPI 1##SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD\
0#SD 0#SD 0##UART 1#UART 1#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#####CAN 0#CAN 0#I2C 1#I2C 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB\
0#USB 0#USB 0#USB 0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
        CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#sclk_out#n_ss_out[2]#n_ss_out[1]#n_ss_out[0]#miso#mosi##sdio0_data_out[0]#sdio0_data_out[1]#sdio0_data_out[2]#sdio0_data_out[3]#sdio0_data_out[4]#sdio0_data_out[5]#sdio0_data_out[6]#sdio0_data_out[7]#sdio0_cmd_out#sdio0_clk_out##txd#rxd#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#####phy_rx#phy_tx#scl_out#sda_out#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out}\
\
        CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
        CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
        CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
        CONFIG.PSU__ACT_DDR_FREQ_MHZ {800.000000} \
        CONFIG.PSU__CAN0__GRP_CLK__ENABLE {0} \
        CONFIG.PSU__CAN0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__CAN0__PERIPHERAL__IO {MIO 42 .. 43} \
        CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
        CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1200.000000} \
        CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {250.000000} \
        CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {250.000000} \
        CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {400.000000} \
        CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1066} \
        CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {600.000000} \
        CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {600.000000} \
        CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {250.000000} \
        CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
        CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
        CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {525.000000} \
        CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {500.000000} \
        CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {50.000000} \
        CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__SRCSEL {IOPLL} \
        CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {100} \
        CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
        CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {500.000000} \
        CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {250.000000} \
        CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1500.000000} \
        CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__ACT_FREQMHZ {125.000000} \
        CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__ACT_FREQMHZ {124.998749} \
        CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__ACT_FREQMHZ {124.998749} \
        CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {125.000000} \
        CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {250.000000} \
        CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
        CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {266.666656} \
        CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {500.000000} \
        CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.500000} \
        CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {300.000000} \
        CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {200.000000} \
        CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {200.000000} \
        CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__ACT_FREQMHZ {199.998001} \
        CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {200.000000} \
        CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {50.000000} \
        CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {250.000000} \
        CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__ACT_FREQMHZ {249.997498} \
        CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {20.000000} \
        CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
        CONFIG.PSU__CSU__PERIPHERAL__ENABLE {0} \
        CONFIG.PSU__DDRC__ADDR_MIRROR {1} \
        CONFIG.PSU__DDRC__BUS_WIDTH {32 Bit} \
        CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
        CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
        CONFIG.PSU__DDRC__DQMAP_0_3 {0} \
        CONFIG.PSU__DDRC__DQMAP_12_15 {0} \
        CONFIG.PSU__DDRC__DQMAP_16_19 {0} \
        CONFIG.PSU__DDRC__DQMAP_20_23 {0} \
        CONFIG.PSU__DDRC__DQMAP_24_27 {0} \
        CONFIG.PSU__DDRC__DQMAP_28_31 {0} \
        CONFIG.PSU__DDRC__DQMAP_32_35 {0} \
        CONFIG.PSU__DDRC__DQMAP_36_39 {0} \
        CONFIG.PSU__DDRC__DQMAP_40_43 {0} \
        CONFIG.PSU__DDRC__DQMAP_44_47 {0} \
        CONFIG.PSU__DDRC__DQMAP_48_51 {0} \
        CONFIG.PSU__DDRC__DQMAP_4_7 {0} \
        CONFIG.PSU__DDRC__DQMAP_52_55 {0} \
        CONFIG.PSU__DDRC__DQMAP_56_59 {0} \
        CONFIG.PSU__DDRC__DQMAP_60_63 {0} \
        CONFIG.PSU__DDRC__DQMAP_64_67 {0} \
        CONFIG.PSU__DDRC__DQMAP_68_71 {0} \
        CONFIG.PSU__DDRC__DQMAP_8_11 {0} \
        CONFIG.PSU__DDRC__DRAM_WIDTH {32 Bits} \
        CONFIG.PSU__DDRC__ECC {Disabled} \
        CONFIG.PSU__DDRC__ENABLE_LP4_HAS_ECC_COMP {0} \
        CONFIG.PSU__DDRC__ENABLE_LP4_SLOWBOOT {0} \
        CONFIG.PSU__DDRC__LPDDR4_T_REF_RANGE {Normal (0-85)} \
        CONFIG.PSU__DDRC__MEMORY_TYPE {LPDDR 4} \
        CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
        CONFIG.PSU__DDRC__ROW_ADDR_COUNT {15} \
        CONFIG.PSU__DDRC__SPEED_BIN {LPDDR4_2133} \
        CONFIG.PSU__DDRC__T_FAW {40.0} \
        CONFIG.PSU__DDRC__T_RAS_MIN {42} \
        CONFIG.PSU__DDRC__T_RC {63} \
        CONFIG.PSU__DDRC__T_RCD {20} \
        CONFIG.PSU__DDRC__T_RP {23} \
        CONFIG.PSU__DDRC__VENDOR_PART {OTHERS} \
        CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {0} \
        CONFIG.PSU__DDR__INTERFACE__FREQMHZ {533.000} \
        CONFIG.PSU__DLL__ISUSED {1} \
        CONFIG.PSU__ENET0__FIFO__ENABLE {0} \
        CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {0} \
        CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__ENET0__PERIPHERAL__IO {MIO 26 .. 37} \
        CONFIG.PSU__ENET0__PTP__ENABLE {0} \
        CONFIG.PSU__ENET0__TSU__ENABLE {0} \
        CONFIG.PSU__ENET1__PERIPHERAL__ENABLE {0} \
        CONFIG.PSU__ENET2__PERIPHERAL__ENABLE {0} \
        CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
        CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
        CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
        CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
        CONFIG.PSU__ENET3__PTP__ENABLE {0} \
        CONFIG.PSU__ENET3__TSU__ENABLE {0} \
        CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
        CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__GEM0_COHERENCY {0} \
        CONFIG.PSU__GEM0_ROUTE_THROUGH_FPD {0} \
        CONFIG.PSU__GEM3_COHERENCY {0} \
        CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
        CONFIG.PSU__GEM__TSU__ENABLE {0} \
        CONFIG.PSU__GEN_IPI_10__MASTER {RPU0} \
        CONFIG.PSU__GEN_IPI_7__MASTER {S_AXI_LPD} \
        CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 44 .. 45} \
        CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {100.000000} \
        CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100} \
        CONFIG.PSU__LPD_SLCR__CSUPMU__FREQMHZ {100} \
        CONFIG.PSU__MAXIGP0__DATA_WIDTH {32} \
        CONFIG.PSU__PROTECTION__DDR_SEGMENTS {SA:0x0; SIZE:511; UNIT:MB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0x1FF00000; SIZE:1; UNIT:MB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:LINUX| SA:0x20000000; SIZE:512; UNIT:MB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0x0; SIZE:1; UNIT:MB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:Secure Subsystem|\
SA:0x1FF00000; SIZE:1; UNIT:MB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:RPU0} \
        CONFIG.PSU__PROTECTION__ENABLE {0} \
        CONFIG.PSU__PROTECTION__FPD_SEGMENTS {SA:0xF9010000; SIZE:448; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:APU Secure| SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:APU Secure| SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:Secure Subsystem| SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware| SA:0xFD000000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD010000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU\
Firmware| SA:0xFD020000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD030000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|\
SA:0xFD040000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD050000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD610000;\
SIZE:512; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD5D0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware} \
        CONFIG.PSU__PROTECTION__LPD_SEGMENTS {SA:0xFF5E0000; SIZE:2560; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:APU Secure| SA:0xFFCC0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:APU Secure| SA:0xFF180000; SIZE:768; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:APU Secure| SA:0xFFA80000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:APU\
Secure| SA:0xC0000000; SIZE:524288; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFF070000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFF030000;\
SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFF170000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFF000000; SIZE:64; UNIT:KB;\
RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFF010000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFF110000; SIZE:64; UNIT:KB; RegionTZ:NonSecure;\
WrAllowed:Read/Write; subsystemId:LINUX| SA:0xFFDC0000; SIZE:128; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:Secure Subsystem| SA:0xFF5E0000; SIZE:2560; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem| SA:0xFFCC0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:Secure Subsystem| SA:0xFF180000; SIZE:768; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem| SA:0xFF9A0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:Secure Subsystem| SA:0xFFD80000; SIZE:256; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem| SA:0xFFE90000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU1| SA:0xFFEB0000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU1|\
SA:0xFF120000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU1| SA:0xFF000000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU1| SA:0xFF070000;\
SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF030000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF170000;\
SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF110000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF120000;\
SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF130000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF140000;\
SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF000000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF010000;\
SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF980000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF5E0000; SIZE:2560;\
UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFCC0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF180000; SIZE:768; UNIT:KB;\
RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF410000; SIZE:640; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFA70000; SIZE:64; UNIT:KB; RegionTZ:Secure;\
WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF9A0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFA50000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware| SA:0xFFE00000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU0| SA:0xFFE20000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU0|\
SA:0xFF120000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU0| SA:0xFF000000; SIZE:64; UNIT:KB; RegionTZ:NonSecure; WrAllowed:Read/Write; subsystemId:RPU0|SA:0xFFC80000 ;SIZE:128;UNIT:KB\
;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:Secure Subsystem|SA:0xFF150000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:PMU Firmware|SA:0xFFA50000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure\
;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA00000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA10000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA30000\
;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA20000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFE000000 ;SIZE:1024;UNIT:KB\
;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFF380000 ;SIZE:512;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA80000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure\
;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA90000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFAA0000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFAB0000\
;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFAC0000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFAD0000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure\
;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFAE0000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFAF0000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFE100000\
;SIZE:1024;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFF0F0000 ;SIZE:64;UNIT:KB ;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX|SA:0xFFA60000 ;SIZE:64;UNIT:KB\
;RegionTZ:NonSecure ;WrAllowed:Read/Write;subsystemId:LINUX} \
        CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:Secure;1|SD0:NonSecure;1|SATA1:NonSecure;1|SATA0:NonSecure;1|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;1|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
        CONFIG.PSU__PROTECTION__MASTERS_TZ {GEM0:NonSecure|SD1:Secure|GEM2:NonSecure|GEM1:NonSecure|GEM3:NonSecure|PCIe:NonSecure|DP:NonSecure|NAND:NonSecure|GPU:NonSecure|RPU1:Secure|RPU0:Secure|SATA0:NonSecure|SATA1:NonSecure|USB1:NonSecure|USB0:NonSecure|LDMA:NonSecure|FDMA:NonSecure|QSPI:NonSecure|SD0:NonSecure}\
\
        CONFIG.PSU__PROTECTION__OCM_SEGMENTS {SA:0xFFFC0000; SIZE:256; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:APU Secure| SA:0xFFFC0000; SIZE:256; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem| SA:0xFFFC0000; SIZE:256; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFFC0000; SIZE:256; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:RPU0} \
        CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;1|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;1|FPD;SATA;FD0C0000;FD0CFFFF;1|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;0|FPD;GPU;FD4B0000;FD4BFFFF;0|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;1|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;3FFFFFFF;1|DDR;DDR_HIGH;800000000;800000000;0|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;1|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
        CONFIG.PSU__PROTECTION__SUBSYSTEMS {APU Secure:SD1;APU|LINUX:SD1;APU;DAP|Secure Subsystem:|RPU1:RPU1|PMU Firmware:PMU|RPU0:RPU0} \
        CONFIG.PSU__PSS_REF_CLK__FREQMHZ {50} \
        CONFIG.PSU__QSPI_COHERENCY {0} \
        CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
        CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {0} \
        CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
        CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 5} \
        CONFIG.PSU__QSPI__PERIPHERAL__MODE {Single} \
        CONFIG.PSU__SATA__LANE0__ENABLE {0} \
        CONFIG.PSU__SATA__LANE1__IO {GT Lane1} \
        CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__SATA__REF_CLK_FREQ {150} \
        CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk1} \
        CONFIG.PSU__SD0_COHERENCY {0} \
        CONFIG.PSU__SD0_ROUTE_THROUGH_FPD {0} \
        CONFIG.PSU__SD0__CLK_200_SDR_OTAP_DLY {0x3} \
        CONFIG.PSU__SD0__CLK_50_DDR_ITAP_DLY {0x12} \
        CONFIG.PSU__SD0__CLK_50_DDR_OTAP_DLY {0x6} \
        CONFIG.PSU__SD0__CLK_50_SDR_ITAP_DLY {0x15} \
        CONFIG.PSU__SD0__CLK_50_SDR_OTAP_DLY {0x6} \
        CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
        CONFIG.PSU__SD0__GRP_POW__ENABLE {0} \
        CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
        CONFIG.PSU__SD0__RESET__ENABLE {0} \
        CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
        CONFIG.PSU__SD1_COHERENCY {0} \
        CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
        CONFIG.PSU__SD1__CLK_50_SDR_ITAP_DLY {0x15} \
        CONFIG.PSU__SD1__CLK_50_SDR_OTAP_DLY {0x5} \
        CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
        CONFIG.PSU__SD1__GRP_CD__ENABLE {0} \
        CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
        CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
        CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
        CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
        CONFIG.PSU__SPI0__PERIPHERAL__ENABLE {0} \
        CONFIG.PSU__SPI1__GRP_SS0__IO {MIO 9} \
        CONFIG.PSU__SPI1__GRP_SS1__ENABLE {1} \
        CONFIG.PSU__SPI1__GRP_SS1__IO {MIO 8} \
        CONFIG.PSU__SPI1__GRP_SS2__ENABLE {1} \
        CONFIG.PSU__SPI1__GRP_SS2__IO {MIO 7} \
        CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__SPI1__PERIPHERAL__IO {MIO 6 .. 11} \
        CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
        CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
        CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
        CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
        CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
        CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
        CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
        CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
        CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
        CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
        CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
        CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
        CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
        CONFIG.PSU__UART0__BAUD_RATE {115200} \
        CONFIG.PSU__UART0__MODEM__ENABLE {0} \
        CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__UART0__PERIPHERAL__IO {EMIO} \
        CONFIG.PSU__UART1__BAUD_RATE {115200} \
        CONFIG.PSU__UART1__MODEM__ENABLE {0} \
        CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 24 .. 25} \
        CONFIG.PSU__USB0_COHERENCY {0} \
        CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
        CONFIG.PSU__USB0__REF_CLK_FREQ {26} \
        CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk3} \
        CONFIG.PSU__USB1__PERIPHERAL__ENABLE {0} \
        CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
        CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
        CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane0} \
        CONFIG.PSU__USB__RESET__MODE {Boot Pin} \
        CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
        CONFIG.PSU__USE__IRQ0 {1} \
        CONFIG.PSU__USE__M_AXI_GP0 {1} \
        CONFIG.PSU__USE__M_AXI_GP2 {0} \
        CONFIG.PSU__USE__S_AXI_GP2 {0} \
    ] $zynq_ultra_ps_e_0

    set_property SELECTED_SIM_MODEL tlm  $zynq_ultra_ps_e_0

    # Create interface connections
    connect_bd_intf_net -intf_net BRAM0_PORTB [get_bd_intf_ports BRAM0_PORTB] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB]
    connect_bd_intf_net -intf_net Vp_Vn_1 [get_bd_intf_ports Vp_Vn] [get_bd_intf_pins system_management_wiz_0/Vp_Vn]
    connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA]
    connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports gpio_rtl_0] [get_bd_intf_pins axi_gpio_0/GPIO]
    connect_bd_intf_net -intf_net axi_gpio_0_GPIO2 [get_bd_intf_ports gpio_rtl_1] [get_bd_intf_pins axi_gpio_0/GPIO2]
    connect_bd_intf_net -intf_net axi_uartlite_1_UART [get_bd_intf_ports UART_1] [get_bd_intf_pins axi_uartlite_1/UART]
    connect_bd_intf_net -intf_net axi_uartlite_2_UART [get_bd_intf_ports UART_2] [get_bd_intf_pins axi_uartlite_2/UART]
    connect_bd_intf_net -intf_net axi_uartlite_3_UART [get_bd_intf_ports UART_3] [get_bd_intf_pins axi_uartlite_3/UART]
    connect_bd_intf_net -intf_net axi_uartlite_4_UART [get_bd_intf_ports UART_4] [get_bd_intf_pins axi_uartlite_4/UART]
    connect_bd_intf_net -intf_net axi_uartlite_5_UART [get_bd_intf_ports UART_5] [get_bd_intf_pins axi_uartlite_5/UART]
    connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins system_management_wiz_0/S_AXI_LITE]
    connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_ports M01_AXI] [get_bd_intf_pins smartconnect_0/M01_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins smartconnect_0/M02_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins smartconnect_0/M03_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins axi_uartlite_1/S_AXI] [get_bd_intf_pins smartconnect_0/M04_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins axi_uartlite_2/S_AXI] [get_bd_intf_pins smartconnect_0/M05_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M06_AXI [get_bd_intf_pins axi_uartlite_3/S_AXI] [get_bd_intf_pins smartconnect_0/M06_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M07_AXI [get_bd_intf_pins axi_uartlite_4/S_AXI] [get_bd_intf_pins smartconnect_0/M07_AXI]
    connect_bd_intf_net -intf_net smartconnect_0_M08_AXI [get_bd_intf_pins axi_uartlite_5/S_AXI] [get_bd_intf_pins smartconnect_0/M08_AXI]
    connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_FPD [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
    connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_UART_0 [get_bd_intf_ports UART_0] [get_bd_intf_pins zynq_ultra_ps_e_0/UART_0]

    # Create port connections
    connect_bd_net -net PL_INT0_1 [get_bd_ports PL_INT0] [get_bd_pins xlconcat_0/In4]
    connect_bd_net -net axi_gpio_0_ip2intc_irpt [get_bd_pins axi_gpio_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In3]
    connect_bd_net -net axi_uartlite_1_interrupt [get_bd_pins axi_uartlite_1/interrupt] [get_bd_pins xlconcat_0/In1]
    connect_bd_net -net axi_uartlite_2_interrupt [get_bd_pins axi_uartlite_2/interrupt] [get_bd_pins xlconcat_0/In2]
    connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_uartlite_1/s_axi_aresetn] [get_bd_pins axi_uartlite_2/s_axi_aresetn] [get_bd_pins axi_uartlite_3/s_axi_aresetn] [get_bd_pins axi_uartlite_4/s_axi_aresetn] [get_bd_pins axi_uartlite_5/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins system_management_wiz_0/s_axi_aresetn]
    connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_ports reset] [get_bd_pins proc_sys_reset_0/peripheral_reset]
    connect_bd_net -net system_management_wiz_0_ip2intc_irpt [get_bd_pins system_management_wiz_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In0]
    connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]
    connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_ports axi_clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_uartlite_1/s_axi_aclk] [get_bd_pins axi_uartlite_2/s_axi_aclk] [get_bd_pins axi_uartlite_3/s_axi_aclk] [get_bd_pins axi_uartlite_4/s_axi_aclk] [get_bd_pins axi_uartlite_5/s_axi_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins system_management_wiz_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]
    connect_bd_net -net zynq_ultra_ps_e_0_ps_pl_irq_ipi_channel7 [get_bd_ports PSPL_IRQ] [get_bd_pins zynq_ultra_ps_e_0/ps_pl_irq_ipi_channel7]

    # Create address segments
    assign_bd_address -offset 0xA0018000 -range 0x00002000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs M01_AXI/Reg] -force
    assign_bd_address -offset 0xA0010000 -range 0x00008000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
    assign_bd_address -offset 0xA001A000 -range 0x00002000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
    assign_bd_address -offset 0xA0020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uartlite_1/S_AXI/Reg] -force
    assign_bd_address -offset 0xA0030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uartlite_2/S_AXI/Reg] -force
    assign_bd_address -offset 0xA0040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uartlite_3/S_AXI/Reg] -force
    assign_bd_address -offset 0xA0050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uartlite_4/S_AXI/Reg] -force
    assign_bd_address -offset 0xA0060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uartlite_5/S_AXI/Reg] -force
    assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs system_management_wiz_0/S_AXI_LITE/Reg] -force

    # Create PFM attributes
    set file $script_folder/bd/[current_bd_design]/[current_bd_design].bd
    set file [file normalize $file]
    set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
    set_property PFM_NAME {Spellman:som:[current_bd_design]:1.0} -objects $file_obj
    set_property REGISTERED_WITH_MANAGER 1 -objects $file_obj
    set_property PFM.AXI_PORT {S01_AXI {memport "S_AXI_HP" sptag "DDR" memory "" is_range "true"}} [get_bd_cells /smartconnect_0]
    set_property PFM.AXI_PORT {M_AXI_HPM0_LPD {memport "M_AXI_GP" sptag "" memory "" is_range "false"}} [get_bd_cells /zynq_ultra_ps_e_0]
    set_property PFM.CLOCK {pl_clk0 {id "0" is_default "true" proc_sys_reset "/proc_sys_reset_0" status "fixed" freq_hz "100000000"}} [get_bd_cells /zynq_ultra_ps_e_0]

    validate_bd_design
    generate_target all [get_files [current_bd_design].bd]
    regenerate_bd_layout
    save_bd_design
    assign_bd_address -force -export_to_file $script_folder/memory_map.txt
    write_bd_layout -format pdf -orientation landscape -force $script_folder/[current_bd_design].pdf
    make_wrapper -files [get_files [current_bd_design].bd] -top

##################################################################