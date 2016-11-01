# include("C:\\Users\\mgb\\Downloads\\projeto.jl")
#=Pkg.clone("https://github.com/timotrob/PathLoss.jl.git")
Pkg.add("RDatasets")
Pkg.add("Distributions")
Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
Pkg.add("Gadfly")
using RDatasets
using Distributions
using DataFrames
using DataFramesMeta
using Gadfly
using PathLoss=#

# Funcao para calcular RMSE
#=function rmse(gt,pred)
    return sqrt(mean((gt - pred).^2))
end;=#

function cal_error(m, db)
    tabela = @byrow! db begin
        @newcol PLMBTS1::Array{Float64}
        @newcol PLMBTS2::Array{Float64}
        @newcol PLMBTS3::Array{Float64}
        @newcol PLMBTS4::Array{Float64}
        @newcol PLMBTS5::Array{Float64}
        @newcol PLMBTS6::Array{Float64}
        @newcol ErrorBTS1::Array{Float64}
        @newcol ErrorBTS2::Array{Float64}
        @newcol ErrorBTS3::Array{Float64}
        @newcol ErrorBTS4::Array{Float64}
        @newcol ErrorBTS5::Array{Float64}
        @newcol ErrorBTS6::Array{Float64}

        :PLMBTS1 = pathloss(m, :DBTS1)
        :ErrorBTS1 = :PLMBTS1  - :PLBTS1
        :PLMBTS2 = pathloss(m, :DBTS2)
        :ErrorBTS2 = :PLMBTS2  - :PLBTS2
        :PLMBTS3 = pathloss(m, :DBTS3)
        :ErrorBTS3 = :PLMBTS3  - :PLBTS3
        :PLMBTS4 = pathloss(m, :DBTS4)
        :ErrorBTS4 = :PLMBTS4  - :PLBTS4
        :PLMBTS5 = pathloss(m, :DBTS5)
        :ErrorBTS5 = :PLMBTS5  - :PLBTS5
        :PLMBTS6 = pathloss(m, :DBTS6)
        :ErrorBTS6 = :PLMBTS6  - :PLBTS6
    end
    delete!(tabela, 1:26)
    return tabela
end;

db_train = readtable("C:\\Users\\mgb\\Desktop\\train.csv", separator = ',') #2045 lines
db_test = readtable("C:\\Users\\mgb\\Desktop\\test.csv", separator = ',') #513 lines
db_erbs = readtable("C:\\Users\\mgb\\Desktop\\erbs.csv", separator = ',') 

# Calculando o pathloss medido
db_train[:PLBTS1] = 0.0
db_train[:PLBTS2] = 0.0
db_train[:PLBTS3] = 0.0
db_train[:PLBTS4] = 0.0
db_train[:PLBTS5] = 0.0
db_train[:PLBTS6] = 0.0

for row in eachrow(db_train)
    row[:PLBTS1] = db_erbs[1,7] - row[3]
    row[:PLBTS2] = db_erbs[2,7] - row[4]
    row[:PLBTS3] = db_erbs[3,7] - row[5]
    row[:PLBTS4] = db_erbs[4,7] - row[6]
    row[:PLBTS5] = db_erbs[5,7] - row[7]
    row[:PLBTS6] = db_erbs[6,7] - row[8]
end

# Calculando o pathloss por modelo
db_train[:DBTS1] = 0.0
db_train[:DBTS2] = 0.0
db_train[:DBTS3] = 0.0
db_train[:DBTS4] = 0.0
db_train[:DBTS5] = 0.0
db_train[:DBTS6] = 0.0

for row in eachrow(db_train)
    row[:DBTS1] = distanceInKm(db_erbs[1,3], db_erbs[1,4], row[1], row[2])
    row[:DBTS2] = distanceInKm(db_erbs[2,3], db_erbs[2,4], row[1], row[2])
    row[:DBTS3] = distanceInKm(db_erbs[3,3], db_erbs[3,4], row[1], row[2])
    row[:DBTS4] = distanceInKm(db_erbs[4,3], db_erbs[4,4], row[1], row[2])
    row[:DBTS5] = distanceInKm(db_erbs[5,3], db_erbs[5,4], row[1], row[2])
    row[:DBTS6] = distanceInKm(db_erbs[6,3], db_erbs[6,4], row[1], row[2])
end


###########################################################
# A partir daqui são tabelas de erro separados por modelo #
###########################################################


#### Free Space Model
m = FreeSpaceModel() # For ERP
m.freq = 1800 #MHz

fs = cal_error(m, db_train)
head(fs)
