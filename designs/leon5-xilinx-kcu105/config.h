/*
 * Automatically generated C config: don't edit
 */
#define AUTOCONF_INCLUDED
/*
 * Synthesis      
 */
#undef  CONFIG_SYN_INFERRED
#undef  CONFIG_SYN_AXCEL
#undef  CONFIG_SYN_AXDSP
#undef  CONFIG_SYN_FUSION
#undef  CONFIG_SYN_PROASIC
#undef  CONFIG_SYN_PROASICPLUS
#undef  CONFIG_SYN_PROASIC3
#undef  CONFIG_SYN_PROASIC3E
#undef  CONFIG_SYN_PROASIC3L
#undef  CONFIG_SYN_IGLOO
#undef  CONFIG_SYN_IGLOO2
#undef  CONFIG_SYN_SF2
#undef  CONFIG_SYN_RTG4
#undef  CONFIG_SYN_POLARFIRE
#undef  CONFIG_SYN_UT025CRH
#undef  CONFIG_SYN_UT130HBD
#undef  CONFIG_SYN_UT90NHBD
#undef  CONFIG_SYN_CYCLONEIII
#undef  CONFIG_SYN_STRATIX
#undef  CONFIG_SYN_STRATIXII
#undef  CONFIG_SYN_STRATIXIII
#undef  CONFIG_SYN_STRATIXIV
#undef  CONFIG_SYN_STRATIXV
#undef  CONFIG_SYN_ALTERA
#undef  CONFIG_SYN_ATC18
#undef  CONFIG_SYN_ATC18RHA
#undef  CONFIG_SYN_CUSTOM1
#undef  CONFIG_SYN_DARE
#undef  CONFIG_SYN_CMOS9SF
#undef  CONFIG_SYN_BRAVEMED
#undef  CONFIG_SYN_ECLIPSE
#undef  CONFIG_SYN_RH_LIB18T
#undef  CONFIG_SYN_RHUMC
#undef  CONFIG_SYN_RHS65
#undef  CONFIG_SYN_SAED32
#undef  CONFIG_SYN_SMIC13
#undef  CONFIG_SYN_TM65GPLUS
#undef  CONFIG_SYN_TSMC90
#undef  CONFIG_SYN_UMC
#undef  CONFIG_SYN_ARTIX7
#undef  CONFIG_SYN_KINTEX7
#define CONFIG_SYN_KINTEXU 1
#undef  CONFIG_SYN_SPARTAN3
#undef  CONFIG_SYN_SPARTAN3E
#undef  CONFIG_SYN_SPARTAN6
#undef  CONFIG_SYN_VIRTEX2
#undef  CONFIG_SYN_VIRTEX4
#undef  CONFIG_SYN_VIRTEX5
#undef  CONFIG_SYN_VIRTEX6
#undef  CONFIG_SYN_VIRTEX7
#undef  CONFIG_SYN_ZYNQ7000
#undef  CONFIG_SYN_INFER_RAM
#undef  CONFIG_SYN_INFER_PADS
#undef  CONFIG_SYN_NO_ASYNC
#undef  CONFIG_SYN_SCAN
/*
 * Clock generation
 */
#undef  CONFIG_CLK_INFERRED
#undef  CONFIG_CLK_HCLKBUF
#undef  CONFIG_CLK_UT130HBD
#undef  CONFIG_CLK_ALTDLL
#undef  CONFIG_CLK_BRAVEMED
#undef  CONFIG_CLK_PRO3PLL
#undef  CONFIG_CLK_PRO3EPLL
#undef  CONFIG_CLK_PRO3LPLL
#undef  CONFIG_CLK_FUSPLL
#undef  CONFIG_CLK_LIB18T
#undef  CONFIG_CLK_RHUMC
#undef  CONFIG_CLK_DARE
#undef  CONFIG_CLK_SAED32
#undef  CONFIG_CLK_EASIC45
#undef  CONFIG_CLK_RHS65
#undef  CONFIG_CLK_CLKPLLE2
#undef  CONFIG_CLK_CLKDLL
#define CONFIG_CLK_DCM 1
#define CONFIG_CLK_MUL (2)
#define CONFIG_CLK_DIV (6)
#undef  CONFIG_PCI_CLKDLL
#undef  CONFIG_CLK_NOFB
#undef  CONFIG_PCI_SYSCLK
/*
 * LEON5 Processor system
 */
