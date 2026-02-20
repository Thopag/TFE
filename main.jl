include("Ploting.jl")
include("utils.jl")

folder = "DIV0"

if folder == "DIV0"
    include("DIV0/ODEs.jl")
    include("DIV0/launch_DIV0.jl")
    launch_function = smallDRG_DIV0
elseif folder == "DIV7"
    include("DIV7/ODEs.jl")
    include("DIV7/launch_DIV7.jl")
    launch_function = smallDRG_DIV7
end

amp = 17                    # pA
duration = 1700             # ms
stim_on = 500               # ms 
stim_length = 1000          # ms

print("folder: $folder with amp = $amp pA\n")

t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test, parameters = launch_function(amp, duration, stim_on, stim_length)

I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak = give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, parameters)

# --- Plots --- #

plot_voltage(t, V, amp)
plot_variables(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)
plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)
plot_currents(t, V, I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, amp)
plot_test(t, V, ndr, ldr, n_test, l_test, amp)
plot_availability_voltage(t, V, m7, h7, m8, h8)