#load the package and dataset
library(AER)
data(Fatalities)
# obtain the dimension and inspect the structure
is.data.frame(Fatalities) 
dim(Fatalities)
#list the first few observations
head(Fatalities)
#summarize the variables 'state' and 'year'
summary(Fatalities[,c(1,2)])
#define the fatality rate
Fatalities$fatal_rate <- Fatalities$fatal/Fatalities$pop*10000
#subset the data
Fatalities1982 <- subset(Fatalities, year=="1982")
Fatalities1988 <- subset(Fatalities, year=="1988")
#estimate simple regression models using 1982 and 1988 data
fatal1982_mod <- lm(fatal_rate~beertax, data=Fatalities1982)
fatal1988_mod <- lm(fatal_rate~beertax, data=Fatalities1988)
library(stargazer)
coeftest(fatal1982_mod,vcov. = vcovHC, type="HC1")
coeftest(fatal1988_mod,vcov. = vcovHC, type="HC1")
#plot the observations and add the estimated regressionline for 1982 data
plot(x= Fatalities1982$beertax,
     y= Fatalities1982$fatal_rate,
     xlab= "Beer tax (in 1988 dollars)",
     ylab = "Fatality rate(fatalities per 10000)",
     main = "Traffic Fatalitiy Rates and Beer Taxes in 1982",
     ylim = c(0,4.5),
     pch =20,
     col ="steelblue")
abline(fatal1988_mod)
#plot the observations and add the estimated regressionline for 1988 data
plot(x= Fatalities1988$beertax,
     y= Fatalities1988$fatal_rate,
     xlab= "Beer tax (in 1988 dollars)",
     ylab = "Fatality rate(fatalities per 10000)",
     main = "Traffic Fatalitiy Rates and Beer Taxes in 1988",
     ylim = c(0,4.5),
     pch =20,
     col ="steelblue")
abline(fatal1988_mod)
#compute the difference
diff_fatal_rate <- Fatalities1988$fatal_rate - Fatalities1982$fatal_rate
diff_beertax <- Fatalities1988$beertax - Fatalities1982$beertax
#estimate a regression using differenced data
fatal_diff_mod <- lm(diff_fatal_rate ~ diff_beertax)
coeftest(fatal_diff_mod, vcov. = vcovHC, type="HC1")
#plot the differenced data
plot(x = diff_beertax,
     y = diff_fatal_rate,
     xlab = "Change in beer tax(in 1988 dollars)",
     ylab = "Change in fatality rate (fatalities per 10000)",
     main = "Changes in Traffic Fatality Rates and Beer Tax in 1982-1988",
     xlim = c(-0.6,0.6),
     ylim = c(-1.5, 1),
     pch = 20,
     col = "steelblue")
abline(fatal_diff_mod)
#simply use the function lm()to obtain an estimate \beta_1
fatal_fe_lm_mod <- lm(fatal_rate~beertax+state-1, data=Fatalities)
fatal_fe_lm_mod
#obtain demeaned data
Fatalities_demeaned <- with(Fatalities,
                            data.frame(fatal_rate = fatal_rate - ave(fatal_rate, state),
                                       beertax = beertax - ave(beertax, state)))
#estimate the regression
summary(lm(fatal_rate ~ beertax -1, data = Fatalities_demeaned)) #ave is convenient for computing group averages.
# load the 'plm' for specifiyng the regression formula and the data to be used in our call of plm()
library(plm)
#estimate the fixed effects regresion with plm()
fatal_fe_mod <- plm(fatal_rate ~ beertax,
                    data = Fatalities,
                    index = c("state", "year"),
                    modle = "within")
coeftest(fatal_fe_mod, vcov. = vcovHC, type = "HC1") #robust standard errors
# estimate a combined time and entity fixed effects regression model
# via lm()
fatal_tefe_lm_mod <- lm(fatal_rate ~ beertax + state + year - 1, data = Fatalities)
fatal_tefe_lm_mod
# via plm()
fatal_tefe_mod <- plm(fatal_rate ~ beertax, 
                      data = Fatalities,
                      index = c("state", "year"), 
                      model = "within", 
                      effect = "twoways")

a <- coeftest(fatal_tefe_mod, vcov = vcovHC, type = "HC1")
stargazer(a)
#check the class of the 'state' and 'year'
class(Fatalities$state)
class(Fatalities$year)
#check class of the model object
class(fatal_tefe_lm_mod)
#obtain heteroskedasticity-robust standard errors
coeftest(fatal_tefe_lm_mod, vcov. = vcovHC, type = "HC1")[1,]
#check the class of the plm model object
class(fatal_tefe_mod)
#obtain a summary based on clustered standard errors
coeftest(fatal_tefe_mod, vcov = vcovHC, type = "HC1")
#descretize the minimum legal drinking age
Fatalities$drinkagec <- cut(Fatalities$drinkage,
                           breaks = 18:22,
                           include.lowest = TRUE,
                           right = FALSE)
#set minimum drinking age 
Fatalities$drinkagec <- relevel(Fatalities$drinkagec, "[21,22]")
#mandatory jail or community serveice?
Fatalities$punish <- with(Fatalities, factor(jail == "yes" | service == "yes",
                                             labels = c("no", "yes")))
#the set of observations on all variables for 1982 and 1988
Fatalities_1982_1988 <- Fatalities[with(Fatalities, year == 1982 | year == 1988),]
#estimate all seven models
fatalities_mod1 <- lm(fatal_rate ~ beertax, data = Fatalities)
fatalities_mod2 <- plm(fatal_rate ~ beertax + state, data = Fatalities)
fatalities_mod3 <- plm(fatal_rate ~ beertax + state + year,
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)
fatalities_mod4 <- plm(fatal_rate ~ beertax + state + year+ drinkagec + punish + miles + unemp + log(income),
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)
fatalities_mod5 <- plm(fatal_rate ~ beertax + state + year + drinkagec +punish + miles,
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)
fatalities_mod6 <- plm(fatal_rate ~ beertax + year + drinkage + punish + miles + unemp + log(income),
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities)
fatalities_mod7 <- plm(fatal_rate ~ beertax + state + year + drinkagec + punish + miles + unemp + log(income),
                       index = c("state", "year"),
                       model = "within",
                       effect = "twoways",
                       data = Fatalities_1982_1988)
#gather clustered standard errors in a list
rob_se <- list (sqrt(diag(vcovHC(fatalities_mod1, type = "HC1"))),
                sqrt(diag(vcovHC(fatalities_mod2, type = "HC1"))),
                sqrt(diag(vcovHC(fatalities_mod3, type = "HC1"))),
                sqrt(diag(vcovHC(fatalities_mod4, type = "HC1"))),
                sqrt(diag(vcovHC(fatalities_mod5, type = "HC1"))),
                sqrt(diag(vcovHC(fatalities_mod6, type = "HC1"))),
                sqrt(diag(vcovHC(fatalities_mod7, type = "HC1"))))
#generate the table 
stargazer(fatalities_mod1, fatalities_mod2, fatalities_mod3, fatalities_mod4, fatalities_mod5,fatalities_mod6, fatalities_mod7,
          digits = 3,
          header = FALSE,
          type = "latex",
          se = rob_se,
          title = "Linear Panel Regression Models of Traffic Fatalities due to Drunk Driving",
          model.names = FALSE,
          column.labels = c("(1)","(2)","(3)","(4)","(5)","(6)","(7)"))
#test 