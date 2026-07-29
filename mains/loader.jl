include("utils.jl")

function main()

    inhib_files = ["inhibition/DIV0_NaV1.8_inhib_NO_pLf",
            "inhibition/DIV7_NaV1.7_inhib_NO_pLf",
            "inhibition/DIV7_NaV1.3_inhib_NO_pLf",
            "inhibition/DIV0_NMDA_inhib_NO_pLf"
            ]

    shift_files = ["shift/DIV0_h8_shift_NO_pLf",
            "shift/DIV0_m8_h8_shift_NO_pLf",
            "shift/DIV0_m8_shift_NO_pLf",
            "shift/DIV7_h3_shift_NO_pLf",
            "shift/DIV7_h7_shift_NO_pLf"
            ]

    plan_files = ["plan/DIV0_NaV1.8_shift_inhib_NO_pLf",
            "plan/DIV7_NaV1.7_shift_inhib_NO_pLf",
            "plan/DIV7_NaV1.3_shift_inhib_NO_pLf",
            "plan/DIV0_inhib_NaV1.8_NMDA_NO_pLf"
            ]

    # file = inhib_files[1]
    # start = 11

    # file = shift_files[3]
    # start = 6

    # file = plan_files[1]
    # start = 5

    file = "proj_baseline_NO_pLf"
    start = 1

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)

    file = file[start:end]

    plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    plot_plan(pp, plan_exct, plan_freq, file)
end

main()