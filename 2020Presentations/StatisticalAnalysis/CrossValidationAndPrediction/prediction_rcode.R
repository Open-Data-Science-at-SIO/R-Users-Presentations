rm(list=ls())
`%notin%`<- Negate(`%in%`)

#Simulate dataset#
b0<- 10
b1<- 1
x<- seq(-3,4,length.out=160)
y<- b0+b1*x+rnorm(160,0,2)
var(y)
plot(y~x)
cor(x,y)
data<- data.frame(x=x,y=y)
##

l0<- lm(y ~ x, data=data) #fit model
betas<- coef(l0) #Extract model coefficients
vcv<- vcov(l0) #Extract variance-covariance matrix for parameters
pars.resamp<- MASS::mvrnorm(500, mu = betas, Sigma = vcv) #Simulate parameter distributions using a multivariate normal

y.conf <- list()
pred.frame<-  expand.grid(x = x,
                             l.ci = NA, 
                             u.ci = NA,
                             l.pi = NA,
                             u.pi = NA,
                             m = NA) 
for(z in 1:length(x)){
  y.conf[[z]] <- pars.resamp[,1] + pars.resamp[,2] * x[z]  # fit the estimate based on the sampled intercept and slopes
  pred.temp<- list()
  
  for(t in 1:100){
    pred.temp[[t]]<- rnorm(500,pars.resamp[,1] + pars.resamp[,2]*x[z], sigma(l0))   #add in model standard deviation
  }
  
  pred.temp.all<- do.call(rbind, lapply(pred.temp, data.frame, stringsAsFactors=FALSE))
  pred.frame[z,2]<- quantile(y.conf[[z]], 0.025)
  pred.frame[z,3]<- quantile(y.conf[[z]], 0.975)
  pred.frame[z,4]<- quantile(pred.temp.all[,1], 0.025)
  pred.frame[z,5]<- quantile(pred.temp.all[,1], 0.975)
  pred.frame[z,6] <- betas[1] + betas[2] * x[z]
}
x.polygon <- c(x, rev(x)) # Define a polygon x value for adding to a plot
y.polygon.ci <- c(pred.frame$l.ci, rev(pred.frame$u.ci)) # Define a polygon y value for adding to a plot
y.polygon.pi <- c(pred.frame$l.pi, rev(pred.frame$u.pi)) # Define a polygon y value for adding to a plot
plot(y~x)
polygon(x.polygon, y.polygon.ci, col = adjustcolor('darkgrey', alpha = 0.8), border=NA) # Add uncertainty polygon
polygon(x.polygon, y.polygon.pi, col = adjustcolor('grey', alpha = 0.3), border=NA) # Add uncertainty polygon


summary(l0)

p2<- NA
for(i in 1:500){
    row_sample<- sample(nrow(data),round(nrow(data)*0.1)) #randomly sample 10% of dataset
    test<- data[row_sample,] #Keep this subset for testing
    train<- test[-row_sample,] #Drop this subset for model training
    
    lt<- lm(y ~ x, data=train) #fit model to training set
    preds<- predict(lt,newdata=test) #make predictions from that model to the testing set
    p2[i]<- cor(test$y,preds)^2 #Estimate prediction accuracy (obs. vs. predicted)
    
}
hist(p2)
abline(v=median(p2),lty=5)

###Adding in group-level variation
tau_a<- rep(rnorm(20,0,1.5),8) #group variation in intercept
tau_b<- rep(rnorm(20,0,0.05),8) #group variation in slope
grp<- rep(seq(1,20),8) #group id

y<- b0+tau_a+(b1+tau_b)*x+rnorm(160,0,1.5) #simulate with group differences
var(y)
plot(y~x,col=as.factor(grp))
cor(x,y)
l0<- lm(y ~ x, data=data) #fit full model
summary(l0)

p2<- NA
for(i in 1:500){
  grp_sample<- sample(20,1) #randomly sample 1 of the 20 groups to drop
  test<- data[grp %in% grp_sample,] #Keep this subset for testing
  train<- data[grp %notin% grp_sample,] #new training dataset
  row_sample<- sample(nrow(train),8) #also randomly drop 8 rows from remaining groups
  test<- rbind(test,train[row_sample,])
  train<- train[-row_sample,]
    
  lt<- lm(y ~ x+grp, data=train) #fit model to training set
  preds<- predict(lt+grp,newdata=test) #make predictions from that model to the testing set
  p2[i]<- cor(test$y,preds)^2 #predictive accuracy
  
}
hist(p2)
abline(v=median(p2),lty=5)

_
