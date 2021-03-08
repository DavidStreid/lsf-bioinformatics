#!/bin/bash

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Provide path to FASTQ_TEXT"
  exit 1
fi

source helpers.sh

FASTQ_LIST=$1
SPLIT_FASTQ_DIR=$2
SAMPLE_SHEET_DIR=$3
FASTQ_LIST_CSV="./fastq_list.csv"

function get_lanes {
  SAMPLE=$1
  SAMPLE_SHEET=$2

  LANES=$(cat ${SAMPLE_SHEET} | grep $SAMPLE | cut -d',' -f1 | sort | uniq) 
  echo $LANES
}

echo "RGID,RGSM,RGLB,Lane,Read1File,Read2File" >> $FASTQ_LIST_CSV

while IFS= read -r LINE; do
  FASTQ1=$(echo $LINE | cut -d' ' -f3)
  FASTQ2=$(echo $LINE | cut -d' ' -f4)

  SAMPLE=$(get_sample $FASTQ1)
  RUN=$(get_run $FASTQ1 | sed -e 's/_A[0-9]$//g')
  SAMPLE_SHEET=$(find ${SAMPLE_SHEET_DIR} -type f -name "SampleSheet_*${RUN}*.csv")
 
  if [[ ! -f ${SAMPLE_SHEET} ]]; then
    echo "Could not find sample sheet for ${RUN}"
    exit 1
  fi

  SAMPLE_LANES=$(get_lanes $SAMPLE ${SAMPLE_SHEET})
  VALID_FASTQ=""
  FASTQ_LANE=""
  for LANE in $SAMPLE_LANES; do
    RESULT=$(grep "${SAMPLE}.*L00${LANE}" ${FASTQ_LIST})
    VALID_FASTQ="${VALID_FASTQ}${RESULT}"
    if [[ ! -z $(echo "${RESULT}" | grep "${FASTQ1}") ]]; then
      FASTQ_LANE=$LANE
    fi
  done
  if [[ -z ${VALID_FASTQ} ]]; then
    CMD="./split_fastq.sh $FASTQ1 $FASTQ2 $SPLIT_FASTQ_DIR $FASTQ_LIST_CSV $SAMPLE_SHEET $SAMPLE_LANES"
    echo $CMD
    JOB_NAME="SPLIT_FASTQ:${RUN}_${SAMPLE}"
    bsub -J ${JOB_NAME} -o ${JOB_NAME}.out -n 4 "$CMD"
  elif [[ ! -z ${FASTQ_LANE} ]]; then
    echo "Writing original location: $FASTQ1 (Lane: ${FASTQ_LANE})"
    ENTRY="$(write_entry $SAMPLE $FASTQ_LANE $SAMPLE_SHEET),$FASTQ1,$FASTQ2"
    echo $ENTRY >> $FASTQ_LIST_CSV
  else
    echo "Failed to extract lane from $FASTQ1"
    exit 1
  fi
done < <(tail -n +2 $FASTQ_LIST)
