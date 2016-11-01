using DataFrames

#grid dimentions =  Longitude  -34.91  a  -34.887  | Latitude de  -8.080 a -8.065;

#GRID Dimentions
init_long = -34.91;
end_long = -34.887;
init_lat = -8.080;
end_lat = -8.065;

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

long_length = abs(end_long - init_long);
lat_length = abs(end_lat - init_lat);


lat_meters = lat_length * LAT;
long_meters = long_length * LONG;
#long_length = 200;
#lat_length = 200;


num_i = ceil(Int64, long_length / rh_long);
num_j = ceil(Int64, lat_length / rh_lat);


for c_i = 0:num_i
    for c_j = 0:num_j
        a_long = (c_i*rh_long) + (rh_long/2);
        a_lat = (c_j*rh_lat) + (rh_lat/2);
        push!(grid, [c_i + 1, c_j + 1, a_long, a_lat]);
    end
end  

