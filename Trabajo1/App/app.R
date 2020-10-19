library(shiny)


ui <- fluidPage(
  
  # Título de la App
  titlePanel("Accidentalidad en Medellín"),
  
  # Tres filas, para Datos Históricos, Predicción y Agrupamiento
  
  # Datos Históricos
  fluidRow(
    h3("Datos históricos", align="center"),
    sidebarPanel(
                   # Rango de Fechas
                   dateRangeInput('dateRange',
                                  label="Rango de Fechas", 
                                  start = "2014-01-01", 
                                  end ="2018-12-31", 
                                  language = "es", 
                                  separator = "hasta", 
                                  min = "2014-01-01",
                                  max = "2018-12-31"),
                   # Tipo de accidente
                   selectInput('hist_accType', 
                               label="Tipo de Accidente",
                               choices=list("Tipo 1" =1, "Tipo 2" = 2), 
                               selected = 1)
                 ),
    # TODO: Gráfica de datos históricos
    mainPanel()
  ),
  
  # Predicción
  fluidRow(
    h3("Predicción", align="center"),
    sidebarPanel(
                   # Fecha de inicio de la prediccón
                   dateInput('dateStart', 
                             label="Fecha de inicio de la predicción",
                             value="2018-12-31",
                             min = "2014-01-01",
                             max = "2018-12-31",
                             language = "es"),
                   # Unidad de tiempo (día, meses, años)
                   selectInput('timeUnit', 
                               label="Unidad de tiempo",
                               choices=list("Día" =1, "Meses" = 2, "Año" = 3), 
                               selected = 1),
                   # Ventana de tiempo
                   sliderInput('timeWindow',
                               label="Ventana de tiempo",
                               min=1,
                               max=50,
                               value=1
                               )
                 ),
    # TODO: Gráfica y resultados de la predicción
    mainPanel()
  ),
  
  # Agrupamiento
  fluidRow(
    h3("Agrupamiento", align="center"),
    sidebarPanel(
                  # Selección de Barrio
                  selectInput('neighborhood',
                              label="Barrio",
                              choices=list("Tipo 1" =1, "Tipo 2" = 2), 
                              selected = 1)
                ),
    # TODO: Datos de barrios
    mainPanel()
  )
)

# Define la lógica del servidor
server <- function(input, output) {
  
  # TODO: Definir las salidas 
  
}

# Crear la app de Shiny
shinyApp(ui = ui, server = server)