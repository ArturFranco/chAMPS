# include("C:\\Users\\mgb\\Downloads\\projeto.jl")
# include("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Comunicações Móveis/chAMPS/fp.jl")
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
function rmse(gt,pred)
    return sqrt(mean((gt - pred).^2))
end;

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

db_train = readtable("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Comunicações Móveis/chAMPS/train.csv", separator = ',') #2045 lines
db_test = readtable("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Comunicações Móveis/chAMPS/test.csv", separator = ',') #513 lines
db_erbs = readtable("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Comunicações Móveis/chAMPS/erbs.csv", separator = ',') 

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
m = FreeSpaceModel() 	# For ERP
m.freq = 1800 			# MHz

fs = cal_error(m, db_train)
head(fs)

#=
#### Okumura Hata Model
m = OkumuraHataModel()
m.freq = 800					# MHz
m.txH = 90						# Height of the cell site (in meters)
m.rxH = 1.2                   	# Height of Mobile Station (in meters)
m.areaKind = AreaKind.Urban  	# Area Type (Urban SubUrban Open)
m.cityKind = CityKind.Medium 	# City type (Small Medium or Large)

fs = cal_error(m, db_train)
head(fs)

#### COST-231 Hata Extension Model
m = Cost231HataModel()
m.freq = 1800    			# MHz
m.txH = 90      			# Height of the cell site
m.rxH = 1.5     			# Height of Mobile Station
m.areaKind = AreaKind.Urban # City type (Small Medium or Large)

fs = cal_error(m, db_train)
head(fs)

#### COST-231 Waldrosch-Ikegami Model
m = Cost231Model()
m.freq = 800    				# MHz
m.txH = 90      				# Height of the cell site
m.rxH = 1.5     				# Height of Mobile Station
m.ws = 20       				# Average width of the street in meters
m.bs = 7        				# Average setback of buildings in meters
m.hr = 8        				# Mean height of houses in meters
m.cityKind = CityKind.Medium 	# City type (Small Medium or Large)

fs = cal_error(m, db_train)
head(fs)

#### ECC-33
m = Ecc33Model()
m.freq = 950   # MHz
m.txH = 90     # Height of the cell site (
m.rxH = 1.2    # Height of MS(Mobile Station)

fs = cal_error(m, db_train)
head(fs)

#### Ericsson 999
m = EricssonModel()
m.freq = 800    			# MHz
m.txH = 35      			# Height of the cell site (15 and 40 m.)
m.rxH = 2       			# Height of Mobile Station
m.cityKind = CityKind.Medium

fs = cal_error(m, db_train)
head(fs)

#### SUI (STANFORD UNIVERSITY INTERIM)
m = SuiModel()
m.freq = 2100    				# MHz
m.txH = 35      				# Height of the cell site (15 and 40 m.)
m.rxH = 2       				# Height of MS(Mobile Station)
m.shadowFading = 9.0 			# Shadow Fading(8.2 dB and 10.6)
m.terrainKind = TerrainKind.B
# TerrainKind
# Category A: hilly terrain with moderate-to-heavy tree densities, which results in the maximum path loss.
# Category B: hilly environment but rare vegetation, or high vegetation but flat terrain. Intermediate path loss condition is typical of this category.
# Category C: mostly flat terrain with light tree densities. It corresponds to minimum path loss conditions

fs = cal_error(m, db_train)
head(fs)

#### Lee Model]
m = LeeModel()
m.freq = 950    				# MHz
m.txH = 90      				# Height of the cell site
m.rxH = 1.5     				# Height of Mobile Station
m.leeArea = LeeArea.NewYorkCity # (determined empirically)
# Area parameters are tuples as follow:
# FreeSpace = (2.0, 45.0)
# OpenArea =  (4.35, 49.0)
# SubUrban= (3.84, 61.7)
# Philadelphia=(3.68, 70.0)
# Newark=(4.31, 64.0)
# Tokyo=(3.05, 84.0)
# NewYorkCity =(4.8, 77.0) # n=4.8 Po=77.0

fs = cal_error(m, db_train)
head(fs)

#### Flat Earth Model
m = FlatEarthModel()
m.freq = 950    # MHz
m.txH = 90      # Height of the cell site
m.rxH = 1.5     # Height of Mobile Station

fs = cal_error(m, db_train)
head(fs) =#



