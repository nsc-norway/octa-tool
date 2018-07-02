from genologics.lims import *
from genologics import config

import sys

lims = Lims(config.BASEURI, config.USERNAME, config.PASSWORD)

first = True

for data in sys.stdin.readlines():
    print (data.rstrip(), end="")
    if first:
        print("\tLibraryPrep\tDups\tPF")
        first = False
        continue

    run_id, lanestr = data.split('\t')[0:2]
    library_prep = None
    dups = None
    pf = None

    if run_id[7] == "N":
        typename = "NextSeq Run (NextSeq) 1.0"
    elif run_id[7] == "M":
        typename = "MiSeq Run (MiSeq) 5.0"
    elif run_id[7] in "JK" or run_id[7:13] == "E0401":
        typename = "Illumina Sequencing (HiSeq 3000/4000) 1.0"
    elif run_id[7] == "E":
        typename = "Illumina Sequencing (HiSeq X) 1.0"
    else:
        print("\n\nFAILING:", run_id)

    processes = lims.get_processes(type=typename, udf={'Run ID': run_id})
    if processes:
        process = processes[0]
        try:
            inputs = process.all_inputs(unique=True)
            if len(inputs) == 1:
                i = inputs[0]
            else:
                i = next(lana for lana in process.all_inputs(unique=True) if lana.location[1] == "{}:1".format(lanestr))
            library_prep = i.samples[0].udf.get('Sample prep NSC')
            dups = i.udf.get('% Sequencing Duplicates')
            pf = i.udf.get('%PF R1')
        except:
            pass

    print("", library_prep, dups, pf, sep="\t")

