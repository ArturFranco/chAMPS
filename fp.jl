#include("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Móveis/Projeto/chAMPS/fp.jl")
#Pkg.clone("https://github.com/timotrob/PathLoss.jl.git")
#Pkg.add("RDatasets")
#Pkg.add("Distributions")
#Pkg.add("DataFrames")
#Pkg.add("DataFramesMeta")
#Pkg.add("Gadfly")
#Pkg.update("DataFramesMeta")
using DataFramesMeta
using RDatasets
using Distributions
using DataFrames
using Gadfly
using PathLoss

db_train = readtable("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Móveis/Projeto/chAMPS/train.csv", separator = ',') #2045 lines
db_test = readtable("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Móveis/Projeto/chAMPS/test.csv", separator = ',') #513 lines
db_erbs = readtable("C:/Users/Artur/Desktop/ARTUR/UFPE/2016.2/Móveis/Projeto/chAMPS/erbs.csv", separator = ',') 

# funcao para calcular RMSE (Erro Quadratico Medio)
function rmse(pathLossMedido, pathLossModelo)
    return sqrt(mean((pathLossMedido - pathLossModelo).^2))
end

# calculando o pathloss medido
function pathLossMedido(model, db)
    table = @byrow! db begin
        @newcol PLBTS1::Array{Float64}
        @newcol PLBTS2::Array{Float64}
        @newcol PLBTS3::Array{Float64}
        @newcol PLBTS4::Array{Float64}
        @newcol PLBTS5::Array{Float64}
        @newcol PLBTS6::Array{Float64}

        :PLBTS1 = db_erbs[1,7] - :RSSI_1
        :PLBTS2 = db_erbs[2,7] - :RSSI_2
        :PLBTS3 = db_erbs[3,7] - :RSSI_3
        :PLBTS4 = db_erbs[4,7] - :RSSI_4
        :PLBTS5 = db_erbs[5,7] - :RSSI_5
        :PLBTS6 = db_erbs[6,7] - :RSSI_6
    end
    return table
end

# calculando a distancia ERB-Móvel
# eh necessaria no calculo do pathloss por modelo
function calcDistance(model, db)
    table = @byrow! db begin
        @newcol DBTS1::Array{Float64}
        @newcol DBTS2::Array{Float64}
        @newcol DBTS3::Array{Float64}
        @newcol DBTS4::Array{Float64}
        @newcol DBTS5::Array{Float64}
        @newcol DBTS6::Array{Float64}

        :DBTS1 = distanceInKm(db_erbs[1,3], db_erbs[1,4], :lat, :lon)
        :DBTS2 = distanceInKm(db_erbs[2,3], db_erbs[2,4], :lat, :lon)
        :DBTS3 = distanceInKm(db_erbs[3,3], db_erbs[3,4], :lat, :lon)
        :DBTS4 = distanceInKm(db_erbs[4,3], db_erbs[4,4], :lat, :lon)
        :DBTS5 = distanceInKm(db_erbs[5,3], db_erbs[5,4], :lat, :lon)
        :DBTS6 = distanceInKm(db_erbs[6,3], db_erbs[6,4], :lat, :lon)
    end
    return table
end

# calculando o erro medio quadratico (RMSE)
function calcErro(model, db)
    table = @byrow! db begin
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

        :PLMBTS1 = pathloss(model, :DBTS1)
        :ErrorBTS1 = rmse(:PLMBTS1, :PLBTS1)
        :PLMBTS2 = pathloss(model, :DBTS2)
        :ErrorBTS2 = rmse(:PLMBTS2, :PLBTS2)
        :PLMBTS3 = pathloss(model, :DBTS3)
        :ErrorBTS3 = rmse(:PLMBTS3, :PLBTS3)
        :PLMBTS4 = pathloss(model, :DBTS4)
        :ErrorBTS4 = rmse(:PLMBTS4, :PLBTS4)
        :PLMBTS5 = pathloss(model, :DBTS5)
        :ErrorBTS5 = rmse(:PLMBTS5, :PLBTS5)
        :PLMBTS6 = pathloss(model, :DBTS6)
        :ErrorBTS6 = rmse(:PLMBTS6, :PLBTS6)
    end
    delete!(table, 1:26)
    return table
end

# calculo da media do rmse para cada ERB
function calcMediaErro(db)
    db[1,1] = mean(db[:,1])
    db[1,2] = mean(db[:,2])
    db[1,3] = mean(db[:,3])
    db[1,4] = mean(db[:,4])
    db[1,5] = mean(db[:,5])
    db[1,6] = mean(db[:,6])
    return db
end

