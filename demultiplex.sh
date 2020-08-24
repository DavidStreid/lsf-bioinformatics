# load config: need bcl2fastq

# bcl2fastq=/opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin/bcl2fastq

if [[ -z "$1"  ||  -z "$2" || -z "$3" || -z "$4" ]]; then
  printf "please specify runpath & samplesheet file like - ./demultiplex.sh {RUN_PATH} {SAMPLESHEET} {OUTPUT_DIR} {PIPELINE_CONFIG}\ne.g.\n"
  printf "\t./demultiplex.sh /igo/sequencers/jax/200821_JAX_0461_AHHYJ5BBXY /home/igo/SampleSheetCopies/SampleSheet_200821_JAX_0461_AHHYJ5BBXY_A1.csv /igo/work/FASTQ/JAX_0461_AHHYJ5BBXY_A1\n"
  exit 1
fi

PIPELINE_CONFIG=$4
. $PIPELINE_CONFIG

RUNPATH=$1
SAMPLESHEET=$2
RUN=$(basename $RUNPATH)
OUTPUT=$3

printf "Demultiplexing $RUN\n\tRunPath:\t$RUNPATH\n\tSampleSheet:\t$SAMPLESHEET\n"

$bcl2fastq \
   --minimum-trimmed-read-length 0 \
   --mask-short-adapter-reads 0 \
   --ignore-missing-bcl \
   --runfolder-dir  $RUNPATH \
   --sample-sheet $SAMPLESHEET \
   --output-dir $OUTPUT \
   --ignore-missing-filter \
   --ignore-missing-positions \
   --ignore-missing-control \
   --barcode-mismatches 1 \
   --no-lane-splitting \
   --loading-threads 12 \
   --processing-threads 24
