
M = 234.337 # g/mol

# Safety and Tolerability of the Lidocaine Patch 5%, a Targeted Peripheral Analgesic: A Review of the Literature
C = 150                 # ng/ml
C = C*(10^-9)/(10^-3)   # g/l
C = C/M                 # M
C = C*10^6              # µM
println("Safety and Tolerability of the Lidocaine Patch 5%, a Targeted Peripheral Analgesic: A Review of the Literature")
println("$(round(C, digits=2)) µM")
println()

# Computer-controlled lidocaine infusion for the evaluation of neuropathic pain after peripheral nerve injury
C = 2                   # µg/ml
C = C*(10^-6)/(10^-3)   # g/l
C = C/M                 # M
C = C*10^6              # µM
println("Computer-controlled lidocaine infusion for the evaluation of neuropathic pain after peripheral nerve injury")
println("$(round(C, digits=2)) µM")
println()

# Determination of the Minimum Local Analgesic Concentrations of Epidural Bupivacaine and Lidocaine in Labor 
C = 0.4                 # %w/v
C = C/100               # g/ml
C = C/10^-3             # g/l
C = C/M                 # M
C = C*10^6              # µM
println("Determination of the Minimum Local Analgesic Concentrations of Epidural Bupivacaine and Lidocaine in Labor")
println("$(round(C, digits=2)) µM")