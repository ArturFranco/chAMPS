# include("C:\\Users\\mgb\\Downloads\\fp.jl")
Pkg.clone("https://github.com/timotrob/PathLoss.jl.git")
# Pkg.add("RDatasets")
Pkg.add("Distributions")
# Pkg.add("DataFrames")
# Pkg.add("DataFramesMeta")
# Pkg.add("Gadfly")
using RDatasets
using Distributions
using DataFrames
using DataFramesMeta
using Gadfly
using PathLoss
#=
db_train = readtable("C:\\Users\\mgb\\Desktop\\train.csv", separator = ',') #2045 lines
db_val = readtable("C:\\Users\\mgb\\Desktop\\validation.csv", separator = ',') #257 lines
db_test = readtable("C:\\Users\\mgb\\Desktop\\test.csv", separator = ',') #257 lines
=#
