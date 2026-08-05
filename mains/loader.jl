include("utils.jl")

function main()

    baseline_files = ["DIV0_baseline",
            "proj_baseline",
            ]

    inhib_files = ["inhibition/DIV0_NaV1.8_inhib",
            "inhibition/DIV7_NaV1.7_inhib",
            "inhibition/DIV7_NaV1.3_inhib",
            "inhibition/DIV0_NMDA_inhib"
            ]

    shift_files = ["shift/DIV0_h8_shift",
            "shift/DIV0_m8_h8_shift",
            "shift/DIV0_m8_shift",
            "shift/DIV7_h3_shift",
            "shift/DIV7_h7_shift",

            "shift/DIV0_m8_shift_0.5-NMDA",
            "shift/DIV0_shift_Mgblock"
            ]

    plan_files = [
            "plan/DIV0_inhib_NaV1.8_shift",
            "plan/DIV7_NaV1.7_shift_inhib",
            "plan/DIV7_NaV1.3_shift_inhib",
            "plan/DIV7_NaV1.3_NaV1.7_inhib",

            "plan/DIV0_inhib_NaV1.8_NMDA",
            "plan/DIV0_NMDA_inhib_m8_shift",
            "plan/DIV0_NMDA_inhib_h8_shift",

            "plan/DIV0_shift_Mgblock_inhib_NMDA",
            
            ]

    # inhib
    # start = 11

    # shift
    # start = 6

    # plan
    # start = 5

    file = "shift/DIV0_m8_shift_0.5-NMDA"
    start = 6

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)

    file = file[start:end]

    plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    plot_plan(pp, plan_exct, plan_freq, file)
end

main()