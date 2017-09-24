type Lattice
    dim :: Int
    size :: Vector{Int}
    nsites :: Int
    nbonds :: Int
    site_coords :: Matrix{Float64}
    bond_dirs :: Matrix{Float64}
    neighbors :: Matrix{Int}
    source :: Vector{Int}
    target :: Vector{Int}
end

import Base.size
import Distributions.dim

"""
    dim(lat::Lattice)

return the dimension of lattice.
"""
dim(lat::Lattice) = lat.dim

"""
    size(lat::Lattice, [dim::Integer])

return the size of lattice.
"""
size(lat::Lattice) = lat.size
size(lat::Lattice, dim::Integer) = lat.size[dim]

"""
    numsites(lat::Lattice)

return the number of sites.
"""
numsites(lat::Lattice) = lat.nsites

"""
    numbonds(lat::Lattice)

return the number of bonds.
"""
numbonds(lat::Lattice) = lat.nbonds

"""
    neighbors(lat::Lattice, site::Integer)

return the array of neighbor sites of `site`.
"""
neighbors(lat::Lattice, site::Integer) = lat.neighbors[:,site]

"""
    source(lat::Lattice, bond::Integer)

return the source site of `bond`.
"""
source(lat::Lattice, bond::Integer) = lat.source[bond]

"""
    target(lat::Lattice, bond::Integer)

return the target site of `bond`.
"""
target(lat::Lattice, bond::Integer) = lat.target[bond]

"""
    coordinate(lat::Lattice, site::Integer)

return the coordinate of the `site`
"""
coordinate(lat::Lattice, site::Integer) = lat.site_coords[:, site]

"""
    bonddirectory(lat::Lattice, bond::Integer)

return the directory of the `bond` as vector
"""
bonddirectory(lat::Lattice, bond::Integer) = lat.bond_dirs[:, bond]

"""
    chain_lattice(L::Integer)
    chain_lattice(params::Dict)
    
generate chain lattice with length `L` or params["L"].
"""
function chain_lattice(L::Integer)
    dim = 1
    coords = zeros(dim, L)
    bond_dirs = zeros(dim, L)
    neighbors = zeros(Int,2,L)
    source = zeros(Int,L)
    target = zeros(Int,L)
    for s in 1:L
        coords[1,s] = (s-1)
        bond_dirs[1,s] = 1.0
        neighbors[1,s] = mod1(s+1,L)
        neighbors[2,s] = mod1(s-1,L)
        source[s] = s
        target[s] = neighbors[1,s]
    end
    Lattice(dim,[L],L,L,coords, bond_dirs, neighbors,source,target)
end
chain_lattice(params::Dict) = chain_lattice(params["L"])

"""
    square_lattice(L::Integer, W::Integer=L)
    square_lattice(params::Dict)
    
generate square lattice with size `L` \\times `W`.
"""
square_lattice(L::Integer) = square_lattice(L,L)
function square_lattice(L::Integer, W::Integer)
    s2xy(s::Integer) = mod(s-1,L),div(s-1,L)
    xy2s(x::Integer, y::Integer) = mod(y,W)*L + mod(x,L) + 1

    dim = 2
    nsites = L*W
    nbonds = 2nsites
    coords = zeros(dim, nsites)
    bond_dirs = zeros(dim, nbonds)
    neighbors = zeros(Int,4,nsites)
    source = zeros(Int,nbonds)
    target = zeros(Int,nbonds)
    @inbounds for s in 1:nsites
        x,y = s2xy(s)
        neighbors[1,s] = xy2s(x+1,y)
        neighbors[2,s] = xy2s(x,y+1)
        neighbors[3,s] = xy2s(x-1,y)
        neighbors[4,s] = xy2s(x,y-1)
        source[2s-1:2s] = s
        target[2s-1:2s] = neighbors[1:2,s]
        coords[1,s] = x
        coords[2,s] = y
        bond_dirs[:, 2s-1] = [1.0, 0.0]
        bond_dirs[:, 2s] = [0.0, 1.0]
    end
    Lattice(dim,[L,W],nsites,nbonds,coords,bond_dirs,neighbors,source,target)
