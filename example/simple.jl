using SpinMonteCarlo

const model = Ising
const lat = square_lattice
const L = 16
const update = SW_update!

const Tc = 2.0/log1p(sqrt(2))
const Ts = Tc*linspace(0.85, 1.15, 31)
const MCS = 8192
const Therm = MCS >> 3

for T in Ts
    params = Dict{String,Any}( "Model"=>model, "Lattice"=>lat,
                                 "L"=>L, "T"=>T, "J"=>1.0,
                                 "UpdateMethod"=>update,
                                 "MCS"=>MCS, "Thermalization"=>Therm,
                             )
    result = runMC(params)
    println(@sprintf("%f %.15f %.15f",
                      T, mean(result["Specific Heat"]), stderror(result["Specific Heat"])))
end
