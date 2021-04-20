//
// Generated by Bluespec Compiler (build 16071eec)
//
//
// Ports:
// Name                         I/O  size props
// tx_get                         O   111
// RDY_tx_get                     O     1
// RDY_rx_put                     O     1 reg
// m_command                      I     3
// verbose                        I     1
// CLK                            I     1 clock
// RST_N                          I     1 reset
// rx_put                         I    45 reg
// EN_rx_put                      I     1
// EN_tx_get                      I     1
//
// Combinational paths from inputs to outputs:
//   m_command -> tx_get
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkTLM2Source(m_command,
		    verbose,
		    CLK,
		    RST_N,

		    EN_tx_get,
		    tx_get,
		    RDY_tx_get,

		    rx_put,
		    EN_rx_put,
		    RDY_rx_put);
  input  [2 : 0] m_command;
  input  verbose;
  input  CLK;
  input  RST_N;

  // actionvalue method tx_get
  input  EN_tx_get;
  output [110 : 0] tx_get;
  output RDY_tx_get;

  // action method rx_put
  input  [44 : 0] rx_put;
  input  EN_rx_put;
  output RDY_rx_put;

  // signals for module outputs
  wire [110 : 0] tx_get;
  wire RDY_rx_put, RDY_tx_get;

  // register gen_b_size_gen_initialized
  reg gen_b_size_gen_initialized;
  wire gen_b_size_gen_initialized$D_IN, gen_b_size_gen_initialized$EN;

  // register gen_burst_length_gen_initialized
  reg gen_burst_length_gen_initialized;
  wire gen_burst_length_gen_initialized$D_IN,
       gen_burst_length_gen_initialized$EN;

  // register gen_burst_mode_gen_initialized
  reg gen_burst_mode_gen_initialized;
  wire gen_burst_mode_gen_initialized$D_IN, gen_burst_mode_gen_initialized$EN;

  // register gen_command_gen_initialized
  reg gen_command_gen_initialized;
  wire gen_command_gen_initialized$D_IN, gen_command_gen_initialized$EN;

  // register gen_count
  reg [7 : 0] gen_count;
  wire [7 : 0] gen_count$D_IN;
  wire gen_count$EN;

  // register gen_data_gen_initialized
  reg gen_data_gen_initialized;
  wire gen_data_gen_initialized$D_IN, gen_data_gen_initialized$EN;

  // register gen_descriptor_gen_initialized
  reg gen_descriptor_gen_initialized;
  wire gen_descriptor_gen_initialized$D_IN, gen_descriptor_gen_initialized$EN;

  // register gen_id
  reg [3 : 0] gen_id;
  reg [3 : 0] gen_id$D_IN;
  wire gen_id$EN;

  // register gen_log_wrap_gen_initialized
  reg gen_log_wrap_gen_initialized;
  wire gen_log_wrap_gen_initialized$D_IN, gen_log_wrap_gen_initialized$EN;

  // register initialized
  reg initialized;
  wire initialized$D_IN, initialized$EN;

  // ports of submodule gen_b_size_gen
  wire [2 : 0] gen_b_size_gen$OUT;
  wire gen_b_size_gen$EN;

  // ports of submodule gen_burst_length_gen
  wire [7 : 0] gen_burst_length_gen$OUT;
  wire gen_burst_length_gen$EN;

  // ports of submodule gen_burst_mode_gen
  wire [1 : 0] gen_burst_mode_gen$OUT;
  wire gen_burst_mode_gen$EN;

  // ports of submodule gen_command_gen
  wire [1 : 0] gen_command_gen$OUT;
  wire gen_command_gen$EN;

  // ports of submodule gen_data_gen
  wire [41 : 0] gen_data_gen$OUT;
  wire gen_data_gen$EN;

  // ports of submodule gen_descriptor_gen
  wire [109 : 0] gen_descriptor_gen$OUT;
  wire gen_descriptor_gen$EN;

  // ports of submodule gen_log_wrap_gen
  wire [1 : 0] gen_log_wrap_gen$OUT;
  wire gen_log_wrap_gen$EN;

  // ports of submodule response_fifo
  wire [44 : 0] response_fifo$D_IN, response_fifo$D_OUT;
  wire response_fifo$CLR,
       response_fifo$DEQ,
       response_fifo$EMPTY_N,
       response_fifo$ENQ,
       response_fifo$FULL_N;

  // rule scheduling signals
  wire CAN_FIRE_RL_gen_b_size_gen_every,
       CAN_FIRE_RL_gen_burst_length_gen_every,
       CAN_FIRE_RL_gen_burst_mode_gen_every,
       CAN_FIRE_RL_gen_command_gen_every,
       CAN_FIRE_RL_gen_data_gen_every,
       CAN_FIRE_RL_gen_descriptor_gen_every,
       CAN_FIRE_RL_gen_log_wrap_gen_every,
       CAN_FIRE_RL_grab_responses,
       CAN_FIRE_RL_start,
       CAN_FIRE_rx_put,
       CAN_FIRE_tx_get,
       WILL_FIRE_RL_gen_b_size_gen_every,
       WILL_FIRE_RL_gen_burst_length_gen_every,
       WILL_FIRE_RL_gen_burst_mode_gen_every,
       WILL_FIRE_RL_gen_command_gen_every,
       WILL_FIRE_RL_gen_data_gen_every,
       WILL_FIRE_RL_gen_descriptor_gen_every,
       WILL_FIRE_RL_gen_log_wrap_gen_every,
       WILL_FIRE_RL_grab_responses,
       WILL_FIRE_RL_start,
       WILL_FIRE_rx_put,
       WILL_FIRE_tx_get;

  // declarations used by system tasks
  // synopsys translate_off
  reg [63 : 0] v__h3506;
  reg [63 : 0] v__h2308;
  // synopsys translate_on

  // remaining internal signals
  wire [109 : 0] IF_gen_count_5_EQ_0_6_THEN_IF_m_command_BIT_2__ETC___d294;
  wire [31 : 0] _theResult___addr__h3323,
		_theResult___data__h3326,
		addr__h2805,
		y__h4039;
  wire [7 : 0] IF_IF_m_command_BIT_2_7_THEN_m_command_BITS_1__ETC___d105,
	       IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104;
  wire [3 : 0] IF_NOT_IF_gen_burst_mode_gen_next_EQ_1_01_THEN_ETC___d278,
	       gen_id_09_PLUS_1___d110,
	       mask__h4022,
	       x__h3365,
	       x__h4037;
  wire [1 : 0] x__h3007;
  wire verbose_AND_NOT_gen_burst_mode_gen_next_EQ_0_4_ETC___d209,
       verbose_AND_gen_burst_mode_gen_next_EQ_0_48_AN_ETC___d257,
       verbose_AND_gen_burst_mode_gen_next_EQ_2_51_AN_ETC___d233;

  // actionvalue method tx_get
  assign tx_get =
	     { gen_count != 8'd0,
	       IF_gen_count_5_EQ_0_6_THEN_IF_m_command_BIT_2__ETC___d294 } ;
  assign RDY_tx_get =
	     (gen_count == 8'd0) ?
	       gen_descriptor_gen_initialized &&
	       gen_command_gen_initialized &&
	       gen_burst_mode_gen_initialized &&
	       gen_b_size_gen_initialized &&
	       gen_burst_length_gen_initialized &&
	       gen_log_wrap_gen_initialized :
	       gen_data_gen_initialized ;
  assign CAN_FIRE_tx_get = RDY_tx_get ;
  assign WILL_FIRE_tx_get = EN_tx_get ;

  // action method rx_put
  assign RDY_rx_put = response_fifo$FULL_N ;
  assign CAN_FIRE_rx_put = response_fifo$FULL_N ;
  assign WILL_FIRE_rx_put = EN_rx_put ;

  // submodule gen_b_size_gen
  ConstrainedRandom #(.width(32'd3),
		      .min(3'd0),
		      .max(3'd2)) gen_b_size_gen(.RST(RST_N),
						 .CLK(CLK),
						 .EN(gen_b_size_gen$EN),
						 .OUT(gen_b_size_gen$OUT));

  // submodule gen_burst_length_gen
  ConstrainedRandom #(.width(32'd8),
		      .min(8'd0),
		      .max(8'd15)) gen_burst_length_gen(.RST(RST_N),
							.CLK(CLK),
							.EN(gen_burst_length_gen$EN),
							.OUT(gen_burst_length_gen$OUT));

  // submodule gen_burst_mode_gen
  ConstrainedRandom #(.width(32'd2),
		      .min(2'd0),
		      .max(2'd1)) gen_burst_mode_gen(.RST(RST_N),
						     .CLK(CLK),
						     .EN(gen_burst_mode_gen$EN),
						     .OUT(gen_burst_mode_gen$OUT));

  // submodule gen_command_gen
  ConstrainedRandom #(.width(32'd2),
		      .min(2'd0),
		      .max(2'd1)) gen_command_gen(.RST(RST_N),
						  .CLK(CLK),
						  .EN(gen_command_gen$EN),
						  .OUT(gen_command_gen$OUT));

  // submodule gen_data_gen
  ConstrainedRandom #(.width(32'd42),
		      .min(42'h00000000140),
		      .max(42'h3FFFFFFFFFF)) gen_data_gen(.RST(RST_N),
							  .CLK(CLK),
							  .EN(gen_data_gen$EN),
							  .OUT(gen_data_gen$OUT));

  // submodule gen_descriptor_gen
  ConstrainedRandom #(.width(32'd110),
		      .min(110'd335544320),
		      .max(110'h2FFFFFFFFFFFFFFFFFFFFFFFFFFD)) gen_descriptor_gen(.RST(RST_N),
										  .CLK(CLK),
										  .EN(gen_descriptor_gen$EN),
										  .OUT(gen_descriptor_gen$OUT));

  // submodule gen_log_wrap_gen
  ConstrainedRandom #(.width(32'd2),
		      .min(2'd1),
		      .max(2'd3)) gen_log_wrap_gen(.RST(RST_N),
						   .CLK(CLK),
						   .EN(gen_log_wrap_gen$EN),
						   .OUT(gen_log_wrap_gen$OUT));

  // submodule response_fifo
  FIFO2 #(.width(32'd45), .guarded(32'd1)) response_fifo(.RST(RST_N),
							 .CLK(CLK),
							 .D_IN(response_fifo$D_IN),
							 .ENQ(response_fifo$ENQ),
							 .DEQ(response_fifo$DEQ),
							 .CLR(response_fifo$CLR),
							 .D_OUT(response_fifo$D_OUT),
							 .FULL_N(response_fifo$FULL_N),
							 .EMPTY_N(response_fifo$EMPTY_N));

  // rule RL_grab_responses
  assign CAN_FIRE_RL_grab_responses = response_fifo$EMPTY_N ;
  assign WILL_FIRE_RL_grab_responses = response_fifo$EMPTY_N ;

  // rule RL_gen_descriptor_gen_every
  assign CAN_FIRE_RL_gen_descriptor_gen_every =
	     !gen_descriptor_gen_initialized ;
  assign WILL_FIRE_RL_gen_descriptor_gen_every =
	     CAN_FIRE_RL_gen_descriptor_gen_every && !EN_tx_get ;

  // rule RL_gen_command_gen_every
  assign CAN_FIRE_RL_gen_command_gen_every = !gen_command_gen_initialized ;
  assign WILL_FIRE_RL_gen_command_gen_every =
	     CAN_FIRE_RL_gen_command_gen_every && !EN_tx_get ;

  // rule RL_gen_burst_mode_gen_every
  assign CAN_FIRE_RL_gen_burst_mode_gen_every =
	     !gen_burst_mode_gen_initialized ;
  assign WILL_FIRE_RL_gen_burst_mode_gen_every =
	     CAN_FIRE_RL_gen_burst_mode_gen_every && !EN_tx_get ;

  // rule RL_gen_burst_length_gen_every
  assign CAN_FIRE_RL_gen_burst_length_gen_every =
	     !gen_burst_length_gen_initialized ;
  assign WILL_FIRE_RL_gen_burst_length_gen_every =
	     CAN_FIRE_RL_gen_burst_length_gen_every && !EN_tx_get ;

  // rule RL_gen_log_wrap_gen_every
  assign CAN_FIRE_RL_gen_log_wrap_gen_every = !gen_log_wrap_gen_initialized ;
  assign WILL_FIRE_RL_gen_log_wrap_gen_every =
	     CAN_FIRE_RL_gen_log_wrap_gen_every && !EN_tx_get ;

  // rule RL_gen_data_gen_every
  assign CAN_FIRE_RL_gen_data_gen_every = !gen_data_gen_initialized ;
  assign WILL_FIRE_RL_gen_data_gen_every =
	     CAN_FIRE_RL_gen_data_gen_every && !EN_tx_get ;

  // rule RL_gen_b_size_gen_every
  assign CAN_FIRE_RL_gen_b_size_gen_every = !gen_b_size_gen_initialized ;
  assign WILL_FIRE_RL_gen_b_size_gen_every =
	     CAN_FIRE_RL_gen_b_size_gen_every && !EN_tx_get ;

  // rule RL_start
  assign CAN_FIRE_RL_start = !initialized ;
  assign WILL_FIRE_RL_start = CAN_FIRE_RL_start ;

  // register gen_b_size_gen_initialized
  assign gen_b_size_gen_initialized$D_IN = 1'd1 ;
  assign gen_b_size_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register gen_burst_length_gen_initialized
  assign gen_burst_length_gen_initialized$D_IN = 1'd1 ;
  assign gen_burst_length_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register gen_burst_mode_gen_initialized
  assign gen_burst_mode_gen_initialized$D_IN = 1'd1 ;
  assign gen_burst_mode_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register gen_command_gen_initialized
  assign gen_command_gen_initialized$D_IN = 1'd1 ;
  assign gen_command_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register gen_count
  assign gen_count$D_IN =
	     (gen_count == 8'd0) ?
	       IF_IF_m_command_BIT_2_7_THEN_m_command_BITS_1__ETC___d105 :
	       gen_count - 8'd1 ;
  assign gen_count$EN = EN_tx_get ;

  // register gen_data_gen_initialized
  assign gen_data_gen_initialized$D_IN = 1'd1 ;
  assign gen_data_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register gen_descriptor_gen_initialized
  assign gen_descriptor_gen_initialized$D_IN = 1'd1 ;
  assign gen_descriptor_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register gen_id
  always@(gen_count or gen_id or x__h3365 or gen_id_09_PLUS_1___d110)
  begin
    case (gen_count)
      8'd0: gen_id$D_IN = x__h3365;
      8'd1: gen_id$D_IN = gen_id_09_PLUS_1___d110;
      default: gen_id$D_IN = gen_id;
    endcase
  end
  assign gen_id$EN = EN_tx_get ;

  // register gen_log_wrap_gen_initialized
  assign gen_log_wrap_gen_initialized$D_IN = 1'd1 ;
  assign gen_log_wrap_gen_initialized$EN = CAN_FIRE_RL_start ;

  // register initialized
  assign initialized$D_IN = 1'd1 ;
  assign initialized$EN = CAN_FIRE_RL_start ;

  // submodule gen_b_size_gen
  assign gen_b_size_gen$EN =
	     EN_tx_get && gen_count == 8'd0 ||
	     WILL_FIRE_RL_gen_b_size_gen_every ;

  // submodule gen_burst_length_gen
  assign gen_burst_length_gen$EN =
	     EN_tx_get && gen_count == 8'd0 &&
	     gen_burst_mode_gen$OUT != 2'd1 ||
	     WILL_FIRE_RL_gen_burst_length_gen_every ;

  // submodule gen_burst_mode_gen
  assign gen_burst_mode_gen$EN =
	     EN_tx_get && gen_count == 8'd0 ||
	     WILL_FIRE_RL_gen_burst_mode_gen_every ;

  // submodule gen_command_gen
  assign gen_command_gen$EN =
	     EN_tx_get && gen_count == 8'd0 ||
	     WILL_FIRE_RL_gen_command_gen_every ;

  // submodule gen_data_gen
  assign gen_data_gen$EN =
	     EN_tx_get && gen_count != 8'd0 ||
	     WILL_FIRE_RL_gen_data_gen_every ;

  // submodule gen_descriptor_gen
  assign gen_descriptor_gen$EN =
	     EN_tx_get && gen_count == 8'd0 ||
	     WILL_FIRE_RL_gen_descriptor_gen_every ;

  // submodule gen_log_wrap_gen
  assign gen_log_wrap_gen$EN =
	     EN_tx_get && gen_count == 8'd0 &&
	     gen_burst_mode_gen$OUT == 2'd1 ||
	     WILL_FIRE_RL_gen_log_wrap_gen_every ;

  // submodule response_fifo
  assign response_fifo$D_IN = rx_put ;
  assign response_fifo$ENQ = EN_rx_put ;
  assign response_fifo$DEQ = response_fifo$EMPTY_N ;
  assign response_fifo$CLR = 1'b0 ;

  // remaining internal signals
  assign IF_IF_m_command_BIT_2_7_THEN_m_command_BITS_1__ETC___d105 =
	     (x__h3007 == 2'd0) ?
	       8'd0 :
	       IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104 ;
  assign IF_NOT_IF_gen_burst_mode_gen_next_EQ_1_01_THEN_ETC___d278 =
	     (IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104 !=
	      8'd0 ||
	      x__h3007 != 2'd1) ?
	       4'hA :
	       mask__h4022 << _theResult___addr__h3323[1:0] ;
  assign IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104 =
	     (gen_burst_mode_gen$OUT == 2'd1) ?
	       (8'd2 << gen_log_wrap_gen$OUT) - 8'd1 :
	       gen_burst_length_gen$OUT ;
  assign IF_gen_count_5_EQ_0_6_THEN_IF_m_command_BIT_2__ETC___d294 =
	     (gen_count == 8'd0) ?
	       { x__h3007,
		 2'd0,
		 _theResult___addr__h3323,
		 gen_descriptor_gen$OUT[73:70],
		 _theResult___data__h3326,
		 IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104,
		 IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104 ==
		 8'd0 &&
		 x__h3007 == 2'd1,
		 IF_NOT_IF_gen_burst_mode_gen_next_EQ_1_01_THEN_ETC___d278,
		 gen_burst_mode_gen$OUT,
		 gen_b_size_gen$OUT,
		 gen_descriptor_gen$OUT[19:14],
		 gen_id,
		 gen_descriptor_gen$OUT[9:0] } :
	       { 68'hAAAAAAAAAAAAAAAAA,
		 gen_data_gen$OUT[41:9],
		 gen_data_gen$OUT[9] ? gen_data_gen$OUT[8:5] : 4'hA,
		 gen_id,
		 gen_data_gen$OUT[0] } ;
  assign _theResult___addr__h3323 = addr__h2805 << gen_b_size_gen$OUT ;
  assign _theResult___data__h3326 =
	     (x__h3007 == 2'd0) ? 32'd0 : gen_descriptor_gen$OUT[69:38] ;
  assign addr__h2805 = gen_descriptor_gen$OUT[105:74] >> gen_b_size_gen$OUT ;
  assign gen_id_09_PLUS_1___d110 = gen_id + 4'd1 ;
  assign mask__h4022 = ~x__h4037 ;
  assign verbose_AND_NOT_gen_burst_mode_gen_next_EQ_0_4_ETC___d209 =
	     verbose && gen_burst_mode_gen$OUT != 2'd0 &&
	     gen_burst_mode_gen$OUT != 2'd2 &&
	     gen_b_size_gen$OUT != 3'd0 &&
	     gen_b_size_gen$OUT != 3'd1 &&
	     gen_b_size_gen$OUT != 3'd2 &&
	     gen_b_size_gen$OUT != 3'd3 &&
	     gen_b_size_gen$OUT != 3'd4 &&
	     gen_b_size_gen$OUT != 3'd5 &&
	     gen_b_size_gen$OUT != 3'd6 ;
  assign verbose_AND_gen_burst_mode_gen_next_EQ_0_48_AN_ETC___d257 =
	     verbose && gen_burst_mode_gen$OUT == 2'd0 &&
	     gen_b_size_gen$OUT != 3'd0 &&
	     gen_b_size_gen$OUT != 3'd1 &&
	     gen_b_size_gen$OUT != 3'd2 &&
	     gen_b_size_gen$OUT != 3'd3 &&
	     gen_b_size_gen$OUT != 3'd4 &&
	     gen_b_size_gen$OUT != 3'd5 &&
	     gen_b_size_gen$OUT != 3'd6 ;
  assign verbose_AND_gen_burst_mode_gen_next_EQ_2_51_AN_ETC___d233 =
	     verbose && gen_burst_mode_gen$OUT == 2'd2 &&
	     gen_b_size_gen$OUT != 3'd0 &&
	     gen_b_size_gen$OUT != 3'd1 &&
	     gen_b_size_gen$OUT != 3'd2 &&
	     gen_b_size_gen$OUT != 3'd3 &&
	     gen_b_size_gen$OUT != 3'd4 &&
	     gen_b_size_gen$OUT != 3'd5 &&
	     gen_b_size_gen$OUT != 3'd6 ;
  assign x__h3007 = m_command[2] ? m_command[1:0] : gen_command_gen$OUT ;
  assign x__h3365 =
	     (IF_IF_m_command_BIT_2_7_THEN_m_command_BITS_1__ETC___d105 ==
	      8'd0) ?
	       gen_id_09_PLUS_1___d110 :
	       gen_id ;
  assign x__h4037 = 4'd15 << y__h4039 ;
  assign y__h4039 = 32'd1 << gen_b_size_gen$OUT ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        gen_b_size_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	gen_burst_length_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	gen_burst_mode_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	gen_command_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	gen_count <= `BSV_ASSIGNMENT_DELAY 8'd0;
	gen_data_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	gen_descriptor_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	gen_id <= `BSV_ASSIGNMENT_DELAY 4'd0;
	gen_log_wrap_gen_initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
	initialized <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (gen_b_size_gen_initialized$EN)
	  gen_b_size_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_b_size_gen_initialized$D_IN;
	if (gen_burst_length_gen_initialized$EN)
	  gen_burst_length_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_burst_length_gen_initialized$D_IN;
	if (gen_burst_mode_gen_initialized$EN)
	  gen_burst_mode_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_burst_mode_gen_initialized$D_IN;
	if (gen_command_gen_initialized$EN)
	  gen_command_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_command_gen_initialized$D_IN;
	if (gen_count$EN) gen_count <= `BSV_ASSIGNMENT_DELAY gen_count$D_IN;
	if (gen_data_gen_initialized$EN)
	  gen_data_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_data_gen_initialized$D_IN;
	if (gen_descriptor_gen_initialized$EN)
	  gen_descriptor_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_descriptor_gen_initialized$D_IN;
	if (gen_id$EN) gen_id <= `BSV_ASSIGNMENT_DELAY gen_id$D_IN;
	if (gen_log_wrap_gen_initialized$EN)
	  gen_log_wrap_gen_initialized <= `BSV_ASSIGNMENT_DELAY
	      gen_log_wrap_gen_initialized$D_IN;
	if (initialized$EN)
	  initialized <= `BSV_ASSIGNMENT_DELAY initialized$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    gen_b_size_gen_initialized = 1'h0;
    gen_burst_length_gen_initialized = 1'h0;
    gen_burst_mode_gen_initialized = 1'h0;
    gen_command_gen_initialized = 1'h0;
    gen_count = 8'hAA;
    gen_data_gen_initialized = 1'h0;
    gen_descriptor_gen_initialized = 1'h0;
    gen_id = 4'hA;
    gen_log_wrap_gen_initialized = 1'h0;
    initialized = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose)
	begin
	  v__h3506 = $time;
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose)
	$write("(%0d) Request is: ", v__h3506);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose)
	$write("<TDESC [%0d] ", gen_id);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose && x__h3007 == 2'd0)
	$write("READ ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose && x__h3007 == 2'd1)
	$write("WRITE");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose && x__h3007 != 2'd0 &&
	  x__h3007 != 2'd1)
	$write("UNKNOWN");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose) $write(" ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_descriptor_gen$OUT[15:14] == 2'd0)
	$write("NORMAL   ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_descriptor_gen$OUT[15:14] == 2'd1)
	$write("EXCLUSIVE");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_descriptor_gen$OUT[15:14] == 2'd2)
	$write("LOCKED   ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_descriptor_gen$OUT[15:14] != 2'd0 &&
	  gen_descriptor_gen$OUT[15:14] != 2'd1 &&
	  gen_descriptor_gen$OUT[15:14] != 2'd2)
	$write("RESERVED ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose) $write(" ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0)
	$write("INCR ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2)
	$write("CNST ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2)
	$write("WRAP ");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd0)
	$write("BITS8");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd1)
	$write("BITS16");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd2)
	$write("BITS32");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd3)
	$write("BITS64");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd4)
	$write("BITS128");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd5)
	$write("BITS256");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2 &&
	  gen_b_size_gen$OUT == 3'd6)
	$write("BITS512");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 &&
	  verbose_AND_NOT_gen_burst_mode_gen_next_EQ_0_4_ETC___d209)
	$write("BITS1024");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd0)
	$write("BITS8");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd1)
	$write("BITS16");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd2)
	$write("BITS32");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd3)
	$write("BITS64");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd4)
	$write("BITS128");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd5)
	$write("BITS256");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd2 &&
	  gen_b_size_gen$OUT == 3'd6)
	$write("BITS512");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 &&
	  verbose_AND_gen_burst_mode_gen_next_EQ_2_51_AN_ETC___d233)
	$write("BITS1024");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0 &&
	  gen_burst_mode_gen$OUT != 2'd2)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd0)
	$write("BITS8");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd1)
	$write("BITS16");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd2)
	$write("BITS32");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd3)
	$write("BITS64");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd4)
	$write("BITS128");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd5)
	$write("BITS256");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT == 2'd0 &&
	  gen_b_size_gen$OUT == 3'd6)
	$write("BITS512");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 &&
	  verbose_AND_gen_burst_mode_gen_next_EQ_0_48_AN_ETC___d257)
	$write("BITS1024");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose &&
	  gen_burst_mode_gen$OUT != 2'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose)
	$write(" (%0d)",
	       { 1'b0,
		 IF_gen_burst_mode_gen_next_EQ_1_01_THEN_2_SL_g_ETC___d104 } +
	       9'd1);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose)
	$write(" A:%h", _theResult___addr__h3323);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose)
	$write(" D:%h>", _theResult___data__h3326);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_tx_get && gen_count == 8'd0 && verbose) $write("\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose)
	begin
	  v__h2308 = $time;
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose)
	$write("(%0d) Response is: ", v__h2308);
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose)
	$write("<TRESP [%0d] ", response_fifo$D_OUT[4:1]);
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[44:43] == 2'd0)
	$write("READ ");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[44:43] == 2'd1)
	$write("WRITE");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[44:43] != 2'd0 &&
	  response_fifo$D_OUT[44:43] != 2'd1)
	$write("UNKNOWN");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose) $write(" ");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd0)
	$write("SUCCESS");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1)
	$write("ERROR  ");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd2)
	$write("EXOKAY ");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] != 2'd0 &&
	  response_fifo$D_OUT[10:9] != 2'd1 &&
	  response_fifo$D_OUT[10:9] != 2'd2)
	$write("UNKNOWN");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd0)
	$write("NONE");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd1)
	$write("SPLIT_CONTINUE");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd2)
	$write("RETRY");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd3)
	$write("SPLIT");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd4)
	$write("RW_ONLY");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd5)
	$write("UNMAPPED");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] == 3'd6)
	$write("SLVERR");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] == 2'd1 &&
	  response_fifo$D_OUT[13:11] != 3'd0 &&
	  response_fifo$D_OUT[13:11] != 3'd1 &&
	  response_fifo$D_OUT[13:11] != 3'd2 &&
	  response_fifo$D_OUT[13:11] != 3'd3 &&
	  response_fifo$D_OUT[13:11] != 3'd4 &&
	  response_fifo$D_OUT[13:11] != 3'd5 &&
	  response_fifo$D_OUT[13:11] != 3'd6)
	$write("DECERR");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  response_fifo$D_OUT[10:9] != 2'd1)
	$write(" %h", response_fifo$D_OUT[42:11]);
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose && response_fifo$D_OUT[0] &&
	  response_fifo$D_OUT[44:43] != 2'd1)
	$write(" (LAST)>");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose &&
	  (!response_fifo$D_OUT[0] || response_fifo$D_OUT[44:43] == 2'd1))
	$write(">");
    if (RST_N != `BSV_RESET_VALUE)
      if (response_fifo$EMPTY_N && verbose) $write("\n");
  end
  // synopsys translate_on
endmodule  // mkTLM2Source

