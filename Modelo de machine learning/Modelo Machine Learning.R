
library(e1071)

#------------------------------------------------------------------------------#
### División de datos entrenamiento/test                                    ####
#------------------------------------------------------------------------------#

#Entrenamiento-80%
#Test-20%
fraudes.tr=0.8
N=nrow(fraudes)
set.seed(1234)
index.tr=sample(1:N,ceiling(fraudes.tr*N),replace=FALSE)
fraudes.tr=fraudes[index.tr,]
fraudes.te=fraudes[-index.tr,]


#------------------------------------------------------------------------------#
### SVM                                                                     ####
#------------------------------------------------------------------------------#
Model_svm= e1071::svm(formula = fraudfound_p ~ ., data = fraudes.tr, scale=TRUE,
                      type = 'C-classification',kernel = 'linear',cost=1,epsilon=0.1) 

coef(Model_svm)
summary(Model_svm)

Predict_svm=predict(Model_svm)

# Indicadores de correcta clasificación.
ICC_svm=caret::confusionMatrix(Predict_svm ,fraudes.tr$fraudfound_p,positive = "1")
ICC_svm$byClass


#Prueba con datos de test
# Model_svm
Predict_svm.te = predict(Model_svm,newdata=fraudes.te,type="class")
ICC_svm.te=caret::confusionMatrix(Predict_svm.te,fraudes.te$fraudfound_p,positive = "1")
ICC_svm.te$byClass

