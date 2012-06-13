#!/bin/bash

#--------- pipeline_wrapper.sh ------------------#
#
# Usage:
# 
#     $ ./pipeline_wrapper.sh DAT_FILE OUTPUT_PATH
# 
# DAT_FILE:
#
#     It is the full path of your SAS experimental data file to be used for models.
#     example: /home/saxswaxs/ASync011_scratch/pipeline_data/test_user_epn/test_experiment/avg/sample.dat
#
# OUTPUT_PATH: 
#
#     It is the full directory path for all output files generated during pipeline modelling. 
#     example:/home/saxswaxs/ASync011_scratch/pipeline_data/test_user_epn/test_experiment/analysis
#

DAT_FILE=$1
OUTPUT_PATH=$2

FIRST=`qsub -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH preprocessor.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $FIRST
SECOND=`qsub -W depend=afterok:$FIRST -t 1-9 -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH dammif.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $SECOND
THIRD=`qsub -W depend=afterokarray:$SECOND -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH damclust.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $THIRD
#FOURTH=`qsub -W depend=afterok:$THIRD postprocessor.pbs`
#echo $FOURTH
exit 0