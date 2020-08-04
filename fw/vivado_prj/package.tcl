source ./project_defines.tcl


#+++++++++++++++++++++++++++++++++++++++++++++++
# Ensure the correct Vivado Version Is running +
#+++++++++++++++++++++++++++++++++++++++++++++++
set current_vivado_version [version -short]

if { [string first $ver $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

# findFiles
# basedir - the directory to start looking in
# pattern - A pattern, as defined by the glob command, that the files must match
proc findFiles { basedir pattern } {

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}

    # Look in the current directory for matching files, -type {f r}
    # means ony readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }

    # Now look for any sub direcories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Recusively call the routine on the sub directory and append any
        # new files to the results
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList
 }

#------------------------------------------------------------------------------
# Setup environment related stuff
#------------------------------------------------------------------------------

set hdl_dir  "../src/"
set phdl_dir "../src/"

if [info exists ::env(ADI_HDL_DIR)] {
  set hdl_dir $::env(ADI_HDL_DIR)
}

if [info exists ::env(ADI_PHDL_DIR)] {
  set phdl_dir $::env(ADI_PHDL_DIR)
}

# Setup Vivado Environmental parameters

#Change project system directory location for Zynq Processor system as desired
set project_system_dir "./$project_name"

#set_property used_in_synthesis false [get_files  ./system_constr.xdc]

## NOTE:: This is set in the options area and will create a new project for you
if { $proj_make eq 1 } {
    create_project $project_name fw-project-$ver -part $project_part -force
      if {$project_board ne "not-applicable"} {
        set_property board $project_board [current_project]
      }
} else {
  open_project ./$project_name/project_1.xpr
}

set lib_dirs $hdl_dir/
  if {$hdl_dir ne $phdl_dir} {
    lappend lib_dirs $phdl_dir/library
  }

## NOTE:: This is set in the options area and will create a new project for you
if {$proj_make eq 1} {
  # Setup Simulator options
  set_property target_language VERILOG [current_project]
  set_property target_simulator ModelSim [current_project]
  set_property -name modelsim.vsim_more_options -value {-dbg} -objects [get_filesets sim_1]
  set_property -name modelsim.vlog_more_options -value {-dbg} -objects [get_filesets sim_1]
  set_property -name modelsim.vcom_more_options -value {-dbg} -objects [get_filesets sim_1]
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set the default lib name and repo paths here
#++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property ip_repo_paths $lib_dirs [current_fileset]
set_property default_lib $defaultLibName [current_project]

update_ip_catalog


#------------------------------------------------------------------------------
# Address Map TODO :: Make this configurable with opts.
#------------------------------------------------------------------------------
#assign_bd_address [get_bd_addr_segs {sys_ps7/S_AXI_HP1/HP1_DDR_LOWOCM }]
#set_property range 1G [get_bd_addr_segs {S_AXI/SEG_sys_ps7_HP1_DDR_LOWOCM}]
#assign_bd_address [get_bd_addr_segs {M_AXI/Reg }]
##set_property offset 0x40000000 [get_bd_addr_segs {sys_ps7/Data/SEG_system_ps7_Reg}]
#set_property offset 0x40000000 [get_bd_addr_segs {sys_ps7/Data/SEG_M_AXI_Reg}]
##set_property range 1G [get_bd_addr_segs {sys_ps7/Data/SEG_system_ps7_Reg}]
#set_property range 1G [get_bd_addr_segs {sys_ps7/Data/SEG_M_AXI_Reg}]
#
#regenerate_bd_layout
#validate_bd_design


#------------------------------------------------------------------------------
# Add system top level design and custom logic modules to project
#------------------------------------------------------------------------------

add_files [findFiles $hdl_dir *.xdc]
add_files [findFiles $hdl_dir *.vhd]
add_files [findFiles $hdl_dir *.sv]
add_files [findFiles $hdl_dir *.v]

#------------------------------------------------------------------------------
# Add Xilinx Cores
#------------------------------------------------------------------------------

add_files [findFiles $hdl_dir *.xci]

#------------------------------------------------------------------------------
#   Set the top level file
#------------------------------------------------------------------------------

set_property top $project_name-top [current_fileset]

#------------------------------------------------------------------------------
# Update  compile order
#------------------------------------------------------------------------------

#Sims
update_compile_order -fileset sim_1
#sources
update_compile_order -fileset sources_1

# STEP#1: run synthesis, report utilization and timing estimates, write checkpoint design
# Create the runs with default of run time optimized design flows. If this fails, come back
# and update this script with different flow options.
#   USER GUIDE 892
create_run urea -flow {Vivado Synthesis 2019} -strategy Flow_RuntimeOptimized
# Optionally the run can be directly stated here
# which will also launch it.
# USER GUIDE 835
#synth_design
# Launch Synth 1 and wait for results
launch_runs synthi -jobs 8
wait_on_run synthi
#+++++++++++++++++++++++++++++++++++++++++++++
# Write the reports and DCP for the post synth analysis.
#+++++++++++++++++++++++++++++++++++++++++++++
write_checkpoint -force $outputDir/post_synth_dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_usage.rpt
report_power -file $outputDir/post_synth_power.rpt
puts "Synth Done... Starting Implementation"


# STEP#2: run placement and logic optimzation, report utilization and timing estimates, write checkpoint design
# Create the runs with default of run time optimized design flows. If this fails, come back
# and update this script with different flow options.
#   USER GUIDE 892
create_run implementation_001 -parent_run synth_1 -flow {Vivado Implementation 2019} -strategy Performance_RefinePlacement
# Optionally the run can be directly stated here
# which will also launch it.
# USER GUIDE 835
#opt_design
#place_design
#phys_opt_design
#route_design
#
# Launch Synth 1 and wait for results
launch_runs implementation_001 -jobs 8
wait_on_run implementation_001
#+++++++++++++++++++++++++++++++++++++++++++++
# Write the reports and DCP for the post synth analysis.
#+++++++++++++++++++++++++++++++++++++++++++++
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
#+++++++++++++++++++++++++++++++++++++++++++++
# These reports are usually not needed.
#+++++++++++++++++++++++++++++++++++++++++++++
#report_power -file $outputDir/post_route_power.rpt
#report_drc -file $outputDir/post_imp_drc.rpt
#write_verilog -force $outputDir/bft_impl_netlist.v
#write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc
puts "Implementation Done, view reports."

puts "If Ready for bitstream, run the following command"
#+++++++++++++++++++++++++++++++++++++++++++++
# If bitstream Go is set, this will skip to generating the bitstream directly
# with no other input from the user.
#+++++++++++++++++++++++++++++++++++++++++++++
if { $doBitStream = 0}
  {
    puts "write_bitstream -force $outputDir/$project_name.bit"
  }
else
  {
    write_bitstream -force $outputDir/$project_name.bit
  }
