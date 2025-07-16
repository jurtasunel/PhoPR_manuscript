### This script process raw data for RNA-seq: quality check with fastqc, trimming with cutadapth, alingment with bowtie2 and samtools ###

#Call the subprocess module to run terminal commands from python.
import subprocess

#THINS TO DO BEFORE RUNING
#Create a list to store the files tags.
tags = ["R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "R11", "R12"]

#Create variables to store the suffixes for the forward and reverse reads.
Fsuffix = "_1.fq.gz"
Rsuffix = "_2.fq.gz"

#Create an index with bowtie2-build. OUTPUT NAME MUST BE THE SAME AS THE REFERENCE NAME ON THE ANNOTATION FILE.
#Create a variable to store the path of the reference sequence.
reference_path = "/path/to/reference_genome"

#FASTQC
#Loop through the tags.
for tag in tags:

    #Print current iteration.
    print(f"Creating fastqc reports. Current iteration is {tag}:")
    #Run fastqc command.
    fastqc_cmd = f"fastqc --threads 2 {tag}{Fsuffix} {tag}{Rsuffix}"
    result = subprocess.check_output(fastqc_cmd, shell = True)

#Ask for confirmation by keyboard to go into the trimming step.
confirmation = input("When you want to start the cutadapt step, type YES:\n")

#Don't continue until the confirmation is correct.
while confirmation != "YES":
    confirmation = input("When you want to start the cutadapt step, type YES:\n")

#CUTADAPT
#Ask for parameters by keyboard.
edges = input("Type the number of bases you want to trim:\n")
quality = input("Type the minimum quality of reads:\n")
lenght = input("Type the minimum length of the reads:\n")

#Loop trought the tags.
for tag in tags:

    #Print current iteration.
    print(f"Trimming the files with cutadapt. Current iteration is {tag}:")
    #Run cutadapt command.
    cutadapt_cmd = f"cutadapt --cut {edges} -U {edges} --quality-cutoff {quality},{quality} --minimum-length {lenght} -o {tag}_trimmed_1.fastq -p {tag}_trimmed_2.fastq {tag}{Fsuffix} {tag}{Rsuffix}"
    result = subprocess.check_output(cutadapt_cmd, shell = True)

#ALIGNMENT
#Loop through the tags.
for tag in tags:

    #Print current iteration and current files.
    print(f"Aligning trimmed fastq files with bowtie2. Current iteration is {tag}:\n{tag}_trimmed_1.fastq\n{tag}_trimmed_2.fastq")
    #Run bowtie2 command.
    bowtie2_cmd = f"bowtie2 --threads 4 -x {reference_path} -1 {tag}_trimmed_1.fastq -2 {tag}_trimmed_2.fastq -S {tag}.sam"
    result = subprocess.check_output(bowtie2_cmd, shell = True)

    #Convert sam file into bam with samtools view.
    samtools_view_cmd = f"samtools view -b --threads 4 {tag}.sam > {tag}.bam"
    result = subprocess.check_output(samtools_view_cmd, shell = True)
    #Remove the sam file once the bam is created to save space.
    rmv_sam_cmd = f"rm {tag}.sam"
    result = subprocess.check_output(rmv_sam_cmd, shell = True)

    #Sort the bam file with samtools sort.
    sort_cmd = f"samtools sort {tag}.bam -o {tag}_srtd.bam"
    result = subprocess.check_output(sort_cmd, shell = True)

