#!/bin/bash

#--------- pipeline_wrapper.sh ------------------#
#
# Usage:
# 
#     $ ./pipeline_wrapper.sh DAT_FILE OUTPUT_PATH PROD_SSH_ACCESS PROD_SCP_DEST PROD_PIPELINE_HARVEST
# 
# DAT_FILE:
#
#     It is a full path of your SAS experimental data file to be used for models.
#     example: /home/saxswaxs/ASync011_scratch/pipeline_data/test_user_epn/test_experiment/avg/sample.dat
#
# OUTPUT_PATH: 
#
#     It is a full directory path for all output files generated during pipeline modelling. 
#     example:/home/saxswaxs/ASync011_scratch/pipeline_data/test_user_epn/test_experiment/analysis
#
# PROD_SSH_ACCESS:
#
#     A string of ssh username and remote hostname used to connect to SAXS production server.
#     example: saxs_user@saxs_production.synchrotron.org.au
#
# PROD_SCP_DEST:
#
#     It is a remote full directory path for this pipeline script to copy output files back to remote SAXS production server.
#     example: saxs_user@saxs_production.synchrotron.org.au:/production/data/test_user_epn/test_experiment/analysis
#
# PROD_PIPELINE_HARVEST:
#
#     It is a remote full path to trigger pipeline harvest script on remote SAXS production server.
#     example: saxs_user@saxs_production.synchrotron.org.au:/production/data/test_user_epn/test_experiment/analysis
#

DAT_FILE=$1
OUTPUT_PATH=$2
PROD_SSH_ACCESS=$3
PROD_SCP_DEST=$4
PROD_PIPELINE_HARVEST=$5
PIPELINE_SOURCE_CODE_HOME=/gpfs/M1Home/projects/ASync011/as-saxs/pipeline

# autorg, datgnom, datporod,dammif in slow mode with 1 round
FIRST=`qsub -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH $PIPELINE_SOURCE_CODE_HOME/preprocessor.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $FIRST

# process input parameters 
INPUT_PARAMETERS=`qsub -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH $PIPELINE_SOURCE_CODE_HOME/input_parameters.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo INPUT_PARAMETERS

# dammif in interactive mode with 9 rounds in parallel
SECOND=`qsub -W depend=afterok:$INPUT_PARAMETERS -t 1-9 -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH $PIPELINE_SOURCE_CODE_HOME/dammif.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $SECOND

# damclust 
THIRD=`qsub -W depend=afterok:$FIRST,afterokarray:$SECOND -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH $PIPELINE_SOURCE_CODE_HOME/damclust.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $THIRD

# copy pipeline output files (*-1.pdb) back to remote saxs production server 
# and trigger remote pipeline_harvest script off to extract required values from pipeline output files and store them into database.
FOURTH=`qsub -W depend=afterok:$THIRD -v dat_file=$DAT_FILE,output_path=$OUTPUT_PATH,prod_ssh_access=$PROD_SSH_ACCESS,prod_scp_dest=$PROD_SCP_DEST,prod_pipeline_harvest=$PROD_PIPELINE_HARVEST $PIPELINE_SOURCE_CODE_HOME/postprocessor.pbs -e $OUTPUT_PATH -o $OUTPUT_PATH`
echo $FOURTH

exit 0