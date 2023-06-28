## -------------------------------------------------------------------------------------
## LIBRARY
library(keras)

## -------------------------------------------------------------------------------------
## CONSTANTES
dataset_dir      <- './data/'
train_images_dir <- paste0(dataset_dir, 'train_images')
test_images_dir  <- paste0(dataset_dir, 'test_images')

## -------------------------------------------------------------------------------------
## Cargar y pre-procesar imágenes
## (utilizar previamente make-dirs.R para separar imagenes en directorios)
img_sample <- image_load(path = './data/train_images/0/0a4b42306-1.jpg', target_size = c(150, 150))
img_sample_array <- array_reshape(image_to_array(img_sample), c(1, 150, 150, 3))
plot(as.raster(img_sample_array[1,,,] / 255))

# https://tensorflow.rstudio.com/reference/keras/image_data_generator.html 
# https://forums.fast.ai/t/split-data-using-fit-generator/4380/4
train_images_generator <- image_data_generator(rescale = 1/255, validation_split = 0.2)
test_images_generator  <- image_data_generator(rescale = 1/255)

# https://tensorflow.rstudio.com/reference/keras/flow_images_from_directory.html
# https://forums.fast.ai/t/split-data-using-fit-generator/4380/4
train_generator_flow <- flow_images_from_directory(
  directory = train_images_dir,
  generator = train_images_generator,
  subset = 'training',
  class_mode = 'categorical',
  batch_size = 20,
  target_size = c(64, 64)         # (w x h) --> (64 x 64)
)

validation_generator_flow <- flow_images_from_directory(
  directory = train_images_dir,
  generator = train_images_generator,
  subset = 'validation',
  class_mode = 'categorical',
  batch_size = 20,
  target_size = c(64, 64)         # (w x h) --> (64 x 64)
)

test_generator_flow <- flow_images_from_directory(
  directory = test_images_dir,
  generator = test_images_generator,
  class_mode = NULL,
  target_size = c(64, 64)         # (w x h) --> (64 x 64)
)

## -------------------------------------------------------------------------------------
## Crear modelo

# Definir arquitectura
model <- keras_model_sequential() %>%
  layer_conv_2d(filters = 32,  kernel_size = c(3, 3), activation = "relu", input_shape = c(64, 64, 3)) %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 64,  kernel_size = c(3, 3), activation = "relu") %>% layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>% layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>% layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_flatten() %>%
  layer_dense(units = 512, activation = "relu") %>%
  layer_dense(units = 5, activation = "softmax")

# Compilar modelo
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(),
  metrics = c('accuracy')
)

# Entrenamiento
history <- model %>% 
  fit(
    train_generator_flow, 
    steps_per_epoch = 10,
    epochs = 15, # Tried from 10 to 25. Seems to overfit for +15 epochs
    validation_data = validation_generator_flow
  )

# Visualizar entrenamiento
plot(history)

# Guardar modelo (en memoria)
model_cnn <- model

