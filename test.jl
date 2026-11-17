

function dichotomic_search(arr, cond)
    L = length(arr)
    low = 1
    high = L
    i= 0
    while (low <= high)
        println("begining : $(low) -- $(high)")
        mid = low + div(high - low, 2) # Find the midpoint safely
        println("mid : $(mid)")

        if cond(arr[mid])
            # If condition is true, narrow down to the lower half
            high = mid - 1
        else
            # If condition is false, narrow down to the upper half
            low = mid + 1
            if low >= L
                return L
            end
        end
        println("end : $(low) -- $(high)")
        i += 1
    end
    println(i)
    return low # Returns the boundary index where the condition flips
end

function cond(a)
    v = -2
    if a < v
        return false
    else
        return true
    end
end

function main()
    arr = 0:3:400

    idx = dichotomic_search(arr, cond)
    println("Found at index: $idx (Value: $(arr[idx]))")
end

main()