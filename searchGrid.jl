using DataFrames
using DataFramesMeta
using RDatasets
using PathLoss
using Distances
db_erbs = readtable("erbs.csv", separator = ',');

function exist(x,Y)
  if(x >= Y[1] && x<= Y[end])
   return true
  else
   return false
  end
end

function divInteiro(int, div)
  value = -1
  if(int >= div)
    if(div > 0)
      value = (int-int%div)/div
    end
  else
    value = int%div
  end
  return Int64(value)
end

function filterGrid(grid, range_i,range_j)
  grid[:flag] = false
  for row in eachrow(grid)
    if(exist(row[:i],range_i) && exist(row[:j],range_j))
      row[:flag] = true
    end
  end
  grid = grid[grid[:flag].== true, :]
  return grid
end

#return the pair(i,j) of df_2 with the minimum distance for the df_1 inside range_i, range_j using func
#range_col  = coloums in df_1 to be compared with df_2
function minimum_distance(func, df_1, df_2)
  pair = (0,0);
  distance = Inf;

  for row in eachrow(df_2)
    df = convert(Array,row[5:10]);
    result = evaluate(func, df_1, convert(Array, df));
    #println(string("distance:", result))
    if(result < distance)
      distance = result;
      pair = (row[:i],row[:j]);
    end
    if(distance == 0)
      return pair
    end
  end

#  println(string("minDist: ",distance))
  return pair;
end

#grid dimentions =  Longitude  -34.91  a  -34.887  | Latitude de  -8.080 a -8.065;

#GRID Dimentions
init_long = -34.91;
end_long = -34.887;
init_lat = -8.080;
end_lat = -8.065;

#meters per Latitude and Longitude units
LAT = 111122.19769903777; #meters
LONG = 111105.27282045991; #meters

function createGRID(rH, X)
  #Latitude and Longitude Precision
  rh_lat = rH*(1/LAT); #coords
  rh_long = rH*(1/LONG); #coords

  #create GRID
  grid = DataFrame(i = [], j = [], long = [], lat = []);

  #calculate Latitude and longitude lengths
  long_length = abs(end_long - init_long);
  lat_length = abs(end_lat - init_lat);

  lat_meters = lat_length * LAT;
  long_meters = long_length * LONG;

  num_i = ceil(Int64, long_length / rh_long);
  X[1] = num_i
  num_j = ceil(Int64, lat_length / rh_lat);
  X[2] = num_j

  for c_i = 0:num_i
      for c_j = 0:num_j
          a_long = init_long + (c_i*rh_long) + (rh_long/2);
          a_lat = init_lat + (c_j*rh_lat) + (rh_lat/2);
          push!(grid, [c_i + 1, c_j + 1, a_long, a_lat]);
      end
  end
  #### Lee Model ####
  lee = LeeModel()
  lee.freq = 1800                   # MHz
  lee.txH = 50                      # Height of the cell site
  lee.rxH = 1.5                     # Height of mobile station
  lee.leeArea = LeeArea.NewYorkCity # (determined empirically)

  lat1 = db_erbs[1,:lat];
  long1 = db_erbs[1,:lon];

  lat2 = db_erbs[2,:lat];
  long2 = db_erbs[2,:lon];

  lat3 = db_erbs[3,:lat];
  long3 = db_erbs[3,:lon];

  lat4 = db_erbs[4,:lat];
  long4 = db_erbs[4,:lon];

  lat5 = db_erbs[5,:lat];
  long5 = db_erbs[5,:lon];

  lat6 = db_erbs[6,:lat];
  long6 = db_erbs[6,:lon];

  grid_2 = @byrow! grid begin
      @newcol PL_1::Array{Float64}
      @newcol PL_2::Array{Float64}
      @newcol PL_3::Array{Float64}
      @newcol PL_4::Array{Float64}
      @newcol PL_5::Array{Float64}
      @newcol PL_6::Array{Float64}
      :PL_1 = pathloss(lee, distanceInKm(:lat,:long, lat1, long1))
      :PL_2 = pathloss(lee, distanceInKm(:lat,:long, lat2, long2))
      :PL_3 = pathloss(lee, distanceInKm(:lat,:long, lat3, long3))
      :PL_4 = pathloss(lee, distanceInKm(:lat,:long, lat4, long4))
      :PL_5 = pathloss(lee, distanceInKm(:lat,:long, lat5, long5))
      :PL_6 = pathloss(lee, distanceInKm(:lat,:long, lat6, long6))
  end;
  return grid_2
