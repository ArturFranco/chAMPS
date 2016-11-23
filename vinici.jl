using DataFrames
using DataFramesMeta
using RDatasets
using PathLoss
using Distances

minGrid_ij = readtable("minGrid_ij.csv", separator = ';');
grid5 = readtable("grid5.csv", separator = ';');

function exist(x,Y)
  if(x >= Y[1] && x <= Y[end])
   return true
  else
   return false
  end
end

function vinici(minGrid_ij, range, distMeters, grid5)

	point_i = 0
	point_j = 0
	range_i = 1:convert(Int64, maximum(convert(Array, grid5[:i])));
	range_j = 1:convert(Int64, maximum(convert(Array, grid5[:j])));
	range_i5 = range_i;
	range_j5 = range_j;
	index = 0;

	@time for row in eachrow(minGrid_ij)

		if(row[:distance] <= (distMeters/1000))
			point_i = row[:Point_i]
			point_j = row[:Point_j]
	
			if(exist(point_i-range, range_i))
				range_i5 = (point_i-range):convert(Int64, maximum(convert(Array, grid5[:i])));
			else 
				range_i5 = range_i
			end

			if(exist(point_i+range, range_i))
				range_i5 = 1:(point_i+range)
			else 
				range_i5 = range_i
			end

			if(exist(point_j-range, range_j))
				range_j5 = (point_j-range):convert(Int64, maximum(convert(Array, grid5[:j])));
			else 
				range_j5 = range_j
			end

			if(exist(point_j+range, range_j))
				range_j5 = 1:(point_j+range)
			else 
				range_j5 = range_j
			end

			index1 = ((range_i[1] - 1) * (range_j[end])) + range_j[1]

			PL_BTS1 = grid5[index1, :PL_1]
			PL_BTS2 = grid5[index1, :PL_2]
			PL_BTS3 = grid5[index1, :PL_3]
			PL_BTS4 = grid5[index1, :PL_4]
			PL_BTS5 = grid5[index1, :PL_5]
			PL_BTS6 = grid5[index1, :PL_6]

			for i in range_i5
				for j in range_j5
					index = ((i - 1) * (range_j[end])) + j
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

	writetable("vinici.csv", grid5, separator = ';')
end

vinici(minGrid_ij, 100, 5, grid5);

println(grid5)