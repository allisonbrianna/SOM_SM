# #################################################################
# Vivado (TM) v2022.2.2 (64-bit)
#
# som_prj.tcl: Tcl script for re-creating project 'som_prj'
#
# The following remote source files that were added to the original project:-
#
#    "C:/hw_src/src/som_pkg.vh"
#    "C:/hw_src/src/blk_led.v"
#    "C:/hw_src/src/clock_div.v"
#    "C:/hw_src/src/clock_en.v"
#    "C:/hw_src/src/som_top.v"
#    "C:/hw_src/src/adr_decoder.v"
#    "C:/hw_src/xdc/som_top.xdc"
#
# #################################################################
namespace eval _tcl {
    proc get_script_folder {} {
       set script_path [file normalize [info script]]
       set script_folder [file dirname $script_path]
       return $script_folder
    }
}

# #################################################################
proc pause {{message "Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

# #################################################################
# Check file required for this script exists
proc checkRequiredFiles { origin_dir} {
  set status true
  set files [list \
 "[file normalize "$script_folder/src/som_pkg.vh"]"\
 "[file normalize "$script_folder/src/blk_led.v"]"\
 "[file normalize "$script_folder/src/clock_div.v"]"\
 "[file normalize "$script_folder/src/clock_en.v"]"\
 "[file normalize "$script_folder/src/som_top.v"]"\
 "[file normalize "$script_folder/xdc/som_top.xdc"]"\
  ]
  foreach ifile $files {
    if { ![file isfile $ifile] } {
      puts " Could not find remote file $ifile "
      set status false
    }
  }
  return $status
}

# #################################################################
# Set the reference directory for source file relative paths
# (by default the value is script directory path)
variable script_folder
set script_folder [_tcl::get_script_folder]

# This script was generated for a non-remote design,
# Set the project name
set proj_name som_prj
set part_number xczu1cg-sfva625-1-e
set design_name zub1cg
set xpath C:/Xilinx/Vivado/2022.2
set xsim_lib $xpath/data/xsim
set src_path $script_folder/src
set xdc_path $script_folder/xdc
set target_xdc $xdc_path/som_top.xdc
set bd_path $script_folder/bd
set report $script_folder/rpt
set prj_path $script_folder/$proj_name

# delete temp folders
file delete -force $bd_path
file delete -force $report
file delete -force $prj_path

set str_bd_path [file normalize ${bd_path}]

variable script_file
set script_file "proj_name.tcl"
set proj_dir [file normalize $prj_path]

# Check for paths and files needed for project creation
set validate_required 0
if { $validate_required } {
  if { [checkRequiredFiles $origin_dir] } {
    puts "Tcl file $script_file is valid. All files required for project creation is accesable."
  } else {
    puts "Tcl file $script_file is not valid. Not all files required for project creation is accesable."
    return
  }
}

# #################################################################
# Create SOM Project
# #################################################################
create_project -force $proj_name $script_folder/$proj_name -part $part_number
# Set project properties
set obj [current_project]
set_property default_lib xil_defaultlib $obj
set_property ip_cache_permissions "read write" $obj
set_property mem.enable_memory_map_generation 1 $obj
set_property part $part_number $obj
set_property tool_flow Vivado -objects $obj
set_property revised_directory_structure 1 -objects $obj
set_property default_lib xil_defaultlib -objects $obj
set_property target_language Verilog $obj
set_property target_simulator XSim -objects $obj
set_property sim_compile_state 1 -objects $obj
set_property sim.ip.auto_export_scripts 1 $obj
set_property simulator_language Verilog $obj
set_property compxlib.funcsim 1 -objects $obj
set_property compxlib.xsim_compiled_library_dir $xsim_lib $obj
set_property xpm_libraries "XPM_CDC XPM_FIFO XPM_MEMORY" $obj
set_property xsim.array_display_limit 1024 -objects $obj
set_property xsim.radix hex -objects $obj
set_property xsim.time_unit ns -objects $obj
set_property xsim.trace_limit 65536 -objects $obj
config_webtalk -user off
config_webtalk -install off

# #################################################################
# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set vlist [list \
 [file normalize "$script_folder/src/som_pkg.vh"] \
 [file normalize "$script_folder/src/blk_led.v"] \
 [file normalize "$script_folder/src/clock_div.v"] \
 [file normalize "$script_folder/src/clock_en.v"] \
 [file normalize "$script_folder/src/som_top.v"] \
]
add_files -norecurse -fileset $obj $vlist

set_property loop_count 1000 -objects $obj
set_property top som_top -objects $obj
set_property top_auto_set 0 -objects $obj
set_property verilog_uppercase 0 -objects $obj
set_property verilog_version verilog_2001 -objects $obj
update_compile_order -fileset sources_1

# Procedure to set properties for verilog files in 'sources_1' fileset
proc set_vlog {flist} {
    foreach fname $flist {
        set file [file normalize $fname]
        set file_obj [get_files -of_objects [get_filesets sources_1] $file]
        set_property file_type Verilog $file_obj
        set_property is_enabled 1 -objects $file_obj
        set_property is_global_include 0 -objects $file_obj
        set_property library xil_defaultlib -objects $file_obj
        set_property path_mode RelativeFirst -objects $file_obj
        set_property used_in "synthesis implementation simulation" -objects $file_obj
        set_property used_in_implementation 1 -objects $file_obj
        set_property used_in_simulation 1 -objects $file_obj
        set_property used_in_synthesis 1 -objects $file_obj
    }
}
set_vlog $vlist

# #################################################################
# Set Header File
# #################################################################
# Set 'sources_1' fileset file properties for remote files
set file "$script_folder/src/som_pkg.vh"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "Verilog Header" -objects $file_obj
set_property -name "is_global_include" -value "1" -objects $file_obj

# #################################################################
# Set Constraint
# #################################################################
# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Procedure to set properties for xdc files in 'constrs_1' fileset
proc set_xdc {flist} {
    foreach fname $flist {
        set file [file normalize $fname]
        set file_obj [get_files -of_objects [get_filesets constrs_1] $file]
        set_property file_type XDC $file_obj
        set_property used_in_implementation true $file_obj
        set_property used_in_synthesis true $file_obj
    }
}

# Add/Import constrs file and set constrs file properties
set xdc_files "[file normalize "$script_folder/xdc/som_top.xdc"]"
add_files -norecurse -fileset $obj $xdc_files
set_xdc $xdc_files

# set target constraint file
set_property "target_constrs_file" [file normalize $target_xdc] $obj
set_property "target_ucf" [file normalize $target_xdc] $obj
set_property "target_part" $part_number $obj

# #################################################################
# Set Board Design
# #################################################################
if { [catch {create_bd_design -dir $str_bd_path $design_name} errmsg] } {
    common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."
    return 1
}
current_bd_design $design_name

# #################################################################
#   SYNTHESIS AND IMPLEMENTATION
# #################################################################

proc implementation_gen {part_number} {
    # #################################################################
    # synthesis
    # Set 'synth_1' fileset object
    set obj [get_runs synth_1]
    set_property part $part_number $obj
    set_property strategy "Vivado Synthesis Defaults" $obj
    set_property flow "Vivado Synthesis 2022" $obj
    set_property report_strategy {Vivado Synthesis Default Reports} $obj
    # Design has unconnected port
    set_msg_config -suppress -id "Synth 8-3331"
    # Propagating constant 
    set_msg_config -suppress -id "Synth 8-3333"
    # Module bound to instance
    set_msg_config -suppress -id "Synth 8-3491"
    # Merging instance
    set_msg_config -suppress -id "Synth 8-3886"
    # Unconnected internal register
    set_msg_config -suppress -id "Synth 8-3936"
    # Merging register 
    set_msg_config -suppress -id "Synth 8-4471"
    # Tying undriven pin to constant 0
    set_msg_config -id "Synth 8-3295" -limit 50
    # Sequential element is unused
    set_msg_config -id "Synth 8-3332" -limit 50
    # Unused sequential element 
    set_msg_config -id "Synth 8-6014" -limit 50
    # Net does not have driver
    set_msg_config -id "Synth 8-3848" -limit 50
    # Clock period x specified during out-of-context at clock pin 'CLK' is different from the actual clock period
    set_msg_config -id "Timing 38-316" -limit 50
    #
    reset_run synth_1
    set_param general.maxThreads 6
    launch_runs synth_1 -jobs 6
    wait_on_runs synth_1
    if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
        error "ERROR: synthesis failed"
    }

    # #################################################################
    # implementation
    set obj [get_runs impl_1]
    set_property part $part_number $obj
    set_property strategy Flow_Quick $obj
    set_property flow "Vivado Implementation 2022" $obj
    set_property steps.opt_design.args.directive RuntimeOptimized $obj
    set_property steps.place_design.args.directive Quick $obj
    set_property steps.route_design.args.directive Quick $obj
    set_property steps.write_bitstream.args.readback_file 0 $obj
    set_property steps.write_bitstream.args.verbose 0 $obj
    set_property report_strategy {Vivado Implementation Default Reports} $obj    
    
    launch_runs impl_1 -to_step write_bitstream -jobs 6
    wait_on_runs impl_1
    if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
        error "ERROR: write bitstream failed"
    }
}

