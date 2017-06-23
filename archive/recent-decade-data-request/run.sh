#!/usr/local/bin/bash
source ./context.sh

NAME=${CONTEXT["model-name"]}
CHAINS=${CONTEXT["chains"]}
INPUT_DIR=${CONTEXT["input"]}
PROCESSED_INPUT_DIR=${CONTEXT["processed-input"]}
OUTPUT_DIR=${CONTEXT["output"]}
PROCESSED_OUTPUT_DIR=${CONTEXT["processed-output"]}
echo -ne "Input from: $INPUT_DIR\n"
echo -ne "Processed input from: $PROCESSED_INPUT_DIR\n"
echo -ne "Output to: $OUTPUT_DIR\n"
echo -ne "Processed output from: $PROCESSED_OUTPUT_DIR\n"

FILE_INFO_FILE=$OUTPUT_DIR/$NAME-file-data.txt
rm -f $FILE_INFO_FILE

echo -ne "input-dir:$INPUT_DIR\n" >> $FILE_INFO_FILE
echo -ne "processed-input-dir:$PROCESSED_INPUT_DIR\n" >> $FILE_INFO_FILE
echo -ne "output-dir:$OUTPUT_DIR\n" >> $FILE_INFO_FILE
echo -ne "processed-output-dir:$PROCESSED_OUTPUT_DIR\n" >> $FILE_INFO_FILE

DATA_FILE=$(ls -lrc $PROCESSED_INPUT_DIR/cmdstan-*-data.rdump | awk '{print $9;}' | head -n1 )
echo -ne "data-file:$DATA_FILE\n"

for i in $(seq "$CHAINS")
do
	INIT_INPUT_FILE=$(ls -lrc $PROCESSED_INPUT_DIR/cmdstan-*-inits-$i.rdump | awk '{print $9;}' | head -n1)
  echo -ne "init-file:$INIT_INPUT_FILE\n"
	DATA_INPUT_FILE=$DATA_FILE
	OPTIM_OUTPUT_FILE=$OUTPUT_DIR/$NAME-optimize-try-$i-output.csv
	OPTIM_DIAGNOSTIC_FILE=$OUTPUT_DIR/$NAME-optimize-try-$i-diagnostics.csv
	OPTIM_TERM_FILE=$OUTPUT_DIR/$NAME-optimize-try-$i-term.csv
	SAMPLER_OUTPUT_FILE=$OUTPUT_DIR/$NAME-sampler-chain-$i-output.csv
	SAMPLER_DIAGNOSTIC_FILE=$OUTPUT_DIR/$NAME-sampler-chain-$i-diagnostics.csv
	SAMPLER_TERM_FILE=$OUTPUT_DIR/$NAME-sampler-chain-$i-term.csv

	echo -ne "try-$i-init-file:$INIT_INPUT_FILE\n" >> $FILE_INFO_FILE
	echo -ne "try-$i-data-file:$DATA_INPUT_FILE\n" >> $FILE_INFO_FILE
	echo -ne "sampler-chain-$i-output-file:$SAMPLER_OUTPUT_FILE\n" >> $FILE_INFO_FILE
	echo -ne "sampler-chain-$i-diagnostic-file:$SAMPLER_DIAGNOSTIC_FILE\n" >> $FILE_INFO_FILE
	
	./$NAME id=$i \
		method=sample save_warmup=1 max_depth=15 num_samples=200 num_warmup=300\
		data file=$DATA_INPUT_FILE init=$INIT_INPUT_FILE \
		output \
			file=$SAMPLER_OUTPUT_FILE diagnostic_file=$SAMPLER_DIAGNOSTIC_FILE   \
			refresh=10 > $SAMPLER_TERM_FILE &
	
done

