using DiscreteExteriorCalculus: Point, Simplex, TriangulatedComplex
using UniqueVectors: UniqueVector
using DotEnv

env = joinpath(@__DIR__, ".env")
open(env, "a") do io
DotEnv.load(env)
include(ENV["gmshjl"]) # include the gmsh module used below

export initialize!
"""
    initialize!()

Start Gmsh.
"""
initialize!() = gmsh.initialize()

function eventloop()
    while true
        gmsh.graphics.draw()
        gmsh.fltk.wait()
        sleep(.01)
    end
end
