using DataFrames
using DataFramesMeta
using PathLoss
#grid dimentions =  Longitude  -34.91  a  -34.887  | Latitude de  -8.080 a -8.065;
med = readtable("medicoes.csv", separator = ',');
#GRID Dimentions
init_lon = minimum(convert(Array, med[:lon]));
end_lon = maximum(convert(Array, med[:lon]));
init_lat = minimum(convert(Array, med[:lat]));
end_lat = maximum(convert(Array, med[:lat]));

#GRID Precition
rH = 50; #meters

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
################################################################

db_erbs = readtable("erbs.csv", separator = ',');

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

grid = @byrow! grid begin
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

################################################################

#=train = readtable("test_pl.csv", separator = ',');

    train_lon = train[2,:lon];
    train_lat = train[2,:lat];

    aux_i = ceil(Int64, (train_lon - init_lon)/rh_lon);
    aux_j = ceil(Int64, (train_lat - init_lat)/rh_lat);

    grid_row = grid[((aux_i - 1) * (num_j +1)) + aux_j , :];
    grid_row[:PL_1] = mean([train[1,:PLBTS1], grid_row[:PL_1]]);
    grid[((aux_i - 1) * (num_j +1)) + aux_j, :] = grid_row;=#

#=for row in eachrow(train)
    train_lon = row[:lon];
    train_lat = row[:lat];

    aux_i = ceil(Int64, (train_lon - init_lon)/rh_lon);
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


