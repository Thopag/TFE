
function INa(gNa,mNa,hNa,V,eNa)
    INa = gNa*mNa^3*hNa*(V-eNa)     # [µA/cm^2]
    return INa
end
function IKDR(gKDR,mKDR,V,eK)
    IKDR = gKDR*mKDR^4*(V-eK)       # [µA/cm^2]
    return IKDR
end
function ICaLf(pCaLf,mCaLf,hCaLf,V,Ca,Ca_o)
    ICaLf = pCaLf*mCaLf^2*hCaLf*ghk_LeFranc(V, Ca, Ca_o) *1000  # [µA/cm^2] instead of [mA/cm^2]
    return ICaLf
end
function ICaLs(pCaLs,mCaLs,hCaLs,V,Ca,Ca_o)
    ICaLs = pCaLs*mCaLs*hCaLs*ghk_LeFranc(V, Ca, Ca_o) *1000    # [µA/cm^2] instead of [mA/cm^2]
    return ICaLs
end
function IKir(gKir,mKir,V,eK)
    IKir = gKir*mKir*(V-eK)         # [µA/cm^2]
    return IKir
end
function IKM(gKM,mKM,V,eK)
    IKM = gKM*mKM*(V-eK)            # [µA/cm^2]
    return IKM
end
function Ileak(gleak,V,eleak)
    Ileak = gleak*(V-eleak)         # [µA/cm^2]
    return Ileak 
end
function INMDA(gNMDA,V,eNMDA)
    INMDA = gNMDA *NMDA_Mg_block(V)*(V-eNMDA) # [µA/cm^2]
    return INMDA
end
function IAMPA(gAMPA,V,eAMPA)
    IAMPA = gAMPA *(V-eAMPA) # [µA/cm^2]
    return IAMPA
end