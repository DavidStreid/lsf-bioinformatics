#!/bin/bash

source helpers.sh

FASTQ1=$1
FASTQ2=$2
SPLIT_FASTQ_DIR=$3
FASTQ_LIST_CSV=$4
SAMPLE_SHEET=$5
LANES="${@:5}"

if [[ -z $FASTQ1 || -z $FASTQ2 || -z $SPLIT_FASTQ_DIR || -z $FASTQ_LIST_CSV || -z $LANES ]]; then
  echo "Missing args - FASTQ1, FASTQ2, SPLIT_FASTQ_DIR, FASTQ_LIST_CSV, LANES"
  exit 1
fi

RUN=$(get_run $FASTQ1)
PRJ=$(get_project $FASTQ1)
SMP=$(get_sample $FASTQ1)

SAMPLE_DIR=${SPLIT_FASTQ_DIR}/${RUN}/${PRJ}/${SMP}

mkdir -p $SAMPLE_DIR

cp $FASTQ1 ${SAMPLE_DIR}
cp $FASTQ2 ${SAMPLE_DIR}

FASTQ1_CP=$(find ${SAMPLE_DIR} -type f -name $(basename $FASTQ1))
FASTQ2_CP=$(find ${SAMPLE_DIR} -type f -name $(basename $FASTQ2))

fastqsplit ${FASTQ1_CP}
fastqsplit ${FASTQ2_CP}

rm $FASTQ1_CP
rm $FASTQ2_CP

for lane in $LANES; do
  LANE_FASTQS=$(ls ${SAMPLE_DIR} | grep "_L00${lane}")
  if [[ -z $LANE_FASTQS ]]; then
    echo "Failed to create _L00${lane} in $SAMPLE_DIR"
    exit 1
  fi

  ENTRY_FASTQ1=$(echo $LANE_FASTQS | tr ' ' '\n' | grep "$SMP.*_L00${lane}_*R1")
  ENTRY_FASTQ2=$(echo $LANE_FASTQS | tr ' ' '\n' | grep "$SMP.*_L00${lane}_*R2")

  if [[ -z $ENTRY_FASTQ1 ]]; then
    "Couldn't find FASTQ1 in $LANE_FASTQS"
    exit 1
  fi
  if [[ -z $ENTRY_FASTQ2 ]]; then
    "Couldn't find FASTQ2 in $LANE_FASTQS"
    exit 1
  fi
  ENTRY="$(write_entry $SMP $lane $SAMPLE_SHEET),$ENTRY_FASTQ1,$ENTRY_FASTQ2"
  echo $ENTRY >> $FASTQ_LIST_CSV
done
