#!/bin/bash

#--------- pipeline_wrapper.sh ------------------#
#
# Usage: $ ./pipeline_wrapper.sh /full/path/sample_file.dat
#


# FILE is the full name of file to be used for models, ex. sample_file.dat
# FILENAME is the file name without extension, ex. sample_file
#FILE=`basename $1`
#FILENAME=${FILE%.*}

DAT_FILE=$1

FIRST=`qsub -v dat_file=$DAT_FILE preprocessor.pbs`
echo $FIRST
SECOND=`qsub -W depend=afterok:$FIRST -t 1-9 -v dat_file=$DAT_FILE dammif.pbs`
echo $SECOND
THIRD=`qsub -W depend=afterokarray:$SECOND -v dat_file=$DAT_FILE damclust.pbs`
echo $THIRD
#FOURTH=`qsub -W depend=afterok:$THIRD postprocessor.pbs`
#echo $FOURTH
exit 0