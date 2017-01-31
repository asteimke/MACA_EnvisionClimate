#!/bin/bash

# Script subsets MACA files into yearly files for Envision
# run after files have been processed by processing.sh 


SA='TV_maca'  									   # study area / naming convention for your files --> ours is TV_maca (Treasure Valley)
model='CanESM2'                                    # change to whatever GCM you are working with, could put in for-loop if you have many models
vars='huss pr rsds tasmax tasmin tasavg was'       # variables needed for Envision (different from processing.sh) corresponding to: humidity, prec, shortwave radiation, max T, min T, avg T, total wind
rcps='rcp45 rcp85'								   # RCP scenarios (historical not included here --> in 2nd for-loop)

future_years={1..95}							   # length of time for future simulations
hist_years={1..56}								   # length of time for historical files

# reads in files and subsets into annual files
for var in $vars
	do
	for yr in $future_years  
		do
		for rcp in $rcps
			do
			start_time=$(($yr*365-364))
			end_time=$(($yr*365))
			output_year=$((2005+$yr))

			input_file=${SA}_${var}_${model}_${rcp}.nc	
			output_file=${SA}_${var}_${model}_${rcp}_${output_year}.nc

			ncea -F -d time,$start_time,$end_time $input_file $output_file
		
			echo finishing year ${output_year} for variable: ${var_out} for ${rcp}
		done
	done
done


# for historical data (as years differ from RCP scenarios) --> could combine into if statement previously if wanted
for var in $vars
	do
	for yr in $hist_years  
		do
			start_time=$(($yr*365-364))
			end_time=$(($yr*365))
			output_year=$((1949+$yr))

			input_file=${SA}_${var}_${model}_historical.nc
			output_file=${SA}_${var}_${model}_historical_${output_year}.nc

			ncea -F -d time,$start_time,$end_time $input_file $output_file

			echo finishing year ${output_year} for variable: ${var_out} for historical
	done
done
