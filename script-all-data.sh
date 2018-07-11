
julia diag.jl /data/runScratch.boston/demultiplexed/completed/1*/* | python nsc-lims-add-info.py | julia nsc-parse-run-id.jl | sed 's/None/NA/g' | tee all-stats.txt
