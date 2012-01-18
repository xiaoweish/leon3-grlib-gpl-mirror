-----------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2012, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 


library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.jtag.all;
-- pragma translate_off
use gaisler.sim.all;
-- pragma translate_on

library esa;
use esa.memoryctrl.all;
use work.config.all;
use work.mypackage.all; --contains type

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW
  );
  port (
    resetn	: in  std_logic; --key[0]
    clock_50	: in  std_logic;
    errorn	: out std_logic; --ledr[0], error from LEON3 DSU

    fl_addr 	: out std_logic_vector(21 downto 0);
    fl_dq	: inout std_logic_vector(7 downto 0);
    dram_addr  	: out std_logic_vector(11 downto 0);
    dram_ba_0	: out std_logic;
    dram_ba_1	: out std_logic;
    dram_dq	: inout std_logic_vector(15 downto 0);

    dram_clk  	: out std_logic;
    dram_cke  	: out std_logic;
    dram_cs_n  	: out std_logic;
    dram_we_n  	: out std_logic;        	-- sdram write enable
    dram_ras_n  : out std_logic;               	-- sdram ras
    dram_cas_n  : out std_logic;               	-- sdram cas
    dram_ldqm	: out std_logic;		-- sdram ldqm
    dram_udqm	: out std_logic;		-- sdram udqm
    uart_txd  	: out std_logic;		-- DSU tx data
    uart_rxd  	: in  std_logic;		-- DSU rx data
    dsubre  	: in std_logic;  --key[1], used to put processor in debug mode.
    dsuact  	: out std_logic; --ledr[1]
    fl_oe_n    	: out std_logic;
    fl_we_n 	: out std_logic;
    fl_rst_n   	: out std_logic;
    fl_ce_n  	: out std_logic;

    lcd_data    : inout std_logic_vector(7 downto 0);
    lcd_blon    : out std_logic;
    lcd_rw      : out std_logic;
    lcd_en      : out std_logic;
    lcd_rs      : out std_logic;
    lcd_on      : out std_logic;

    gpio_0        : inout std_logic_vector(CFG_GRGPIO_WIDTH-1 downto 0); 	-- I/O port 0
    gpio_1        : inout std_logic_vector(CFG_GRGPIO2_WIDTH-1 downto 0); 	-- I/O port 1

    ps2_clk       : inout std_logic;
    ps2_dat       : inout std_logic;

    vga_clk       : out std_ulogic;
    vga_blank     : out std_ulogic;
    vga_sync      : out std_ulogic;
    vga_hs        : out std_ulogic;
    vga_vs        : out std_ulogic;
    vga_r         : out std_logic_vector(9 downto 0);
    vga_g         : out std_logic_vector(9 downto 0);
    vga_b         : out std_logic_vector(9 downto 0);

    sw      	: in std_logic_vector(0 to 2) := "000"

    );
end;

architecture rtl of leon3mp is

signal vcc, gnd   : std_logic_vector(4 downto 0);
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
signal sdo2, sdo3 : sdctrl_out_type;

--AMBA bus standard interface signals--
signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

signal clkm, rstn, rstraw, pciclk, sdclkl, lclk, rst : std_logic;

signal cgi : clkgen_in_type;
signal cgo : clkgen_out_type;

signal u1i, dui : uart_in_type;
signal u1o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to CFG_NCPU-1);
signal irqo : irq_out_vector(0 to CFG_NCPU-1);

signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal stati : ahbstat_in_type;

signal gpti : gptimer_in_type;

signal gpioi_0, gpioi_1 : gpio_in_type;
signal gpioo_0, gpioo_1 : gpio_out_type;

signal dsubren : std_logic;

signal tck, tms, tdi, tdo : std_logic;

signal fpi : grfpu_in_vector_type;
signal fpo : grfpu_out_vector_type;

signal kbdi  : ps2_in_type;
signal kbdo  : ps2_out_type;
signal moui  : ps2_in_type;
signal mouo  : ps2_out_type;
signal vgao  : apbvga_out_type;
signal video_clk, clk40  : std_logic;

signal lcdo : lcd_out_type;
signal lcdi : lcd_in_type;

constant BOARD_FREQ : integer := 50000;	-- Board frequency in KHz, used in clkgen
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz (current 50Mhz)
constant IOAEN : integer := 1;
constant CFG_SDEN : integer := CFG_MCTRL_SDEN;
constant CFG_INVCLK : integer := CFG_MCTRL_INVCLK;
constant OEPOL : integer := padoen_polarity(padtech);

attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute keep : boolean;

