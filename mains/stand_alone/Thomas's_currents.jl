
function compute_in_out_Iions(Iion_s)
    ## Compute in and out currents vector for each "complete" current vector in soma
    Iion_in_s = []
    Iion_out_s = []
    for i in eachindex(Iion_s)
        Iion_in = zeros(size(Iion_s[i]))
        Iion_in[Iion_s[i].<0].=Iion_s[i][Iion_s[i].<0] #Negative current is inward
        Iion_out =zeros(size(Iion_s[i])) 
        Iion_out[Iion_s[i].>0].=Iion_s[i][Iion_s[i].>0] #Positive current is outward
        push!(Iion_in_s,Iion_in)
        push!(Iion_out_s,Iion_out)
    end
    
    ## Compute total in and out currents in soma 
    sum_in_Iion_s = sum(Iion_in_s) #[µA/cm²] 
    sum_out_Iion_s = sum(Iion_out_s) #[µA/cm²] 

    ## Sum in and out currents in all compartments (only one here)
    Iion_all = [(Iion_s[i]) for i in eachindex(Iion_s)]
    Iion_all_in = [(Iion_in_s[i]) for i in eachindex(Iion_in_s)]
    Iion_all_out = [(Iion_out_s[i]) for i in eachindex(Iion_out_s)]
    sum_in_Iion_all =  sum_in_Iion_s  #[µA/cm²] 
    sum_out_Iion_all = sum_out_Iion_s #[µA/cm²] 

    return Iion_all,Iion_all_in,Iion_all_out,sum_in_Iion_all,sum_out_Iion_all
end

function display_in_out_ratios(Iion_all_in,sum_in_Iion_all,Iion_all_out,sum_out_Iion_all)
    ## Initializing plots
    plt_in = Plots.plot() 
    Plots.plot!(plt_in,xlabel="t [min]",ylabel="%in",grid=:none)
    Plots.plot!(plt_in,legend=:outertopright,fontfamily="Computer Modern")#,legendfontsize=15,xlabelfontsize=15,ylabelfontsize=15,tickfontsize=15)
    plt_out = Plots.plot() 
    Plots.plot!(xlabel="t [min]",ylabel="%out",grid=:none)
    Plots.plot!(legend=:outertopright,fontfamily="Computer Modern")#,legendfontsize=15,xlabelfontsize=15,ylabelfontsize=15,tickfontsize=15)
    
    ## Initializing sum of previous Iion in or out already considered in the loop, and the ratio in total sum of ion currents (in or out)
    sum_in_prev = []
    ratio_in_prev = []
    sum_out_prev = []
    ratio_out_prev = []

    ## Display ratio of each inward and outward current in total inward or outward current
    for i in eachindex(Iion_all_in)
        i_max_t = length(t)
        if i>1 
            #Compute current sum of all Iion already considered, and the corresponding ratio of total current  
            sum_in_current = Iion_all_in[i].+sum_in_prev[end]
            ratio_in_current = abs.(sum_in_current./sum_in_Iion_all)
            if maximum(ratio_in_current)>1e-6  && maximum(abs.(Iion_all_in[i]./sum_in_Iion_all))>1e-6
                #Display the ratio of total inward current in the plot, from previous ratio to current ratio (filled color correspond to the contribution of Iion[i])
                plot!(plt_in,t[1:i_max_t]./1000 ./60,ratio_in_current,fillrange=ratio_in_prev[end],fillcolor=pal_Iion[i],label=lab_Ix[i],lc=pal_Iion[i],fillalpha=0.95,ylims=(-0.1,1))
                display(plt_in)
            end
        else 
            #First current considered 
            sum_in_current = Iion_all_in[i]
            ratio_in_current = abs.(sum_in_current./sum_in_Iion_all)
            if maximum(abs.(Iion_all_in[i]./sum_in_Iion_all))>1e-6
                #Display the ratio of total inward current in the plot, from 0 to current ratio (filled color correspond to the contribution of Iion[i])
                plot!(plt_in,t[1:i_max_t]./1000 ./60,ratio_in_current,fillrange=0 .*sum_in_Iion_all,fillcolor=pal_Iion[i],lc=pal_Iion[i],fillalpha=0.95,label=lab_Ix[i],ylims=(-0.1,1))
                display(plt_in)
            end
        end
        push!(sum_in_prev,sum_in_current)
        push!(ratio_in_prev,ratio_in_current)

        if i>1 
            #Compute current sum of all Iion already considered, and the corresponding ratio of total current  
            sum_out_current = Iion_all_out[i].+sum_out_prev[end]
            ratio_out_current = abs.(sum_out_current./sum_out_Iion_all)
            if maximum(ratio_out_current)>1e-6 && maximum(abs.(Iion_all_out[i]./sum_out_Iion_all))>1e-6
                #Display the ratio of total inward current in the plot, from previous ratio to current ratio (filled color correspond to the contribution of Iion[i])
                plot!(plt_out,t[1:i_max_t]./1000 ./60,ratio_out_current,fillrange=ratio_out_prev[end],fillcolor=pal_Iion[i],label=lab_Ix[i],lc=pal_Iion[i],fillalpha=0.95,ylims=(-0.1,1))
                display(plt_out)
            end
        else 
            #First current considered 
            sum_out_current = Iion_all_out[i]
            ratio_out_current = abs.(sum_out_current./sum_out_Iion_all)
            if maximum(abs.(Iion_all_out[i]./sum_out_Iion_all))>1e-6
                #Display the ratio of total inward current in the plot, from 0 to current ratio (filled color correspond to the contribution of Iion[i])
                plot!(plt_out,t[1:i_max_t]./1000 ./60,ratio_out_current,fillrange=0 .*sum_out_Iion_all,fillcolor=pal_Iion[i],lc=pal_Iion[i],fillalpha=0.95,label=lab_Ix[i],ylims=(-0.1,1))
                display(plt_out)
            end
        end
        push!(sum_out_prev,sum_out_current)
        push!(ratio_out_prev,ratio_out_current)
        display(plt_out)
    end
    display(plt_in)
    display(plt_out)
    return plt_in,plt_out
end

global lab_Ix = ["INa","IBNa","IKDR","IKDRI","IKA","IKCa","IKir","Ileak"]
global pal_Iion = palette(:tab10,rev=true)[vcat(1:4,6:7,[8],[10])]

Iion_s = [INa_s,IBNa_s,IKDR_s,IKDRI_s,IKA_s,IKCa_s,IKir_s,Ileak_s]
    
Iion_all,Iion_all_in,Iion_all_out,sum_in_Iion_all,sum_out_Iion_all = compute_in_out_Iions(Iion_s)

plt_in,plt_out = display_in_out_ratios(Iion_all_in,sum_in_Iion_all,Iion_all_out,sum_out_Iion_all);
plt_ratio = plot(plt_in,plt_out,layout=(2,1),size=(800,400))
