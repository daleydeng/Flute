// Copyright (c) 2021 Bluespec, Inc. All Rights Reserved.
// Author: Rishiyur S. Nikhil

package AWSteria_Core;

// ================================================================
// This package defines a 'mkAWSteria_Core' module containing 
//     - mkCPU (the RISC-V CPU)
//     - mkFabric_1x3
//     - mkNear_Mem_IO_AXI4   (memory-mapped MTIME, MTIMECMP, MSIP etc.)
//     - mkPLIC_16_2_7        (RISC-V platform level interrupt controller or other)
//     - mkDebug_Module       (RISC-V Debug Module, optional: INCLUDE_GDB_CONTROL)
//     - mkTV_Encode          (Tandem-Verification logic, optional: INCLUDE_TANDEM_VERIF)
// and their connecting logic

// ================================================================
// Lib imports

// BSV libs
import Clocks       :: *;

import Vector       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;
import Connectable  :: *;

// ----------------
// BSV additional libs

import Cur_Cycle  :: *;
import GetPut_Aux :: *;
import Semi_FIFOF :: *;

// ----------------
// AXI

import AXI4_Types     :: *;
import AXI4_Fabric    :: *;
import AXI4_Deburster :: *;

// ================================================================
// Project imports

import SoC_Map     :: *;

// ----------------
// AWSteria_Core interface and related defs

import AWSteria_Core_IFC :: *;
import Interrupt_Defs    :: *;
import AXI_Param_Defs    :: *;
import DMI               :: *;
import PC_Trace          :: *;
import TV_Info           :: *;

// ----------------
// RISC-V CPU and related IPs

import CPU_IFC     :: *;
import CPU         :: *;

import Fabric_1x3  :: *;    // CPU MMIO to Fabric, Near_Mem_IO and PLIC

import PLIC        :: *;
import PLIC_16_2_7 :: *;

import DM_TV       :: *;    // Encapsulation of Debug Module and Tandem Verifier Encoder

import Near_Mem_IO_AXI4  :: *;

// se_control_status decoder
import Host_Control_Status :: *;

// ================================================================
// Interface specialization to non-polymorphic type.
// These parameter values are used in AWSteria_RISCV_Virtio
// with Flute or Toooba CPUs.

typedef AWSteria_Core_IFC #(// AXI widths for Mem
			    AXI4_Wd_Id, AXI4_Wd_Addr, AXI4_Wd_Data_A, AXI4_Wd_User,

			    // AXI widths for MMIO
			    AXI4_Wd_Id, AXI4_Wd_Addr, AXI4_Wd_Data_B, AXI4_Wd_User,

			    // AXI widths for DMA port
			    AXI4_Wd_Id, AXI4_Wd_Addr, AXI4_Wd_Data_A, AXI4_Wd_User,

			    // UART, virtio 1,2,3,4
			    N_External_Interrupt_Sources
			    ) AWSteria_Core_IFC_Specialized;

// ================================================================
// The extra clocks are typically slower clocks for some components
// that may need them.

