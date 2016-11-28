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

################################################################
function mapGrid(N,n,x)

return ((N/n)*(2*x -1) + 1)/2

end

function vinici(minGrid_ij, range, distMeters, grid5,name)

	point_i = 0
	point_j = 0
	end_i = convert(Int64, maximum(convert(Array, grid5[:i])));
	end_j = convert(Int64, maximum(convert(Array, grid5[:j])));

	range_i = 1:end_i;
	range_j = 1:end_j;
	range_i5 = range_i;
	range_j5 = range_j;
	index = 0;

	maxPoint_i5 = 0;
	maxPoint_j5 = 0;
	minPoint_i5 = 0;
	minPoint_j5 = 0;

	minGrid_ij[:Flag] = false;
  grid5[:Flag] = false;

	for row in eachrow(minGrid_ij)
		if(row[:distance] <= (distMeters/1000))
			row[:Flag] = true;
      index = ((row[:Point_i] - 1) * range_j[end]) + row[:Point_j]
      #println(grid5[index,:Flag])
      grid5[index,:Flag] = true;
      #println(index)
      #println(grid5[index,:Flag])
		end
	end
	for row in eachrow(minGrid_ij)

		if(row[:Flag] == true)


			point_i = row[:Point_i]
			point_j = row[:Point_j]

			if(exist(point_i-range, range_i))
				minPoint_i5 = point_i-range;
			else
				minPoint_i5 = 1;
			end

			if(exist(point_i+range, range_i))
				maxPoint_i5 = point_i+range;
			else
				range_i5 = end_i;
			end

			if(exist(point_j-range, range_j))
				minPoint_j5 = point_j-range;
			else
				minPoint_j5 = 1;
			end

			if(exist(point_j+range, range_j))
				maxPoint_j5 = point_j+range;

			else
				maxPoint_j5 = end_j;
			end

			range_i5 = minPoint_i5:maxPoint_i5;
			range_j5 = minPoint_j5:maxPoint_j5;

			index1 = ((point_i - 1) * (end_j)) + point_j

			PL_BTS1 = grid5[index1, :PL_1]
			PL_BTS2 = grid5[index1, :PL_2]
			PL_BTS3 = grid5[index1, :PL_3]
			PL_BTS4 = grid5[index1, :PL_4]
			PL_BTS5 = grid5[index1, :PL_5]
			PL_BTS6 = grid5[index1, :PL_6]

			for i in range_i5
				for j in range_j5

					index = ((i - 1) * (range_j[end])) + j

					if(grid5[index, :Flag] == false)
            #println("A");
          	grid5[index, :PL_1] = (PL_BTS1 + grid5[index, :PL_1])/2
						grid5[index, :PL_2] = (PL_BTS2 + grid5[index, :PL_2])/2
						grid5[index, :PL_3] = (PL_BTS3 + grid5[index, :PL_3])/2
						grid5[index, :PL_4] = (PL_BTS4 + grid5[index, :PL_4])/2
						grid5[index, :PL_5] = (PL_BTS5 + grid5[index, :PL_5])/2
						grid5[index, :PL_6] = (PL_BTS6 + grid5[index, :PL_6])/2
					end

				end

			end

		end

	end
  delete!(grid5, :Flag);
	writetable(string("grid",name,"_ij.csv"), grid5, separator = ';');

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
#=
g1  g2  g3  grid_T  erro tempo
50	20	10	train	   99	   116-----------configuração com menor tempo dentre as configurações com o menor erro
50	20	10	test    120    30------------s
75	20	10	train	  102	   64------------configuração com o menor erro dentre as configurações com menores tempo
75	20	10	test	  120	   16------------
=#
search = readtable("search.csv", separator =';',header = false)
search[:error] = 0.0

for row1 in eachrow(search)

  map1 = row1[:x1];
  map2 = row1[:x2];
  map3 = row1[:x3];

  minGrid = readtable(string(row1[:x4],"_pl.csv"), separator = ',')
  #println(num_i, num_j)
  #println(nrow(grid))
  delete!(minGrid, (3:8));

  grid50 = readtable(string("grid",map1,".csv"), separator = ';');
  num_i = maximum(convert(Array, grid50[:i]))#X[1];
  num_j = maximum(convert(Array, grid50[:j]))#X[2];

  #=grid10 = createGRID(10,X);
  grid5 = createGRID(5,X);

  writetable("grid10.csv", grid10,separator=';')
  writetable("grid5.csv", grid5,separator=';')=#

  grid10 = readtable(string("grid",map2,".csv"), separator = ';');
  global grid5 = readtable(string("grid",map3,".csv"), separator = ';');
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

  @time for row in eachrow(minGrid)
  	#search in 50 meters
      df_1 = [row[:PLBTS1] row[:PLBTS2] row[:PLBTS3] row[:PLBTS4] row[:PLBTS5] row[:PLBTS6]];
      row[:SqEuclidean1], row[:longM], row[:latM] = minimum_distance(SqEuclidean(), df_1, grid50);
    #--------------------------- search in 10 meters
    if(map2 != 0)
      range_j = mapGrid(map1,map2,row[:SqEuclidean1][2]-aux_j10) : mapGrid(map1,map2,row[:SqEuclidean1][2]+aux_j10)
      range_i = mapGrid(map1,map2,row[:SqEuclidean1][1]-aux_i10) : mapGrid(map1,map2,row[:SqEuclidean1][1]+aux_i10)
      gridAux = filterGrid(grid10,range_i,range_j)
      row[:SqEuclidean2], row[:longM], row[:latM] = minimum_distance(SqEuclidean(), df_1, gridAux);
    end
  	#--------------------------- search in 5 meters
    if(map3 != 0)
        aux_i5 = divInteiro((range_i[end]+1)-range_i[1],divArea)
      	aux_j5 = divInteiro((range_j[end]+1)-range_j[1],divArea)
      	range_i = mapGrid(map2,map3,row[:SqEuclidean2][1]-aux_i5) : mapGrid(map2,map3,row[:SqEuclidean2][1]+aux_i5)
        range_j = mapGrid(map2,map3,row[:SqEuclidean2][2]-aux_j5) : mapGrid(map2,map3,row[:SqEuclidean2][2]+aux_j5)
        gridAux = filterGrid(grid5,range_i,range_j)
        row[:SqEuclidean3], row[:longM], row[:latM] = minimum_distance(SqEuclidean(), df_1, gridAux);
    end
    row[:distance] = distanceInKm(row[:latM], row[:longM], row[:lat], row[:lon]);

  end
  row1[:error] = mean(minGrid[:distance])
  println(row1[:error])
  #=
  #---------------------- COMENTA AQUI PARA TIRAR O APRIMORAMENTO --------------------
  global minGrid2 = @byrow! minGrid begin
       @newcol Point_i::Array{Int64}
       @newcol Point_j::Array{Int64}
       :Point_i = :SqEuclidean3[1]
       :Point_j = :SqEuclidean3[2]
  end

  #writetable("minGrid_ij.csv", minGrid2, separator = ';');
  vinici(minGrid2, 4, 50, grid5, row1[:x3]);
  #---------------------- ATE AQUI --------------------------------------------------
=#
end
    #println(head(minGrid))


#
#para deixar mais rapido, tentar verificar pontos próximos para não ter que fazer o grid toda iteração

# Separando tupla SqEuclidean3 em duas colunas diferentes
