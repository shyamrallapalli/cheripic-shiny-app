library(shiny)
library(ggplot2)

shinyServer(function(input, output, session) {

  options(DT.options = list(pageLength = 5))
  output$contents = DT::renderDataTable({
  # output$contents <- renderTable({

    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.

    inFile <- input$infile

    if (is.null(inFile))
      return(NULL)

    read.csv(inFile$datapath, header=input$header, sep=input$sep,
         quote=input$quote)
  })

  dataset <- reactive({
    inFile <- input$infile
    if (is.null(inFile))
      return(NULL)
    read.csv(inFile$datapath, header=input$header, sep=input$sep,
         quote=input$quote)
    # output$contents
  })

#  dataset <- output$contents
  output$plot <- renderPlot({
    ggplot(dataset(), aes(seq_id)) + geom_bar()
  })

  # output$summary <- renderPrint({
  #   summary(cars)
  # })

})
