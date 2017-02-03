using LibExpat

function get_unknown_barcodes(stats_dir, lane)
    summary_path = joinpath(stats_dir, "DemuxSummaryF1L$(lane).txt")
    unknown_barcode_count = Dict()
    open(summary_path) do f
        found_unknown_bc_section = false
        for line = eachline(f)
            if found_unknown_bc_section
                if ! startswith(line, "###")
                    (barcode, count_str) = split(line, "\t")
                    unknown_barcode_count[barcode] = count_str
                end
            elseif strip(line) == "### Most Popular Unknown Index Sequences"
                found_unknown_bc_section = true
            end
        end
    end
    return unknown_barcode_count
end

function get_demultiplexing_stats(stats_dir)
    xml_path = joinpath(stats_dir, "DemultiplexingStats.xml")
    xmltree = xp_parse(readall(xml_path))
    mismatch_xpath = "Flowcell/Project[@name != \"all\"]/Sample/Barcode[@name != \"all\"]/Lane/BarcodeCount"
    mismatch_results = xmltree[mismatch_xpath]
    perfect_xpath = "Flowcell/Project[@name != \"all\"]/Sample/Barcode[@name != \"all\"]/Lane/PerfectBarcodeCount"
    perfect_results = xmltree[perfect_xpath]

    read_counts = Dict()
    perfect_read_counts = Dict()

    for res = mismatch_results
        lane = parse(Int,res.parent.attr["number"])
        barcode = res.parent.parent.attr["name"]
        
        read_counts[(lane, barcode)] = parse(Int64, res.elements[1])
    end
    return read_counts, perfect_read_counts
end

function analyse(sample_indexes, unknown_indexes, unknown_total_reads)
    # Generates array with index1s and index2s as elements
    sample_single_indexes = map(Set, zip(keys(sample_indexes)...))

    combinations = [(i1, i2)
            for i1 in sample_single_indexes[1],
            i2 in sample_single_indexes[2]
            ] 
    feasible = length(combinations) > length(sample_indexes)
    if ! feasible
        println("Sorry, all possible combinations have been used")
        return nothing
    end

    # Deal with index1 and index2 the same way, hold one fixed and test
    # the other
    in_known_samples = 0
    in_misassigned = 0
    for (fixed_i, test_i) = [(1,2), (2,1)]
        # Process all sample indexes one by one
        for index_seq = sample_single_indexes[fixed_i]
            # Compute the number of known, unknown reads for this fixed
            # single index
            for other_index_seq = sample_single_indexes[test_i]
                if fixed_i == 1
                    key = [index_seq, other_index_seq]
                else
                    key = [other_index_seq, index_seq]
                end
                in_known_samples += get(sample_indexes, key, 0)
                in_misassigned += get(unknown_indexes, key, 0)
            end
        end
    end
    return in_misassigned, in_known_samples
end


function process_path(path)
    if isdir(path)
        cand = joinpath(path, "Data", "Intensities", "BaseCalls", "Stats")
        if isdir(cand)
            return cand
        else
            return path
        end
    end # Raise hell
end

function main(path)
    stats_dir = process_path(path)

    (read_counts, perfect_read_counts) = get_demultiplexing_stats(stats_dir)
    lanes_with_dual_indexing = []
    for (lane, barcode) = keys(read_counts)
        if (contains(barcode, "+") || contains(barcode, "-"))
            push!(lanes_with_dual_indexing, lane)
        end
    end

    lanes = Set(map(coordinates -> coordinates[1], keys(read_counts)))

    for lane = lanes # TODO sort
        result = nothing
        if in(lane, lanes_with_dual_indexing)
            unknown_barcodes_raw = get_unknown_barcodes(stats_dir, lane)
            unknown_barcodes = Dict(
                        map(
                            x -> split(replace(x[1], "+", "-"), "-") => x[2],
                            unknown_barcodes_raw
                            )
                    )
            filtered_read_counts = filter((k, v) ->
                            (k[1] == lane && k[2] != "unknown"), read_counts)
            lane_read_counts = Dict(
                [split(replace(barcode, "+", "-"), "-") => read_count
                    for ((_,barcode), read_count) in filtered_read_counts]
                )
            unknown_total_reads = read_counts[(lane, "unknown")]
            result = analyse(lane_read_counts, unknown_barcodes, unknown_total_reads)
        end
        if result != nothing
            println(lane, "RESULT: ", result)
        else
            println(lane, "\tNA\tNA")
        end
    end
    
end

main("/home/fa2k/nsc/statfiles/1612/161228_D00132_0217_ACAJEMANXX")