begin

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

  clk_pad : clkpad generic map (tech => padtech) port map (clock_50, lclk); 

  clkgen0 : entity work.clkgen_de2
	generic map (clk_mul => CFG_CLKMUL, clk_div => CFG_CLKDIV, 
		clk_freq => BOARD_FREQ, sdramen => CFG_SDCTRL)
	port map (inclk0 => lclk, c0 => clkm, c0_2x => clk40, e0 => sdclkl,
		  locked => cgo.clklock);

  sdclk_pad : outpad generic map (tech => padtech, slew => 1) 
	port map (dram_clk, sdclkl);

  resetn_pad : inpad generic map (tech => padtech) port map (resetn, rst); 
  rst0 : rstgen			-- reset generator (reset is active LOW)
    port map (rst, clkm, cgo.clklock, rstn, rstraw);

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
	rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, ioen => IOAEN,
	nahbm => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE,
	devid => ALTERA_DE2, nahbs => 8) 

  port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
-----  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  cpu : for i in 0 to CFG_NCPU-1 generate
    nosh : if CFG_GRFPUSH = 0 generate    
      u0 : leon3s 		-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	0, 0, CFG_MMU_PAGE, CFG_BP)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
  end generate;

  sh : if CFG_GRFPUSH = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      u0 : leon3sh 		-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, CFG_NCPU-1,
	0, 0, CFG_MMU_PAGE, CFG_BP)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i), fpi(i), fpo(i));
    end generate;

    grfpush0 : grfpushwx generic map ((CFG_FPU-1), CFG_NCPU, fabtech)
      port map (clkm, rstn, fpi, fpo);
    
  end generate;
  --ledr[0] lit when leon 3 debugvector signals error
  errorn_pad : odpad generic map (tech => padtech) port map (errorn, dbgo(0).error);
  
  dsugen : if CFG_DSU = 1 generate
    dsu0 : dsu3			-- LEON3 Debug Support Unit (slave)
    generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
       ncpu => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
    port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
    dsui.enable <= '1';
    dsubre_pad : inpad generic map (tech => padtech) port map (dsubre, dsubren);
    dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, dsuo.active); --ledr[1] is lit in debug mode.
    dsui.break <= not dsubren;
  end generate; 
  nodsu : if CFG_DSU = 0 generate 
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0'; --no timer freeze, no light.
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => CFG_NCPU, pindex => 7, paddr => 7)
    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(CFG_NCPU));  
      dui.rxd <= uart_rxd when sw(0) = '0' else '1';
  end generate;
  
  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  memi.edac <= '0'; memi.bwidth <= "00";

  mctrl0 : if CFG_MCTRL_LEON2 = 1 generate 	-- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 0, pindex => 0, paddr => 0, 
	srbanks => 4, sden => 0, ram8 => CFG_MCTRL_RAM8BIT, 
	ram16 => CFG_MCTRL_RAM16BIT, invclk => CFG_MCTRL_INVCLK, 
	sepbus => CFG_MCTRL_SEPBUS, oepol => OEPOL, iomask => 0, 
	sdbits => 32 + 32*CFG_MCTRL_SD64, rammask => 0 ,pageburst => CFG_MCTRL_PAGE)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(0), apbi, apbo(0), wpo, sdo);

    addr_pad : outpadv generic map (width => 22, tech => padtech)
	port map (fl_addr, memo.address(21 downto 0)); 
    roms_pad : outpad generic map (tech => padtech) 
	port map (fl_ce_n, memo.romsn(0)); --PROM chip select
    oen_pad  : outpad generic map (tech => padtech) 
	port map (fl_oe_n, memo.oen);
    wri_pad  : outpad generic map (tech => padtech) 
	port map (fl_we_n, memo.writen); --write strobe
    fl_rst_pad : outpad generic map (tech => padtech) 
	port map (fl_rst_n, rstn); --reset flash with common reset signal
    data_pad : iopadvv generic map (tech => padtech, width => 8, oepol => OEPOL)
      port map (fl_dq, memo.data(31 downto 24), memo.vbdrive(31 downto 24), memi.data(31 downto 24));
    memi.brdyn <= '1'; memi.bexcn <= '1';
    memi.writen <= '1'; memi.wrn <= "1111";
  end generate;


  sdctrl0 : if CFG_SDCTRL = 1 generate 	-- 16-bit SDRAM controller
      sdc : sdctrl16 generic map (hindex => 3, haddr => 16#400#, hmask => 16#FF8#, -- hmask => 16#C00#, 
	ioaddr => 1, fast => 0, pwron => 0, invclk => 0, 
	sdbits => 16, pageburst => 2)
      port map (rstn, clkm, ahbsi, ahbso(3), sdi, sdo2);
      sa_pad : outpadv generic map (width => 12, tech => padtech) 
	   port map (dram_addr, sdo2.address(13 downto 2));
      ba0_pad : outpad generic map (tech => padtech) 
	   port map (dram_ba_0, sdo2.address(15));
      ba1_pad : outpad generic map (tech => padtech) 
	   port map (dram_ba_1, sdo2.address(16)); 
      sd_pad : iopadvv generic map (width => 16, tech => padtech, oepol => OEPOL) 
	   port map (dram_dq(15 downto 0), sdo2.data(15 downto 0), sdo2.vbdrive(15 downto 0), sdi.data(15 downto 0));
      sdcke_pad : outpad generic map (tech => padtech) 
	   port map (dram_cke, sdo2.sdcke(0)); 
      sdwen_pad : outpad generic map (tech => padtech) 
	   port map (dram_we_n, sdo2.sdwen);
      sdcsn_pad : outpad generic map (tech => padtech) 
	   port map (dram_cs_n, sdo2.sdcsn(0)); 
      sdras_pad : outpad generic map (tech => padtech) 
	   port map (dram_ras_n, sdo2.rasn);
      sdcas_pad : outpad generic map (tech => padtech) 
	   port map (dram_cas_n, sdo2.casn);
      sdldqm_pad : outpad generic map (tech => padtech) 
	   port map (dram_ldqm, sdo2.dqm(0) );
      sdudqm_pad : outpad generic map (tech => padtech) 
	   port map (dram_udqm, sdo2.dqm(1));
  end generate;


  mg0 : if CFG_MCTRL_LEON2 = 0 generate	-- No PROM/SRAM controller
    apbo(0) <= apb_none; ahbso(0) <= ahbs_none;
    roms_pad : outpad generic map (tech => padtech) 
	port map (fl_ce_n, gnd(0));
  end generate;


