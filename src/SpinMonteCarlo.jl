__precompile__()

module SpinMonteCarlo

using Random
using Printf
using Markdown
using Statistics
using LinearAlgebra

using DataStructures

export Parameter
export @gen_convert_parameter, convert_parameter
export Model, Ising, XY, Potts, Clock
export QuantumLocalZ2Model, QuantumXXZ
export local_update!, SW_update!, Wolff_update!, loop_update!
export default_estimator, simple_estimator, improved_estimator
export dimer_lattice, chain_lattice, square_lattice, triangular_lattice, cubic_lattice, fully_connected_lattice
export Lattice, dim, size, numsites, numbonds, neighbors, source, target, sitetype, bondtype
export sitecoordinate, bonddirection, lattice_sitecoordinate, lattice_bonddirection
export UnionFind, addnode!, unify!, clusterize!, clusterid
export gen_snapshot!, gensave_snapshot!, load_snapshot
export runMC, print_result

abstract type Model end

@doc doc"""
Input parameter of simulation
"""
const Parameter = Dict{String, Any}
const Measurement = Dict{String, Any}

include("union_find.jl")
include("lattice.jl")
include("gen_lattice.jl")
include("model.jl")
include("qmodel.jl")
include("parameter.jl")
include("local_update.jl")
include("SW.jl")
include("loop.jl")
include("Wolff.jl")
include("simple_estimator.jl")
include("improved_estimator.jl")
include("snapshot.jl")
include("observables/MCObservables.jl")
include("runMC.jl")
include("print.jl")
end # of module
