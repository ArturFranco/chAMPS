#directoryIN = "C:/Users/Vinicius Sanguinete/Documents/chAMPS/"
using DataFrames
using RDatasets
#read the input file
set = readtable("medicoes.csv", separator = ',')

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

function pathLossMedido(db)
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

set[:sort] = 0.0;

srand(1);
for row in eachrow(set)
  row[:sort] = rand()*rand();
end
set = sort(set,cols=[:sort]);

delete!(set,:sort);
writetable("medicoesSort.csv", set, separator =',')

#pegando os [1-80]%
train = set[1:(divInteiro(nrow(set)*4,5)),:]
#pegando os [80-100]%
test = set[(divInteiro(nrow(set)*4,5)+1):nrow(set),:]

writetable("train.csv", train,separator = ',')

writetable("test.csv", test,separator = ',')

train_pl = pathLossMedido(train);

test_pl = pathLossMedido(test);

med_pl = pathLossMedido(set);

writetable("train_pl.csv", train_pl,separator = ',')

writetable("test_pl.csv", test_pl,separator = ',')

writetable("med_pl.csv", test_pl,separator = ',')
