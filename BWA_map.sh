#!/bin/bash
#SBATCH -N 1            # number of nodes
#SBATCH -n 1            # number of "tasks" (default: 1 core per task)
#SBATCH -t 2-04:00:00   # time in d-hh:mm:ss
#SBATCH -p general      # partition
#SBATCH -q public       # QOS
#SBATCH -o slurm.%j.out # file to save job's STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err # file to save job's STDERR (%j = JobId)
#SBATCH --export=NONE   # Purge the job-submitting shell environment
#SBATCH --mem=60GB

module load bwa-0.7.17-gcc-12.1.0

bwa index ../fastas/MERLIN.fasta

for file in ../trimmed/*_1.fastq
     do
        sample=$(basename "$file" _1.fastq)
        dir_loc=$(dirname "$file")
	tag="${file%%[ _]*}"
        name=$(basename $tag)
        while IFS="," read -r column1 column2 column3
        do
bwa mem -k "$column2" "../fastas/MERLIN.fasta" "$file" "$dir_loc"/"$sample"_2.fastq > ../mapped/"$sample"_BWA_"$column1"_MERLIN.sam

bwa index ../fastas/${name}.fasta

bwa mem -k "$column2" "../fastas/${name}.fasta" "$file" "$dir_loc"/"$sample"_2.fastq > ../mapped/"$sample"_BWA_"$column1"_${name}.sam

	done < <(sed -n '2p' +2 BWA_param.csv)
done
