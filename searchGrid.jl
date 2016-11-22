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
  long = 0.0;
  lat = 0.0;

  for row in eachrow(df_2)
    df = convert(Array,row[5:10]);
    result = evaluate(func, df_1, convert(Array, df));
    #println(string("distance:", result))
    if(result < distance)
      distance = result;
      pair = (row[:i],row[:j]);
      long = row[:lon]
      lat = row[:lat]
    end
    if(distance == 0)
      return pair, long, lat
    end
  end

#  println(string("minDist: ",distance))
  return pair, long, lat;
end

#grid dimentions =  Longitude  -34.91  a  -34.887  | Latitude de  -8.080 a -8.065;

#med = readtable("medicoes.csv", separator = ',');
#GRID Dimentions
#=init_lon = minimum(convert(Array, med[:lon]));
end_lon = maximum(convert(Array, med[:lon]));
init_lat = minimum(convert(Array, med[:lat]));
end_lat = maximum(convert(Array, med[:lat]));=#

init_lon = -34.905396;
end_lon = -34.885067;
init_lat = -8.077546;
end_lat = -8.060549;

function createGRID(rH, X)
  #Latitude and Longitude Precision
  #create GRID
  grid = DataFrame(i = [], j = [], lon = [], lat = []);

  #new_latitude  = latitude  + (dy / r_earth) * (180 / pi);
  #new_longitude = longitude + (dx / r_earth) * (180 / pi) / cos(latitude * pi/180);
  r_earth = 6378; #km
  rH = rH/1000; #km

  num_i = 1;
  num_j = 1;
  aux_j = 1;

  new_lat = init_lat + ((rH/2) / r_earth) * (180 / pi);
  new_lon = init_lon + ((rH/2) / r_earth) * (180 / pi) / cos(new_lat * pi/180);
  #push!(grid, [num_i, num_j, new_lon, new_lat]);


  @time while new_lat <= end_lat
      lat = new_lat;
      while new_lon <= end_lon
          push!(grid, [num_i, aux_j, new_lon, new_lat]);
          lon = new_lon;
          new_lon = lon + (rH / r_earth) * (180 / pi) / cos(lat * pi/180);
          aux_j = aux_j + 1;
          num_j = aux_j;

      end

      new_lat = lat + (rH / r_earth) * (180 / pi);
      new_lon = init_lon + ((rH/2) / r_earth) * (180 / pi) / cos(new_lat * pi/180);
      aux_j = 1;
      num_i = num_i + 1;
  end
  num_i = num_i - 1;
  num_j = num_j - 1;

  X[1] = num_i;
  X[2] = num_j;
  ################################################################

  #### Lee Model ####
  lee = LeeModel()
  lee.freq = 1800                   # MHz
  lee.txH = 50                      # Height of the cell site
  lee.rxH = 1.5                     # Height of mobile station
  lee.leeArea = LeeArea.NewYorkCity # (determined empirically)

  lat1 = db_erbs[1,:lat];
  lon1 = db_erbs[1,:lon];

  lat2 = db_erbs[2,:lat];
  lon2 = db_erbs[2,:lon];

  lat3 = db_erbs[3,:lat];
  lon3 = db_erbs[3,:lon];

  lat4 = db_erbs[4,:lat];
  lon4 = db_erbs[4,:lon];

  lat5 = db_erbs[5,:lat];
  lon5 = db_erbs[5,:lon];

  lat6 = db_erbs[6,:lat];
  lon6 = db_erbs[6,:lon];

  grid_2 = @byrow! grid begin
      @newcol PL_1::Array{Float64}
      @newcol PL_2::Array{Float64}
      @newcol PL_3::Array{Float64}
      @newcol PL_4::Array{Float64}
      @newcol PL_5::Array{Float64}
      @newcol PL_6::Array{Float64}
      :PL_1 = pathloss(lee, distanceInKm(:lat,:lon, lat1, lon1))
      :PL_2 = pathloss(lee, distanceInKm(:lat,:lon, lat2, lon2))
      :PL_3 = pathloss(lee, distanceInKm(:lat,:lon, lat3, lon3))
      :PL_4 = pathloss(lee, distanceInKm(:lat,:lon, lat4, lon4))
      :PL_5 = pathloss(lee, distanceInKm(:lat,:lon, lat5, lon5))
      :PL_6 = pathloss(lee, distanceInKm(:lat,:lon, lat6, lon6))
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
grid50 = readtable("grid50.csv", separator = ';');
num_i = maximum(convert(Array, grid50[:i]))#X[1];
num_j = maximum(convert(Array, grid50[:j]))#X[2];

#=grid10 = createGRID(10,X);
grid5 = createGRID(5,X);

writetable("grid10.csv", grid10,separator=';')
writetable("grid5.csv", grid5,separator=';')=#

grid10 = readtable("grid10.csv", separator = ';');
grid5 = readtable("grid5.csv", separator = ';');
#grid1 = createGRID(1,X);

