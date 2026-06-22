export reponse_time

const pattern_list   = ["No spike"    , "Single spike", "Two spikes", "Transient" , "Spiking" ]
const markers_list   = [:circle       , :utriangle    , :dtriangle  , :diamond    , :square   ]
const colors_list    = [:midnightblue , :darkgreen    , :yellowgreen, :orange     , :red3     ]

const pattern_palette = cgrad(colors_list, categorical = true)

function NaV_palettes(L; dark=0.95, light=0.4)

    if L == 1
        return [:red], [:blue], [:green], [:grey]
    end

    reds   = [get(colorschemes[:Reds], i)   for i in range(light, stop=dark, length=L)]
    blues  = [get(colorschemes[:Blues], i)  for i in range(light, stop=dark, length=L)]
    greens = [get(colorschemes[:Greens], i) for i in range(light, stop=dark, length=L)]
    greys  = [get(colorschemes[:Greys], i)  for i in range(light, stop=dark, length=L)]

    return reds, blues, greens, greys
end

# Made by gemini, have to remake 
function reponse_time(t_resp, sol_t, dt)
    mask = [any(tp <= t <= (tp + dt) for tp in t_resp) for t in sol_t]
    return sol_t, Int.(mask)
end
