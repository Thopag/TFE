using Plots,LaTeXStrings,DifferentialEquations,Statistics

include("gates.jl")

i_scenario = 2
list_scenarios = ["BT","SS"]

include("param_n1.jl")
include("param_n2.jl")
include("currents.jl")
include("network_events.jl")
include("indices_network.jl")
include("ic_n2.jl")

ti1=200
tf1=350

    if list_scenarios[i_scenario] == "BT"
        T=2000
        mul_pulse(t,n)=sum(pulse(t,ti1+(i-1)*T,tf1+(i-1)*T) for i=1:n) #burst-like stimulation 
        println("Burst-like stimulation ")
    end
    if list_scenarios[i_scenario] == "SS"        
        T=2000
        mul_pulse(t,n)=sum(pulse(t,ti1+(i-1)*T,ti1+25+(i-1)*T) for i=1:n) #single-spike-like stimulation
        println("Single-spike-like stimulation ")
    end
    stop_pulse(n) = [ti1+(i-1)*T for i=1:n] #help for solver in single-spike-like stimulation

    p_indices = indices_states(p_syn_var_n1,p_syn_var_n2)
    
    w_NMDA___n1_to_n2 = 0.003*8     #w_NMDA
    w_AMPA___n1_to_n2 = 0.00225*8   #w_AMPA

    d_NMDA___n1_to_n2 = 0.5         #d_NMDA
    d_AMPA___n1_to_n2 = 0.5         #d_AMPA

    p_conn_d___n1_to_n2 = [d_NMDA___n1_to_n2,d_AMPA___n1_to_n2]
    p_conn_w___n1_to_n2 = [w_NMDA___n1_to_n2,w_AMPA___n1_to_n2]

include("solver_fun_event__.jl")
    
    tmax = 15000.
    n_pulse = Int(ceil((tmax/T)))
    if list_scenarios[i_scenario] == "BT"
        I_n1(t) = (0. /10^6) +(10 /10^6)*(mul_pulse(t,n_pulse))
    else
        I_n1(t) = (0. /10^6) +(5 /10^6)*(mul_pulse(t,n_pulse)) 
    end
    loc_spk(v) = [1*(v[i]>0 && v[i-1]<0) for i in 2:length(v)]
    n_spk_per_burst(v,t,T) = [sum(loc_spk(v[t .>=(i-1)*T .&& t .<(i)*T])) for i in 1:n_pulse]

    p_glob_n1_I_ = (I_n1)
    p_glob_n1_ = (p_glob_n1_I_,p_glob_n1[2:end]...)
    p_n1 = (p_glob_n1_,((p_fixed_n1,p_var_n1),(p_syn_fixed_n1,p_syn_var_n1)),((0,0,0),(0,0,0)))
    p_n2 = (p_glob_n2,((p_fixed_n2,p_var_n2),(p_syn_fixed_n2,p_syn_var_n2)),(p_conn_w___n1_to_n2,p_conn_d___n1_to_n2))
    p_net = (p_n1,p_n2,p_indices)

    ic = vcat(ic_n1,ic_n2)

    dt_=0.1
    saveat_range = 0:dt_:tmax
    ind_to_save = vcat(p_indices[1][1],p_indices[2][1],p_indices[2][3],p_indices[2][2])

prob = ODEProblem(network!,ic,(0.,tmax),p_net)
@time sol_all =solve(prob,Rodas5(),callback=cbs,save_idxs = ind_to_save,tstops = stop_pulse(n_pulse))


include("show_sim_network.jl")
## Display voltages
    plt_V_n1_n2 = plt_x_ni(sol_all.t,[[sol_all[1,:]],[sol_all[2,:]]],[["V (n1)"],["V (n2)"]],(-100,50),[pal,pal_offset])

