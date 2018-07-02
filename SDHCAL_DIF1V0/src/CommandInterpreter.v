`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Wang Yu
//
// Create Date: 2018/06/26 11:01:14
// Design Name: SDHCAL DIF 1V0
// Module Name: CommandInterpreter
// Project Name: SDHCAL DIF 1V0
// Target Devices: XC7A100TFGG484-2l
// Tool Versions: Vivado 2018.1
// Description: The command together with its enable signal (CommandWord and
// CommandWordEn) store in an internal FIFO. When the FIFO is not empty, the
// command is readout and interpreted.
// The command must be 16 bits and organized in following fomat
//    WXYZ: W, X, Y, Z is the hexadecimal number
//        WX: Address
//        Y:  Sub-address
//        Z:  Data (If necessary, Z can be seperated. But not
//        recommanded)
//  Call the CommandDecoder module to get the command.
//  Use as CommandDecoder instname (/*autoinst*/);
//  CommandDecoder
//  #(
//    .COMMAND_WIDTH(2'b0),
//    .COMMAND_ADDRESS(12'hFFF)
//  )
//  instname(
//    .Clk(Clk),
//    .reset_n(reset_n),
//    .CommandFifoReadEn(CommandFifoReadEn),
//    .COMMAND_WORD(COMMAND_WORD),
//    .DefaultValue(DefaultValue),
//    .CommandOut(CommandOut)
//  );
//
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - autoinst added 20180702
// Revision 0.03 - AutoInst
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module CommandInterpreter(
  input Clk,
  input IFCLK,
  input reset_n,
  // USB interface
  input CommandWordEn,
  input [15:0] CommandWord,
  //--- Command ---//
  output AcquisitionStartStop,
  output ResetDataFifo,
  output [3:0] AsicChainSelect, // Considering the expand board in the future,
  //  the max ASIC chain is set to 16
  //*** Microorc Parameter
  // MICROROC slow control parameter
  output reg MicrorocSlowControlOrReadScopeSelect,
  output reg MicrorocParameterLoadStart,
  output reg [1:0] MicrorocDataoutChannelSelect,
  output reg [1:0] MicrorocTransmitOnChannelSelect,
  // ChipSatbEnable
  output reg MicrorocStartReadoutChannelSelect,
  output reg MicrorocEndReadoutChannelSelect,
  // [1:0] NC
  output reg [1:0] MicrorocInternalRazSignalLength,
  output reg MicrorocCkMux,
  output reg MicrorocLvdsReceiverPPEnable,
  output reg MicrorocExternalRazSignalEnable,
  output reg MicrorocInternalRazSignalEnable,
  output reg MicrorocExternalTriggerEnable,
  output reg MicrorocTriggerNor64OrDirectSelect,
  output reg MicrorocTriggerOutputEnable,
  output reg [2:0] MicrorocTriggerToWriteSelect,
  output reg [9:0] MicrorocDac2Vth,
  output reg [9:0] MicrorocDac1Vth,
  output reg [9:0] MicrorocDac0Vth,
  output reg MicrorocDacEnable,
  output reg MicrorocDacPPEnable,
  output reg MicrorocBandGapEnable,
  output reg MicrorocBandGapPPEnable,
  output reg [7:0] MicrorocChipID,
  output reg [191:0] MicrorocChannelDiscriminatorMask,
  output reg MicrorocLatchedOrDirectOutput,
  output reg MicrorocDiscriminator2PPEnable,
  output reg MicrorocDisriminator1PPEnable,
  output reg MicrorocDiscriminator0PPEnable,
  output reg MicrorocOTAqPPEnable,
  output reg MicrorocOTAqEnable,
  output reg MicrorocDac4bitPPEnable,
  output [255:0] ChannelAdjust,
  output reg [1:0] MicrorocHighGainShaperFeedbackSelect,
  output reg MicrorocShaperOutLowGainOrHighGain,
  output reg MicrorocWidlarPPEnable,
  output reg [1:0] MicrorocLowGainShaperFeedbackSelect,
  output reg MicrorocLowGainShaperPPEnable,
  output reg MicrorocHighGainShaperPPEnable,
  output reg MicrorocGainBoostEnable,
  output reg MicororcPreAmplifierPPEnable,
  output reg [63:0] MicrorocCTestChannel,
  output reg [63:0] MicrorocReadScopeChannel,
  output reg MicrorocReadoutChannelSelect,// To redundancy module
  output reg [1:0] MicrorocExternalRazMode,
  output reg [3:0] MicrorocExternalRazDelayTime,

  // Microroc Control
  output reg MicrorocResetTimeStamp,



  //*** Acquisition Control
  // Mode Select
  output reg [3:0] ModeSelect,
  output reg [1:0] DacSelect,
  // Sweep Dac parameter
  output reg [9:0] StartDac,
  output reg [9:0] EndDac,
  output reg [9:0] DacStep,
  // SCurve Test Port
  output reg SingleOr64Channel,
  output reg CTestOrInput,
  output reg [5:0] SingleTestChannel,
  output reg [15:0] TriggerCountMax,
  output reg [3:0] TriggerDelay,
  output reg SweepTestStartStop,
  output reg UnmaskAllChannel,
  // Count Efficiency
  output reg TriggerEfficiencyOrCountEfficiency,
  output reg [15:0] CounterMax,
  input SweepTestDone,
  input UsbFifoEmpty,
  // Sweep Acq
  output reg [15:0] SweepAcqMaxPackageNumber,
  // Reset Microroc
  output reg ForceMicrorocAcqReset,
  // ADC Control
  output reg AdcStartStop,
  output reg [3:0] AdcStartDelayTime,
  output reg [7:0] AdcDataNumber,
  output reg [1:0] TriggerCoincidence,
  output reg [7:0] HoldDelay,
  output reg [15:0] HoldTime,
  output reg HoldEnable,
  // Slave DAQ
  output reg [15:0] EndHoldTime,
  output reg DaqSelect,
  // LED
  output reg [3:0] LED
  );

  // Command FIFO interface
  wire [15:0] COMMAND_WORD;
  reg CommandFifoReadEn;
  wire CommandFifoEmpty;
  wire FifoWriteResetBusy;
  wire FifoReadResetBusy;
  wire FifoReady;
  assign FifoReady = !FifoReadResetBusy & !FifoReadResetBusy;
  CommandFifo CommandFifo32Depth (
    .rst(!reset_n),                  // input wire rst
    .wr_clk(IFClk),            // input wire wr_clk
    .rd_clk(Clk),            // input wire rd_clk
    .din(CommandWord),                  // input wire [15 : 0] din
    .wr_en(CommandWordEn),              // input wire wr_en
    .rd_en(CommandFifoReadEn),              // input wire rd_en
    .dout(COMMAND_WORD),                // output wire [15 : 0] dout
    .full(),                // output wire full
    .empty(CommandFifoEmpty),              // output wire empty
    .wr_rst_busy(FifoWriteResetBusy),  // output wire wr_rst_busy
    .rd_rst_busy(FifoReadResetBusy)  // output wire rd_rst_busy
    );

  //*** Read command
  localparam Idle = 1'b0;
  localparam READ = 1'b1;
  reg State;
  always @ (posedge Clk, negedge reset_n) begin
    if(~reset_n) begin
      CommandFifoReadEn <= 1'b0;
      State <= Idle;
    end
    else begin
      case (State)
        Idle:begin
          if(CommandFifoEmpty)
            State <= Idle;
          else begin
            CommandFifoReadEn <= 1'b1;
            State <= READ;
          end
        end
        READ:begin
          CommandFifoReadEn <= 1'b0;
          State <= Idle;
        end
        default:State <= Idle;
      endcase
    end
  end

  //*** Microroc Control Parameter
  // Slow Control or Read Scope, default A0A0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(`SlowControlOrReadScopeSelect_CAND)
  )
  SlowControlOrReadScopeSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocSlowControlOrReadScopeSelect)
    );

  // Dataout Channel Select 2bits, Default A0B3
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b1),
    .COMMAND_ADDRESS_AND_DEFAULT(`DataoutChannelSelect_CAND)
  )
  DataoutChannelSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocDataoutChannelSelect)
    );

  // TransmitOn channel select 2bit, default A0C3
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b1),
    .COMMAND_ADDRESS_AND_DEFAULT(`TransmitOnChannelSelect_CAND)
  )
  TransmitOnChannelSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocTransmitOnChannelSelect)
    );

  // StartReadout channel select 1bit, default A0D1
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(`StartReadoutChannelSelect_CAND)
  )
  StartReadoutChannelSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocStartReadoutChannelSelect)
    );

  // EndReadout channel select 1bit, default A0E1
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(`EndReadoutChannelSelect_CAND)
  )
  EndReadoutChannelSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocEndReadoutChannelSelect)
    );

  // InternalRazSignalLenth set 2bits, default A0F3
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b1),
    .COMMAND_ADDRESS_AND_DEFAULT(`InternalRazSignalLength_CAND)
  )
  InternalRazSignalLenth(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocInternalRazSignalLength)
    );

  // CkMux 1bit, default A001
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(`CkMux_CAND)
  )
  CkMux(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocCkMux)
    );

  // ExternalRazSignalEnable 1bit, default A030
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(`ExternalRazSignalEnable_CAND)
  )
  ExternalRazSignalEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocExternalRazSignalEnable)
    );

  // InternalRazSignalEnable 1bit, default A041
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(`InternalRazSignalEnable_CAND)
  )
  InternalRazSignalEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocInternalRazSignalEnable)
    );

  // ExternalTriggerEnable 1bit, default A051
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(ExternalTriggerEnable_CAND)
  )
  ExternalTriggerEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocExternalTriggerEnable)
    );

  // TriggerNor64OrDirectSelect 1bit, default A061
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(TriggerNor64OrDirectSelect_CAND)
  )
  TriggerNor64OrDirectSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(MicrorocTriggerNor64OrDirectSelect)
    );

  // TriggerOutputEnable 1bit, default A071
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerOutputEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // TriggerToWriteSelect 3bits, default A087
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerToWriteSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // Dac2Vth 10bits
  // Dac2Vth[3:0], default C060
  // Dac2Vth[7:4], default C070
  // Dac2Vth[9:8], default C080
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac2Vth3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac2Vth7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac2Vth9to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // Dac1Vth 10bits
  // Dac1Vth[3:0], default C030
  // Dac1Vth[7:4], default C040
  // Dac1Vth[9:8], default C050
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac1Vth3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac1Vth7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac1Vth9to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // Dac0Vth 10bits
  // Dac0Vth[3:0], default C000
  // Dac0Vth[7:4], default C010
  // Dac0Vth[9:8], default C020
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac0Vth3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac0Vth7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac0Vth9to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // DacEnable 1bit, default A091
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  DacEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // BandGapEnable 1bit, default A1A1
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  BandGapEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ChipID 8bits
  // ChipID[3:0], default A1B1
  // ChipID[7:0], default A1CA
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ChipID3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ChipID7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  //////////////////////////////////////////////////////////////
  // ChannelDiscriminatorMask
  //
  // Each discriminator of all channels can be masked by set the
  // corresponding bit to 0. The
  // 1. Set the mask channel
  //    MaskChannel[3:0], A2AX
  //    MaskChannel[5:4], A2BX
  // 2. Set the disciminator mask parameter
  //    3'b000: mask discri0,1,2
  //    3'b001: mask discri1,2
  //    3'b010: mask discri0,2
  //    3'b011: mask discri2
  //    3'b100: mask discri0,1
  //    3'b101: mask discri1
  //    3'b110: mask discri0
  //    3'b111: no mask
  //
  //    DiscriMask[2:0], A2CX
  // 3. Set Mask or Unmask all channel
  //    Maks A2D1
  //    Unmask A2D2
  //    MaskClear A0D3
  //
  ////////////////////////////////////////////////////////////////
  reg [7:0] MaskShift;
  reg [5:0] MaskChannel;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  MaskChannel3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  MaskChannel5to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  reg [2:0] DiscriMask;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  DiscriMaskSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  reg [1:0] MaskOrUnmask;
  // Pulse signal
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  MaskSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  always @ (posedge Clk or reset_n) begin
    if(~reset_n)
      MaskShift <= 8'b0;
    else
      MaskShift <= MaskChannel + MaskChannel + MaskChannel;
  end

  reg [191:0] SingleChannelMask;
  reg [1:0] MaskState;
  localparam [1:0]  IDLE       = 2'b00,
                    MASK       = 2'b01,
                    UNMASK     = 2'b10,
                    MASK_CLEAR = 2'b11;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n) begin
      MaskState <= IDLE;
      SingleChannelMask <= {192{1'b1}};
      MicrorocChannelDiscriminatorMask <= {192{1'b1}};
    end
    else begin
      case(MaskState)
        IDLE:begin
          if(MaskOrUnmask == A2C0) begin
            MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask;
            MaskState <= IDLE;
          end
          else if(MaskOrUnmask == A2C1) begin
            SingleChannelMask <= {{189{1'b1}},DiscriMask} << MaskShift | {DiscriMask,{189{1'b1}}} >> (192- MaskShift - 3);
            MaskState <= MASK;
          end
          else if(MaskOrUnmask == A2C2) begin
            SingleChannelMask <= {189'b0, 3'b111} << MaskShift;
            MaskState <= UNMASK;
          end
          else begin
            MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask;
            MaskState <= IDLE;
          end
        end
        MASK:begin
          MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask & SingleChannelMask;
          MaskState <= IDLE;
        end
        UNMASK:begin
          MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask | SingleChannelMask;
          MaskState <= IDLE;
        end
        MASK_CLEAR:begin
          MicrorocChannelDiscriminatorMask <= {192{1'b1}};
        end
        default:begin
          MicrorocChannelDiscriminatorMask <= MicrorocChannelDiscriminatorMask;
          MaskState <= IDLE;
        end
      endcase
    end
  end

  // LatchedOrDirectOutput 1bit, default A101
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  LatchedOrDirectOutput(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // OTAqEnable 1bit, A111
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  OTAqEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  //4-bit DAC set. 4-bit DAC is used to adjust the Vref_hg,
  //Vref_hg = Vref+sh - 728*DAC_Code(uV), while Vref_sh = 2.2V
  //The MSB of the 4-bit DAC burst out first
  reg [3:0] Dac4bit[0:63];
  always @ (posedge clk or negedge reset_n)begin
    if(~reset_n) begin
      Dac4bit[0] <= 4'b0;
      Dac4bit[1] <= 4'b0;
      Dac4bit[2] <= 4'b0;
      Dac4bit[3] <= 4'b0;
      Dac4bit[4] <= 4'b0;
      Dac4bit[5] <= 4'b0;
      Dac4bit[6] <= 4'b0;
      Dac4bit[7] <= 4'b0;
      Dac4bit[8] <= 4'b0;
      Dac4bit[9] <= 4'b0;
      Dac4bit[10] <= 4'b0;
      Dac4bit[11] <= 4'b0;
      Dac4bit[12] <= 4'b0;
      Dac4bit[13] <= 4'b0;
      Dac4bit[14] <= 4'b0;
      Dac4bit[15] <= 4'b0;
      Dac4bit[16] <= 4'b0;
      Dac4bit[17] <= 4'b0;
      Dac4bit[18] <= 4'b0;
      Dac4bit[19] <= 4'b0;
      Dac4bit[20] <= 4'b0;
      Dac4bit[21] <= 4'b0;
      Dac4bit[22] <= 4'b0;
      Dac4bit[23] <= 4'b0;
      Dac4bit[24] <= 4'b0;
      Dac4bit[25] <= 4'b0;
      Dac4bit[26] <= 4'b0;
      Dac4bit[27] <= 4'b0;
      Dac4bit[28] <= 4'b0;
      Dac4bit[29] <= 4'b0;
      Dac4bit[30] <= 4'b0;
      Dac4bit[31] <= 4'b0;
      Dac4bit[32] <= 4'b0;
      Dac4bit[33] <= 4'b0;
      Dac4bit[34] <= 4'b0;
      Dac4bit[35] <= 4'b0;
      Dac4bit[36] <= 4'b0;
      Dac4bit[37] <= 4'b0;
      Dac4bit[38] <= 4'b0;
      Dac4bit[39] <= 4'b0;
      Dac4bit[40] <= 4'b0;
      Dac4bit[41] <= 4'b0;
      Dac4bit[42] <= 4'b0;
      Dac4bit[43] <= 4'b0;
      Dac4bit[44] <= 4'b0;
      Dac4bit[45] <= 4'b0;
      Dac4bit[46] <= 4'b0;
      Dac4bit[47] <= 4'b0;
      Dac4bit[48] <= 4'b0;
      Dac4bit[49] <= 4'b0;
      Dac4bit[50] <= 4'b0;
      Dac4bit[51] <= 4'b0;
      Dac4bit[52] <= 4'b0;
      Dac4bit[53] <= 4'b0;
      Dac4bit[54] <= 4'b0;
      Dac4bit[55] <= 4'b0;
      Dac4bit[56] <= 4'b0;
      Dac4bit[57] <= 4'b0;
      Dac4bit[58] <= 4'b0;
      Dac4bit[59] <= 4'b0;
      Dac4bit[60] <= 4'b0;
      Dac4bit[61] <= 4'b0;
      Dac4bit[62] <= 4'b0;
      Dac4bit[63] <= 4'b0;
    end
    else if(fifo_rden && (USB_COMMAND[15:8] == 8'hCC
      || USB_COMMAND[15:8] == 8'hCD
      || USB_COMMAND[15:8] == 8'hCE
      || USB_COMMAND[15:8] == 8'hCF))
      Dac4bit[USB_COMMAND[11:4] - 8'd192] <= USB_COMMAND[3:0];
    else begin
      Dac4bit[0] <= Dac4bit[0];
      Dac4bit[1] <= Dac4bit[1];
      Dac4bit[2] <= Dac4bit[2];
      Dac4bit[3] <= Dac4bit[3];
      Dac4bit[4] <= Dac4bit[4];
      Dac4bit[5] <= Dac4bit[5];
      Dac4bit[6] <= Dac4bit[6];
      Dac4bit[7] <= Dac4bit[7];
      Dac4bit[8] <= Dac4bit[8];
      Dac4bit[9] <= Dac4bit[9];
      Dac4bit[10] <= Dac4bit[10];
      Dac4bit[11] <= Dac4bit[11];
      Dac4bit[12] <= Dac4bit[12];
      Dac4bit[13] <= Dac4bit[13];
      Dac4bit[14] <= Dac4bit[14];
      Dac4bit[15] <= Dac4bit[15];
      Dac4bit[16] <= Dac4bit[16];
      Dac4bit[17] <= Dac4bit[17];
      Dac4bit[18] <= Dac4bit[18];
      Dac4bit[19] <= Dac4bit[19];
      Dac4bit[20] <= Dac4bit[20];
      Dac4bit[21] <= Dac4bit[21];
      Dac4bit[22] <= Dac4bit[22];
      Dac4bit[23] <= Dac4bit[23];
      Dac4bit[24] <= Dac4bit[24];
      Dac4bit[25] <= Dac4bit[25];
      Dac4bit[26] <= Dac4bit[26];
      Dac4bit[27] <= Dac4bit[27];
      Dac4bit[28] <= Dac4bit[28];
      Dac4bit[29] <= Dac4bit[29];
      Dac4bit[30] <= Dac4bit[30];
      Dac4bit[31] <= Dac4bit[31];
      Dac4bit[32] <= Dac4bit[32];
      Dac4bit[33] <= Dac4bit[33];
      Dac4bit[34] <= Dac4bit[34];
      Dac4bit[35] <= Dac4bit[35];
      Dac4bit[36] <= Dac4bit[36];
      Dac4bit[37] <= Dac4bit[37];
      Dac4bit[38] <= Dac4bit[38];
      Dac4bit[39] <= Dac4bit[39];
      Dac4bit[40] <= Dac4bit[40];
      Dac4bit[41] <= Dac4bit[41];
      Dac4bit[42] <= Dac4bit[42];
      Dac4bit[43] <= Dac4bit[43];
      Dac4bit[44] <= Dac4bit[44];
      Dac4bit[45] <= Dac4bit[45];
      Dac4bit[46] <= Dac4bit[46];
      Dac4bit[47] <= Dac4bit[47];
      Dac4bit[48] <= Dac4bit[48];
      Dac4bit[49] <= Dac4bit[49];
      Dac4bit[50] <= Dac4bit[50];
      Dac4bit[51] <= Dac4bit[51];
      Dac4bit[52] <= Dac4bit[52];
      Dac4bit[53] <= Dac4bit[53];
      Dac4bit[54] <= Dac4bit[54];
      Dac4bit[55] <= Dac4bit[55];
      Dac4bit[56] <= Dac4bit[56];
      Dac4bit[57] <= Dac4bit[57];
      Dac4bit[58] <= Dac4bit[58];
      Dac4bit[59] <= Dac4bit[59];
      Dac4bit[60] <= Dac4bit[60];
      Dac4bit[61] <= Dac4bit[61];
      Dac4bit[62] <= Dac4bit[62];
      Dac4bit[63] <= Dac4bit[63];
      //Dac4bit <= Dac4bit;
    end
  end
  assign ChannelAdjust = {Invert4bit(Dac4bit[63]),
    Invert4bit(Dac4bit[62]),
    Invert4bit(Dac4bit[61]),
    Invert4bit(Dac4bit[60]),
    Invert4bit(Dac4bit[59]),
    Invert4bit(Dac4bit[58]),
    Invert4bit(Dac4bit[57]),
    Invert4bit(Dac4bit[56]),
    Invert4bit(Dac4bit[55]),
    Invert4bit(Dac4bit[54]),
    Invert4bit(Dac4bit[53]),
    Invert4bit(Dac4bit[52]),
    Invert4bit(Dac4bit[51]),
    Invert4bit(Dac4bit[50]),
    Invert4bit(Dac4bit[49]),
    Invert4bit(Dac4bit[48]),
    Invert4bit(Dac4bit[47]),
    Invert4bit(Dac4bit[46]),
    Invert4bit(Dac4bit[45]),
    Invert4bit(Dac4bit[44]),
    Invert4bit(Dac4bit[43]),
    Invert4bit(Dac4bit[42]),
    Invert4bit(Dac4bit[41]),
    Invert4bit(Dac4bit[40]),
    Invert4bit(Dac4bit[39]),
    Invert4bit(Dac4bit[38]),
    Invert4bit(Dac4bit[37]),
    Invert4bit(Dac4bit[36]),
    Invert4bit(Dac4bit[35]),
    Invert4bit(Dac4bit[34]),
    Invert4bit(Dac4bit[33]),
    Invert4bit(Dac4bit[32]),
    Invert4bit(Dac4bit[31]),
    Invert4bit(Dac4bit[30]),
    Invert4bit(Dac4bit[29]),
    Invert4bit(Dac4bit[28]),
    Invert4bit(Dac4bit[27]),
    Invert4bit(Dac4bit[26]),
    Invert4bit(Dac4bit[25]),
    Invert4bit(Dac4bit[24]),
    Invert4bit(Dac4bit[23]),
    Invert4bit(Dac4bit[22]),
    Invert4bit(Dac4bit[21]),
    Invert4bit(Dac4bit[20]),
    Invert4bit(Dac4bit[19]),
    Invert4bit(Dac4bit[18]),
    Invert4bit(Dac4bit[17]),
    Invert4bit(Dac4bit[16]),
    Invert4bit(Dac4bit[15]),
    Invert4bit(Dac4bit[14]),
    Invert4bit(Dac4bit[13]),
    Invert4bit(Dac4bit[12]),
    Invert4bit(Dac4bit[11]),
    Invert4bit(Dac4bit[10]),
    Invert4bit(Dac4bit[9]),
    Invert4bit(Dac4bit[8]),
    Invert4bit(Dac4bit[7]),
    Invert4bit(Dac4bit[6]),
    Invert4bit(Dac4bit[5]),
    Invert4bit(Dac4bit[4]),
    Invert4bit(Dac4bit[3]),
    Invert4bit(Dac4bit[2]),
    Invert4bit(Dac4bit[1]),
    Invert4bit(Dac4bit[0])
  };

  // HighGainShaperFeedbackSelect 2 bits, default A122, invert
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HighGainShaperFeedbackSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ShaperOutLowGainOrHighGain 1bit, default A130
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ShaperOutLowGainOrHighGain(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // LowGainShaperFeedbackSelect 2bits, default A142, invert
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  LowGainShaperFeedbackSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // GainBoostEnable 1bit, default A051
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  GainBoostEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // CTestChannel 64bit, need decode
  // CTestChannel[3:0] default A16X
  // CTestChannel[7:4] default A17X
  reg [7:0] CTestChannel;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CTestChannel3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CTestChannel7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  always @(*) begin
    if(~reset_n)
      MicrorocCTestChannel = 64'b0;
    else begin
      case(CTestChannel)
        8'd0: MicrorocCTestChannel   = 64'h0000_0000_0000_0000;
        8'd1: MicrorocCTestChannel   = 64'h0000_0000_0000_0001;
        8'd2: MicrorocCTestChannel   = 64'h0000_0000_0000_0002;
        8'd3: MicrorocCTestChannel   = 64'h0000_0000_0000_0004;
        8'd4: MicrorocCTestChannel   = 64'h0000_0000_0000_0008;
        8'd5: MicrorocCTestChannel   = 64'h0000_0000_0000_0010;
        8'd6: MicrorocCTestChannel   = 64'h0000_0000_0000_0020;
        8'd7: MicrorocCTestChannel   = 64'h0000_0000_0000_0040;
        8'd8: MicrorocCTestChannel   = 64'h0000_0000_0000_0080;
        8'd9: MicrorocCTestChannel   = 64'h0000_0000_0000_0100;
        8'd10:MicrorocCTestChannel   = 64'h0000_0000_0000_0200;
        8'd11:MicrorocCTestChannel   = 64'h0000_0000_0000_0400;
        8'd12:MicrorocCTestChannel   = 64'h0000_0000_0000_0800;
        8'd13:MicrorocCTestChannel   = 64'h0000_0000_0000_1000;
        8'd14:MicrorocCTestChannel   = 64'h0000_0000_0000_2000;
        8'd15:MicrorocCTestChannel   = 64'h0000_0000_0000_4000;
        8'd16:MicrorocCTestChannel   = 64'h0000_0000_0000_8000;
        8'd17:MicrorocCTestChannel   = 64'h0000_0000_0001_0000;
        8'd18:MicrorocCTestChannel   = 64'h0000_0000_0002_0000;
        8'd19:MicrorocCTestChannel   = 64'h0000_0000_0004_0000;
        8'd20:MicrorocCTestChannel   = 64'h0000_0000_0008_0000;
        8'd21:MicrorocCTestChannel   = 64'h0000_0000_0010_0000;
        8'd22:MicrorocCTestChannel   = 64'h0000_0000_0020_0000;
        8'd23:MicrorocCTestChannel   = 64'h0000_0000_0040_0000;
        8'd24:MicrorocCTestChannel   = 64'h0000_0000_0080_0000;
        8'd25:MicrorocCTestChannel   = 64'h0000_0000_0100_0000;
        8'd26:MicrorocCTestChannel   = 64'h0000_0000_0200_0000;
        8'd27:MicrorocCTestChannel   = 64'h0000_0000_0400_0000;
        8'd28:MicrorocCTestChannel   = 64'h0000_0000_0800_0000;
        8'd29:MicrorocCTestChannel   = 64'h0000_0000_1000_0000;
        8'd30:MicrorocCTestChannel   = 64'h0000_0000_2000_0000;
        8'd31:MicrorocCTestChannel   = 64'h0000_0000_4000_0000;
        8'd32:MicrorocCTestChannel   = 64'h0000_0000_8000_0000;
        8'd33:MicrorocCTestChannel   = 64'h0000_0001_0000_0000;
        8'd34:MicrorocCTestChannel   = 64'h0000_0002_0000_0000;
        8'd35:MicrorocCTestChannel   = 64'h0000_0004_0000_0000;
        8'd36:MicrorocCTestChannel   = 64'h0000_0008_0000_0000;
        8'd37:MicrorocCTestChannel   = 64'h0000_0010_0000_0000;
        8'd38:MicrorocCTestChannel   = 64'h0000_0020_0000_0000;
        8'd39:MicrorocCTestChannel   = 64'h0000_0040_0000_0000;
        8'd40:MicrorocCTestChannel   = 64'h0000_0080_0000_0000;
        8'd41:MicrorocCTestChannel   = 64'h0000_0100_0000_0000;
        8'd42:MicrorocCTestChannel   = 64'h0000_0200_0000_0000;
        8'd43:MicrorocCTestChannel   = 64'h0000_0400_0000_0000;
        8'd44:MicrorocCTestChannel   = 64'h0000_0800_0000_0000;
        8'd45:MicrorocCTestChannel   = 64'h0000_1000_0000_0000;
        8'd46:MicrorocCTestChannel   = 64'h0000_2000_0000_0000;
        8'd47:MicrorocCTestChannel   = 64'h0000_4000_0000_0000;
        8'd48:MicrorocCTestChannel   = 64'h0000_8000_0000_0000;
        8'd49:MicrorocCTestChannel   = 64'h0001_0000_0000_0000;
        8'd50:MicrorocCTestChannel   = 64'h0002_0000_0000_0000;
        8'd51:MicrorocCTestChannel   = 64'h0004_0000_0000_0000;
        8'd52:MicrorocCTestChannel   = 64'h0008_0000_0000_0000;
        8'd53:MicrorocCTestChannel   = 64'h0010_0000_0000_0000;
        8'd54:MicrorocCTestChannel   = 64'h0020_0000_0000_0000;
        8'd55:MicrorocCTestChannel   = 64'h0040_0000_0000_0000;
        8'd56:MicrorocCTestChannel   = 64'h0080_0000_0000_0000;
        8'd57:MicrorocCTestChannel   = 64'h0100_0000_0000_0000;
        8'd58:MicrorocCTestChannel   = 64'h0200_0000_0000_0000;
        8'd59:MicrorocCTestChannel   = 64'h0400_0000_0000_0000;
        8'd60:MicrorocCTestChannel   = 64'h0800_0000_0000_0000;
        8'd61:MicrorocCTestChannel   = 64'h1000_0000_0000_0000;
        8'd62:MicrorocCTestChannel   = 64'h2000_0000_0000_0000;
        8'd63:MicrorocCTestChannel   = 64'h4000_0000_0000_0000;
        8'd64:MicrorocCTestChannel   = 64'h8000_0000_0000_0000;
        8'd255:MicrorocCTestChannel  = 64'hFFFF_FFFF_FFFF_FFFF;
        default:MicrorocCTestChannel = 64'h0000_0000_0000_0000;
      endcase
    end
  end

  // ReadScopeChannel
  // ReadScopeChannel[3:0], default A18X
  // ReadScopeChannel[7:4], default A19X
  reg [7:0] ReadScopeChannel;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ReadScopeChannel3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ReadScopeChannel7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  always @ (*) begin
    if(~reset_n)
      MicrorocReadScopeChannel = 64'b0;
    else begin
      case(ReadScopeChannel)
        8'd0: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0000;
        8'd1: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0001;
        8'd2: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0002;
        8'd3: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0004;
        8'd4: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0008;
        8'd5: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0010;
        8'd6: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0020;
        8'd7: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0040;
        8'd8: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0080;
        8'd9: MicrorocReadScopeChannel   = 64'h0000_0000_0000_0100;
        8'd10:MicrorocReadScopeChannel   = 64'h0000_0000_0000_0200;
        8'd11:MicrorocReadScopeChannel   = 64'h0000_0000_0000_0400;
        8'd12:MicrorocReadScopeChannel   = 64'h0000_0000_0000_0800;
        8'd13:MicrorocReadScopeChannel   = 64'h0000_0000_0000_1000;
        8'd14:MicrorocReadScopeChannel   = 64'h0000_0000_0000_2000;
        8'd15:MicrorocReadScopeChannel   = 64'h0000_0000_0000_4000;
        8'd16:MicrorocReadScopeChannel   = 64'h0000_0000_0000_8000;
        8'd17:MicrorocReadScopeChannel   = 64'h0000_0000_0001_0000;
        8'd18:MicrorocReadScopeChannel   = 64'h0000_0000_0002_0000;
        8'd19:MicrorocReadScopeChannel   = 64'h0000_0000_0004_0000;
        8'd20:MicrorocReadScopeChannel   = 64'h0000_0000_0008_0000;
        8'd21:MicrorocReadScopeChannel   = 64'h0000_0000_0010_0000;
        8'd22:MicrorocReadScopeChannel   = 64'h0000_0000_0020_0000;
        8'd23:MicrorocReadScopeChannel   = 64'h0000_0000_0040_0000;
        8'd24:MicrorocReadScopeChannel   = 64'h0000_0000_0080_0000;
        8'd25:MicrorocReadScopeChannel   = 64'h0000_0000_0100_0000;
        8'd26:MicrorocReadScopeChannel   = 64'h0000_0000_0200_0000;
        8'd27:MicrorocReadScopeChannel   = 64'h0000_0000_0400_0000;
        8'd28:MicrorocReadScopeChannel   = 64'h0000_0000_0800_0000;
        8'd29:MicrorocReadScopeChannel   = 64'h0000_0000_1000_0000;
        8'd30:MicrorocReadScopeChannel   = 64'h0000_0000_2000_0000;
        8'd31:MicrorocReadScopeChannel   = 64'h0000_0000_4000_0000;
        8'd32:MicrorocReadScopeChannel   = 64'h0000_0000_8000_0000;
        8'd33:MicrorocReadScopeChannel   = 64'h0000_0001_0000_0000;
        8'd34:MicrorocReadScopeChannel   = 64'h0000_0002_0000_0000;
        8'd35:MicrorocReadScopeChannel   = 64'h0000_0004_0000_0000;
        8'd36:MicrorocReadScopeChannel   = 64'h0000_0008_0000_0000;
        8'd37:MicrorocReadScopeChannel   = 64'h0000_0010_0000_0000;
        8'd38:MicrorocReadScopeChannel   = 64'h0000_0020_0000_0000;
        8'd39:MicrorocReadScopeChannel   = 64'h0000_0040_0000_0000;
        8'd40:MicrorocReadScopeChannel   = 64'h0000_0080_0000_0000;
        8'd41:MicrorocReadScopeChannel   = 64'h0000_0100_0000_0000;
        8'd42:MicrorocReadScopeChannel   = 64'h0000_0200_0000_0000;
        8'd43:MicrorocReadScopeChannel   = 64'h0000_0400_0000_0000;
        8'd44:MicrorocReadScopeChannel   = 64'h0000_0800_0000_0000;
        8'd45:MicrorocReadScopeChannel   = 64'h0000_1000_0000_0000;
        8'd46:MicrorocReadScopeChannel   = 64'h0000_2000_0000_0000;
        8'd47:MicrorocReadScopeChannel   = 64'h0000_4000_0000_0000;
        8'd48:MicrorocReadScopeChannel   = 64'h0000_8000_0000_0000;
        8'd49:MicrorocReadScopeChannel   = 64'h0001_0000_0000_0000;
        8'd50:MicrorocReadScopeChannel   = 64'h0002_0000_0000_0000;
        8'd51:MicrorocReadScopeChannel   = 64'h0004_0000_0000_0000;
        8'd52:MicrorocReadScopeChannel   = 64'h0008_0000_0000_0000;
        8'd53:MicrorocReadScopeChannel   = 64'h0010_0000_0000_0000;
        8'd54:MicrorocReadScopeChannel   = 64'h0020_0000_0000_0000;
        8'd55:MicrorocReadScopeChannel   = 64'h0040_0000_0000_0000;
        8'd56:MicrorocReadScopeChannel   = 64'h0080_0000_0000_0000;
        8'd57:MicrorocReadScopeChannel   = 64'h0100_0000_0000_0000;
        8'd58:MicrorocReadScopeChannel   = 64'h0200_0000_0000_0000;
        8'd59:MicrorocReadScopeChannel   = 64'h0400_0000_0000_0000;
        8'd60:MicrorocReadScopeChannel   = 64'h0800_0000_0000_0000;
        8'd61:MicrorocReadScopeChannel   = 64'h1000_0000_0000_0000;
        8'd62:MicrorocReadScopeChannel   = 64'h2000_0000_0000_0000;
        8'd63:MicrorocReadScopeChannel   = 64'h4000_0000_0000_0000;
        8'd64:MicrorocReadScopeChannel   = 64'h8000_0000_0000_0000;
        default:MicrorocReadScopeChannel = 64'h0000_0000_0000_0000;
      endcase
    end
  end

  // Powerpulsing control 1 bit
  // LvdsReceiverPPEnable default A2E0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  LvdsReceiverPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // DacPPEnable default A2F0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  DacPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // BandGapPPEnable default A200
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  BandGapEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // DiscriminatorPPEnable default A210
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  DiscriminatorPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // OTAqPPEnable default A220
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  OTAqPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // Dac4bitPPEnable default A230
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  Dac4bitPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // WidlarPPEnable default A240
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  WidlarPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // LowGainShaperPPEnable default A250
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  LowGainShaperPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // HighGainShaperPPEnable default A260
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HighGainShaperPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  // PreAmplifierPPEnable default A270
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  PreAmplifierPPEnable(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ReadoutChannelSelect 1bit, default A281
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ReadoutchannelSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ExternalRazMode 2bits, default A29X
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ExternalRazMode(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ExternalRazDelayTime 4bits, default A3A7
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ExternalRazDelayTime(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ParameterLoadStart 1bit, default D0A0, pulse
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ParameterLoadStart(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  //*** Test Command

  // RunningModeSelect 4bits, default E0A0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  RunningModeSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SweepDacSelect 2bits, default E0B0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SweepDacStartValue 10bits
  // SweepDacStartValue[3:0] E0C0
  // SweepDacStartValue[7:4] E0D0
  // SweepDacStartValue[9:8] E0E0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacStartValue3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacStartValue7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacStartValue9to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SweepDacEndValue
  // SweepDacEndValue[3:0] E0FF
  // SweepDacEndValue[7:4] E00F
  // SweepDacEndValue[9:0] E013;
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacEndValue3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacEndValue7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacEndValue9to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SweepDacStepValue
  // SweepDacStepValue[3:0] E021
  // SweepDacStepValue[7:4] E030
  // SweepDacStepValue[9:8] E040
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacStepValue3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacStepValue7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepDacStepValue9to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  //*** SCurve Test
  // SingleOr64ChannelSelect 1bit, default E051
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SingleOr64ChannelSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // CTestOrInputSelect 1bit, default E061
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CTestOrInputSelect(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SingleTestChannelSet 6bits
  // SingleTestChannelSet[3:0] E070
  // SingleTestChannelSet[5:4] E080
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SingleTestChannelSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SingleTestChannelSet5to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // TriggerCountMaxSet
  // TriggerCountMaxSet[3:0] E1A8
  // TriggerCountMaxSet[7:4] E1B8
  // TriggerCountMaxSet[11:8] E1C3
  // TriggerCountMaxSet[15:12] E1D1
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerCountMaxSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerCountMaxSet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerCountMaxSet11to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerCountMaxSet15to12(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // TriggerDelaySet 4bits, default E1E3
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerDelaySet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SweepTestStartStop 1bit, default F0A0
  reg SweepTestStartStop_reg;
  always @ (posedge Clk or negedge reset_n) begin
    if(~reset_n)
      SweepTestStartStop <= 1'b0;
    else if(UsbFifoEmpty && SweepTestDone)
      SweepTestStartStop <= 1'b0;
    else
      SweepTestStartStop <= SweepTestStartStop_reg;
  end
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepTestStartStopSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );


  // UnmaskAllChannelSet 1bit, default E1F0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  UnmaskAllChannelSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // TriggerEfficiencyOrCountEfficiencySet 1bit, default E101
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerEfficiencyOrCountEfficiencySet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // CounterMaxSet 16bits
  // CounterMaxSet[3:0] E118
  // CounterMaxSet[7:4] E128
  // CounterMaxSet[11:8] E133
  // CounterMaxSet[15:12] E141
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CounterMaxSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CounterMaxSet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CounterMaxSet11to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  CounterMaxSet15to12(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // SweepAcqMaxPackageNumberSet 16bit
  // SweepAcqMaxPackageNumberSet[3:0] E158
  // SweepAcqMaxPackageNumberSet[7:4] E168
  // SweepAcqMaxPackageNumberSet[11:8] E173
  // SweepAcqMaxPackageNumberSet[15:12] E181
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepAcqMaxPackageNumberSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepAcqMaxPackageNumberSet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepAcqMaxPackageNumberSet11to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  SweepAcqMaxPackageNumberSet15to12(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // Reset Microroc 1bit, default E190, pulse
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ResetMicrorocAcq(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ADC Start Stop 1bit, default F0B0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  ExternalAdcStartStop(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  //AdcStartDelayTimeSet 4bit, default E2A8
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  AdcStartDelayTimeSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // AdcDataNumberSet 8bit,
  // AdcDataNumberSet[3:0] E2B0
  // AdcDataNumberSet[7:4] E2C2
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  AdcDataNumberSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  AdcDataNumberSet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // TriggerCoincidenceSet 2bits, default E2D0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  TriggerCoincidenceSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // HoldDelaySet 8bits
  // HoldDelaySet[3:0] E2E6
  // HoldDelaySet[7:4] E2F1
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldDelaySet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldDelaySet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // HoldTimeSet 16bits
  // HoldTimeSet[3:0] E208
  // HoldTimeSet[7:4] E21C
  // HoldTimeSet[11:8] E220
  // HoldTimeSet[15:12] E230
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldTimeSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldTimeSet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldTimeSet11to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldTimeSet15to12(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // HoldEnable 1bit, default E240
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  HoldEnableSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // Slave DAQ
  // EndHoldTimeSet 15bits
  // EndHoldTimeSet[3:0] E254
  // EndHoldTimeSet[7:4] E261
  // EndHoldTimeSet[11:8] E270
  // EndHoldTimeSet[15:12] E280
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  EndHoldTimeSet3to0(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  EndHoldTimeSet7to4(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  EndHoldTimeSet11to8(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  EndHoldTimeSet15to12(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // ASIC Chain select 4bit, default B0A0
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  AsicChainSelectSet(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );

  // LED 4bits, default B000
  CommandDecoder
  #(
    .LEVEL_OR_PULSE(1'b1),
    .COMMAND_WIDTH(2'b0),
    .COMMAND_ADDRESS_AND_DEFAULT(16'hFFFF)
  )
  LightLed(
    .Clk(Clk),
    .reset_n(reset_n),
    .CommandFifoReadEn(CommandFifoReadEn),
    .COMMAND_WORD(COMMAND_WORD),
    // input [COMMAND_WIDTH:0] DefaultValue,
    .CommandOut(CommandOut)
    );


  //Swap the LSB and MSB
  function [3:0] Invert4bit(input [3:0] num);
    begin
      Invert4bit = {num[0], num[1], num[2], num[3]};
    end
  endfunction
endmodule
