if [[ -z "$1"  ||  -z "$2" || -z "$3" || -z "$4" ]]; then
  printf "usage: ./demultiplex_wrapper.sh {RUN_PATH} {SAMPLESHEET} {OUTPUT_DIRECTORY} {PIPELINE_CONFIG}\ne.g.\n\t"
  printf "./demultiplex_wrapper.sh /igo/sequencers/diana/201012_DIANA_0246_AHKWJLDSXY /home/igo/SampleSheetCopies/SampleSheet_201026_DIANA_0246_RP.csv /igo/work/FASTQ/DIANA_0248_AHL2WFDSXY_RP /home/streidd/work/lsf-bioinformatics/pipeline.config\n"
  exit 1
fi

RUNPATH=$1
SAMPLESHEET=$2
RUN=$(basename $RUNPATH)
OUTPUT=$3
LOG=${OUTPUT}/${RUN}_bcl2fastq.log
PIPELINE_CONFIG=$4

JOB_NAME=BCL2FASTQ:${RUN}

# load config
. $PIPELINE_CONFIG
echo "Running scripts in WORK_DIR: $WORK_DIR"

printf "Demultiplexing $RUN\n\tRunPath:\t$RUNPATH\n\tSampleSheet:\t$SAMPLESHEET\n"
mkdir -p $OUTPUT
touch $LOG
echo "Submitting $JOB_NAME to bsub"
echo "Log: $LOG"
echo "Writing to ${OUTPUT}"

# Run demultiplex cmmand
bsub -J $JOB_NAME -o ${OUTPUT}/${JOB_NAME}.out -e ${OUTPUT}/${JOB_NAME}.err -n 36 -M 6 "${WORK_DIR}/demultiplex.sh $RUNPATH $SAMPLESHEET ${OUTPUT} ${PIPELINE_CONFIG} >> $LOG 2>&1"
