library(keras)

## -------------------------------------------------------------------------------------
## CONSTANTES
dataset_dir      <- './data/'
train_images_dir <- paste0(dataset_dir, 'train_images')
test_images_dir  <- paste0(dataset_dir, 'test_images')

## -------------------------------------------------------------------------------------
## MODELOS INDIVIDUALES
source(file = "./adoption-ffn.R")
source(file = "./adoption-cnn.R")

## -------------------------------------------------------------------------------------
## STACKING

# Crear stacking
cnn_input <- layer_input(shape=(model_cnn$input_shape %>% unlist))
fnn_input <- layer_input(shape=(model_fnn$input_shape %>% unlist))

model_list <- c(model_cnn(cnn_input), model_fnn(fnn_input))
model_output <- layer_average(model_list)

model <- keras_model(
  inputs = c(cnn_input, fnn_input), 
  outputs = c(model_output)
)
