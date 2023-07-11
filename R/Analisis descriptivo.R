install.packages("DBI")
install.packages("RPostgres")

library(DBI)
library(RPostgres)  # o el controlador correspondiente a tu base de datos
library(dplyr)

# Establecer la conexión con la base de datos
con <- dbConnect(Postgres(),
                 dbname = "Fraudes",
                 host = "localhost",
                 port = 5432,
                 user = "postgres",
                 password = "postgres")

# Leer la tabla "fraudes"
query <- "SELECT * FROM fraudes"
fraudes <- dbGetQuery(con, query)

# Cerrar la conexión
dbDisconnect(con)


### ----------------------------------------------------------------------------

# Análisis Exploratorio 

str(fraudes)    # Verificar la estructura de las variables
table(fraudes$weekofmonth)
fraudes <- fraudes %>%
  mutate_if(is.character, as.factor)%>%
  mutate_if(is.logical, as.factor)%>%
  mutate_if(is.integer, as.factor)


fraudesACM <- fraudes %>%
  select(-c(weekofmonth,weekofmonthclaimed,age,policynumber,repnumber,deductible,
            driverrating,yearr))

x11()
visdat::vis_miss(fraudes)   #función que visualiza los datos faltantes 


## Representación Gráfica
color=c("aquamarine","blue")             

# Graficos individuales de todas las variables (Cuantitativas)
windows(height=10,width=15)
par(mfrow=c(2,4))   # Partición de la ventana grafica 2x3
attach(fraudes)
tabla<-prop.table(table(fraudfound_p))
coord<-barplot(tabla,col=color, ylim=c(0,1), main="Incidentes fraudulentos")
text(coord,tabla,labels=round(tabla,2), pos=3)
lapply(names(fraudes[,c(2,8,11,17,18,19,20)]),function(y){
  boxplot(fraudes[,y]~fraudes[,"fraudfound_p"],
          ylab= y, xlab="Fraude",boxwex = 0.5,col=NULL)
  stripchart(fraudes[,y] ~ fraudes[,"fraudfound_p"], vertical = T,
             method = "jitter", pch = 19,
             col = color, add = T)
})


relacion_cualitativa <- function(variable1, variable2, titulos) {
  ggplot(fraudes, aes(x=variable1))+
    geom_bar(aes(fill=variable2))+
    labs(x = "",y = "Frecuencia")+
    ggtitle(titulos)+
    theme (plot.title = element_text(size=rel(1.5),vjust=2,face="bold",))+
    guides(fill = guide_legend(title = "Fraude"))+
    theme_bw()
}
g1 <- relacion_cualitativa(accidentarea,fraudfound_p, "Area del accidente vs Fraude") #
g2 <- relacion_cualitativa(vehiclecategory, fraudfound_p, "Tipo de auto vs Fraude") #
g3 <- relacion_cualitativa(ageofvehicle, fraudfound_p, "Edad del vehículo vs Fraude") #
g4 <- relacion_cualitativa(policereportfiled, fraudfound_p, "Denuncia a la policía vs Fraude") #
g5 <- relacion_cualitativa(witnesspresent, fraudfound_p, "Testigos vs Fraude") #
g6 <- relacion_cualitativa(agenttype, fraudfound_p, "Tipo de agente vs Fraude") #
g7 <- relacion_cualitativa(basepolicy, fraudfound_p, "Tipo de seguro vs Fraude") #
g8 <- relacion_cualitativa(fault, fraudfound_p, "Culpable vs Fraude") #

x11()
graficos <- ggpubr::ggarrange(g1,g2,g3,g4,g5,g6,g7,g8) 

ggsave(
  filename = "graficos cualitativos.png",
  plot = graficos,
  units = "in",
  dpi = 300,
  width = 16,
  height = 12
)



### ------------------ Analisis de componentes multiples -----------------------

library(FactoMineR)
library(factoextra)

fraudesACM <- fraudes %>%
  select(c(make,accidentarea,sex,maritalstatus,policytype,vehiclecategory,
           days_policy_claim,pastnumberofclaims,ageofvehicle,policereportfiled,
           witnesspresent,agenttype,numberofsuppliments,basepolicy,fraudfound_p ))


FMRmca <- MCA(fraudesACM)

x11()
grafico1 <- fviz_mca_biplot(FMRmca, repel = TRUE, habillage=fraudes$fraudfound_p,
                            col.ind =color,addEllipses = T, ellipse.level = 0.95, 
                            ggtheme = theme_grey())+labs(
                            title ="Representación simultanea de los individuos y las categorías")

ggsave(
  filename = "Representacion Simultanea.png",
  plot = grafico1,
  units = "in",
  dpi = 300,
  width = 12,
  height = 10
)

windows(height=10,width=15)
par(mfrow=c(1,2))
categorias<- fviz_mca_var(FMRmca,axes=c(1,2), col.var = "cos2",
                          gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), 
                          repel = TRUE )


### ----------------------------------------------------------------------------
### Clusters

ACM_ind=get_mca_ind(FMRmca)
Factores= ACM_ind$coord[,1:3]

K=4                      # Incialmente definiremos 4 grupos


set.seed(101)            # Semilla aleatoria
km_clusters <- kmeans(x = Factores, centers = K, nstart = 50,iter.max=1000)
km_clusters
Grupos=km_clusters$cluster

# Evaluación del Número adecuado de cluster
Evaluar_k=function(n_clust,data,iter.max,nstart){
  km <- kmeans(x = data, centers = n_clust, nstart = nstart,iter.max=iter.max)
  return(km$tot.withinss)
}

k.opt=2:10
Eval_k=sapply(k.opt,Evaluar_k,data=Factores,iter.max=1000,nstart=50)

windows(height=10,width=15)
plot(k.opt,Eval_k,type="l",xlab="Número Cluster",ylab="SSE")

# Representación grafica de los cluster
windows(height=10,width=15)
cluster <-fviz_cluster(object=km_clusters, data = Factores, show.clust.cent = TRUE,
                       ellipse.type = "euclid", star.plot = TRUE, repel = TRUE,
                       axes=c(1,2))

ggsave(
  filename = "cluster.png",
  plot = cluster,
  units = "in",
  dpi = 300,
  width = 15,
  height = 10
)

dataFactores= cbind(fraudes,Grupos)
write.csv(dataFactores, "data.csv")