end
function square_lattice(params::Dict)
    L = params["L"]
    W = get(params, "W", L)
    return square_lattice(L, W)
end

"""
    triangular_lattice(L::Integer, W::Integer=L)
    triangular_lattice(params::Dict)
    
generate triangular lattice with size `L` \\times `W`.
"""
triangular_lattice(L::Integer) = triangular_lattice(L,L)
function triangular_lattice(L::Integer, W::Integer)
    s2xy(s::Integer) = mod(s-1,L),div(s-1,L)
    xy2s(x::Integer, y::Integer) = mod(y,W)*L + mod(x,L) + 1
    ex = [1.0, 0.0]
    ey = [0.5, 0.5sqrt(3)]
    dim = 2
    nsites = L*W
    nbonds = 3nsites
    coords = zeros(dim, nsites)
    bond_dirs = zeros(dim, nbonds)
    neighbors = zeros(Int,6,nsites)
    source = zeros(Int,nbonds)
    target = zeros(Int,nbonds)
    @inbounds for s in 1:nsites
        x,y = s2xy(s)
        neighbors[1,s] = xy2s(x+1,y)
        neighbors[2,s] = xy2s(x,y+1)
        neighbors[3,s] = xy2s(x+1,y+1)
        neighbors[4,s] = xy2s(x-1,y)
        neighbors[5,s] = xy2s(x,y-1)
        neighbors[6,s] = xy2s(x-1,y-1)
        source[3s-2:3s] = s
        target[3s-2:3s] = neighbors[1:3,s]
        coords[:,s] = x*ex + y*ey
        bond_dirs[:, 3s-2] = ex
        bond_dirs[:, 3s-1] = ey
        bond_dirs[:, 3s] = ex+ey
    end
    Lattice(dim,[L,W],nsites,nbonds,coords,bond_dirs,neighbors,source,target)
end
function triangular_lattice(params::Dict)
    L = params["L"]
    W = get(params, "W", L)
    return triangular_lattice(L, W)
end

"""
    cubic_lattice(L::Integer, W::Integer=L, H::Integer=W)
    
generate cubic lattice with size `L` \\times `W` \\times `H`.
"""
cubic_lattice(L::Integer) = cubic_lattice(L,L,L)
cubic_lattice(L::Integer, W::Integer) = cubic_lattice(L,W,W)
function cubic_lattice(L::Integer, W::Integer, H::Integer)
    function s2xyz(s::Integer)
        z = div(s-1, L*W)
        xy = mod(s-1, L*W)
        x = mod(xy, L)
        y = div(xy, L)
        return x, y, z
    end
    xyz2s(x::Integer, y::Integer, z::Integer) = mod(z,H)*W*L + mod(y,W)*L + mod(x,L) + 1

    dim = 3
    nsites = L*W*H
    nbonds = 3nsites
    coords = zeros(dim, nsites)
    bond_dirs = zeros(dim, nbonds)
    neighbors = zeros(Int,6,nsites)
    source = zeros(Int,nbonds)
    target = zeros(Int,nbonds)
    @inbounds for s in 1:nsites
        x,y,z = s2xyz(s)
        neighbors[1,s] = xyz2s(x+1,y,z)
        neighbors[2,s] = xyz2s(x,y+1,z)
        neighbors[3,s] = xyz2s(x,y,z+1)
        neighbors[4,s] = xyz2s(x-1,y,z)
        neighbors[5,s] = xyz2s(x,y-1,z)
        neighbors[6,s] = xyz2s(x,y,z-1)
        source[3s-2:3s] = s
        target[3s-2:3s] = neighbors[1:3,s]
        coords[1,s] = x
        coords[2,s] = y
        coords[3,s] = z
        bond_dirs[:, 3s-2] = [1.0, 0.0, 0.0]
        bond_dirs[:, 3s-1] = [0.0, 1.0, 0.0]
        bond_dirs[:, 3s-0] = [0.0, 0.0, 1.0]
    end
    Lattice(dim,[L,W,H],nsites,nbonds,coords,bond_dirs,neighbors,source,target)
end
function cubic_lattice(params::Dict)
    L = params["L"]
    W = get(params, "W", L)
    H = get(params, "H", W)
    return cubic_lattice(L, W, H)
end