## Display number of spikes per burst
    n_spk_per_burst_n1 = n_spk_per_burst(sol_all[1,:],sol_all.t,T)
    plt_n_spk_n1 = plot()
    # plot!(0:(n_pulse+1),0 .*(0:n_pulse+1) .+ mean(n_spk_per_burst_n1) .- std(n_spk_per_burst_n1),fillrange=0 .*(0:n_pulse+1) .+ mean(n_spk_per_burst_n1) .+ std(n_spk_per_burst_n1),fillcolor=:purple,lc=:black,lw=0,ls=:dash,label=L"\pm \sigma",fillalpha=0.15)
    bar!(n_spk_per_burst_n1,label=L"n_{spikes}"*" per burst ",fontfamily="Computer Modern",color=pal[1])
    plot!(0:(n_pulse+1),0 .*(0:n_pulse+1) .+ mean(n_spk_per_burst_n1),lc=:black,lw=2,ls=:dash,label="Average")
    plot!(ylims=(floor(minimum(n_spk_per_burst_n1*0.9)),ceil(maximum(n_spk_per_burst_n1)*1.1)))

    n_spk_per_burst_n2 = n_spk_per_burst(sol_all[2,:],sol_all.t,T)
    plt_n_spk_n2 = plot()
    # plot!(0:(n_pulse+1),0 .*(0:n_pulse+1) .+ mean(n_spk_per_burst_n2) .- std(n_spk_per_burst_n2),fillrange=0 .*(0:n_pulse+1) .+ mean(n_spk_per_burst_n2) .+ std(n_spk_per_burst_n2),fillcolor=:purple,lc=:black,lw=0,ls=:dash,label=L"\pm \sigma",fillalpha=0.15)
    bar!(n_spk_per_burst_n2,label=L"n_{spikes}"*" per burst ",fontfamily="Computer Modern",color=pal_offset[1])
    plot!(0:(n_pulse+1),0 .*(0:n_pulse+1) .+ mean(n_spk_per_burst_n2),lc=:black,lw=2,ls=:dash,label="Average")
    plot!(ylims=(floor(minimum(n_spk_per_burst_n2*0.9)),ceil(maximum(n_spk_per_burst_n2)*1.1)),xlabel="Burst id")

    plot(plt_n_spk_n1,plt_n_spk_n2,layout=(2,1),fontfamily="Computer Modern",size=(600,600),xticks=1:length(n_spk_per_burst_n1),ylabel="Number of spikes")
   
## Display the applied current
    plot(sol_all.t,I_n1.(sol_all.t)*10^6,ylabel="Current on n1 [pA]", fontfamily="Computer Modern")
    plot(sol_all.t,I_n1.(sol_all.t)./(2*pi*(D/2)*L *10^(-8) ),ylabel="Current on n1 [µA/cm2]", fontfamily="Computer Modern")


## Display synaptic processes
    plt_xsyn_n2 = plt_x_ni(sol_all.t,[[sol_all[3,:],sol_all[4,:],sol_all[5,:],sol_all[6,:],sol_all[4,:].-sol_all[3,:]],[sol_all[7,:],sol_all[8,:],sol_all[9,:],sol_all[10,:],sol_all[8,:].-sol_all[7,:]]],[["A_NMDA (n2)","B_NMDA (n2)","Use_NMDA (n2)","P_NMDA (n2)","B_NMDA - A_NMDA (n2)"],["A_AMPA (n2)","B_AMPA (n2)","Use_AMPA (n2)","P_AMPA (n2)","B_AMPA - A_AMPA (n2)"]],(),[palette(:rainbow),palette(:rainbow)])
## Display calcium concentrations
#     plt_Ca_n2 = plt_x_ni(sol_all.t,[[sol_all[end,:]]],[["Ca (n2)"]],(),[pal_offset])

# tp_NMDA = (tau_rise_NMDA*tau_decay_NMDA)/(tau_decay_NMDA-tau_rise_NMDA)*log(tau_decay_NMDA/tau_rise_NMDA)
# fact_NMDA = 1/(-exp(-tp_NMDA/tau_rise_NMDA)+exp(-tp_NMDA/tau_decay_NMDA))

# tp_AMPA = (tau_rise_AMPA*tau_decay_AMPA)/(tau_decay_AMPA-tau_rise_AMPA)*log(tau_decay_AMPA/tau_rise_AMPA)
# fact_AMPA = 1/(-exp(-tp_AMPA/tau_rise_AMPA)+exp(-tp_AMPA/tau_decay_AMPA))
    

# ## Display some currents
     plt_I_n2 = plot(fontfamily="Computer Modern",palette=:tab10)
     plot!(sol_all.t,-(sol_all[8,:].-sol_all[7,:]).*(sol_all[2,:].-eAMPA),label="-I_AMPA (n2)",lc=palette(:tab10)[7],lw=2,ylabel="I [µA/cm2]") 
     plot!(sol_all.t,-(sol_all[4,:].-sol_all[3,:]).*NMDA_Mg_block.(sol_all[2,:]).*(sol_all[2,:].-eNMDA),label="-I_NMDA (n2)",lc=palette(:tab10)[6],lw=2,ylabel="I [µA/cm2]") 
    #  plot!(sol_all.t,-(sol_all[4,:].-sol_all[3,:]).*NMDA_Mg_block.(sol_all[2,:]).*(sol_all[2,:].-eNMDA)-(sol_all[8,:].-sol_all[7,:]).*(sol_all[2,:].-eAMPA),label="-I_NMDA -I_AMPA (n2)",lc=palette(:tab10)[5],lw=2,ylabel="I [µA/cm2]") 
   
## Display bump with NMDA current 
#     plt_bump_V = plot(sol_all.t,sol_all[2,:],label="V (n2)",lc=palette(:seaborn_colorblind6)[4],lw=2)
#     plot(plt_bump_V,plt_bump_sum_I,layout=(2,1))
