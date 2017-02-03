using LibExpat

function get_dm_summary_paths(stats_dir)
    stat_files = readdir(stats_dir)
    demux_summary_files = Dict()
    for filename = stat_files
        m = match(r"^DemuxSummaryF1L(\d)\.txt", filename)
        if (m != nothing)
            demux_summary_files[parse(Int, m.captures[1])] =
                    joinpath(stats_dir, filename)
        end
    end
    return demux_summary_files
end

function get_unknown_barcodes(stats_dir, lane)
    summary_path = joinpath(stats_dir, "DemuxSummaryF1L$(lane).txt")
    unknown_barcode_count = Dict()
    open(summary_path) do f
        found_unknown_bc_section = false
        for line = eachline(f)
            if found_unknown_bc_section
                if ! startswith(line, "###")
                    barcode = "Lol"
                    count = 1
                    unknown_barcode_count[barcode] = count
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

function analyse(sample_barcodes, unknown_barcodes)
    # TODO analysis
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

    for lane = lanes
        if in(lane, lanes_with_dual_indexing)
            unknown_barcodes = get_unknown_barcodes(stats_dir, lane)
            lane_read_counts = Dict(
                [replace(barcode, "+", "-") => read_count
                    for ((lane,barcode), read_count) in read_counts]
                )
            analyse(lane_read_counts, unknown_barcodes)
            println(lane, "\t?\tNA")
        else
            println(lane, "\tNA\tNA")
        end
    end
    
end

main("/home/fa2k/nsc/statfiles/170113_NB501273_0042_AHTKM2BGXY")