# calcula RMSE para um determinado modelo
function errorModel(model, db)
    db = pathLossMedido(model, db)
    db = calcDistance(model, db)
    tableError = calcErro(model, db)
    tableError = calcMediaErro(tableError)
    deleterows!(tableError, 2:nrow(tableError))
    return tableError
end

###########################################################
# A partir daqui são tabelas de erro separados por modelo #
###########################################################

#### Free Space Model ####
fs = FreeSpaceModel() 	
fs.freq = 1800 	# MHz

errorFreeSpace = errorModel(fs, db_train)

#### Okumura Hata Model ####
oh = OkumuraHataModel()
oh.freq = 800					# MHz
oh.txH = 90						# Height of the cell site (meters)
oh.rxH = 1.2                   	# Height of mobile station (meters)
oh.areaKind = AreaKind.Urban  	# Area type (Urban, SubUrban or Open)
oh.cityKind = CityKind.Medium 	# City type (Small, Medium or Large)

errorOkumuraHata = errorModel(oh, db_train)

#### COST-231 Hata Extension Model ####
c231h = Cost231HataModel()
c231h.freq = 1800    			# MHz
c231h.txH = 90      			# Height of the cell site
c231h.rxH = 1.5     			# Height of mobile station
c231h.areaKind = AreaKind.Urban # City type (Small, Medium or Large)

errorCost231Hata = errorModel(c231h, db_train)

#### COST-231 Waldrosch-Ikegami Model ####
c231wi = Cost231Model()
c231wi.freq = 800    				# MHz
c231wi.txH = 90      				# Height of the cell site
c231wi.rxH = 1.5     				# Height of mobile station
c231wi.ws = 20       				# Average width of the street (meters)
c231wi.bs = 7        				# Average setback of buildings (meters)
c231wi.hr = 8        				# Mean height of houses (meters)
c231wi.cityKind = CityKind.Medium 	# City type (Small, Medium or Large)

errorCost231WaldIk = errorModel(c231wi, db_train)

#### ECC-33 ####
ecc33 = Ecc33Model()
ecc33.freq = 950   # MHz
ecc33.txH = 90     # Height of the cell site
ecc33.rxH = 1.2    # Height of mobile station

errorECC33 = errorModel(ecc33, db_train)

#### Ericsson 999
er999 = EricssonModel()
er999.freq = 800    # MHz
er999.txH = 35      # Height of the cell site (15~40m)
er999.rxH = 2       # Height of mobile station
er999.cityKind = CityKind.Medium

errorEricsson999 = errorModel(er999, db_train)

#### SUI (STANFORD UNIVERSITY INTERIM) ####
sui = SuiModel()
sui.freq = 2100    		# MHz
sui.txH = 35      		# Height of the cell site (15~40m)
sui.rxH = 2       		# Height of mobile station
sui.shadowFading = 9.0 	# Shadow fading (8.2~10.6dB)
sui.terrainKind = TerrainKind.B
# TerrainKind
# Category A: hilly terrain with moderate-to-heavy tree
            # densities, which results in the maximum path loss
# Category B: hilly environment but rare vegetation, or high 
            # vegetation but flat terrain. Intermediate path loss
            # condition is typical of this category.
# Category C: mostly flat terrain with light tree densities. 
            # It corresponds to minimum path loss conditions

errorSUI = errorModel(sui, db_train)

#### Lee Model ####
lee = LeeModel()
lee.freq = 950    				  # MHz
lee.txH = 90      				  # Height of the cell site
lee.rxH = 1.5     				  # Height of mobile station
lee.leeArea = LeeArea.NewYorkCity # (determined empirically)
# Area parameters are tuples as follow:
# FreeSpace = (2.0, 45.0)
# OpenArea = (4.35, 49.0)
# SubUrban = (3.84, 61.7)
# Philadelphia = (3.68, 70.0)
# Newark = (4.31, 64.0)
# Tokyo = (3.05, 84.0)
# NewYorkCity = (4.8, 77.0) //n = 4.8 and Po = 77.0

errorLee = errorModel(lee, db_train)

#### Flat Earth Model ####
fe = FlatEarthModel()
fe.freq = 950    # MHz
fe.txH = 90      # Height of the cell site
fe.rxH = 1.5     # Height of mobile station

errorFlatEarth = errorModel(fe, db_train)

# construindo DataFrame com os RMSE para cada modelo
errorModels = vcat(errorFreeSpace, errorOkumuraHata,
                    errorCost231Hata, errorCost231WaldIk,
                    errorECC33, errorEricsson999, errorSUI,
                    errorLee, errorFlatEarth)

modelNames = DataFrame(ModelName=["FreeSpace","OkumuraHata",
                                "Cost231Hata","Cost231WI",
                                "ECC-33","Ericsson999", 
                                "SUI","Lee","FlatEarth"])

errorModels2 = hcat(modelNames, errorModels)



