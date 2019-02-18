setwd("~/investing-models")

con = gzcon(url('https://github.com/systematicinvestor/SIT/raw/master/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')   

models = list()

data <- readRDS("./data/raw-prices.RData")
econ <- readRDS("./data/raw-fred.RData")

for(i in econ$symbolnames)
  econ[[i]] = make.stock.xts(na.omit(econ[[i]]))
bt.prep(econ, align='remove.na')

bt.prep(data, align='remove.na')
prices = data$prices 

period.ends.prices = endpoints(prices, 'months')
period.ends.prices = period.ends.prices[period.ends.prices > 0]		
period.ends.prices = c(1, period.ends.prices)

monthly.prices = prices[period.ends.prices,]


# Need to merge economic data into a daily series and then lag it
# by one day
dataseries = prices
dataseries[] = NA
#econdaily = cbind(dataseries,econ$prices)[,colnames(econ$prices)]
econdaily = merge(dataseries,econ$prices)[,colnames(econ$prices)]
econdaily = econdaily[paste(min(index(prices)),"/"),]
econdaily = lag(econdaily,k=-1)
period.ends.econ = endpoints(econdaily,'months')
indexes = econdaily[period.ends.econ,]

index12ret = indexes/mlag(indexes,12)-1
lagindex12ret = mlag(index12ret)
lagindex12ret = na.locf(lagindex12ret)

voo = prices$VOO[period.ends.prices,]
vooind = voo/mlag(voo,10) - 1

# If both economic indicators are > 0, then VOO = 1, IEF = 0
# else if VOO > 10MA, VOO = 1, IEF = 0
# if VOO < 10MA, and one economic indicator < 0, VOO = 0, IEF = 1

indicators = cbind(lagindex12ret,vooind,prices$VOO[period.ends.prices,],prices$IEF[period.ends.prices,])

# This calculates the VOO indicator, need to calculate when IEF
voo = ifelse(indicators$RRSFS > 0 & indicators$INDPRO > 0, 1,
       ifelse(indicators$VOO > 0, 1, 0))
colnames(voo) = "VOO"

ief = ifelse(voo$VOO > 0, 0, 1)
colnames(ief) = "IEF"

trades = merge(voo,ief)
data$weight = trades
data$weight$VEA = 0
data$weight$BND = 0
data$weight$VWO = 0
data$weight$LQD = 0
data$weight$TLT = 0
data$weight$SHY = 0

data$weight = prices
data$weight[] = NA
data$weight[period.ends.prices,colnames(trades)]= trades

models$gtt = bt.run(data, type='weight', trade.summary=T)

currentModel = models$gtt
currentModel$equity=currentModel$equity["1997-04-30/"]
model.detail = bt.detail.summary(currentModel)
twelve.ret = ROC(currentModel$equity,12,type="discrete")
model.detail$System$Roll.TwelveM = (sum(twelve.ret > 0,na.rm=TRUE)/(sum(twelve.ret > 0,na.rm=TRUE)+sum(twelve.ret < 0,na.rm=TRUE)))*100

kable(list2matrix(model.detail)) %>% kable_styling()
plotbt.monthly.table(currentModel$equity)
plot(currentModel$equity)
plot(compute.drawdown(currentModel$equity)*100)
