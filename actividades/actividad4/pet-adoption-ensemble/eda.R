## -------------------------------------------------------------------------------------
## Sistemas Inteligentes para la Gestión en la Empresa
## Curso 2021-2022
## Juan Gómez Romero
## -------------------------------------------------------------------------------------

## -------------------------------------------------------------------------------------
## LIBRARY
library(keras)
library(tidyverse)
library(funModeling)
library(ggthemes)

## -------------------------------------------------------------------------------------
## CONSTANTES
dataset_dir      <- './data/'
train_images_dir <- paste0(dataset_dir, 'train_images')
train_data_file  <- paste0(dataset_dir, 'train.csv')

## -------------------------------------------------------------------------------------
## Cargar y explorar dataset
data_raw <- read_csv(train_data_file)

data_raw
df_status(data_raw)

#- cambiar NAs (solo aparecen en el nombre)
data <- data_raw %>%
  mutate(Name = replace_na(Name, "No name"))

#- histograma (variable objetivo: AdoptionSpeed)
data %>%
  mutate(AdoptionSpeed = as.factor(AdoptionSpeed)) %>%
  ggplot(aes(x = AdoptionSpeed)) +
  geom_histogram(aes(fill = AdoptionSpeed), stat = 'count') +
  geom_text(aes(label = scales::percent((..count..)/sum(..count..))), stat = "count", vjust = -0.5, size = 3, color = "white") +
  labs(title = "# mascotas adoptadas por tiempo-adopcion", x = "AdoptionSpeed", y = "", fill = "") + 
  theme_dark()

#- histograma (variable objetivo: Type)
data %>%
  mutate(Type = as.factor(Type)) %>%
  ggplot(aes(x = Type)) +
  geom_histogram(aes(fill = Type), stat = 'count') +
  geom_text(aes(label = scales::percent((..count..)/sum(..count..))), stat = "count", vjust = -0.5, size = 3, color = "white") +
  labs(title = "# mascotas por tipo (1: perro, 2: gato)", x = "Type", y = "", fill = "") + 
  theme_dark()

#- histograma (variable objetivo: AdoptionSpeed, separacion: Type)
data %>%
  mutate(AdoptionSpeed = as.factor(AdoptionSpeed)) %>%
  ggplot(aes(x = AdoptionSpeed)) +
  geom_histogram(aes(fill = AdoptionSpeed), stat = 'count') +
  geom_text(aes(label = scales::percent((..count..)/sum(..count..))), stat = "count", vjust = -0.5, size = 3, color = "white") +
  labs(title = "# mascotas adoptadas por tiempo-adopcion (1: perro, 2: gato)", x = "AdoptionSpeed", y = "", fill = "") + 
  theme_dark() + facet_wrap(~Type)

#- histograma (variable objetivo: AdoptionSpeed, color: Type)
data %>%
  mutate(AdoptionSpeed = as.factor(AdoptionSpeed), Type = as.factor(Type)) %>%
  ggplot(aes(x = AdoptionSpeed)) +
  geom_histogram(aes(fill = Type), stat = 'count') +
  labs(title = "# mascotas adoptadas por tiempo-adopcion (1: perro, 2: gato)", x = "AdoptionSpeed", y = "", fill = "") + 
  theme_dark()
  
#- histograma (variable: Age)
data %>%
  filter(Age < 120) %>%
  ggplot(aes(x = Age)) +
  geom_histogram(aes(fill = Age), stat = 'count') +
  labs(title = "# mascotas por edad", x = "Age", y = "", fill = "") + 
  theme_dark()


#- histograma (variable: Age, color: AdoptionRate)
data %>%
  filter(Age < 120) %>%
  mutate(AdoptionSpeed = as.factor(AdoptionSpeed)) %>%
  ggplot(aes(x = Age)) +
  geom_line(aes(color = AdoptionSpeed), stat = 'count') +
  labs(title = "# mascotas por edad y tiempo-adopcion", x = "Age", y = "", color = "") + 
  theme_dark()

## -------------------------------------------------------------------------------------
## Correlacion (sobre las variables)
correlation_table(data, target='AdoptionSpeed')
data_num <-
  data %>%
  mutate_if(is.character, as.factor) %>%
  mutate_if(is.factor, as.numeric)
cor(data_num)

# Correlacion detallada (sobre las variables)
library(Hmisc)
library(corrplot)
rcorr(as.matrix(data_num))
corrplot(cor(data_num), type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)
heatmap(x = cor(data_num), symm = TRUE)

