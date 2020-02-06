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
set datecode [lindex $datetime_arr 1][lindex $datetime_arr 2][lindex $datetime_arr 3][lindex $datetime_arr 4]
# Show this in the log
puts DATECODE=$datecode
 
# Get the git hashtag for this project
set curr_dir [pwd]
set proj_dir [get_property DIRECTORY [current_project]]
cd $proj_dir
set git_hash [exec git log -1 --pretty='%h']
# Show this in the log
puts HASHCODE=$git_hash
 
# Update the generics
set initial_generics [get_property generic [current_fileset]]
set_property generic "$initial_generics DATE_CODE=32'h$datecode HASH_CODE=32'h$git_hash" [current_fileset]