----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR)
  port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo );

  lcd : apblcd
  generic map(pindex => 4, paddr => 4, pmask => 16#fff#, oepol => OEPOL, tas => 1, epw => 12)
  port map(rstn, clkm, apbi, apbo(4), lcdo, lcdi);

  rs_pad : outpad generic map (tech => padtech)
     port map (lcd_rs, lcdo.rs);
  rw_pad : outpad generic map (tech => padtech)
     port map (lcd_rw, lcdo.rw);
  e_pad : outpad generic map (tech => padtech)
     port map (lcd_en, lcdo.e);
  db_pad : iopadv generic map (width => 8, tech => padtech, oepol => OEPOL) 
     port map (lcd_data, lcdo.db, lcdo.db_oe, lcdi.db);
  blon_pad : outpad generic map (tech => padtech) 
     port map (lcd_blon, gnd(0));
  on_pad : outpad generic map (tech => padtech) 
     port map (lcd_on, vcc(0));

----------------------------------------------------------------------------------------
  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart, flow => 0,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0';
    u1i.rxd <= '1' when sw(0) = '0' else uart_rxd;
  end generate;
  uart_txd <= duo.txd when sw(0) = '0' else u1o.txd;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp			-- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
    port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU-1 generate irqi(i).irl <= "0000"; end generate;
    apbo(2) <= apb_none;
  end generate;
 
  --Timer unit, generates interrupts when a timer underflow.
  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer 			-- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ, 
	sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM, 
	nbits => CFG_GPT_TW)
    port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GR GPIO0 unit
    grgpio0: grgpio
      generic map( pindex => 9, paddr => 9, imask => CFG_GRGPIO_IMASK, nbits => CFG_GRGPIO_WIDTH)
      port map( rstn, clkm, apbi, apbo(9), gpioi_0, gpioo_0);
      pio_pads : for i in 0 to CFG_GRGPIO_WIDTH-1 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (gpio_0(i), gpioo_0.dout(i), gpioo_0.oen(i), gpioi_0.din(i));
      end generate;
  end generate;
  nogpio0: if CFG_GRGPIO_ENABLE = 0 generate apbo(9) <= apb_none; end generate;

  gpio1 : if CFG_GRGPIO2_ENABLE /= 0 generate     -- GR GPIO1 unit
    grgpio1: grgpio
      generic map( pindex => 10, paddr => 10, imask => CFG_GRGPIO2_IMASK, nbits => CFG_GRGPIO2_WIDTH)
      port map( rstn, clkm, apbi, apbo(10), gpioi_1, gpioo_1);
      pio_pads : for i in 0 to CFG_GRGPIO2_WIDTH-1 generate
        pio_pad : iopad generic map (tech => padtech)
            port map (gpio_1(i), gpioo_1.dout(i), gpioo_1.oen(i), gpioi_1.din(i));
      end generate;
  end generate;
  nogpio1: if CFG_GRGPIO2_ENABLE = 0 generate apbo(10) <= apb_none; end generate;

  ahbs : if CFG_AHBSTAT = 1 generate	-- AHB status register
    stati.cerror(1 to NAHBSLV-1) <= (others => '0');
    stati.cerror(0) <= memo.ce; --connect as many fault tolerans units as specified by nftslv generic.
    ahbstat0 : ahbstat generic map (pindex => 15, paddr => 15, pirq => 1,
	nftslv => CFG_AHBSTATN)
      port map (rstn, clkm, ahbmi, ahbsi, stati, apbi, apbo(15));
  end generate;
  nop2 : if CFG_AHBSTAT = 0 generate apbo(15) <= apb_none; end generate;

  kbd : if CFG_KBD_ENABLE /= 0 generate
    ps20 : apbps2 generic map(pindex => 5, paddr => 5, pirq => 5)
      port map(rstn, clkm, apbi, apbo(5), kbdi, kbdo);
  end generate;
  nokbd : if CFG_KBD_ENABLE = 0 generate 
	apbo(5) <= apb_none; kbdo <= ps2o_none;
  end generate;
  kbdclk_pad : iopad generic map (tech => padtech)
      port map (ps2_clk,kbdo.ps2_clk_o, kbdo.ps2_clk_oe, kbdi.ps2_clk_i);
  kbdata_pad : iopad generic map (tech => padtech)
        port map (ps2_dat, kbdo.ps2_data_o, kbdo.ps2_data_oe, kbdi.ps2_data_i);

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 6, paddr => 6)
       port map(rstn, clkm, clk40, apbi, apbo(6), vgao);
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vga_clk, video_clk);
    video_clk <= not clk40;
   end generate;
  
  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(memtech => memtech, pindex => 6, paddr => 6,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
	clk0 => 40000, --1000000000/((BOARD_FREQ * CFG_CLKMUL)/CFG_CLKDIV),
	clk1 => 0, clk2 => 0, clk3 => 0, burstlen => 8)
       port map(rstn, clkm, clk40, apbi, apbo(6), vgao, ahbmi, 
		ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), open);
    video_clk <= not clk40;
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vga_clk, video_clk);
  end generate;

  novga : if (CFG_VGA_ENABLE = 0 and CFG_SVGA_ENABLE = 0) generate
    apbo(6) <= apb_none; vgao <= vgao_none;
    video_clk <= not clkm;
    video_clock_pad : outpad generic map ( tech => padtech)
        port map (vga_clk, video_clk);
  end generate;
  
  blank_pad : outpad generic map (tech => padtech)
        port map (vga_blank, vgao.blank);
  comp_sync_pad : outpad generic map (tech => padtech)
        port map (vga_sync, vgao.comp_sync);
  vert_sync_pad : outpad generic map (tech => padtech)
        port map (vga_vs, vgao.vsync);
  horiz_sync_pad : outpad generic map (tech => padtech)
        port map (vga_hs, vgao.hsync);
  video_out_r_pad : outpadv generic map (width => 8, tech => padtech)
        port map (vga_r(9 downto 2), vgao.video_out_r);
  video_out_g_pad : outpadv generic map (width => 8, tech => padtech)
        port map (vga_g(9 downto 2), vgao.video_out_g);
  video_out_b_pad : outpadv generic map (width => 8, tech => padtech)
        port map (vga_b(9 downto 2), vgao.video_out_b); 

  vga_r(1 downto 0) <= "00";
  vga_g(1 downto 0) <= "00";
  vga_b(1 downto 0) <= "00";

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

--  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+log2x(CFG_PCI)+CFG_AHB_JTAG) to NAHBMST-1 generate
--    ahbmo(i) <= ahbm_none;
--  end generate;
--  nam2 : if CFG_PCI > 1 generate
--    ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+log2x(CFG_PCI)-1) <= ahbm_none;
--  end generate;
--  nap0 : for i in 11 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
--  apbo(6) <= apb_none;

-----------------------------------------------------------------------
---  Test report module  ----------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off

  test0 : ahbrep generic map (hindex => 7, haddr => 16#200#)
   port map (rstn, clkm, ahbsi, ahbso(7));

-- pragma translate_on
-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => "LEON3 Altera DE2-EP2C35 Demonstration design",
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
