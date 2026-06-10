using Plots,LaTeXStrings,DifferentialEquations

include("gates.jl")

    ## Fixed parameters
    C = 1 #µF/cm²
    eNa = 50 # [mV]
    eK = -70 # [mV]
    eK_ais = -77 # [mV]
    eCa = 132.46 # [mV]
    eleak = -65 # [mV]
    eNMDA = 0 # [mV]
    eAMPA = 0 # [mV]
    Ca_o = 2 # Extracellular Ca concentration [mM]

    ## Intracellular calcium dynamics parameters
    k = 1.0e4 # [µm.cm^(-1)] 
    F = 96480 #96520 # Faraday default value [C/mol]
    d = 0.1 # [µm]
    Ca_i_0 = 5.0e-5 # Initial intracellular Ca concentration [mM]
    tau_Ca = 2 # [ms]
    tau_Ca_soma = 1 # [ms]

    ## Compartment parameters
    Ra = 150 # Axial resistivity in [ohm.cm]
    L = 20 #[µm] 
    D = 20 #[µm] 

    ## Stimulation 
    I_s_n1(t) = (0/10^6) 

    p_glob_n1 = (I_s_n1,k,F,L,D)
    p_fixed_n1 = (C,eNa,eK,eCa,eleak,Ca_o,Ca_i_0,tau_Ca,d,Ra)
  
    ## Initial conditions
    V_ic = -66.5 # [mV]
    Ca_ic = 5.0e-5 # [mM]
    A_ic = 0
    B_ic = 0
    Use_ic = 0
    P_ic = 1
    mKir_ic = 1
    ic_n1 = [V_ic,mNa(V_ic),hNa(V_ic),mKDR(V_ic),Ca_ic,
        #A_ic,B_ic,Use_ic,P_ic,A_ic,B_ic,Use_ic,P_ic,A_ic,B_ic,Use_ic,P_ic,mKir(V_ic)
        ]

    ## Varying parameters
    gNa_s = 30 #mS/cm²
    gKDR_s = 4 #mS/cm²
    gleak_s =  0.03268  #mS/cm²

    gNa_d = 30 #mS/cm²
    gKDR_d = 4 #mS/cm²
    gleak_d =  0.03268  #mS/cm²

    gNa_a = 30 #mS/cm²
    gKDR_a = 4 #mS/cm²
    gleak_a =  0.03268  #mS/cm²

    p_var_n1 = (gNa_d,gKDR_d,gleak_d)

    #to check if these values are not changed in other files of Medlock 
    U1_NMDA = 1.            #[.]
    tau_rise_NMDA = 2.      #[ms]
    tau_decay_NMDA = 100.   #[ms]
    tau_fac_NMDA = 0.1      #[ms]
    tau_rec_NMDA = 0.1      #[ms]
    U1_AMPA = 1.            #[.]
    tau_rise_AMPA = 0.1     #[ms]
    tau_decay_AMPA = 5.     #[ms]
    tau_fac_AMPA = 0.1      #[ms]
    tau_rec_AMPA = 0.1      #[ms]
    ratio_ICa_of_INMDA = 0.1 #[.]
    p_syn_fixed_n1 = (eNMDA,eAMPA,U1_NMDA,tau_rise_NMDA,tau_decay_NMDA,tau_fac_NMDA,tau_rec_NMDA,U1_AMPA,tau_rise_AMPA,tau_decay_AMPA,tau_fac_AMPA,tau_rec_AMPA,ratio_ICa_of_INMDA)

    gNMDA = 0 #mS/cm²
    gAMPA = 0 #mS/cm²
    gGRPR = 0 #mS/cm²
    p_syn_var_n1 = (gNMDA,gAMPA)

