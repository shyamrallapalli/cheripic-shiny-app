shinyServer(function(input, output) {
  datasetInput <- reactive({
    switch(input$dataset,
           "rock" = rock,
           "pressure" = pressure,
           "cars" = cars)
  })

  options(DT.options = list(pageLength = 5))
  output$table = DT::renderDataTable(datasetInput())
  # output$table <- renderTable({
  #   datasetInput()
  # })

  output$downloadData <- downloadHandler(
    filename = function() {
		 paste(input$dataset, '.csv', sep='')
	 },
    content = function(file) {
      write.csv(datasetInput(), file)
    }
  )
})

