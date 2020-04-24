# load config: need bcl2fastq
. /home/streidd/pipeline-scripts/pipeline.config
# bcl2fastq=/opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin/bcl2fastq

if [[ -z "$1"  ||  -z "$2" ]]
   then
      printf "please specify runpath & samplesheet file like - ./demultiplex.sh {RUN_PATH} {SAMPLESHEET}\ne.g.\n"
      printf "\t./demultiplex.sh /ifs/input/GCL/hiseq/michelle/200317_MICHELLE_0220_AH3YNYDSXY /home/upops/nyx__SampleSheets/SampleSheet_200317_MICHELLE_0220_AH3YNYDSXY.csv\n"
   exit 1
fi

RUNPATH=$1
SAMPLESHEET=$2
RUN=$(basename $RUNPATH)
OUTPUT=./${RUN}_bcl2fastq

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
   --no-lane-splitting 
