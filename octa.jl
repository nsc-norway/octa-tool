

function get_dm_summmary_path(stats_dir)
    stat_files = readdir(stat_dir)
    demux_summary_files = Dict()
    for filename = stat_files
    m = match(r"^DemuxSummaryF1L(\d)\.txt", filename)
    if (m != nothing)
        demux_summary_files[parse(Int, m.captures[1])] = joinpath(stat_dir, filename)
    end
    return demux_summary_files
end

function get_dm_summary(stats_dir)
    for lane, path = get_dm_summary_paths(stats_dir)
        
    end
end



function get_demultiplexing_xml()
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
    

end
