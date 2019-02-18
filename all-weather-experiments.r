setwd("~/investing-models")

con = gzcon(url('https://github.com/systematicinvestor/SIT/raw/master/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')   

models = list()

data <- readRDS("./data/raw-prices-allweather.RData")

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

data$weight[] = NA
data$weight$GLD[period.ends.prices,] = 0.075
data$weight$DBC[period.ends.prices,] = 0.075
data$weight$IEF[period.ends.prices,] = 0.15
data$weight$TLT[period.ends.prices,] = 0.4
data$weight$US.EQ[period.ends.prices,] = 0.3

#data$weight$GLD[period.ends.prices,] = 0.33
#data$weight$DBC[period.ends.prices,] = 0.075
#data$weight$IEF[period.ends.prices,] = 0.15
#data$weight$TLT[period.ends.prices,] = 0.33
#data$weight$VOO[period.ends.prices,] = 0.33

#data$weight = prices
#data$weight[] = NA
#data$weight[period.ends.prices,colnames(trades)]= trades

models$allweather = bt.run(data, type='weight', trade.summary=T)

currentModel = models$allweather
#currentModel$equity=currentModel$equity["1997-04-30/"]
model.detail = bt.detail.summary(currentModel)
twelve.ret = ROC(currentModel$equity,12,type="discrete")
model.detail$System$Roll.TwelveM = (sum(twelve.ret > 0,na.rm=TRUE)/(sum(twelve.ret > 0,na.rm=TRUE)+sum(twelve.ret < 0,na.rm=TRUE)))*100
list2matrix(model.detail)
#kable(list2matrix(model.detail)) %>% kable_styling()
plotbt.monthly.table(currentModel$equity)
plot(currentModel$equity)
plot(compute.drawdown(currentModel$equity)*100)


data$weight[] = NA
data$weight$GLD[period.ends.prices,] = 0.2
data$weight$SHY[period.ends.prices,] = 0.2
data$weight$TLT[period.ends.prices,] = 0.2
data$weight$US.EQ[period.ends.prices,] = 0.2
data$weight$US.SMCAP[period.ends.prices,] = 0.2

models$goldenbutterfly = bt.run(data, type='weight', trade.summary=T)

currentModel = models$goldenbutterfly
#currentModel$equity=currentModel$equity["1997-04-30/"]
model.detail = bt.detail.summary(currentModel)
twelve.ret = ROC(currentModel$equity,12,type="discrete")
model.detail$System$Roll.TwelveM = (sum(twelve.ret > 0,na.rm=TRUE)/(sum(twelve.ret > 0,na.rm=TRUE)+sum(twelve.ret < 0,na.rm=TRUE)))*100
list2matrix(model.detail)
#kable(list2matrix(model.detail)) %>% kable_styling()
plotbt.monthly.table(currentModel$equity)
plot(currentModel$equity)
plot(compute.drawdown(currentModel$equity)*100)

data$weight[] = NA
data$weight$GLD[period.ends.prices,] = 0.33
#data$weight$SHY[period.ends.prices,] = 0.2
data$weight$TLT[period.ends.prices,] = 0.33
data$weight$US.EQ[period.ends.prices,] = 0.33
#data$weight$US.SMCAP[period.ends.prices,] = 0.2

models$perm = bt.run(data, type='weight', trade.summary=T)

currentModel = models$perm
#currentModel$equity=currentModel$equity["1997-04-30/"]
model.detail = bt.detail.summary(currentModel)
twelve.ret = ROC(currentModel$equity,12,type="discrete")
model.detail$System$Roll.TwelveM = (sum(twelve.ret > 0,na.rm=TRUE)/(sum(twelve.ret > 0,na.rm=TRUE)+sum(twelve.ret < 0,na.rm=TRUE)))*100
list2matrix(model.detail)
#kable(list2matrix(model.detail)) %>% kable_styling()
plotbt.monthly.table(currentModel$equity)
plot(currentModel$equity)
plot(compute.drawdown(currentModel$equity)*100)

# Compare all portfolios

#```{r, echo=FALSE}

plotbt.strategy.sidebyside(models, make.plot=F, return.table=T)

#```