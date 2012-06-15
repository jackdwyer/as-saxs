#!/bin/bash

#---------- Auto processor settings -------------------------------------------#
PROD_USER=joannah
PROD_HOST=as-saxs-dev.synchrotron.org.au

PROD_SOURCE_CODE_HOME=/gpfs/M1Home/projects/ASync011/as-saxs/pipeline
PROD_DATA_HOME=/home/joannah/production_data
PROD_PIPELINE_HARVEST=pipeline_harvest.sh

PROD_USER_EPN=joannah_epn
PROD_USER_EXP=joannah_exp
PROD_USER_DAT_FILE=sample.dat
PROD_PIPELINE_OUTPUT_DIR=analysis

PROD_SSH_ACCESS="$PROD_USER"@"$PROD_HOST"
PROD_PIPELINE_SCP_DEST="$PROD_DATA_HOME"/"$PROD_USER_EPN"/"$PROD_USER_EXP"/"$PROD_PIPELINE_OUTPUT_DIR"/
PROD_PIPELINE_HARVEST_PATH="$PROD_SOURCE_CODE_HOME"/"$PROD_PIPELINE_HARVEST"

#---------- Pipeline settings -------------------------------------------------#
MASSIVE_USER=saxswaxs
MASSIVE_HOST=m1.massive.org.au

PIPELINE_SOURCE_CODE_HOME=/gpfs/M1Home/projects/ASync011/as-saxs/pipeline
PIPELINE_DATA_HOME=/gpfs/M1Scratch/ASync011/pipeline_data
PIPELINE_WRAPPER=pipeline_wrapper.sh

PIPELINE_INPUTPUT_DIR=avg
PIPELINE_OUTPUT_DIR=analysis

PIPELINE_USER_EXP_DIR="$PIPELINE_DATA_HOME"/"$PROD_USER_EPN"/"$PROD_USER_EXP"
PIPELINE_USER_INPUT_DIR="$PIPELINE_USER_EXP_DIR"/"$PIPELINE_INPUT_DIR"
PIPELINE_USER_OUTPUT_DIR="$PIPELINE_USER_EXP_DIR"/"$PIPELINE_OUTPUT_DIR"

#---------- Create user's directories -----------------------------------------#
# create user pipeline input directory
ssh "$MASSIVE_USER"@"$MASSIVE_HOST" mkdir -p "$PIPELINE_USER_INPUT_DIR"

# create user pipeline output directory
ssh "$MASSIVE_USER"@"$MASSIVE_HOST" mkdir -p "$PIPELINE_USER_OUTPUT_DIR"

#---------- Cope user's experimental data file --------------------------------#
# Copy a local data file on production to a remote massive host 
scp "$PROD_USER_DAT_FILE" "$MASSIVE_USER"@"$MASSIVE_HOST":"$PIPELINE_USER_INPUT_DIR"/"$PROD_USER_DAT_FILE"

#---------- Pipeline modelling ------------------------------------------------#
# Submit pipeline process jobs on to massive cluster
# Arguments for pipeline wrapper:
#   ARG1: A full path of user's experimental data file to be used for models.
#   ARG2: A full directory path for all output files generated during pipeline 
#         modelling.
#   ARG3: A string of ssh username and remote hostname used to connect to SAXS 
#         production server, ex. username@hostname.
#   ARG4: A remote full directory path for pipeline to copy output files back to 
#         remote SAXS production server.
#   ARG5: A remote full path to trigger pipeline harvest script on remote SAXS 
#         production server.

ARG1="$PIPELINE_USER_INPUT_DIR"/"$PROD_USER_DAT_FILE"
ARG2="$PIPELINE_USER_OUTPUT_DIR"
ARG3="$PROD_SSH_ACCESS"
ARG4="$PROD_PIPELINE_SCP_DEST"
ARG5="$PROD_PIPELINE_HARVEST_PATH"

ssh "$MASSIVE_USER"@"$MASSIVE_HOST" bash "$PIPELINE_SOURCE_CODE_HOME"/"$PIPELINE_WRAPPER" "$ARG1" "$ARG2" "$ARG3" "$ARG4" "$ARG5"
