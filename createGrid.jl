using DataFrames
using DataFramesMeta
using PathLoss

#grid dimentions =  Longitude  -34.91  a  -34.887  | Latitude de  -8.080 a -8.065;
med = readtable("medicoes.csv", separator = ',');
#GRID Dimentions
init_long = minimum(convert(Array, med[:lon]));
end_long = maximum(convert(Array, med[:lon]));
init_lat = minimum(convert(Array, med[:lat]));
end_lat = maximum(convert(Array, med[:lat]));

#GRID Precition
rH = 50; #meters

#meters per Latitude and Longitude units
LAT = 111122.19769903777; #meters
LONG = 111105.27282045991; #meters

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
num_j = ceil(Int64, lat_length / rh_lat);

for c_i = 0:num_i
    for c_j = 0:num_j
        a_long = init_long + (c_i*rh_long) + (rh_long/2);
        a_lat = init_lat + (c_j*rh_lat) + (rh_lat/2);
        push!(grid, [c_i + 1, c_j + 1, a_long, a_lat]);
    end
end  

################################################################

db_erbs = readtable("erbs.csv", separator = ',');

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

grid = @byrow! grid begin
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

################################################################

train = readtable("test_pl.csv", separator = ',');

    train_long = train[1,:lon];
    train_lat = train[1,:lat];

    aux_i = ceil(Int64, (train_long - init_long)/rh_long);
    aux_j = ceil(Int64, (train_lat - init_lat)/rh_lat);

    grid_row = grid[((aux_i - 1) * (num_j +1)) + aux_j , :];
    grid_row[:PL_1] = mean([train[1,:PLBTS1], grid_row[:PL_1]]);
    grid[((aux_i - 1) * (num_j +1)) + aux_j, :] = grid_row;

#=for row in eachrow(train)
    train_long = row[:lon];
    train_lat = row[:lat];

    aux_i = ceil(Int64, (train_long - init_long)/rh_long);
    aux_j = ceil(Int64, (train_lat - init_lat)/rh_lat);

    grid_row = grid[((aux_i - 1) * (num_j +1)) + aux_j , :];

    grid_row[:PL_1] = mean([row[:PLBTS1], grid_row[:PL_1]]);
    grid_row[:PL_2] = mean([row[:PLBTS2], grid_row[:PL_2]]);
    grid_row[:PL_3] = mean([row[:PLBTS3], grid_row[:PL_3]]);
    grid_row[:PL_4] = mean([row[:PLBTS4], grid_row[:PL_4]]);
    grid_row[:PL_5] = mean([row[:PLBTS5], grid_row[:PL_5]]);
    grid_row[:PL_6] = mean([row[:PLBTS6], grid_row[:PL_6]]);

    grid[((aux_i - 1) * (num_j +1)) + aux_j, :] = grid_row;

end=#


