

function compute_ccg(spikes_A::Vector{Float64}, spikes_B::Vector{Float64}; bin_width=1.0, window=50.0)
    lags = Float64[]
    
    for t_a in spikes_A
        # Range search: find spikes in B within [t_a - window, t_a + window]
        idx_start = searchsortedfirst(spikes_B, t_a - window)
        idx_end = searchsortedlast(spikes_B, t_a + window)
        
        for idx in idx_start:idx_end
            push!(lags, spikes_B[idx] - t_a)
        end
    end
    
    # Define bin edges centered around 0
    edges = -window:bin_width:window
    counts = zeros(Int, length(edges) - 1)

    # Bin the time lags
    for lag in lags
        bin_idx = floor(Int, (lag + window) / bin_width) + 1
        if 1 <= bin_idx <= length(counts)
            counts[bin_idx] += 1
        end
    end

    bin_centers = collect(edges[1:end-1] .+ bin_width / 2)
    return bin_centers, counts
end