range_i = 1:(num_i);
range_j = 1:(num_j);
range_col = 1:10;
#println(nrow(grid))
#@time grid50 = filterGrid(grid50,range_i,range_j)
#println(head(grid50))#minGrid[:SqEuclidean] = (0,0);
#println(head(grid10))
#println(head(grid5))
#println(nrow(grid))
#minGrid = head(minGrid , 1);

minGrid[:SqEuclidean1] = (0,0)
minGrid[:SqEuclidean2] = (0,0)
minGrid[:SqEuclidean3] = (0,0)#=
minGrid[:SqEuclidean4] = (0,0)=#
minGrid[:latM] = 0.0
minGrid[:longM] = 0.0
minGrid[:distance] = 0.0

divArea = 8

aux_i10 = divInteiro((range_i[end]+1)-range_i[1],divArea*2)
aux_j10 = divInteiro((range_j[end]+1)-range_j[1],divArea*2)


#=
distance = [Euclidean(), SqEuclidean(), Cityblock(), Chebyshev(), Jaccard(), CosineDist(), CorrDist(), CorrDist()]
distance_mean = fill(0.0, size(distance)[1]);


i = 1;

@time while(i <= size(distance)[1])
  @time for row in eachrow(minGrid)
  	#search in 50 meters
      df_1 = [row[:PLBTS1] row[:PLBTS2] row[:PLBTS3] row[:PLBTS4] row[:PLBTS5] row[:PLBTS6]];
      row[:SqEuclidean1], row[:longM], row[:latM] = minimum_distance(distance[i], df_1, grid50);
    #--------------------------- search in 10 meters
      range_i = mapGrid(50,10,row[:SqEuclidean1][1]-aux_i10) : mapGrid(50,10,row[:SqEuclidean1][1]+aux_i10)
      range_j = mapGrid(50,10,row[:SqEuclidean1][2]-aux_j10) : mapGrid(50,10,row[:SqEuclidean1][2]+aux_j10)
      gridAux = filterGrid(grid10,range_i,range_j)
      row[:SqEuclidean2], row[:longM], row[:latM] = minimum_distance(distance[i], df_1, gridAux);
  	#--------------------------- search in 5 meters
    	aux_i5 = divInteiro((range_i[end]+1)-range_i[1],divArea)
    	aux_j5 = divInteiro((range_j[end]+1)-range_j[1],divArea)
    	range_i = mapGrid(10,5,row[:SqEuclidean2][1]-aux_i5) : mapGrid(10,5,row[:SqEuclidean2][1]+aux_i5)
      range_j = mapGrid(10,5,row[:SqEuclidean2][2]-aux_j5) : mapGrid(10,5,row[:SqEuclidean2][2]+aux_j5)
      gridAux = filterGrid(grid5,range_i,range_j)
      row[:SqEuclidean3], row[:longM], row[:latM] = minimum_distance(distance[i], df_1, gridAux);
      row[:distance] = distanceInKm(row[:latM], row[:longM], row[:lat], row[:lon]); 
  end
  distance_mean[i] = mean(minGrid[:distance])
  i = i + 1;
  
end=#

@time for row in eachrow(minGrid)
    #search in 50 meters
      df_1 = [row[:PLBTS1] row[:PLBTS2] row[:PLBTS3] row[:PLBTS4] row[:PLBTS5] row[:PLBTS6]];
      row[:SqEuclidean1], row[:longM], row[:latM] = minimum_distance(SqEuclidean(), df_1, grid50);
    #--------------------------- search in 10 meters
      range_i = mapGrid(50,10,row[:SqEuclidean1][1]-aux_i10) : mapGrid(50,10,row[:SqEuclidean1][1]+aux_i10)
      range_j = mapGrid(50,10,row[:SqEuclidean1][2]-aux_j10) : mapGrid(50,10,row[:SqEuclidean1][2]+aux_j10)
      gridAux = filterGrid(grid10,range_i,range_j)
      row[:SqEuclidean2], row[:longM], row[:latM] = minimum_distance(SqEuclidean(), df_1, gridAux);
    #--------------------------- search in 5 meters
      aux_i5 = divInteiro((range_i[end]+1)-range_i[1],divArea)
      aux_j5 = divInteiro((range_j[end]+1)-range_j[1],divArea)
      range_i = mapGrid(10,5,row[:SqEuclidean2][1]-aux_i5) : mapGrid(10,5,row[:SqEuclidean2][1]+aux_i5)
      range_j = mapGrid(10,5,row[:SqEuclidean2][2]-aux_j5) : mapGrid(10,5,row[:SqEuclidean2][2]+aux_j5)
      gridAux = filterGrid(grid5,range_i,range_j)
      row[:SqEuclidean3], row[:longM], row[:latM] = minimum_distance(SqEuclidean(), df_1, gridAux);
      row[:distance] = distanceInKm(row[:latM], row[:longM], row[:lat], row[:lon]); 
end

println(head(minGrid))
println(mean(minGrid[:distance]))
#
#para deixar mais rapido, tentar verificar pontos próximos para não ter que fazer o grid toda iteração
