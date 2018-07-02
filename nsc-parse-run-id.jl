for line = readlines()
    firstbox = search(line, '\t')
    if firstbox != 0
        run_id = line[1:firstbox]
        if isdigit(run_id[1])
            print("20$(run_id[1:2])-$(run_id[3:4])-$(run_id[5:6])")
        else
            print("Date")
        end
        print('\t')
        machine_id = run_id[8:search(run_id, '_', 8)-1]
        if in(machine_id, ["NB501273", "NS500336"])
            print("NS")
        elseif in(machine_id, ["M01132", "M01334", "M02980"])
            print("MS")
        elseif in(machine_id, ["J00146", "E00401"])
            print("H4")
        elseif in(machine_id, ["E00423"])
            print("HX")
        else
            print("Instrument")
        end
        print('\t')
        println(line[firstbox+1:end])
    end
end