#define CONFIG_PROC_NUM (1)
#define CONFIG_FPU_NANOFPU 1
#undef  CONFIG_FPU_GRFPU5
#undef  CONFIG_AHB_32BIT
#undef  CONFIG_AHB_64BIT
#define CONFIG_AHB_128BIT 1
#define CONFIG_BWMASK 00FF
#define CONFIG_CACHE_FIXED 0
/*
 * L2 Cache
 */
#undef  CONFIG_L2_ENABLE
#undef  CONFIG_L2_ASSO1
#undef  CONFIG_L2_ASSO2
#undef  CONFIG_L2_ASSO3
#define CONFIG_L2_ASSO4 1
#undef  CONFIG_L2_SZ1
#undef  CONFIG_L2_SZ2
#undef  CONFIG_L2_SZ4
#undef  CONFIG_L2_SZ8
#undef  CONFIG_L2_SZ16
#undef  CONFIG_L2_SZ32
#undef  CONFIG_L2_SZ64
#define CONFIG_L2_SZ128 1
#undef  CONFIG_L2_SZ256
#undef  CONFIG_L2_SZ512
#define CONFIG_L2_LINE32 1
#undef  CONFIG_L2_LINE64
#undef  CONFIG_L2_HPROT
#undef  CONFIG_L2_PEN
#undef  CONFIG_L2_WT
#undef  CONFIG_L2_RAN
#undef  CONFIG_L2_SHARE
#define CONFIG_L2_MAP 00F0
#define CONFIG_L2_MTRR (0)
#define CONFIG_L2_EDAC_NONE 1
#undef  CONFIG_L2_EDAC_YES
#undef  CONFIG_L2_EDAC_TECHSPEC
#define CONFIG_L2_AXI 1
/*
 * Debug Link           
 */
#define CONFIG_DSU_UART 1
#define CONFIG_DSU_JTAG 1
#define CONFIG_DSU_ETH 1
#undef  CONFIG_DSU_ETHSZ1
#define CONFIG_DSU_ETHSZ2 1
#undef  CONFIG_DSU_ETHSZ4
#undef  CONFIG_DSU_ETHSZ8
#undef  CONFIG_DSU_ETHSZ16
#define CONFIG_DSU_IPMSB C0A8
#define CONFIG_DSU_IPLSB 0033
#define CONFIG_DSU_ETHMSB 020000
#define CONFIG_DSU_ETHLSB 000000
#undef  CONFIG_DSU_ETH_PROG
/*
 * Peripherals             
 */
/*
 * Memory controller             
 */
/*
 * MIG 7-Series memory controller   
 */
#define CONFIG_MIG_7SERIES 1
#undef  CONFIG_MIG_7SERIES_MODEL
#undef  CONFIG_AHBSTAT_ENABLE
/*
 * On-chip RAM/ROM                 
 */
#undef  CONFIG_AHBROM_ENABLE
#undef  CONFIG_AHBRAM_ENABLE
/*
 * Ethernet             
 */
#define CONFIG_GRETH_ENABLE 1
#undef  CONFIG_GRETH_GIGA
#undef  CONFIG_GRETH_FIFO4
#define CONFIG_GRETH_FIFO8 1
#undef  CONFIG_GRETH_FIFO16
#undef  CONFIG_GRETH_FIFO32
#undef  CONFIG_GRETH_FIFO64
#undef  CONFIG_GRETH_FMC_MODE
#define CONFIG_GRETH_PHY_ADDR (1)
/*
 * GPIO
 */
#define CONFIG_GRGPIO_ENABLE 1
#define CONFIG_GRGPIO_WIDTH (20)
#define CONFIG_GRGPIO_IMASK 0000
/*
 * I2C
 */
#undef  CONFIG_I2C_ENABLE
/*
 * VHDL Debugging        
 */
#undef  CONFIG_IU_DISAS
#undef  CONFIG_AHB_DTRACE
