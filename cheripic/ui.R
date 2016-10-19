library(shiny)
library(ggplot2)
library(markdown)

shinyUI(navbarPage(
  "CHERPIC Variants", id = "navbar",

  tabPanel(
    title = "Input",
    value = "Input",
    fluidPage(
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
          DT::dataTableOutput('contents')
        )
      )
    )
  ),

  tabPanel(
    title = "Plot",
    value = "Plot",
    fluidPage(
      fluidRow(
        column(width = 12,
          htmlOutput('text')
        )
      ),
      fluidRow(
        column(width = 8,
          # Specification of range within an interval
          sliderInput("range", "Range in percent:",
            min = 0, max = 100, value = c(0,100), width = '100%')
        ),
        column(width = 1),
        column(width = 3, actionButton("viewvars", "View selected") )
      ),
      hr(),
      fluidRow(
        plotOutput('plot')
      )
    )
  ),

  tabPanel(
    title = "Selected Variants",
    value = "Vars",
    fluidPage(
      fluidRow(
        column(width = 4),
        column(width = 8,
          downloadButton('downloadVars', 'Download Selected Variants')
        )
      ),
      hr(),
      mainPanel(
        DT::dataTableOutput('summary')
      )
    )
  ),

  navbarMenu("More",
    tabPanel("About",
      fluidRow(
        column(width = 8,
          includeMarkdown("about.md")
        ),
        column(width = 3,
          tags$img(src="https://upload.wikimedia.org/wikipedia/commons/3/34/Cherry_picking_%287848350200%29.jpg",
          width = "256px", height = "171px"),
          tags$small("Cherry picking By Charles Nadeau from San Mateo, CA, CC BY 2.0",
            a(href="https://commons.wikimedia.org/w/index.php?curid=38449766", "Source")
          )
        )
      )
    )
  )

))

