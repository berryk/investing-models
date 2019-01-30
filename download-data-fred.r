con = gzcon(url('https://github.com/systematicinvestor/SIT/raw/master/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')   

con = gzcon(url('https://github.com/systematicinvestor/SIT/raw/master/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')   

# SPY,QQQ,IWM,VGK,EWJ,VWO,GSG,GLD,VNQ,HYG, LQD,TLT + C2:SHY,IEF

tickers = '
RRSFS,
INDPRO
'

raw <- new.env()

getSymbols.extra(tickers, src='FRED', from = '1970-01-01', env = raw, set.symbolnames = T, auto.assign = T)
#for(i in raw$symbolnames) raw[[i]] = adjustOHLC(raw[[i]], use.Adjusted = TRUE, symbol.name=i)

saveRDS(raw, file="./data/raw-fred.RData")