library(shiny)
library(ggplot2)
library(hash)
source("ggplot_theme.R")

options(shiny.trace = TRUE)
# option to increase upload file size to 30Mb
options(shiny.maxRequestSize=30*1024^2)
shinyServer(function(input, output, session) {

  # input$infile will be NULL initially. After the user selects
  # and uploads a file, it will be a data frame with 'name',
  # 'size', 'type', and 'datapath' columns. The 'datapath'
  # column will contain the local filenames where the data can
  # be found.
  scaninput <- reactive({
    inFile <- input$infile

    if (is.null(inFile)){
      return(NULL)
    }

    read.csv(inFile$datapath, header=input$header, sep=input$sep,
         quote=input$quote)
    })

  options(DT.options = list(pageLength = 5))
  output$contents = DT::renderDataTable({
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


    y_select <- eventReactive(input$viewvars, {
      TRUE
    })

    # Change the selected tab.
    # Note that the tabset container must have been created with an 'id' argument
    if (isTRUE(y_select())) {
      updateNavbarPage(session, "navbar", selected = "Vars")
    }

  })

  dataset <- reactive({
    df = scaninput()
    if (is.null(df)){
      return(NULL)
    }

    scores = sort(unique(df$Score), decreasing = TRUE)
    newdf <- data.frame(matrix(ncol=ncol(df), nrow=0))
    colnames(newdf) = colnames(df)
    int = 0

    for (score in scores) {
      selection = subset(df, df$Score == score)
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
    newdf
  })

  adjdataset <- reactive({
    df = dataset()
    if (is.null(df)){
      return(NULL)
    }
    limits = input$range
    cat(paste("limits: ", limits))
    nums = nrow(df)
    if(limits[1] == 0){
      minrow = 1
    } else {
      minrow = round(nums * limits[1] / 100)
    }
    maxrow = round(nums * limits[2] / 100)
    cat(paste("items: ", minrow, maxrow))
    df = df[minrow:maxrow,]
    seq_lens = unique(df[, c("seq_id", "length")])
    seq_lens$cumlen = cumsum(seq_lens$length)
    seq_lens$cumlen = c(0, seq_lens$cumlen[-nrow(seq_lens)])
    len_hash = hash(seq_lens$seq_id, seq_lens$cumlen)
    df$adj_pos = df$length
    seqids = as.vector(df$seq_id)
    for(i in 1:nrow(df)){
      df$adj_pos[i] = df$position[i] + len_hash[[seqids[i]]]
    }
    df
  })

  output$text <- renderUI({
    if(is.null(adjdataset())) {
      HTML("<center><b>Please select an appropriate input file and select Plot button on Input tab</b></center><br><br>")
    } else {
      HTML("<center>Below is the density plot of the variants selected and their HMEscore</center><br>")
    }
  })

  output$plot <- renderPlot({
    if(is.data.frame(adjdataset())) {
      ggplot(adjdataset(), aes(adj_pos)) + geom_density(adjust = 1/3) + labs(x ="position", y="density", main=NULL) + mytheme
    }
  })

  output$summary <- DT::renderDataTable({
    adjdataset()
  })

})
