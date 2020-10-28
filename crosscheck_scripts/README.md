# Run CROSSCHECK on an input directory of BAM files. BAMs MUST follow this naming,
`DIANA_0246_AHKWJLDSXY_RP___P09863_C___CH16_PIL_7_IGO_09863_C_7___hg19___MD.bam`

# Steps
1) Run `make_rg_bam.sh`
2) Add all the `headers.bam` files created to a file (e.g. `find ../bam_headers -type f -name "*headers.bam" > CrosscheckFingerprints_bam_input.txt`)
3) Run `run_crosscheck.sh`
