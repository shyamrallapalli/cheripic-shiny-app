library(shiny)
library(ggplot2)

shinyUI(navbarPage(
  "CHERPIC Variants",
  tabPanel("Input",
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
          radioButtons('sep', 'Separator',
                       c(Comma=',',
                         Semicolon=';',
                         Tab='\t'),
                       ','),
          radioButtons('quote', 'Quote',
                       c(None='',
                         'Double Quote'='"',
                         'Single Quote'="'"),
                       '"')
        ),
        mainPanel(
          # tableOutput('contents')
          DT::dataTableOutput('contents')
        )
      )
    )
  ),
  tabPanel("Plot",
    fluidPage(
      title = "Contig bar chart",
      plotOutput('plot')
    )
  ),
  tabPanel("Selected Variants")
))

