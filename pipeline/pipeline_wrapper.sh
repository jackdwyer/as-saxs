#!/bin/bash

# Usage: ./pipeline_wrapper.sh sample_file.dat

# FILE is the full name of file to be used for models, ex. sample_file.dat
# FILENAME is the file name without extension, ex. sample_file
FILE=`basename $1`
FILENAME=${FILE%.*}

FIRST=`qsub -v file=$FILE preprocessor.pbs`
echo $FIRST
SECOND=`qsub -W depend=afterok:$FIRST -t 1-9 -v filename=$FILENAME dammif.pbs`
echo $SECOND
THIRD=`qsub -W depend=afterokarray:$SECOND -v filename=$FILENAME damclust.pbs`
echo $THIRD
#FOURTH=`qsub -W depend=afterok:$THIRD postprocessor.pbs`
#echo $FOURTH
exit 0