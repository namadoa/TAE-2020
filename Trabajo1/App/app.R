library(shiny)
library(ggplot2)

load("./model.RData")
load("./days_df.RData")
load("./clases.RData")

# Función para obtener la fecha final
resolveEnd <- function(dateStart, timeUnit, timeWindow){
  daysToSum <- timeUnit * timeWindow
  return(as.Date(dateStart) + daysToSum)
}


ui <- fluidPage(
  
  # Título de la App
  titlePanel("Accidentalidad en Medellín"),
  
  # Tres filas, para Datos Históricos, Predicción y Agrupamiento
  tabsetPanel(
    # Datos Históricos
    tabPanel(
      title = "Datos históricos",
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
      mainPanel()
    ),
    
    # Predicción
    tabPanel(
      title = "Predicción",
      hr(),
      helpText("La predicción solo es posible realizarla desde el ",
      strong("1 de Enero de 2019"),
      "hasta el ",
      strong("31 de Diciembre de 2020")),
      sidebarPanel(
        # Fecha de inicio de la predicción
        dateInput('dateStart', 
                  label="Fecha de inicio de la predicción",
                  value="2019-01-01",
                  min = "2019-01-01",
                  max = "2020-12-30",
                  language = "es"),
        # Unidad de tiempo (día, meses, años)
        selectInput('timeUnit', 
                    label="Unidad de tiempo",
                    choices=list("Días" =1, "Semanas" = 7, "Meses" = 30), 
                    selected = 1),
        # Ventana de tiempo
        sliderInput('timeWindow',
                    label="Ventana de tiempo",
                    min=1,
                    max=50,
                    value=1
        ),
        # Tipo de Accidente
        selectInput('accidentClass',
                    label="Tipo de Accidente",
                    choices=clases,
                    selected = "Atropello")
        
      ),
      # TODO: Gráfica y resultados de la predicción
      mainPanel(
        
        plotOutput('accPredictPlot'),
        textOutput('accPredictCount')
      )
    ),
    
    # Agrupamiento
    tabPanel(
      title = "Agrupamiento",
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

)

# Define la lógica del servidor
server <- function(input, output) {
  # TODO: Definir las salidas 
  
  output$accPredictPlot <- renderPlot({
    timeUnit <- as.integer(input$timeUnit)
    timeWindow <- as.integer(input$timeWindow)
    dateStart <- as.Date(input$dateStart)
    dateEnd <- resolveEnd(dateStart,timeUnit,timeWindow)
    
    # Validar que 'dateEnd' sea menor al 2020-12-31
    if (dateEnd > "2020-12-31"){
      dateEnd = as.Date("2020-12-31")
      showNotification("La fecha final excede el rango permitido, se usará el 31 de Diciembre de 2020 como fecha final", duration =  10, type = "warning")
    }
    
    fdateStart <- format(dateStart, "%Y-%m-%d")
    fdateEnd <- format(dateEnd, "%Y-%m-%d")
    predictionSubset <- subset(days_df, (FECHA >= fdateStart & FECHA <= fdateEnd))
    
    predictionSubset$CLASE = input$accidentClass
    
    results <- round(predict(model, newdata= predictionSubset, type="response"))
    
    output$accPredictCount <- renderText({
      x <- sprintf("Número de Accidentes: %i, Promedio de Accidentes por día: %g", sum(results), mean(results))
    });
    
    predictionPlot <- ggplot() + geom_point(mapping = aes(c(1:length(results)),results)) + geom_line(mapping = aes(c(1:length(results)),results))
    
    predictionPlot + ggtitle("Predicción de Accidentalidad en Medellín (2019-2020)", subtitle=sprintf("Con %i Registros",length(results)))+ ylab("No. de Accidentes") + xlab("Registros")
  })
  

  

  
}

# Crear la app de Shiny
shinyApp(ui = ui, server = server)