# #################################################################
#   REPORT GENERATION
# #################################################################
proc report_gen {report {full_report true}} {
    file mkdir $report
    open_run impl_1
    set_param general.maxThreads 6
    if { $full_report } {
        report_methodology -name methodology_1 -file $report/methodology_report.txt -checks\
 {BSCK-10 BSCK-11 BSCK-8\
 CKLD-1 CKLD-2 CLKC-1 CLKC-10 CLKC-11 CLKC-12 CLKC-13 CLKC-14 CLKC-15 CLKC-16 CLKC-17 CLKC-18 CLKC-19\
 CLKC-2 CLKC-20 CLKC-21 CLKC-22 CLKC-23 CLKC-24 CLKC-25 CLKC-26 CLKC-27 CLKC-28 CLKC-29 CLKC-3 CLKC-30\
 CLKC-31 CLKC-32 CLKC-33 CLKC-34 CLKC-35 CLKC-36 CLKC-37 CLKC-38 CLKC-39 CLKC-4 CLKC-40 CLKC-41 CLKC-42\
 CLKC-43 CLKC-44 CLKC-47 CLKC-48 CLKC-5 CLKC-51 CLKC-52 CLKC-53 CLKC-54 CLKC-55 CLKC-56 CLKC-57 CLKC-58\
 CLKC-6 CLKC-63 CLKC-7 CLKC-8 CLKC-9 DPIR-1 DPIR-2 HPDR-1 LUTAR-1 NTCN-1 PDRC-190 PDRC-204\
 SYNTH-10 SYNTH-11 SYNTH-12 SYNTH-13 SYNTH-14 SYNTH-15 SYNTH-16 SYNTH-4 SYNTH-5 SYNTH-6 SYNTH-9\
 TIMING-1 TIMING-10 TIMING-11 TIMING-12 TIMING-13 TIMING-14 TIMING-15 TIMING-16 TIMING-17 TIMING-18\
 TIMING-19 TIMING-2 TIMING-20 TIMING-21 TIMING-22 TIMING-23 TIMING-24 TIMING-25 TIMING-26 TIMING-27\
 TIMING-28 TIMING-29 TIMING-3 TIMING-30 TIMING-31 TIMING-32 TIMING-33 TIMING-34 TIMING-35 TIMING-36\
 TIMING-37 TIMING-38 TIMING-39 TIMING-4 TIMING-40 TIMING-41 TIMING-42 TIMING-43 TIMING-44 TIMING-45\
 TIMING-46 TIMING-5 TIMING-6 TIMING-7 TIMING-8 TIMING-9\
 XDCB-1 XDCB-2 XDCB-3 XDCB-4 XDCB-5 XDCC-1 XDCC-2 XDCC-3 XDCC-4\
 XDCC-5 XDCC-6 XDCC-7 XDCC-8 XDCH-1 XDCH-2 XDCV-1 XDCV-2}
        report_drc -ruledecks default -file $report/drc_report.txt
        config_timing_analysis -disable_flight_delays true
        report_cdc -file $report/cdc_report.txt
        report_clocks -file $report/route_clock.txt
        report_clock_networks -file $report/route_clock_nets.txt
        report_clock_interaction -delay_type min_max -significant_digits 3 -file $report/clock_report.txt
    }
    report_timing_summary -file $report/timing_summary.txt
    report_design_analysis -timing -setup -file $report/design_analysis.txt
    report_utilization -file $report/route_utilization.txt
}

# #################################################################
#   MAIN
# #################################################################
source $script_folder/board_design.tcl
add_files -norecurse $str_bd_path/[current_bd_design]/hdl/[current_bd_design]_wrapper.v

# #################################################################
implementation_gen $part_number
report_gen $report
write_hw_platform -fixed -include_bit -force -file $script_folder/zub1cg.xsa
close_project

# #################################################################
