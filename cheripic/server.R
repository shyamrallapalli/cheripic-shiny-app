library(shiny)
library(ggplot2)
library(hash)

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
    # output$contents
    inFile <- input$infile
    if (is.null(inFile))
      return(NULL)
    input = read.csv(inFile$datapath, header=input$header, sep=input$sep,
         quote=input$quote)
    scores = sort(unique(input$HMEscore), decreasing = TRUE)
    newdf <- data.frame(matrix(ncol=ncol(input), nrow=0))
    colnames(newdf) = colnames(input)
    int = 0

    for (score in scores) {
      selection = subset(input, input$HMEscore == score)
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