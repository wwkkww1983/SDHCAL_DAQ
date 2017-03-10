# 
# Synthesis run script generated by Vivado
# 

set_param simulator.modelsimInstallPath D:/Program%20Files/ModelSim/win64
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -ruleid {1}  -id {Synth 8-3917}  -string {{WARNING: [Synth 8-3917] design FPGA_TOP has port usb_slcs driven by constant 0}}  -suppress 
set_msg_config  -ruleid {2}  -id {Synth 8-3917}  -string {{WARNING: [Synth 8-3917] design FPGA_TOP has port usb_fifoaddr[0] driven by constant 0}}  -suppress 
set_msg_config  -ruleid {3}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'usb_cmd_fifo' instantiated as 'usb_control/usbcmdfifo_16depth' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/usb_command_interpreter.v:55]}}  -suppress 
set_msg_config  -ruleid {4}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'usb_data_fifo' instantiated as 'usb_data_fifo_8192depth' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/FPGA_TOP.v:294]}}  -suppress 
set_msg_config  -ruleid {5}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'param_store_fifo' instantiated as 'Microroc_u1/SC_Readreg/param_store_fifo_16bitx256deep' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/SlowControl_ReadReg.v:339]}}  -suppress 
set_msg_config  -ruleid {6}  -id {Synth 8-3917}  -string {{WARNING: [Synth 8-3917] design FPGA_TOP has port LED[5] driven by constant 1}}  -suppress 
set_msg_config  -ruleid {7}  -id {Synth 8-350}  -string {{WARNING: [Synth 8-350] instance 'SC_Readreg' of module 'SlowControl_ReadReg' requires 53 connections, but only 52 given [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/Microroc_top.v:135]}}  -suppress 
set_msg_config  -ruleid {8}  -id {Project 1-486}  -string {{WARNING: [Project 1-486] Could not resolve non-primitive black box cell 'param_store_fifo' instantiated as 'Microroc_u1/SC_Readreg/param_store_fifo_16bitx256deep' [D:/Xilinx_Vivado_workspace/SDHCAL_DAQ2V0/RTL/SlowControl_ReadReg.v:283]}}  -suppress 
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7a100tfgg484-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.cache/wt [current_project]
set_property parent.project_path D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_ip -quiet D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo.xci
set_property is_locked true [get_files D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo.xci]

foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

set cached_ip [config_ip_cache -export -no_bom -use_project_ipc -dir D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1 -new_name param_store_fifo -ip [get_ips param_store_fifo]]

if { $cached_ip eq {} } {

synth_design -top param_store_fifo -part xc7a100tfgg484-2 -mode out_of_context

#---------------------------------------------------------
# Generate Checkpoint/Stub/Simulation Files For IP Cache
#---------------------------------------------------------
catch {
 write_checkpoint -force -noxdef -rename_prefix param_store_fifo_ param_store_fifo.dcp

 set ipCachedFiles {}
 write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ param_store_fifo_stub.v
 lappend ipCachedFiles param_store_fifo_stub.v

 write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ param_store_fifo_stub.vhdl
 lappend ipCachedFiles param_store_fifo_stub.vhdl

 write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ param_store_fifo_sim_netlist.v
 lappend ipCachedFiles param_store_fifo_sim_netlist.v

 write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ param_store_fifo_sim_netlist.vhdl
 lappend ipCachedFiles param_store_fifo_sim_netlist.vhdl

 config_ip_cache -add -dcp param_store_fifo.dcp -move_files $ipCachedFiles -use_project_ipc -ip [get_ips param_store_fifo]
}

rename_ref -prefix_all param_store_fifo_

write_checkpoint -force -noxdef param_store_fifo.dcp

catch { report_utilization -file param_store_fifo_utilization_synth.rpt -pb param_store_fifo_utilization_synth.pb }

if { [catch {
  file copy -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1/param_store_fifo.dcp D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo.dcp
} _RESULT ] } { 
  send_msg_id runtcl-3 error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}

if { [catch {
  write_verilog -force -mode synth_stub D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}


} else {


if { [catch {
  file copy -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1/param_store_fifo.dcp D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo.dcp
} _RESULT ] } { 
  send_msg_id runtcl-3 error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}

if { [catch {
  file rename -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1/param_store_fifo_stub.v D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  file rename -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1/param_store_fifo_stub.vhdl D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  file rename -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1/param_store_fifo_sim_netlist.v D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  file rename -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.runs/param_store_fifo_synth_1/param_store_fifo_sim_netlist.vhdl D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

}; # end if cached_ip 

if {[file isdir D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.ip_user_files/ip/param_store_fifo]} {
  catch { 
    file copy -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_stub.v D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.ip_user_files/ip/param_store_fifo
  }
}

if {[file isdir D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.ip_user_files/ip/param_store_fifo]} {
  catch { 
    file copy -force D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.srcs/sources_1/ip/param_store_fifo/param_store_fifo_stub.vhdl D:/MyProject/SDHCAL_DAQ/SDHCAL_DAQ2V0_SCurveTest/SDHCAL_DAQ2V0.ip_user_files/ip/param_store_fifo
  }
}
