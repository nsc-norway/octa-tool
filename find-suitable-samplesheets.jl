
for fp = ARGS
    index1col = -1
    index2col = -1
    index1s = []
    index2s = []
    indexes = []
    for l = eachline(open(fp))
        parts = [lowercase(part) for part=split(l, ",")]
        if "index" in parts && "index2" in parts
            index1col = findfirst(parts, "index")
            index2col = findfirst(parts, "index2")
        elseif index1col != -1
            push!(index1s, parts[index1col])
            push!(index2s, parts[index2col])
            push!(indexes, (parts[index1col], parts[index2col]))
        end
    end
    permutations = Set([(i1, i2) for i1=index1s, i2=index2s])
    known = Set(indexes)
    unknown = setdiff(permutations, known)
    if !isempty(unknown)
        println(basename(dirname(fp)), ": ", join(unknown, ","))
    end
end
