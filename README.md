# OCTA TOOL -- The Opportunistic Cross-Talk Assessment tool

# Warning: Experimental repository
* This is not a complete program, and it's not ready for use yet, not 
even for testing. So far, this repo is more of a notebook, not for
public use.*

This program reads the statistics from Illumina's demultiplexing
tool bcl2fastq (version 2.17 and above), and makes an estimate of
the sample cross-talk (mis-assignment rate).

It relies on the method of TODO REF: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5097354/
in order to determine the mis-assignment, utilising dual indexed data.
This method consists of looking for combinations of (index1, index2)
in the index read data that don't correspond to actual samples. This
requires there to be some unique combinations...

## Requirements
The script is written in the Julia language, and thus requires the
Julia runtime, and it also requires the following packages:

 * Julia package: LibExpat
 * System library: ??? TODO

## Usage
Start the program specifying the run folder of the Illumina 
sequencing run to analyse:

$ julia octa.jl RUN_DIRECTORY_PATH

Alternatively, you can specify the path directly to the Stats 
directory written by bcl2fastq2 (e.g. in case you don't have the
full run directory tree).

## Output description


## Implementation details
The bcl2fastq2 software (TODO URL) produces an XML file 
DemultiplexingStats.xml. The index sequence of each sample and the
number of reads are read from this file. bcl2fastq2 also writes a
set of text-based summary files, DemuxSummaryF1L1.txt, which crucially
contain the 1000 most frequent *unknown* index sequences seen in the
data (i.e., indexes read from data which don't correspond to a sample
specified in the sample sheet). The program analyses and compares 
these statistics, and produces a table of the mis-assignment rate.





