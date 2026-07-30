using Plots

x = range(-2, 2, length=40)
y = range(-2, 2, length=40)

# Convert 1D range axes into 2D meshgrids
X = [x_i for x_i in x, y_j in y]
Y = [y_j for x_i in x, y_j in y]

z_planes = [1.0, 2.5, 4.0, 5.5]

plt = plot(xlabel="X", ylabel="Y", zlabel="Z", legend=false)

for z_val in z_planes
    Z = fill(z_val, size(X))
    intensity = @. exp(-(X^2 + Y^2) / z_val)
    
    # When X and Y are 2D matrices, fill_z = intensity works seamlessly!
    surface!(
        plt, X, Y, Z,
        fill_z = intensity,
        color = :turbo
    )
end

display(plt)