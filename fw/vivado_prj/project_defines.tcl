# Define Xilinx part and board
set ver "2019.1"
#set xl_board ""
set project_part "xczu27dr-ffvg1517-1-e"
set project_board "not-applicable"
set project_name "sandbox"

set MAJ_VER D0000000
set MIN_VER 00000000

set dLib "lib"
set top "_top"
set lib "_lib"
set project_top $project_name$top
set project_lib $project_name$lib
set projectDefaultLib $project_name$dLib
set outputDir ./

puts -nonewline "\033\[1;32m"; #GREEN
puts ""
puts "Using $project_top as top and $project_lib as Project Library namespace with $projectDefaultLib as vivado default library"
puts ""
puts -nonewline "\033\[0m";# Reset

#Vivado Creatiuon Opts
set PROJ_DEF_USED 1

#------------------------------------------------------------------------------
#   Grab Date, Ver, and Hash variables to insert into design ....
#------------------------------------------------------------------------------


# Current date, time, and seconds since epoch
# 0 = 4-digit year
# 1 = 2-digit year
# 2 = 2-digit month
# 3 = 2-digit day
# 4 = 2-digit hour
# 5 = 2-digit minute
# 6 = 2-digit second
# 7 = Epoch (seconds since 1970-01-01_00:00:00)
# Array index                                            0  1  2  3  4  5  6  7
set datetime_arr [clock format [clock seconds] -format {%Y %y %m %d %H %M %S %s}]

# Get the datecode in the yy-mm-dd-HH format
set datecode [lindex $datetime_arr 2][lindex $datetime_arr 3][lindex $datetime_arr 4][lindex $datetime_arr 5]
# Show this in the log
puts DATECODE=$datecode

# Get the git hashtag for this project
set git_hash [exec git log -1 --pretty=%h]
puts HASHCODE=$git_hash

# Update the generics
if { [catch {current_project} result] } {
  puts  "Generics NOT set, no project open"
} else {
    set initial_generics [get_property generic [current_fileset]]
    set_property generic "$initial_generics DATE_CODE=32'h$datecode GIT_HASH=32'h$git_hash MAJOR_VER=32h'$MAJ_VER MINOR_VER=32'h$MIN_VER" [current_fileset]
    # Show this in the log
    puts ""
    puts -nonewline "\033\[1;32m"; #GREEN
    puts "Creating bitstream ver $MAJ_VER . $MIN_VER on commit $git_hash.  Starting @ $datecode"
    puts "use these values to verify the bitstream version on the fpga"
    puts ""
    puts -nonewline "\033\[0m";# Reset
}
#------------------------------------------------------------------------------
#   END Grabbing date and hashes
#------------------------------------------------------------------------------



puts "PROJECT DEFINES HAVE BEEN SET"
