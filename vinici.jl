using DataFrames
using DataFramesMeta
using RDatasets
using PathLoss
using Distances

minGrid = readtable("minGrid.csv", separator = ';');
grid5 = readtable("grid5.csv", separator = ';');

function exist(x,Y)
  if(x >= Y[1] && x <= Y[end])
   return true
  else
   return false
  end
end

function vinici(minGrid, range, distMeters, grid5)

	cont = 0;
	point = (0.0, 0.0)
	range_i = 1:maximum(convert(Array, grid5[:i]));
	range_j = 1:maximum(convert(Array, grid5[:j]));
	range_i5 = range_i;
	range_j5 = range_j;
	index = 0;

	@time for row in eachrow(minGrid)

		if(row[:distance] <= (distMeters/1000))

			point = convert(Tuple{Int64, Int64}, row[:SqEuclidean3])
			println(point)
			break;
	
			if(exist(point[1]-range, range_i))
				range_i5[1] = point[1]-range
			else 
				range_i5[1] = range_i[1]
			end

			if(exist(point[1]+range, range_i))
				range_i5[2] = point[1]+range
			else 
				range_i5[2] = range_i[2]
			end

			if(exist(point[2]-range, range_j))
				range_j5[1] = point[2]-range
			else 
				range_j5[1] = range_j[1]
			end

			if(exist(point[2]+range, range_j))
				range_j5[2] = point[2]+range
			else 
				range_j5[2] = range_j[2]
			end

			PL_BTS1 = grid5[((point[1] - 1) * (range_j[2])) + point[2], :PL_1]
			PL_BTS2 = grid5[((point[1] - 1) * (range_j[2])) + point[2], :PL_2]
			PL_BTS3 = grid5[((point[1] - 1) * (range_j[2])) + point[2], :PL_3]
			PL_BTS4 = grid5[((point[1] - 1) * (range_j[2])) + point[2], :PL_4]
			PL_BTS5 = grid5[((point[1] - 1) * (range_j[2])) + point[2], :PL_5]
			PL_BTS6 = grid5[((point[1] - 1) * (range_j[2])) + point[2], :PL_6]


			for i in range_i5
				for j in range_j5
					index = ((i - 1) * (range_j[2])) + j
					grid5[index, :PL_1] = mean(PL_BTS1, grid5[index, :PL_1])
					grid5[index, :PL_2] = mean(PL_BTS2, grid5[index, :PL_2])
					grid5[index, :PL_3] = mean(PL_BTS3, grid5[index, :PL_3])
					grid5[index, :PL_4] = mean(PL_BTS4, grid5[index, :PL_4])
					grid5[index, :PL_5] = mean(PL_BTS5, grid5[index, :PL_5])
					grid5[index, :PL_6] = mean(PL_BTS6, grid5[index, :PL_6])
				end
			end

		end
	end

	writetable("vinici.csv", grid5, separator = ';')
end

vinici(minGrid, 1, 10, grid5)