(* synthesize *)
module mkAWSteria_Core #(Reset dm_reset,                // reset for Debug Module
			 Clock b_CLK, Reset b_RST_N,    // extra clock and reset b
			 Clock c_CLK, Reset c_RST_N)    // extra clock and reset c
                       (AWSteria_Core_IFC_Specialized);

   Integer verbosity = 0;    // Normally 0; non-zero for debugging

   // System address map
   SoC_Map_IFC  soc_map  <- mkSoC_Map;

   // The CPU
   CPU_IFC  cpu <- mkCPU;

   // A 1x3 fabric for connecting CPU to {Fabric, Near_Mem_IO, PLIC}
   Fabric_1x3_IFC  fabric_1x3 <- mkFabric_1x3;

   // Near_Mem_IO
   Near_Mem_IO_AXI4_IFC  near_mem_io <- mkNear_Mem_IO_AXI4;

   // PLIC (Platform-Level Interrupt Controller)
   PLIC_IFC_16_2_7  plic <- mkPLIC_16_2_7;

   // AXI4 Deburster in front of core's coherent DMA port
   AXI4_Deburster_IFC #(AXI4_Wd_Id,
			AXI4_Wd_Addr,
			AXI4_Wd_Data_A,
			AXI4_Wd_User)   dma_server_axi4_deburster <- mkAXI4_Deburster_A;
   mkConnection (dma_server_axi4_deburster.to_slave, cpu.dma_server);

   // Control-Status decoder
   Host_Control_Status_IFC host_cs <- mkHost_Control_Status;

   // Debug Module and Tandem Verifier complex
   let dm_tv_param = DM_TV_Param {
      cpu_dma_server:            dma_server_axi4_deburster.from_master,
`ifdef INCLUDE_TANDEM_VERIF
      cpu_trace_data_out:        cpu.trace_data_out,
`else
      cpu_trace_data_out:        getstub,
`endif
      cpu_hart0_put_other_req:   cpu.hart0_put_other_req,
      cpu_hart0_server_run_halt: cpu.hart0_server_run_halt,
      cpu_hart0_csr_mem_server:  cpu.hart0_csr_mem_server,
`ifdef ISA_F
      cpu_hart0_fpr_mem_server:  cpu.hart0_fpr_mem_server,
`endif
      cpu_hart0_gpr_mem_server:	 cpu.hart0_gpr_mem_server,
      cs_cl_hart0_reset:         host_cs.cl_cpu_reset,
      cs_cl_run_halt:            host_cs.cl_run_halt,
      cs_cl_csr_rw:              host_cs.cl_csr_rw};

   DM_TV_IFC dm_tv <- mkDM_TV (dm_tv_param);

   // External interrupts
   Vector #(N_External_Interrupt_Sources, FIFOF #(Bool))
   v_f_ext_intrs <- replicateM (mkFIFOF);

   Vector #(N_External_Interrupt_Sources, Reg #(Bool))
   v_rg_ext_intrs <- replicateM (mkReg (False));

   // Non-maskable interrupts
   FIFOF #(Bool) f_nmi  <- mkFIFOF;
   Reg #(Bool)   rg_nmi <- mkReg (False);

   // TV Info
   FIFOF # (TV_Info) f_tv_info <- mkFIFOF;

   // ================================================================
   // RESET from host-control or from Debug Module

   rule rl_reset_start;
      let running <- dm_tv.cl_reset.request.get;

      cpu.hart0_server_reset.request.put (running);    // CPU
      near_mem_io.server_reset.request.put (?);        // Near_Mem_IO
      plic.server_reset.request.put (?);               // PLIC
      fabric_1x3.reset;                                // Local 1x3 Fabric

      $display ("%0d: core: reset start ...", cur_cycle);
      $display ("        At: %m");
      $display ("            rule rl_reset_start");
   endrule

   rule rl_reset_finish;
      let running <- cpu.hart0_server_reset.response.get;      // CPU
      let rsp2    <- near_mem_io.server_reset.response.get;    // Near_Mem_IO
      let rsp3    <- plic.server_reset.response.get;           // PLIC
      cpu.ma_ddr4_ready;

      near_mem_io.set_addr_map (zeroExtend (soc_map.m_near_mem_io_addr_base),
				zeroExtend (soc_map.m_near_mem_io_addr_lim));

      plic.set_addr_map (zeroExtend (soc_map.m_plic_addr_base),
			 zeroExtend (soc_map.m_plic_addr_lim));

      dm_tv.cl_reset.response.put (running);
      $display ("%0d: core: reset finish. CPU running = ", cur_cycle, fshow (running));
      $display ("        At: %m");
      $display ("            rule rl_reset_finish");
   endrule

   // ================================================================
   // Connect CPU to local 1x3 fabric, and fabric to Near_Mem_IO and PLIC

   // Initiators on the local 1x3 fabric
   mkConnection (cpu.imem_master, fabric_1x3.v_from_masters [cpu_mmio_master_num]);

   // Targets on the local 1x3 fabric
   // default target is taken out directly to Core interface
   mkConnection (fabric_1x3.v_to_slaves [near_mem_io_target_num], near_mem_io.axi4_slave);
   mkConnection (fabric_1x3.v_to_slaves [plic_target_num],        plic.axi4_slave);

   // ================================================================
   // Connect SW, timer and external interrupts to CPU

   rule rl_relay_sw_interrupt;    // from Near_Mem_IO (CLINT)
      Bool x <- near_mem_io.get_sw_interrupt_req.get;
      cpu.software_interrupt_req (x);
      // $display ("%0d: Core.rl_relay_sw_interrupt: %d", cur_cycle, pack (x));
   endrule

   rule rl_relay_timer_interrupt;    // from Near_Mem_IO (CLINT)
      Bool x <- near_mem_io.get_timer_interrupt_req.get;
      cpu.timer_interrupt_req (x);

       // $display ("%0d: %m.rl_relay_timer_interrupt: %d", cur_cycle, pack (x));
   endrule

   rule rl_relay_external_interrupt;    // from PLIC
      Bool meip = plic.v_targets [0].m_eip;
      cpu.m_external_interrupt_req (meip);

      Bool seip = plic.v_targets [1].m_eip;
      cpu.s_external_interrupt_req (seip);

      // $display ("%0d: %m.rl_relay_external_interrupt: %d", ur_cycle, pack (x));
   endrule

   // ================================================================
   // Connect external interrupts to PLIC

   // Register interrupt set/clear requests
   for (Integer j = 0; j < valueOf (N_External_Interrupt_Sources); j = j + 1)
      rule rl_register_interrupt;
	 Bool b <- pop (v_f_ext_intrs [j]);
	 v_rg_ext_intrs [j] <= b;
      endrule

   // Drive PLIC's interrupt lines
   for (Integer j = 0; j < valueOf (N_External_Interrupt_Sources); j = j + 1)
      (* fire_when_enabled, no_implicit_conditions *)
      rule rl_drive_interrupt;
	 plic.v_sources [j].m_interrupt_req (v_rg_ext_intrs [j]);
      endrule

   // Tie-off PLIC's unused interrupts
   for (Integer j = valueOf (N_External_Interrupt_Sources); j < 16; j = j + 1)
      rule rl_drive_no_interrupt;
	 plic.v_sources [j].m_interrupt_req (False);
      endrule

   // ================================================================
   // Non-maskable interrupts (NMI)

   // Register NMI set/clear requests
   rule rl_register_nmi;
      Bool b <- pop (f_nmi);
      rg_nmi <= b;
   endrule

   // Drive CPU's NMI line
   (* fire_when_enabled, no_implicit_conditions *)
   rule rl_drive_nmi;
      cpu.nmi_req (rg_nmi);
   endrule

   // =================================================================
   // PC trace output

   // PC Trace
   FIFOF #(PC_Trace) f_pc_trace               <- mkFIFOF;
   Reg #(Bit #(64))  rg_pc_trace_interval_ctr <- mkReg (0);

   rule rl_pc_trace;
      PC_Trace x <- cpu.g_pc_trace.get;
      match { .pc_trace_on, .pc_trace_interval } = host_cs.mv_pc_trace;

      if (pc_trace_on && (rg_pc_trace_interval_ctr == 0)) begin
	 f_pc_trace.enq (x);
	 rg_pc_trace_interval_ctr <= pc_trace_interval;
      end
      else begin
	 // Discard the sample
	 rg_pc_trace_interval_ctr <= rg_pc_trace_interval_ctr - 1;
      end
   endrule

   // =================================================================
   // Misc CPU control/status

   rule rl_set_verbosity;
      match { .verbosity, .log_delay } <- host_cs.g_verbosity.get;
      cpu.set_verbosity (verbosity, log_delay);
   endrule

   rule rl_watch_thost;
      match { .watch, .tohost_addr } <- host_cs.g_watch_tohost.get;
      cpu.set_watch_tohost (watch, tohost_addr);
   endrule

   rule rl_tohost_value;
      host_cs.ma_tohost_value (cpu.mv_tohost_value);
   endrule

   // ================================================================
   // INTERFACE

   // ----------------------------------------------------------------
   // AXI4 interfaces for memory, MMIO, and DMA
   // Note: DMA may or may not be coherent, depending on internal Core architecture.

   interface AXI4_Master_IFC mem_M  = cpu.mem_master;
   interface AXI4_Master_IFC mmio_M = fabric_1x3.v_to_slaves [default_target_num];
   interface AXI4_Slave_IFC  dma_S  = dm_tv.dma_S;

   // ----------------------------------------------------------------
   // External interrupt sources

   interface v_fi_external_interrupt_reqs = map (to_FIFOF_I, v_f_ext_intrs);

   // ----------------------------------------------------------------
   // Non-maskable interrupt request

   interface fi_nmi = to_FIFOF_I (f_nmi);

   // ----------------------------------------------------------------
   // Trace and Tandem Verification output

   interface fo_pc_trace = to_FIFOF_O (f_pc_trace);
   interface fo_tv_info  = to_FIFOF_O (f_tv_info);

   // ----------------------------------------------------------------
   // Debug Module interfaces

   // DMI (Debug Module Interface) facing remote debugger

   interface Server_DMI se_dmi = dm_tv.se_dmi;

   // Non-Debug-Module Reset (reset "all" except DM)
   // These Bit#(0) values are just tokens for signaling 'reset request' and 'reset done'

   interface cl_ndm_reset = dm_tv.cl_ndm_reset;

   // ----------------------------------------------------------------
   // Misc. control and status

   interface Server_Semi_FIFOF se_control_status = host_cs.se_control_status;
endmodule

// ****************************************************************
// Specialization of parameterized AXI4 Debursters for this SoC.

(* synthesize *)
module mkAXI4_Deburster_A (AXI4_Deburster_IFC #(AXI4_Wd_Id,
						AXI4_Wd_Addr,
						AXI4_Wd_Data_A,
						AXI4_Wd_User));
   let m <- mkAXI4_Deburster;
   return m;
endmodule

// ================================================================

endpackage