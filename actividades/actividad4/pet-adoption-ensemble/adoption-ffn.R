## -------------------------------------------------------------------------------------
## LIBRARY
library(keras)
library(tidyverse)
library(sjmisc)

## -------------------------------------------------------------------------------------
## CONSTANTES
dataset_dir      <- './data/'
train_images_dir <- paste0(dataset_dir, 'train_images')
train_data_file  <- paste0(dataset_dir, 'train.csv')

breed_labels_file <- paste0(dataset_dir, 'breed_labels.csv')
color_labels_file <- paste0(dataset_dir, 'color_labels.csv')
state_labels_file <- paste0(dataset_dir, 'state_labels.csv')

## -------------------------------------------------------------------------------------
## Cargar datos
breed_labels <- read_csv(breed_labels_file) %>% select(one_of('BreedID', 'BreedName'))
color_labels <- read_csv(color_labels_file)
state_labels <- read_csv(state_labels_file)

train_raw <- read_csv(train_data_file)

train <- train_raw %>%
  na.omit() %>%
  select(-one_of('Name', 'RescuerID', 'Breed2', 'Color2', 'Color3', 'Description', 'PetID')) %>%
  left_join(breed_labels, by = c('Breed1' = 'BreedID')) %>%
  left_join(color_labels, by = c('Color1' = 'ColorID')) %>%
  left_join(state_labels, by = c('State' = 'StateID')) %>%
  select(-one_of('Breed1', 'Color1', 'State'))

# - train (x)
x_train <- train %>%
  select(-one_of("AdoptionSpeed")) 

# -- binarizar
dummy_vars <- c('Type', 'BreedName', 'ColorName', 'StateName', 'Gender', 'MaturitySize', 'FurLength', 'Vaccinated', 'Dewormed', 'Sterilized', 'Health')
for(var in dummy_vars) {
  col <- data.frame(var = x_train[var]) %>% 
    mutate_if(is.numeric, as.character)
  x_train <- x_train %>%
    cbind(to_dummy(col, suffix = "label")) %>%
    select(-one_of(var))
}

# -- normalizar
norm_vars <- c('Age', 'Quantity', 'Fee', 'VideoAmt', 'PhotoAmt')
x_train <- x_train %>% 
  mutate_at(norm_vars, scale)
# mutate_all(scale) 

# -- dimensiones
x_width  <- ncol(x_train)
x_height <- nrow(x_train)
x_train  <- as.matrix(x_train)
#  unname()

# - train (y)
y_train <- train %>%
  select("AdoptionSpeed") %>%
  as.matrix() %>%
  to_categorical(5)

y_width <- ncol(y_train)

## -------------------------------------------------------------------------------------
## Modelo

# Definir arquitectura
model <- keras_model_sequential() 
model %>% 
  layer_dense(units = 256, activation = 'tanh', input_shape = c(x_width)) %>% 
  layer_dense(units = 128, activation = 'tanh') %>%
  layer_dense(units = y_width, activation  = 'softmax')

summary(model)

# Compilar modelo
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(),
  metrics = c('accuracy')
)

# Entrenamiento
history <- model %>% 
  fit(
    x_train, y_train, 
    epochs = 10,  # Tried with 25, same result 
    batch_size = 128, 
    validation_split = 0.2
  )

# Visualizar entrenamiento
plot(history)

# Guardar modelo (en memoria)
model_fnn <- model
