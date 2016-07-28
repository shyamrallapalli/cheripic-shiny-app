library(shiny)
library(ggplot2)
library(hash)

options(shiny.trace = TRUE)
shinyServer(function(input, output, session) {

  # input$infile will be NULL initially. After the user selects
  # and uploads a file, it will be a data frame with 'name',
  # 'size', 'type', and 'datapath' columns. The 'datapath'
  # column will contain the local filenames where the data can
  # be found.
  scaninput <- reactive({
    inFile <- input$infile

    if (is.null(inFile))
      return(NULL)

    read.csv(inFile$datapath, header=input$header, sep=input$sep,
         quote=input$quote)
    })

  options(DT.options = list(pageLength = 5))
  output$contents = DT::renderDataTable({
  # output$contents <- renderTable({
    scaninput()
  })



  observe({
    x_select <- eventReactive(input$plotButton, {
      TRUE
    })

    # Change the selected tab.
    # Note that the tabset container must have been created with an 'id' argument
    if (isTRUE(x_select())) {
      updateNavbarPage(session, "navbar", selected = "Plot")
    }
  })

  dataset <- reactive({
    # output$contents
    df = scaninput()
    scores = sort(unique(df$HMEscore), decreasing = TRUE)
    newdf <- data.frame(matrix(ncol=ncol(df), nrow=0))
    colnames(newdf) = colnames(df)
    int = 0

    for (score in scores) {
      selection = subset(df, df$HMEscore == score)
      elements = as.vector(unique(selection$seq_id))
      one_item = ''
      len = length(elements)

      if(len%%2 == 1) {
        one_item = elements[len]
        elements = elements[-len]
      }
      subset0 = subset(selection, seq_id == one_item)

      if (int == 0) {
        newdf = rbind(subset0, newdf)
        int = 1
      } else {
        newdf = rbind(newdf, subset0)
        int = 0
      }

      if(length(elements) > 0) {
        items = split(elements, 1:2)
        subset1 = subset(selection, seq_id %in% items$`1`)
        subset2 = subset(selection, seq_id %in% items$`2`)
        newdf = rbind(subset1, newdf, subset2)
      }

    }


    seq_lens = unique(newdf[, c("seq_id", "length")])
    seq_lens$cumlen = cumsum(seq_lens$length)
    seq_lens$cumlen = c(0, seq_lens$cumlen[-nrow(seq_lens)])
    len_hash = hash(seq_lens$seq_id, seq_lens$cumlen)
    newdf$adj_pos = newdf$length
    seqids = as.vector(newdf$seq_id)
    for(i in 1:nrow(newdf)){
      newdf$adj_pos[i] = newdf$position[i] + len_hash[[seqids[i]]]
    }

    newdf
  })

  output$text <- renderUI({
    if(is.null(adjdataset())) {
      HTML("<center><b>Please select an appropriate input file and select Plot button on Input tab</b></center><br><br>")
    } else {
      HTML("<center>Below is the density plot of the variants selected and their HMEscore</center><br>")
    }
  })

  output$plot <- renderPlot({
    # ggplot(dataset(), aes(seq_id)) + geom_bar()
    if(is.data.frame(dataset())) {
      ggplot(dataset(), aes(adj_pos)) + geom_density(adjust = 1/5)
    }
  })

  # output$summary <- renderPrint({
  #   summary(cars)
  # })

})
