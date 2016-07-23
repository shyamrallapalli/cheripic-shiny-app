shinyUI(fluidPage(
  titlePanel('Download Data'),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "Choose a dataset:",
                  choices = c("rock", "pressure", "cars")),
      downloadButton('downloadData', 'Download')
    ),
    mainPanel(
      # tableOutput('table')
      DT::dataTableOutput('table')
    )
  )
))
