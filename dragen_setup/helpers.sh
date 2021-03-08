#!/bin/bash

function write_entry {
  SAMPLE=$1
  LANE=$2
  SS=$3
  LIBRARY="Illumina"

  HEADER_MARKER="Lane,"

  HEADERS=$(cat $SS | grep ${HEADER_MARKER})
  idx=0
  for header in $(echo $HEADERS | tr ',' ' '); do
    idx=$((idx + 1))
    if [[ "$header" == "index" ]]; then
      idx1=${idx}
    elif [[ "$header" == "index2" ]]; then
      idx2=${idx}
    fi
  done

  barcode1=$(cat $SS | grep "^${LANE}.*${SAMPLE}" | cut -d',' -f${idx1} | sort | uniq)
  RGID="${barcode1}"
  if [[ ! -z $idx2 ]]; then
    barcode2=$(cat $SS | grep "^${LANE}.*${SAMPLE}" | cut -d',' -f${idx2} | sort | uniq)
    RGID="${RGID}.${barcode2}"
  fi
  RGID="${RGID}.${LANE}"

  ENTRY=${RGID},${SAMPLE},Illumina,${LANE}

  echo $ENTRY
}

function get_sample {
  FASTQ=$1
  SAMPLE_NAME=$(echo $FASTQ | cut -d'/' -f7)
  if [[ -z $(echo $SAMPLE_NAME | grep "Sample_") ]]; then
    echo "Failed to find Sample_ in $SAMPLE_NAME"
    exit 1
  fi
  SAMPLE=$(echo $SAMPLE_NAME | sed -e 's/Sample_//g')
  echo $SAMPLE
}
  # RUN=$(echo ${RUN_NAME} | sed -e 's/_A[0-9]$//g')
function get_project {
  FASTQ=$1
  PROJECT_NAME=$(echo $FASTQ | cut -d'/' -f6)
  if [[ -z $(echo $PROJECT_NAME | grep "Project_") ]]; then
    echo "Failed to find Project_ in $PROJECT_NAME"
    exit 1
  fi
  PROJECT=$(echo $PROJECT_NAME | sed -e 's/Project_//g')
  echo $PROJECT
}

function get_run {
  FASTQ=$1
  RUN_NAME=$(echo $FASTQ | cut -d'/' -f5)
  echo $RUN_NAME
}
