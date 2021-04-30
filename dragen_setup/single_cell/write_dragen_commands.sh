#!/bin/bash
# ./write_dragen_commands.sh FASTQ_LIST.csv OUTPUT

ANNOTATION_FILE= # TODO - Add annotation file
REFERENCE_FILE= # TODO - Add Dragen Reference file

FASTQ_LIST_CSV=$1
OUTPUT=$2

if [[ -z ${FASTQ_LIST_CSV} || ! -f ${FASTQ_LIST_CSV} ]]; then
  echo "Invalid fastq_list.csv: ${FASTQ_LIST_CSV}"
  echo "./write_dragen_commands.sh FASTQ_LIST.csv OUTPUT"
  exit 1
else
  FASTQ_LIST_CSV=$(realpath ${FASTQ_LIST_CSV})
fi

if [[ -z ${OUTPUT} || ! -d ${OUTPUT} ]]; then
  echo "Output does not exist: ${OUTPUT}"
  echo "./write_dragen_commands.sh FASTQ_LIST.csv OUTPUT"
  exit 1
fi

echo "Reading ${FASTQ_LIST_CSV}"
cat ${FASTQ_LIST_CSV} | tail -n+2 | cut -d',' -f2 | sort | uniq |  while read -r SAMPLE; do
  echo "Processing Sample ${SAMPLE}"
  # SAMPLE=$(echo $line | cut -d',' -f2) 
  SAMPLE_OUTPUT=${OUTPUT}/${SAMPLE}
  mkdir -p ${SAMPLE_OUTPUT}
  dragen_cmd_file="${SAMPLE_OUTPUT}/DRAGEN_SCRNA___${SAMPLE}.sh"
  printf "#!/bin/bash\n\n" > ${dragen_cmd_file}
  echo "/opt/edico/bin/dragen \\" >> ${dragen_cmd_file}
  echo "  --enable-rna=true \\" >> ${dragen_cmd_file}
  echo "  --enable-single-cell-rna=true \\" >> ${dragen_cmd_file}
  echo "  -r ${REFERENCE_FILE} \\" >> ${dragen_cmd_file}
  echo "  -a ${ANNOTATION_FILE} \\" >> ${dragen_cmd_file}
  echo "  --fastq-list-sample-id ${SAMPLE} \\" >> ${dragen_cmd_file}
  echo "  --fastq-list ${FASTQ_LIST_CSV} \\" >> ${dragen_cmd_file}
  echo "  --umi-source=read1 \\" >> ${dragen_cmd_file}
  echo "  --output-dir=${OUTPUT} \\" >> ${dragen_cmd_file}
  echo "  --single-cell-barcode-position 0_15 \\" >> ${dragen_cmd_file}
  echo "  --single-cell-umi-position 16_25 \\" >> ${dragen_cmd_file}
  echo "  --output-file-prefix ${SAMPLE}" >> ${dragen_cmd_file}
done 
