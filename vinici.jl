using DataFrames
using DataFramesMeta
using RDatasets
using PathLoss
using Distances

minGrid_ij = readtable("minGrid_ij.csv", separator = ';');
grid = readtable("grid40.csv", separator = ';');

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
  global count = 0
	@time for row in eachrow(minGrid_ij)
		if(row[:distance] <= (distMeters/1000))
			row[:Flag] = true;
      index = ((row[:Point_i] - 1) * range_j[end]) + row[:Point_j]
      #println(grid5[index,:Flag])
      #println(string(row[:Point_i],",",row[:Point_j]))
      grid5[index,:Flag] = true;
      #println(index)
      #println(grid5[index,:Flag])
		end
	end

#=

  min_i = convert(Array, minGrid_ij[minGrid_ij[:Flag].==true,:Point_i]);
  min_j = convert(Array, minGrid_ij[minGrid_ij[:Flag].==true,:Point_j]);
  grid_i = convert(Array, grid5[grid5[:Flag].==true,:i]);
  grid_j = convert(Array, grid5[grid5[:Flag].==true,:j]);
  println(evaluate(SqEuclidean(), min_i, grid_i))
  println(evaluate(SqEuclidean(), min_j, grid_j))
#  println(range_i)
=#
  	@time for row in eachrow(minGrid_ij)

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
  	writetable("grid40_ij.csv", grid5, separator = ';');

end

vinici(minGrid_ij, 10, 50, grid);

#println(head(vinici5));
