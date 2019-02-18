setwd("~/investing-models")

con = gzcon(url('https://github.com/systematicinvestor/SIT/raw/master/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')   

# SPY,QQQ,IWM,VGK,EWJ,VWO,GSG,GLD,VNQ,HYG, LQD,TLT + C2:SHY,IEF

tickers = '
VTI = [VTI] + VTSMX + VFINX,
VEA = VEA + VGTSX, #Developed markets - Aug 1 1999 (Could use VGTSX goes back to 94 or index)
VWO = VWO + VEIEX, #FTSE Emerging Markets 1 May 1994
GLD, #Gold
TLT = TLT + VUSTX, #20+ Year Treasury - June 86
SHY = SHY + VFISX, #1 to 3 Year Treasury - Oct 91
IEF = IEF + VFITX, #7 to 10 Year Treasury - Nov 91
'

raw <- new.env()

getSymbols.extra(tickers, src='yahoo', from = '1970-01-01', env = raw, set.symbolnames = T, auto.assign = T)
for(i in raw$symbolnames) raw[[i]] = adjustOHLC(raw[[i]], use.Adjusted = TRUE, symbol.name=i)

raw$GLD = extend.GLD(raw$GLD)

saveRDS(raw, file="./data/raw-prices-goldenkb.RData")