end
################################################################
function mapGrid(N,n,x)

return ((N/n)*(2*x -1) + 1)/2

end
#=
minGrid = readtable("test_pl.csv", separator = ',')
srand(1)
minGrid[:sort] = 0.0
for row in eachrow(minGrid)
	row[:sort] = rand()
end
minGrid = sort(minGrid, cols=[:sort])
delete!(minGrid,:sort)
writetable("test_pl.csv", minGrid,separator=',')
=#
#println(head(grid))

minGrid = readtable("test_pl.csv", separator = ',')
#println(num_i, num_j)
#println(nrow(grid))
delete!(minGrid, (3:8));

X = [0,0];
grid50 = createGRID(50,X);
num_i = X[1];
num_j = X[2];

grid10 = readtable("grid10.csv", separator = ';');
grid5 = readtable("grid5.csv", separator = ';');
#grid1 = createGRID(1,X);

range_i = 1:(num_i+1);
range_j = 1:(num_j+1);
range_col = 1:10;
#println(nrow(grid))
@time grid50 = filterGrid(grid50,range_i,range_j)
println(head(grid50))#minGrid[:SqEuclidean] = (0,0);
#println(head(grid10))
#println(head(grid5))
#println(nrow(grid))
#minGrid = head(minGrid , 1);

minGrid[:SqEuclidean1] = (0,0)
minGrid[:SqEuclidean2] = (0,0)
minGrid[:SqEuclidean3] = (0,0)#=
minGrid[:SqEuclidean4] = (0,0)=#

divArea = 8

aux_i10 = divInteiro((range_i[end]+1)-range_i[1],divArea*2)
aux_j10 = divInteiro((range_j[end]+1)-range_j[1],divArea*2)

@time for row in eachrow(minGrid)
	#search in 50 meters
    df_1 = [row[:PLBTS1] row[:PLBTS2] row[:PLBTS3] row[:PLBTS4] row[:PLBTS5] row[:PLBTS6]];
    row[:SqEuclidean1] = minimum_distance(SqEuclidean(), df_1, grid50);
    #--------------------------- search in 10 meters
    range_i = mapGrid(50,10,row[:SqEuclidean1][1]-aux_i10) : mapGrid(50,10,row[:SqEuclidean1][1]+aux_i10)
    range_j = mapGrid(50,10,row[:SqEuclidean1][2]-aux_j10) : mapGrid(50,10,row[:SqEuclidean1][2]+aux_j10)
    gridAux = filterGrid(grid10,range_i,range_j)
    row[:SqEuclidean2] = minimum_distance(SqEuclidean(), df_1, gridAux);
	#--------------------------- search in 5 meters
	aux_i5 = divInteiro((range_i[end]+1)-range_i[1],divArea)
	aux_j5 = divInteiro((range_j[end]+1)-range_j[1],divArea)
	range_i = mapGrid(10,5,row[:SqEuclidean2][1]-aux_i5) : mapGrid(10,5,row[:SqEuclidean2][1]+aux_i5)
    range_j = mapGrid(10,5,row[:SqEuclidean2][2]-aux_j5) : mapGrid(10,5,row[:SqEuclidean2][2]+aux_j5)
    gridAux = filterGrid(grid5,range_i,range_j)
    row[:SqEuclidean3] = minimum_distance(SqEuclidean(), df_1, gridAux);
	
end
println(head(minGrid))
#
#para deixar mais rapido, tentar verificar pontos próximos para não ter que fazer o grid toda iteração
