if [[ -z "$1"  ||  -z "$2" ]]
   then
      printf "please specify runpath & samplesheet file like - ./demultiplex.sh {RUN_PATH} {SAMPLESHEET}\ne.g.\n"
      printf "\tdemultiplex /ifs/input/GCL/hiseq/michelle/200317_MICHELLE_0220_AH3YNYDSXY /home/upops/nyx__SampleSheets/SampleSheet_200317_MICHELLE_0220_AH3YNYDSXY.csv\n"
   exit 1
fi

RUNPATH=$1
SAMPLESHEET=$2
RUN=$(basename $RUNPATH)
OUTPUT=./${RUN}_bcl2fastq
LOG=${OUTPUT}/${RUN}_bcl2fastq.log

JOB_NAME=BCL2FASTQ:${RUN}

# load config
. /home/streidd/pipeline-scripts/pipeline.config
echo "Running scripts in WORK_DIR: $WORK_DIR"

printf "Demultiplexing $RUN\n\tRunPath:\t$RUNPATH\n\tSampleSheet:\t$SAMPLESHEET\n"
mkdir -p $OUTPUT
touch $LOG
echo "Log: $LOG"

echo "Please provide an LSF node to run on"
read LSF_NODE

echo "Submitting $JOB_NAME to bsub"
# Run demultiplex cmmand
bsub -J $JOB_NAME -o ${OUTPUT}/${JOB_NAME}.out -m $LSF_NODE -n 72 -M 6 "${WORK_DIR}/demultiplex.sh $RUNPATH $SAMPLESHEET >> $LOG 2>&1"
