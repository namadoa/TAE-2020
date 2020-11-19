library(shiny)
library(ggplot2)
library(leaflet)

Sys.setlocale(locale="spanish") # Idioma en Español para windows
Sys.setlocale(locale="es") # Idioma en Español para linux
load("./model.RData") # Modelo para predecir
load("./days_df.RData") # Dataframe de días pre-calculados para el modelo 
load("./clases.RData") # Clases precargadas, usadas en el modelo
load("./historicos_df.RData") # Datos históricos
load("./mapaClusters.RData") # Mapa de los clusters

clases_p <- clases[- 4]
print(clases_p)
print(clases)
# Función para obtener la fecha final
resolveEnd <- function(dateStart, timeUnit, timeWindow){
  daysToSum <- timeUnit * timeWindow
  return(as.Date(dateStart) + daysToSum)
}

# Procesa los resultados y los entrega para su visualización, dependiendo de la
# ventana de tiempo escogida
processResults <- function(timeUnit, dateStart, dateEnd, results){
  # Días
  if(timeUnit == 1){
    # Si son días, no se tienen que procesar los datos
    dates <- seq.Date(from = dateStart,to = dateEnd, by = 1)
    results_df <- data.frame(value = results, fecha = dates)
    processedResults <- list("timeString" = "Día", "timeStringPlural" = "Días", "results_df" = results_df)
    
    return(processedResults)
  }else{
    # Si no son días, se tienen que sumarizar los datos por la unidad de tiempo escogida
    numPoints <- ceiling(length(results)/timeUnit) # Número de puntos
    newResults <- integer(numPoints) # Arreglo de enteros
    count <- 1
    for(i in seq(from = 1, to = length(results), by = timeUnit)){
      limit <-i+timeUnit
      if ((limit) > length(results)+1){ # Esto para evitar indices fuera de borde
        limit <- length(results)
      }
      limit <- limit -1
      newResults[count] <- sum(results[i:limit])
      count <- count + 1
    }
    dates <- seq.Date(from = dateStart,to = dateEnd, by= timeUnit)
    results_df <- data.frame(value = newResults, fecha = dates)
    
    # Resolver cadenas de unidad de tiempo
    timeString <- ""
    timeStringPlural <- ""
    if (timeUnit == 7){
      timeString <- "Semana"
      timeStringPlural <- "Semanas"
    }else if (timeUnit == 30){
      timeString <- "Mes"
      timeStringPlural <- "Meses"
    }
    processedResults <- list("timeString" = timeString, "timeStringPlural" = timeStringPlural, "results_df" = results_df)
    return(processedResults)
  }
}


ui <- fluidPage(
  
  # Título de la App
  titlePanel("Accidentalidad en Medellín"),
  
  # Tres filas, para Datos Históricos, Predicción y Agrupamiento
  tabsetPanel(
    # Datos Históricos
    tabPanel(
      title = "Datos históricos",
      hr(),
      helpText("Es importante notar que para la unidad de tiempo se asume, que las semanas son igual a 7 días y los meses a 30, por
      esto es posible obtener puntos que son más bajos ya que como tal no encierran meses exactos."),
      sidebarPanel(
        # Rango de Fechas
        dateRangeInput('dateRange',
                       label="Rango de Fechas", 
                       start = "2014-01-01", 
                       end ="2014-12-31", 
                       language = "es", 
                       separator = "a", 
                       min = "2014-01-01",
                       max = "2018-12-31"),
        # Unidad de tiempo (día, meses, años)
        selectInput('hist_timeUnit', 
                    label="Unidad de tiempo",
                    choices=list("Días" =1, "Semanas" = 7, "Meses" = 30), 
                    selected = 30),
        # Tipo de accidente
        selectInput('hist_accClass', 
                    label="Tipo de Accidente",
                    choices=clases, 
                    selected = "Atropello")
      ),
      mainPanel(
        plotOutput('accHistPlot'),
        textOutput('accHistCount')
      )
    ),
    
    # Predicción
    tabPanel(
      title = "Predicción",
      hr(),
      helpText("La predicción solo es posible realizarla desde el ",
      strong("1 de Enero de 2019"),
      "hasta el ",
      strong("31 de Diciembre de 2020."),
      "Es importante notar que para la unidad de tiempo se asume, que las semanas son igual a 7 días y los meses a 30, por
      esto es posible obtener puntos que son más bajos ya que como tal no encierran meses exactos."),
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
                    max=365,
                    value=7
        ),
        # Tipo de Accidente
        selectInput('accidentClass',
                    label="Tipo de Accidente",
                    choices=clases_p,
                    selected = "Atropello")
        
      ),
      mainPanel(
        plotOutput('accPredictPlot'),
        textOutput('accPredictCount')
      )
    ),
    
    # Agrupamiento
    tabPanel(
      title = "Agrupamiento",
      hr(),
      helpText("Los “Barrios/Veredas sin información” son Barrios o Veredas de los cuales no hay datos en las bases de datos."),
      leafletOutput("mapa")
    )
  )

)

