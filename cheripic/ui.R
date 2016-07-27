library(shiny)
library(ggplot2)

shinyUI(navbarPage(
  "CHERPIC Variants", id = "navbar",
  tabPanel(
    title = "Input",
    value = "Input",
    fluidPage(
      #titlePanel("Upload File"),
      sidebarLayout(
        sidebarPanel(
          fileInput('infile', 'Choose Input Text/CSV File',
                    accept=c('text/csv',
                     'text/comma-separated-values,text/plain',
                     '.csv')),
          tags$hr(),
          checkboxInput('header', 'Header', TRUE),
          # tab delimited is default
          radioButtons('sep', 'Separator',
                       c(Tab='\t', Comma=','),
                       '\t'),
          # double quotes is default
          radioButtons('quote', 'Quote',
                       c('Double Quote'='"', 'Single Quote'="'", None=''),
                       '"'),
          actionButton("plotButton", "Plot Density"),
          p("Click the button to plot the density.")
        ),
        mainPanel(
          # tableOutput('contents')
          DT::dataTableOutput('contents')
        )
      )
    )
  ),
  tabPanel(
    title = "Plot",
    value = "Plot",
    fluidPage(
      title = "Variant position density chart",
      plotOutput('plot')
    )
  ),
  tabPanel(
    title = "Selected Variants",
    value = "Vars")
))

