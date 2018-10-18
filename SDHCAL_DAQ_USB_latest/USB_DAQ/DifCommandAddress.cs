﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class DifCommandAddress
    {
        public const string SlowControlOrReadScopeSelectAddress = "A0A0";
        public const string DataoutChannelSelectAddress = "A0B0";
        public const string TransmitOnChannelSelectAddress = "A0C0";
        public const string StartReadoutChannelSelectAddress = "A0D0";
        public const string EndReadoutChannelSelectAddress = "A0E0";
        public const string InternalRazSignalLengthAddress = "A0F0";
        public const string CkMuxAddress = "A000";
        public const string ExternalRazSignalEnableAddress = "A030";
        public const string InternalRazSignalEnableAddress = "A040";
        public const string ExternalTriggerEnableAddress = "A050";
        public const string TriggerNor64OrDirectSelectAddress = "A060";
        public const string TriggerOutputEnableAddress = "A070";
        public const string TriggerToWriteSelectAddress = "A080";
        public const string DacEnableAddress = "A090";
        public const string BandGapEnableAddress = "A1A0";
        public const string ChipID3to0Address = "A1B0";
        public const string ChipID7to4Address = "A1C0";
        public const string MaskChannel3to0Address = "A2A0";
        public const string MaskChannel5to4Address = "A2B0";
        public const string DiscriMaskAddress = "A2C0";
        public const string MaskSetAddress = "A2D0";
        public const string LatchedOrDirectOutputAddress = "A100";
        public const string OTAqEnableAddress = "A110";
        public const string HighGainShaperFeedbackSelectAddress = "A120";
        public const string ShaperOutLowGainOrHighGainAddress = "A130";
        public const string LowGainShaperFeedbackSelectAddress = "A140";
        public const string GainBoostEnableAddress = "A150";
        public const string CTestChannel3to0Address = "A160";
        public const string CTestChannel7to4Address = "A170";
        public const string ReadScopeChannel3to0Address = "A180";
        public const string ReadScopeChannel7to4Address = "A190";
        public const string LvdsReceiverPPEnableAddress = "A2E0";
        public const string DacPPEnableAddress = "A2F0";
        public const string BandGapPPEnableAddress = "A200";
        public const string DiscriminatorPPEnableAddress = "A210";
        public const string OTAqPPEnableAddress = "A220";
        public const string Dac4bitPPEnableAddress = "A230";
        public const string WidlarPPEnableAddress = "A240";
        public const string LowGainShaperPPEnableAddress = "A250";
        public const string HighGainShaperPPEnableAddress = "A260";
        public const string PreAmplifierPPEnableAddress = "A270";
        public const string ReadoutChannelSelectAddress = "A280";
        public const string ExternalRazModeSelectAddress = "A290";
        public const string ExternalRazDelayTimeAddress = "A3A0";
        public const string PowerPulsingPinEnableAddress = "A3B0";
        public const string EndReadoutParameterAddress = "A3C0";
        // = "A3D0"; is reserved for EndReadoutParameter more than 4bits
        public const string AsicNumberSetAddress = "A3E0";
        public const string SCurveTestAsicSelectAddress = "A3F0";
        public const string ResetTimeStampAddress = "A300";

        public const string AsicChainSelectSetAddress = "B0A0";
        public const string LightLedAddress = "B000";

        public const string Dac0Vth3to0Address = "C000";
        public const string Dac0Vth7to4Address = "C010";
        public const string Dac0Vth9to8Address = "C020";
        public const string Dac1Vth3to0Address = "C030";
        public const string Dac1Vth7to4Address = "C040";
        public const string Dac1Vth9to8Address = "C050";
        public const string Dac2Vth3to0Address = "C060";
        public const string Dac2Vth7to4Address = "C070";
        public const string Dac2Vth9to8Address = "C080";

        public const string ParameterLoadStartAddress = "D0A0";

        public const string RunningModeSelectAddress = "E0A0";
        public const string SweepDacSelectAddress = "E0B0";
        public const string SweepDacStartValue3to0Address = "E0C0";
        public const string SweepDacStartValue7to4Address = "E0D0";
        public const string SweepDacStartValue9to8Address = "E0E0";
        public const string SweepDacEndValue3to0Address = "E0F0";
        public const string SweepDacEndValue7to4Address = "E000";
        public const string SweepDacEndValue9to8Address = "E010";
        public const string SweepDacStepValue3to0Address = "E020";
        public const string SweepDacStepValue7to4Address = "E030";
        public const string SweepDacStepValue9to8Address = "E040";
        public const string SingleOr64ChannelSelectAddress = "E050";
        public const string CTestOrInputSelectAddress = "E060";
        public const string SingleTestChannelSet3to0Address = "E070";
        public const string SingleTestChannelSet5to4Address = "E080";
        public const string TriggerCountMaxSet3to0Address = "E1A0";
        public const string TriggerCountMaxSet7to4Address = "E1B0";
        public const string TriggerCountMaxSet11to8Address = "E1C0";
        public const string TriggerCountMaxSet15to12Address = "E1D0";
        public const string TriggerDelaySetAddress = "E1E0";
        public const string SweepTestStartStopAddress = "F0A0";
        public const string UnmaskAllChannelSetAddress = "E1F0";
        public const string TriggerEfficiencyOrCountEfficiencySetAddress = "E100";
        public const string CounterMaxSet3to0Address = "E110";
        public const string CounterMaxSet7to4Address = "E120";
        public const string CounterMaxSet11to8Address = "E130";
        public const string CounterMaxSet15to12Address = "E140";
        public const string SweepAcqMaxPackageNumberSet3to0Address = "E150";
        public const string SweepAcqMaxPackageNumberSet7to4Address = "E160";
        public const string SweepAcqMaxPackageNumberSet11to8Address = "E170";
        public const string SweepAcqMaxPackageNumberSet15to12Address = "E180";
        public const string ResetMicrorocAcqAddress = "E190";
        public const string ExternalAdcStartStopAddress = "F0B0";
        public const string AdcStartDelayTimeSetAddress = "E2A0";
        public const string AdcDataNumberSet3to0Address = "E2B0";
        public const string AdcDataNumberSet7to4Address = "E2C0";
        public const string TriggerCoincidenceSetAddress = "E2D0";
        public const string HoldDelaySet3to0Address = "E2E0";
        public const string HoldDelaySet7to4Address = "E2F0";
        public const string HoldTimeSet3to0Address = "E200";
        public const string HoldTimeSet7to4Address = "E210";
        public const string HoldTimeSet11to8Address = "E220";
        public const string HoldTimeSet15to12Address = "E230";
        public const string HoldEnableSetAddress = "E240";
        public const string EndHoldTimeSet3to0Address = "E250";
        public const string EndHoldTimeSet7to4Address = "E260";
        public const string EndHoldTimeSet11to8Address = "E270";
        public const string EndHoldTimeSet15to12Address = "E280";
        
        public const string DaqSelectAddress = "E290";
        public const string MicrorocStartAcquisitionTime3to0Address = "E3A0";
        public const string MicrorocStartAcquisitionTime7to4Address = "E3B0";
        public const string MicrorocStartAcquisitionTime11to8Address = "E3C0";
        public const string MicrorocStartAcquisitionTime15to12Address = "E3D0";
        public const string TestSignalColumnSelectAdress = "E3E0";
        public const string TestSignalRowSelectAdress = "E3F0";
        public const string TriggerSuppressWidth3to0Address = "E300";
        public const string TriggerSuppressWidth7to4Address = "E31B";
        public const string TriggerSuppressWidth11to8Address = "E321";
        public const string TriggerSuppressWidth15to12Address = "E337";
        public const string TriggerSuppressWidth19to16Address = "E34B";
        public const string ChipFullEnableAddress = "E351";
        public const string AutoDaqAcquisitionModeSelectAddress = "E360";
        public const string AutoDaqTriggerModeSelectAddress = "E370";
        public const string AutoDaqTriggerDelayTime3to0Address = "E380";
        public const string AutoDaqTriggerDelayTime7to4Address = "E390";
        public const string AutoDaqTriggerDelayTime11to8Address = "E4A0";
        public const string AutoDaqTriggerDelayTime15to12Address = "E4B0";
        public const string SCurveTestInnerClockEnableAddress = "E4C0";

        public const string AcquisitionStartStopAddress = "F0F0";
        public const string ResetDataFifoAddress = "F1A0";
        public const string ResetSCurveTestAdress = "F1B0";

    }
}