# Define la lógica del servidor
server <- function(input, output, session) {
  
  # Gráfica de predicción
  output$accPredictPlot <- renderPlot({
    timeUnit <- as.integer(input$timeUnit)
    timeWindow <- as.integer(input$timeWindow)
    dateStart <- as.Date(input$dateStart)
    dateEnd <- resolveEnd(dateStart,timeUnit,timeWindow)
    dateStart <- dateStart + 1 # No incluir la fecha inicial
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
    
    # Procesar los datos según la unidad de tiempo
    pResults <- processResults(timeUnit, dateStart, dateEnd, results)
    
    values <- pResults$results_df
    timeString <- pResults$timeString
    timeStringP <- pResults$timeStringPlural
    
    
    output$accPredictCount <- renderText({
      x <- sprintf("Número de Accidentes: %i, Promedio de Accidentes por %s: %g", sum(values$value),timeString,mean(values$value))
    });
    
    predictionPlot <- ggplot() + geom_point(mapping = aes(values$fecha,values$value)) + geom_line(mapping = aes(values$fecha,values$value))
    
    predictionPlot + ggtitle("Predicción de Accidentalidad en Medellín (2019-2020)", subtitle=sprintf("Con %i Registros, %i %s",length(results), length(values$value), timeStringP))+ ylab("No. de Accidentes") + xlab("Fecha")
  })
  
  # Gráfica de datos históricos
  output$accHistPlot <- renderPlot({
    dateRange <- as.Date(input$dateRange)
    dateStart <- dateRange[1]
    dateEnd <- dateRange[2]
    timeUnit <- as.integer(input$hist_timeUnit)
    accClass <- input$hist_accClass
    
    # Validar las fechas
    
    if (dateStart >= dateEnd){
      showNotification("La fecha final no puede estar antes de la fecha incial, se extenderá la fecha inicial 30 días.", duration =  10, type = "warning")
      
      dateEnd <- dateStart + 30
      
      updateDateRangeInput(session, 'dateRange', end= dateEnd)
    }
    
    values <- subset(historicos_df,(CLASE == accClass & FECHA >= dateStart & FECHA <= dateEnd))
    pResults <- processResults(timeUnit, dateStart, dateEnd, values$NRO_ACC)
    newValues <- pResults$results_df
    timeString <- pResults$timeString
    timeStringP <- pResults$timeStringPlural
    
    output$accHistCount <- renderText({
      x <- sprintf("Número de Accidentes: %i, Promedio de Accidentes por %s: %g", sum(newValues$value),timeString,mean(newValues$value))
      
    })
    histPlot <- ggplot() + geom_point(mapping = aes(newValues$fecha, newValues$value)) + geom_line(mapping = aes(newValues$fecha, newValues$value))
    histPlot + ggtitle(sprintf("Número de accidentes de tipo %s por %s", accClass, timeString)) + xlab("Fecha") + ylab("Número de Accidentes")
  })
  
  output$mapa <- renderLeaflet({ 
    mapaClusters
  })
}

# Crear la app de Shiny
shinyApp(ui = ui, server = server)