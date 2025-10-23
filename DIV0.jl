using Plots
using ColorSchemes
include("equations_code.jl")

function smallDRG_DIV0(amp, duration, stim_on, stim_length)

    with_noise = true

    # --- Cell Properties --- #

    # Cell Morphology
    r = 11.63                           # [µm] cell radius
    CellArea = 4*pi*(r^2)               # [µm2] cell area (sphere)
    SAV = 3/(r*10^-4)                   # surface area to volume ratio (µm to cm)

    # Cell Capacitance:
    Cr = 17                             # [pF] 
    C = (Cr/CellArea)*100               # [µF/cm^2]

    # Cell Resistance:
    # Rr = 2.5                          # real cell resistance in [GOhms]
    # R = (Rr * CellArea)*10            # model cell resistance in [Ohms*cm^2]

    # Reversal Potential 
    Ena = 50                            # [mV]
    Ek = -90                            # [mV]
    ELeak = -62.5                       # [mV] mean RMP of DIV0 neurons = -62.5196 after JP correction(+15mV)

    # **** BASELINE: rheo = 17pA
    gLeak = 0.025                       #(1/Rr)/CellArea*(10^2); # [mS/cm2] normalized by cell area
    gAHP =  2.5 
    gKm = 0.05
    gKdr = 3.5 
    beta_z_AHP = 5                      # [mV]
    gamma_z =  4                        # [mV] - same for gAHP and gM
    tau_z = 100

    # ** Na conductances
    g_nav1p3 = 0 
    g_nav1p8 = 30                       # native
    g_nav1p7 = 3                        # native 
    # g_nav1p9 = 0

    # **** PHARMACOLOGY
    # g_nav1p8 = 4                      # 90% block - rheo = 17pA

    # **** DYNAMIC CLAMP EXPERIMENT
    # g_nav1p7 = 40                     # rheo = 6 pA

    # --- Stimulus parameters --- #

    dt = 0.01                           # time step for forward euler method
    loop  = Int(duration/dt)            # no. of iterations of euler
    stim_off = stim_on + stim_length    # [ms]

    # --- Noise parameters --- #

    mu_noise = 0
    tau_noise = 5                       #(ms)
    sigma_noise = 0.05                  # 0.1 # !sigma(noise) !0.5 uA/cm2

    # ----- Initialize empty vectors ----- #

    V = zeros(loop)

    INaV1p3 = zeros(loop) 
    INaV1p7 = zeros(loop)
    INaV1p8 = zeros(loop)
    IKdr = zeros(loop)
    IKm = zeros(loop)
    ILeak = zeros(loop)
    IAHP = zeros(loop)
    Ihold = -3
    Istim = zeros(loop) .+ (Ihold*(10^-6))/(CellArea*(10^-8)) # convert pA to um/cm2
    Inoise = zeros(loop)

    m3 = zeros(loop) 
    m7 = zeros(loop)
    h7 = zeros(loop) 
    h3 = zeros(loop) 
    m8 = zeros(loop)
    h8 = zeros(loop)

    ndr = zeros(loop)
    ldr = zeros(loop)
    nm = zeros(loop)

    z_AHP = zeros(loop)                 # Prescott et al. 2008

    spike = zeros(loop)
    ref = zeros(loop)

    # --- Set initial values --- #

    m3[1] = 0
    m7[1] = 0
    m8[1] = 0
    h3[1] = 0
    h7[1] = 0
    h8[1] = 0.9952

    ndr[1] =  0
    ldr[1] = 0.6487
    nm[1] =  0.0014

    V[1] = -69.5

    # --- Run simulation --- #

    print("--------------- Start Simulation ---------------\n")

    Istim[Int(stim_on/dt):Int(stim_off/dt)] .+= (amp * (10^-6)) / (CellArea * (10^-8))

    # Euler method
    for step in 1:(loop-1)

        # --- Voltage Calculation --- #

        dV_dt = (Istim[step]+Inoise[step]-INaV1p3[step]-INaV1p7[step]-INaV1p8[step]-IKdr[step]-IKm[step]-ILeak[step]-IAHP[step])/C
        V[step+1] = V[step] + dV_dt*dt

        # --- Current Equations --- #

        # -- Sodium currents -- #

        # - NaV1p3 - #
    
        m3[step+1] = m3[step] + dt*dot_m(V[step], m3[step], alpha_m_1_3, beta_m_1_3)
        h3[step+1] = h3[step] + dt*dot_h(V[step], h3[step], alpha_h_1_3, beta_h_1_3)
        INaV1p3[step+1] = g_nav1p3 * (m3[step]^3) * h3[step] * (V[step]-Ena)

        # - NaV1p7 - #

        m7[step+1] = m7[step] + dt*dot_m(V[step], m7[step], alpha_m_1_7, beta_m_1_7)
        h7[step+1] = h7[step] + dt*dot_h(V[step], h7[step], alpha_h_1_7, beta_h_1_7)
        INaV1p7[step+1] = g_nav1p7 * (m7[step]^3) * h7[step] * (V[step]-Ena)

        # - NaV1p8 - #

        m8[step+1] = m8[step] + dt*dot_m(V[step], m8[step], alpha_m_1_8, beta_m_1_8)
        h8[step+1] = h8[step] + dt*dot_h(V[step], h8[step], alpha_h_1_8, beta_h_1_8)
        INaV1p8[step+1] = g_nav1p8 * (m8[step]^3) * h8[step] * (V[step]-Ena)

        # -- Potassium currents -- #

        # - Kdr - activation(n), inactivation(l) - #

        ###### CODE VERSION ######

        q10=3^((25-30)/10)
        ninf = 1/(1+alpha_n_K_dr(V[step]))
        taun = beta_n_K_dr(V[step])/(q10*0.03*(1+alpha_n_K_dr(V[step])))
        linf = 1/(1+alpha_l_K_dr(V[step]))
        taul = beta_l_K_dr(V[step])/(q10*0.001*(1 + alpha_l_K_dr(V[step])))

        dndr_dt = (ninf - ndr[step])/taun
        ndr[step+1] = ndr[step] + dndr_dt*dt
        dldr_dt = (linf - ldr[step])/taul
        ldr[step+1] = ldr[step] + dldr_dt*dt
        
        ###### ARTICLE VERSION ######
        # (Don't work)

        # ndr[step+1] = ndr[step] + dt*dot_n_K_dr(V[step], ndr[step])
        # ldr[step+1] = ldr[step] + dt*dot_l_K_dr(V[step], ldr[step])

        IKdr[step+1] = gKdr * (ndr[step]^3) * ldr[step] * (V[step]-Ek)

        # - Km - #

        nm[step+1] = nm[step] + dt*dot_n_K_M(V[step], nm[step])
        IKm[step+1] = gKm*nm[step] * (V[step]-Ek)

        # - AHP - #

        z_AHP[step+1] = z_AHP[step] + dt*dot_z_AHP(V[step], z_AHP[step])

        # -- Leak current -- #

        ILeak[step+1] = gLeak * (V[step]-ELeak)

        # -- Noise (Ornstein-Uhlenbeck process) -- #
        
        noise_term = sigma_noise / sqrt(dt) * sqrt(2 / tau_noise) * randn()
        di_noise_dt = - (Inoise[step] - mu_noise) / tau_noise + noise_term

        if with_noise
            Inoise[step+1] = Inoise[step] + dt * di_noise_dt
        else
            Inoise[step+1] = 0
        end

        spike[step] = Int(V[step] > 0) * Int(!Bool(ref[step]))
        ref[step+1] = (V[step] > 0)

    end

    t = 0:dt:(duration-dt)

    plot(t, V, color= :black, label="")
    xlims!((400, 1700))
    ylims!((-100, 0))
    xlabel!("Time (ms)")
    ylabel!("Voltage (mV)")

    savefig("plots/plot_1.pdf")

    plot(V, m7.^3 .* h7 .* 100, color=:green, label="NaV1p7")
    plot!(V, m8.^3 .* h8 .* 100, color=:blue, label="NaV1p8")
    ylabel!("Availability (%)")
    xlabel!("Voltage (mV)")
    plot!(aspect_ratio = 1)

    savefig("plots/plot_2.pdf")

    p = plot(layout = (2, 1))
    x_range = (450, 600)

    plot!(p[1], t, V)
    xlims!(p[1], x_range)
    ylims!(p[1], (-100, 50))
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "Voltage (mV)")

    plot!(p[2], t, INaV1p3 .+ INaV1p7 .+ INaV1p8, color=:red, label="Sodium", legend = :topleft)
    plot!(p[2], t, IKdr .+ IKm .+ IAHP, color=:blue , label="Potassium")
    xlims!(p[2], x_range)
    ylims!(p[2], (-250, 250))
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Current (uA/cm2)")

    savefig(p, "plots/plot_3.pdf")

    y_range = (519, 625)
    x_range = (-100, 60)

    idx = Int(y_range[1]/dt):Int(y_range[2]/dt)
    N = length(idx)
    V_color = get.(Ref(ColorSchemes.jet), range(0, stop=1, length=N))

    p = plot(layout = (3, 1)) #, size = (500,1000))

    # - 1 - #

    plot!(p[1], V[idx], y_range[1]:dt:y_range[2], label="")
    xlims!(p[1], x_range)
    ylims!(p[1], y_range)
    xlabel!(p[1], "Voltage (mV)")
    ylabel!(p[1], "Time (ms)")
    #plot!(p[1], aspect_ratio = 1)

    # - 2 - #

    v = collect(x_range[1]:1:x_range[2])

    malpha = alpha_m_1_8.(v)
    mbeta  = beta_m_1_8.(v)
    halpha = alpha_h_1_8.(v)
    hbeta  = beta_h_1_8.(v)

    m = malpha ./ (malpha .+ mbeta)
    h = halpha ./ (halpha .+ hbeta)

    m = m.^3

    plot!(p[2], v , m, color=:blue, label="m")
    xlabel!(p[2], "Voltage (mV)")
    ylabel!(p[2], "Activation (%)")
    xlims!(p[2], x_range)
    ylims!(p[2], (0,1))
    #plot!(p[2], aspect_ratio = 1)

    # - 3 - #

    plot!(p[3], V[idx], m7[idx].^3 .*h7[idx] .* 100, color=:green, label = "")

    X = V[idx]
    Y = (m8[idx] .^3 .* h8[idx]) .* 100

    for i in 1:(length(X)-1)
        plot!(p[3], X[i:i+1], Y[i:i+1], color = V_color[i], label = "")
    end

    xlims!(p[3], x_range)
    xlabel!(p[3], "Voltage (mV)")
    ylabel!(p[3], "Availability  (%)")
    #plot!(p[3], aspect_ratio = 1)

    savefig(p, "plots/plot_4.pdf")

    return spike, V
end

spike, V = smallDRG_DIV0(17,1500,500,1000)
