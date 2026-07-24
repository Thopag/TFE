include("utils.jl")

function main()

    inhib_files = ["inhibition/DIV0_NaV1.8_inhib",
            "inhibition/DIV7_NaV1.7_inhib",
            "inhibition/DIV7_NaV1.3_inhib"
            ]

    shift_files = ["shift/DIV0_h8_shift",
            "shift/DIV0_m8_h8_shift",
            "shift/DIV0_m8_shift",
            "shift/DIV7_h3_shift",
            "shift/DIV7_h7_shift"
            ]

    plan_files = ["plan/DIV0_NaV1.8_shift_inhib",
            "plan/DIV7_NaV1.7_shift_inhib",
            "plan/DIV7_NaV1.3_shift_inhib",
            "plan/DIV0_inhib_NaV1.8_NMDA"
            ]

    # file = inhib_files[1]
    # start = 11

    # file = shift_files[3]
    # start = 6

    # file = plan_files[1]
    # start = 5

    file = "shift/DIV0_h8_shift"
    start = 6

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)

    file = file[start:end]

    plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    plot_plan(pp, plan_exct, plan_freq, file)
end

main()