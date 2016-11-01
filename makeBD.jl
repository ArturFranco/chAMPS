directoryIN = "C:/Users/Vinicius Sanguinete/Documents/chAMPS/"
using DataFrames
#read the input file
set = readtable("C:/Users/Vinicius Sanguinete/Documents/chAMPS/medicoes.csv", separator = ',')

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

#pegando os [1-80]%
train = set[1:(divInteiro(nrow(set)*4,5)),:]
#pegando os [80-90]%
test = set[(divInteiro(nrow(set)*4,5)+1):(divInteiro(nrow(set)*9,10)),:]
#pegando os [90-100]%
validation = set[((divInteiro(nrow(set)*9,10))+1):nrow(set),:]

writetable("C:/Users/Vinicius Sanguinete/Documents/chAMPS/train.csv", train,separator = ',')

writetable("C:/Users/Vinicius Sanguinete/Documents/chAMPS/test.csv", test,separator = ',')

writetable("C:/Users/Vinicius Sanguinete/Documents/chAMPS/validation.csv", validation,separator = ',')
