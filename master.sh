#!/bin/ksh

in=/p/largedata/hhb19/jstreffi/runtime/oifsamip
out=/p/project/chhb19/jstreffi/postprocessing/PAMIP

cd $in
ncl /p/project/chhb19/jstreffi/postprocessing/ncl-plot-scripts/epflux.ncl res="159" exp1="11" exp2="16"
