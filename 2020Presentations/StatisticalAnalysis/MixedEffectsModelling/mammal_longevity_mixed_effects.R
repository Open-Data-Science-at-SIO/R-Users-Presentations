library(dplyr);library(ggplot2);library(traitdataform)
traitdataform::pulldata("amniota") #You may have to install this package from github using devtools: devtools::install_github('EcologicalTraitData/traitdataform')
amniota=dplyr::na_if(amniota,-999) #convert missing data (-999) to NAs
mam=subset(amniota,class=='Mammalia') #Let's pull out the mammals
mam<- mam[complete.cases(mam$longevity_y),] #Keep all those species with longevity data
mam<- mam[complete.cases(mam$adult_body_mass_g),] #Ditch those without adult body mass 
order_n<- mam %>% group_by(order) %>% summarize(n=n()) %>% subset(n>20) #Let's keep the more speciose orders (min. of 21 species)
mam<- subset(mam,order %in% order_n$order) #drop out the other orders


#Plot the raw data
plot(log10(longevity_y)~log10(adult_body_mass_g),data=mam,bty='l',pch=21,bg=adjustcolor('black',alpha.f=0.5),col='white',lwd=0.5,cex=1.2)

#If we pool everything (ignore the taxonomic differences) what's the relationship between log10(longevity) and log10(mass)?
m_pooled<- lm(log10(longevity_y)~log10(adult_body_mass_g),data=mam)
summary(m_pooled)
abline(m_pooled) #fitted line

#Let's try to make it 'independent' (it's still not of course, they shared evolutionary history) by averaging for each order
ord_grp<- mam %>% group_by(order) %>% summarize(m.longevity=mean(log10(longevity_y)),m.bodysize=mean(log10(adult_body_mass_g)))
#Plot the 12 orders
plot(m.longevity~m.bodysize,data=ord_grp,bty='l',pch=21,bg=adjustcolor('black',alpha.f=0.5),col='white',lwd=0.5,cex=1.2)

#What if we run separate regressions for each order?
o_mam<- list()
lm_o<- list()
p<- list()
a<- NA
b<- NA
#Let's start with a blank plot that we'll add each order to
plot(log10(longevity_y)~log10(adult_body_mass_g),data=mam,bty='l',pch=21,bg=adjustcolor('black',alpha.f=0.5),col='white',lwd=0.5,cex=1.2,type='n')
#These are just plotting colours to use
cols<- c('darkblue','darkred','goldenrod','darkgray','darkolivegreen','peru','slateblue','sienna','tan','seagreen','cyan4','darksalmon')
#For each order... (n=12)
for(i in 1:length(unique(mam$order))){
  o_mam[[i]]<- subset(mam,order==unique(mam$order)[i]) #subset out just those species
  lm_o[[i]]<- lm(log10(longevity_y)~log10(adult_body_mass_g),data=o_mam[[i]]) #fit an order-specific linear model
  a[i]<- coef(lm_o[[i]])[1] #pull out the intercept
  b[i]<- coef(lm_o[[i]])[2] #pull out the slope
  p[[i]]<- predict(lm_o[[i]]) #What's the predicted fit
  
  #Plot the raw data and the fitted lines:
  points(log10(longevity_y)~log10(adult_body_mass_g),data=o_mam[[i]],cex=1.2,bg=adjustcolor(cols[i],alpha.f=0.5),pch=21,lwd=0.5,col='white')
  lines(p[[i]]~log10(o_mam[[i]]$adult_body_mass_g),col=cols[i])
  text(5,0.6-0.1*i,unique(mam$order)[i],col=adjustcolor(cols[i],alpha.f=0.5)) 
}
#Beaut.

#Mixed-effects models
library(lme4) #We'll use lme4, other options include 'nlme' and 'glmmTMB' (and more, I'm sure)

#Model with random intercepts - ie. (1|order)
lmer_int<- lmer(log10(longevity_y)~log10(adult_body_mass_g)+(1|order),data=mam)
summary(lmer_int)

#Let's look at shrinkage of the intercepts compared to the fixed effects model above
plot(coef(lmer_int)$order[,1]~a,bty='l',cex=log10(order_n$n))
abline(0,1) #1:1 line
#The further the point deviates from the line, the more shrinkage towards the global mean has occurred

#Model with random slopes only - ie. (0+x|order)
lmer_slope_only<- lmer(log10(longevity_y)~log10(adult_body_mass_g)+(0+log10(adult_body_mass_g)|order),data=mam)
summary(lmer_slope_only)

#Model with random intercept and slopes - ie. (1+x|order) (note: you don't need to specify the 1 for intercept)
lmer_int_slope<- lmer(log10(longevity_y)~log10(adult_body_mass_g)+(log10(adult_body_mass_g)|order),data=mam,control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4)))
summary(lmer_int_slope)

#Let's look at order intercepts and slopes in this model
coef(lmer_int_slope)$order

#Let's overlay the intercept/slope combo for the independent models and the mixed model (in blue)
plot(b~a,bty='l',cex=log10(order_n$n))
points(coef(lmer_int_slope)$order[,2]~coef(lmer_int_slope)$order[,1],cex=log10(order_n$n),col='navy')
#As you can see they are pulled together far more and slope variation is much lower (due to shrinkage)


#Plot the mixed effects model fits
plot(log10(longevity_y)~log10(adult_body_mass_g),data=mam,bty='l',pch=21,bg=adjustcolor('black',alpha.f=0.5),col='white',lwd=0.5,cex=1.2,type='n')
cols<- c('darkblue','darkred','goldenrod','darkgray','darkolivegreen','peru','slateblue','sienna','tan','seagreen','cyan4','darksalmon')
for(i in 1:length(unique(mam$order))){
  o_mam[[i]]<- subset(mam,order==unique(mam$order)[i])
  p[[i]]<- predict(lmer_int_slope,newdata=o_mam[[i]])
  points(log10(longevity_y)~log10(adult_body_mass_g),data=o_mam[[i]],cex=1.2,bg=adjustcolor(cols[i],alpha.f=0.5),pch=21,lwd=0.5,col='white')
  lines(p[[i]]~log10(o_mam[[i]]$adult_body_mass_g),col=cols[i])
  text(5,0.6-0.1*i,unique(mam$order)[i],col=adjustcolor(cols[i],alpha.f=0.5))
}


#variance partitioning
#How does longevity vary at each taxonomic level in mammals? (ie. order, family, genus)
var_par_mod<- lmer(log10(longevity_y)~1+(1|order/family/genus),data=mam)
summary(var_par_mod)
var_tax<- as.data.frame(VarCorr(var_par_mod)) #extract out the variance estimates for each taxonomic rank
var_par<- matrix(ncol=1,nrow=4) #let's create a new matrix
rownames(var_par)<- c('order','family','genus','resid')
var_par[1,]<- (var_tax$sdcor[3]^2)/sum(var_tax$sdcor^2)  #the variance of order as a proportion of TOTAl variance (all ranks + residual variance)
var_par[2,]<- (var_tax$sdcor[2]^2)/sum(var_tax$sdcor^2) #since this is variance we take the standard deviation to the power of 2
var_par[3,]<- (var_tax$sdcor[1]^2)/sum(var_tax$sdcor^2) 
var_par[4,]<- (var_tax$sdcor[4]^2)/sum(var_tax$sdcor^2) 
var_par #proportion of variance for each level
