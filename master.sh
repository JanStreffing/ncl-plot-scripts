#!/bin/ksh

in=/p/largedata/hhb19/jstreffi/runtime/oifsamip
out=/p/project/chhb19/jstreffi/postprocessing/PAMIP
wd=`pwd`

##############################
#     EP-FLUX plotting       #
##############################

#cd $in
#ncl /p/project/chhb19/jstreffi/postprocessing/ncl-plot-scripts/epflux.ncl res="159" exp1="11" exp2="16"
#ncl /p/project/chhb19/jstreffi/postprocessing/ncl-plot-scripts/epflux.ncl res="511" exp1="11" exp2="16"
#ncl /p/project/chhb19/jstreffi/postprocessing/ncl-plot-scripts/epflux.ncl res="1279" exp1="11" exp2="16"




##############################
#     SEVF calculation       #
##############################

res='T159'
for res in {T159,T511,T1279}
do
	if [ $res == T1279 ]; then
		start=61
		end=100
	elif [ $res == T511 ]; then
		start=101
		end=200
	elif [ $res == T159 ]; then
		start=101
		end=300
	fi
	
	#e=11
	for e in {11,16}
	do
		for i in {${start}..${end}}
		do
			echo "   ====================================================="
			echo "   Calculating SEVF for $res E$(printf "%03g" i) "
			echo "   ====================================================="
			cd $in/$res/Experiment_${e}/E$(printf "%03g" i)/outdata/oifs/bandpass
			pwd
			ls
			ncl ${wd}/sevf.ncl
		done
	done
done
