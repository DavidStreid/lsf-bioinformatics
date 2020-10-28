# !/bin/bash
# Executes CrossCheck on runs of certain naming convention across multiple input folders
# Run: 
#   ./make_rg_bam.sh -d /igo/stats/DIANA_0246_AHKWJLDSXY_RP

while getopts d: flag
do
    case "${flag}" in
	d) DIRS="${DIRS} ${OPTARG}";;
    esac
done

if [[ -z "$DIRS" ]]; then
  echo "No input DIRs"
  echo "usage: make_rg_bam.sh -d {DIR}"
  exit 1
fi

BAMS=""
for dir in $DIRS; do
  DIR_BAMS=$(find $dir -type f -name "*___MD.bam")
  BAMS="${BAMS} ${DIR_BAMS}"
done

for bam in $BAMS; do
  bam_file=$(basename $bam)
  BAM_ROOT=$(echo ${bam_file} | sed 's/.bam//g')
  SM_TAG=$(echo ${bam_file} | grep -oP "(?<=IGO_).*?(?=___)")
  JOB_NAME=READ_GROUP:${bam_file}
  OUTPUT_BAM=${BAM_ROOT}_headers.bam

  # "@RG	ID:JAX_0378_BHFHF5BBXY LB:JAX_0378_BHFHF5BBXY..." -> "JAX_0378_BHFHF5BBXY"
  LB=$(samtools view -H ${bam} | grep RG | grep -oP "(?<=LB:)[^\\s]+" | head -1)
  PL="illumina" # $(samtools view -H ${bam} | grep RG | grep -oP "(?<=PL:)[^\\s]+" | head -1)
  PU=$(samtools view -H ${bam} | grep RG | grep -oP "(?<=PU:)[^\\s]+" | head -1)

  if [[ -z "$LB" ]]; then
    LB="Unknown"
  fi
  if [[ -z "$PU" ]]; then
    PU="Unknown"
  fi

  echo "RGSM=${SM_TAG} I=${bam_file} O=${OUTPUT_BAM}"
  echo "LB=${LB} PL=${PL} PU=${PU}"
  bsub -J ${JOB_NAME} -e ${JOB_NAME}_error.log -o ${JOB_NAME}.log -n 2 -M 12 "java -jar /home/streidd/dependencies/picard/picard.jar AddOrReplaceReadGroups \
     	I=$bam \
      	O=${OUTPUT_BAM} \
      	SO=coordinate \
      	CREATE_INDEX=true \
      	RGLB=${LB} \
      	RGPL=${PL} \
      	RGPU=${PU} \
      	RGCN=IGO@MSKCC \
      	RGSM=${SM_TAG} "
done
