using DiscreteExteriorCalculus: Point, Simplex, TriangulatedComplex
using UniqueVectors: UniqueVector
using DotEnv

env = joinpath(@__DIR__, ".env")
open(env, "a") do io
DotEnv.load(env)
include(ENV["gmshjl"]) # include the gmsh module used below

