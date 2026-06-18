using Plots,LaTeXStrings

pal = palette(:seaborn_colorblind6)
pal_offset = palette(vcat(pal[4:6],pal[1:3]))

function plt_x_ni(t,x,lab,ylims_,pal_)
    plt_ni = []
    for i in eachindex(x)
        if length(ylims_)>0
            plt_ni_ = plot(fontfamily="Computer Modern",palette=pal_[Int(1+1*iseven(i))],ylims=ylims_)
        else
            plt_ni_ = plot(fontfamily="Computer Modern",palette=pal_[Int(1+1*iseven(i))])
        end
        for j in eachindex(x[i])
            plot!(plt_ni_,t,x[i][j],label=lab[i][j],lw=2)
        end
        push!(plt_ni,plt_ni_)
    end
    if length(plt_ni) ==1
        plt = plot(plt_ni[1])
        return plt
    end
    if length(plt_ni) ==2
        plt = plot(plt_ni[1],plt_ni[2],layout=(2,1),size=(600,600),legend=:outertopright,fontfamily="Computer Modern")
        return plt
    end
    if length(plt_ni) ==3
        plt = plot(plt_ni[1],plt_ni[2],plt_ni[3],layout=(3,1),size=(600,800),legend=:outertopright,fontfamily="Computer Modern")
        return plt
    end
end

