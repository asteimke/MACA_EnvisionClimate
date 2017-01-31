#!/bin/bash


# This script reads in MACA gridded netcdf files and processes the variables to a format readable by Envision
# Use subsetYears.sh to take the output of this script to get yearly files (also needed for Envision)
# Either add in pathways to files or run script from folder containing the files

SA='TV_maca'  
model='CanESM2'   						    # change to whatever GCM you are working with, could put in for-loop if you have many models
vars='huss pr rsds tasmax tasmin uas vas'   # variables named with MACA format, corresponding to: humidity, prec, shortwave radiation, max T, min T, eastward wind, northward wind
scenarios='historical rcp45 rcp85'			# model scenarios 


# This loop renames files to a more user-friendly file format and change longitude format
for var in $vars
    do
   
	ncap2 -O -s lon=lon-360 agg_macav1metdata_${var}_${model}_r1i1p1_historical_1950_2005_WUSA.nc ${SA}_${var}_${model}_historical.nc
	ncap2 -O -s lon=lon-360 agg_macav1metdata_${var}_${model}_r1i1p1_rcp45_2006_2100_WUSA.nc ${SA}_${var}_${model}_rcp45.nc
	ncap2 -O -s lon=lon-360 agg_macav1metdata_${var}_${model}_r1i1p1_rcp85_2006_2100_WUSA.nc ${SA}_${var}_${model}_rcp85.nc
	echo finishing variable: ${var}
	
done


# This loop processes certain variables (i.e. changing units, creating new variables)
for scenario in $scenarios
    do
	
	string1=${model}_${scenario}  # string for naming convention in files
	echo starting $string1
	
	# precipitation processing
	ncrename -v precipitation_flux,prec ${SA}_pr_${string1}.nc                         # rename precipitation flux variable
	ncap2 -O -s prec=prec*24*3600 ${SA}_pr_${string1}.nc ${SA}_pr_${string1}.nc      # calculate precipitation amount instead of flux --> prec(mm) = (day precipitation flux kg/m2 s)* ( m3/ 1000.0 kg)*(3600 sec/hr) *(24 hr/day)* (1000 mm/m) 
	ncatted -O -a units,prec,o,c,millimeters ${SA}_pr_${string1}.nc                    # change units name for precipitation
	ncatted -O -a standard_name,prec,o,c,Precipitation ${SA}_pr_${string1}.nc          # change standard name
	echo finished precipitation with $string1

	# temp processing
	# convert to C, change to float, calculate average
	ncap2 -O -s air_temperature=air_temperature-273.15 ${SA}_tasmax_${string1}.nc ${SA}_tasmax_${string1}.nc     # convert from K to C
	ncap2 -O -s air_temperature=air_temperature-273.15 ${SA}_tasmin_${string1}.nc ${SA}_tasmin_${string1}.nc
	ncap2 -O -s 'air_temperature=float(air_temperature)' ${SA}_tasmax_${string1}.nc ${SA}_tasmax_${string1}.nc   # change to float
	ncap2 -O -s 'air_temperature=float(air_temperature)' ${SA}_tasmin_${string1}.nc ${SA}_tasmin_${string1}.nc
	ncatted -O -a units,air_temperature,o,c,C ${SA}_tasmax_${string1}.nc										 # change units
	ncatted -O -a units,air_temperature,o,c,C ${SA}_tasmin_${string1}.nc
	nces ${SA}_tasmax_${string1}.nc ${SA}_tasmin_${string1}.nc ${SA}_tasavg_${string1}.nc                      # average max and min temperatures to get average temperature
	ncatted -O -a long_name,air_temperature,o,c,"Daily Average Near-Surface Air Temperature - created by avg Max and Min" ${SA}_tasavg_${string1}.nc   
	echo finished temperature with $string1

	# wind processing
	# wind comes in eastward and northward components, to get overall wind, square each variable, rename, combine, then take the square root   
	ncap2 -O -s eastward_wind=eastward_wind*eastward_wind ${SA}_uas_${string1}.nc ${SA}_uas_${string1}.nc       # square variables
	ncap2 -O -s northward_wind=northward_wind*northward_wind ${SA}_vas_${string1}.nc ${SA}_vas_${string1}.nc
	ncrename -v eastward_wind,was ${SA}_uas_${string1}.nc														# rename
	ncrename -v northward_wind,was ${SA}_vas_${string1}.nc
	ncbo -v was --op_typ=+ ${SA}_uas_${string1}.nc ${SA}_vas_${string1}.nc ${SA}_was_${string1}.nc              # sum together
	ncap2 -O -s 'was=sqrt(was)' ${SA}_was_${string1}.nc ${SA}_was_${string1}.nc									# take square root
	ncatted -O -a comments,was,o,c,"Surface (10m) wind, created by squaring and summing uas and vas, then took square root" ${SA}_was_${string1}.nc
	ncatted -O -a long_name,was,o,c,"Wind" ${SA}_was_${string1}.nc
	ncatted -O -a standard_name,was,o,c,"Wind" ${SA}_was_${string1}.nc
	echo finished wind with $string1
	
done
