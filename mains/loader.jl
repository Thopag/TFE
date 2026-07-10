include("utils.jl")

function main()

    files = ["DIV0_inhib_NMDA", "DIV0_inhib_NaV1.8", "DIV0_inhib_AMPA", "DIV0_plan_inhib_NaV1.8_NMDA", "DIV0_plan_inhib_AMPA_NMDA"]

    noci_files = ["noci/DIV0_NaV1.8_h8_shift", 
                "noci/DIV0_NaV1.8_inhib",
                "noci/DIV0_NaV1.8_m0.6_h0.4_shift",
                "noci/DIV0_NaV1.8_m8_shift",
                "noci/DIV0_NaV1.8_shift_h0.4_m0.6_inhib",
                "noci/DIV7_NaV1.3_inhib",
                "noci/DIV7_NaV1.3_shift_h_inhib",
                "noci/DIV7_NaV1.3_shift",
                "noci/DIV7_NaV1.7_inhib",
                "noci/DIV7_NaV1.7_shift_h_inhib",
                "noci/DIV7_NaV1.7_shift"]

    #file = "DIV0_default"
    #file = files[4]

    file = noci_files[11]

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)

    plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file[6:end])
    plot_plan(pp, plan_exct, plan_freq, file[6:end])
end

main()