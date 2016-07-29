###WORK IN PROGRESS####


#Load some libraries
library(XLConnect)
library(reshape2)
library(zoo)


###################################################################
#Import species data
wb <- loadWorkbook("Data/RAW/BMQP_data4Angelica.xlsx")

sp <-  readWorksheet(wb, 
                     sheet = 4:17, #get all sheets
                     startCol = which(LETTERS=="A"), 
                     startRow = 3, 
                     endCol = which(LETTERS=="P"),
                     endRow = 134 
)

#get column with species name in each sheet
sp_names<- getSheets(wb)[4:17]
sp2<- Map(cbind, 
          sp, Species = sp_names)

#function to change sheets from wide into long format
reshapes<- function(x){
  melt(x,
       id.vars=c("Deployment.Session", "Site","Species"),
       variable.name="night",
       value.name="present")
}

out<-lapply(sp2,reshapes)  
#combine
all_data<- do.call(rbind,out)

###########################################################
#Import site veg data
wb2 <- loadWorkbook("Data/RAW/BMQP_site&veg_data_sheet.xlsx")

veg <-  readWorksheet(wb2, 
                     sheet = 1,
                     startCol = which(LETTERS=="A"), 
                     startRow = 1, 
                     endCol = which(LETTERS=="T"),
                     endRow = 133
)
#change column names
colnam<- names(veg)
colnam[7]<-"X"; colnam[8]<-"Y";colnam[9]<-"Name"
colnam[10]<-"Year"; colnam[11]<-"Category";
colnam[12]<-"PFC.Canopy.6m";colnam[13]<-"Canopy.species"
colnam[14]<-"PFC.Mid.1-6m";colnam[15]<-"Mid.species"
colnam[16]<-"PFC.Ground.1m";colnam[17]<-"Ground.species"
siteveg<-veg[-1,]
names(siteveg)<-colnam
#make strings to factors
siteveg[sapply(siteveg, is.character)] <- lapply(siteveg[sapply(siteveg, is.character)], 
                                       as.factor)

###########################################################
#camera activity
cams <-  readWorksheet(wb2, 
                      sheet = 4,
                      startCol = which(LETTERS=="A"), 
                      startRow = 1, 
                      endCol = which(LETTERS=="K"),
                      endRow = 133
)
colnam<-names(cams)
colnam[5]<-"X"; colnam[6]<-"Y";colnam[7]<-"Name"
colnam[8]<-"Year"; colnam[9]<-"Category"

sitecams<-cams[-1,]
names(sitecams)<-colnam
#make strings to factors
sitecams[sapply(sitecams, is.character)] <- lapply(sitecams[sapply(sitecams, is.character)], 
                                                 as.factor)
###################################################################
#fauna activity
fa <-  readWorksheet(wb2, 
                       sheet = 5,
                       startCol = which(LETTERS=="A"), 
                       startRow = 1, 
                       endCol = which(LETTERS=="N"),
                       endRow = 833 
)
colnam<-names(fa)
colnam[5]<-"X"; colnam[6]<-"Y";colnam[7]<-"Name"
colnam[10]<-"Common.name"; colnam[11]<-"Sci.name";colnam[14]<-"Comment"
FA<-fa[-1,]
names(FA)<-colnam

#Fill in NA's
FA$Deployment<- na.locf(FA[,1])
FA$Site<- na.locf(FA[,2])
FA$Number<- na.locf(FA[,3])
FA$Camera<- na.locf(FA[,4])
FA$X<- na.locf(FA[,5])
FA$Y<- na.locf(FA[,6])
FA$Name<- na.locf(FA[,7])

#make strings to factors
FA[sapply(FA, is.character)] <- lapply(FA[sapply(FA, is.character)], 
                                                   as.factor)
