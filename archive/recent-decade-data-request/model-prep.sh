#!/usr/local/bin/bash
source ./context.sh

#FUNCTIONS_FILE="/home/krzysiek/R/x86_64-pc-linux-gnu-library/3.1/GFS/stan/gaussfrankenspline-functions.stan"
USAGE_FILE="model.stan"
OUTPUT_FILE="${CONTEXT["model-name"]}.stan"

#echo 'functions {' > $OUTPUT_FILE
#cat cjs-functions.stan >> $OUTPUT_FILE
#echo '}' >> $OUTPUT_FILE
cat $USAGE_FILE > $OUTPUT_FILE

