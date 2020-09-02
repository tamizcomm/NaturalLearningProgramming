
# Load libraries 
library(shiny)
library(dplyr)
library(stringr)
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library(ggplot2)
library(wordcloud2)


shinyServer(function(input,output){
	Dataset<-reactive({
		if(is.null(input$file)) 
		  { return (NULL)}
		else{
			infile<-input$file
			Dataset<-as.data.frame(read.csv(infile$datapath,header=TRUE,sep=","))
		return(Dataset)
		}
	})
	
# Get Keywords
	keywords<-reactive({
		if(length(strsplit(input$keyword,',')[[1]])==0){return(NULL)}
		else{
			return(strsplit(input$keyword,',')[[1]])
		}
	})
	
	sentence.data <- reactive({
	  spl <- unlist(strsplit(keywords(), ","))
	  res1 <- Dataset()$Reviews[Reduce(`|`, lapply(spl, grepl, x = Dataset()$Reviews))]
	})
	
	output$keywords <- renderTable({ sentence.data() })
	
	barplot.data <- reactive({
	  Reviewdocs <- Corpus(VectorSource(	sentence.data()))
	  transtoSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
	  Reviewdocs <- tm_map(Reviewdocs, transtoSpace, "/")
	  Reviewdocs <- tm_map(Reviewdocs, transtoSpace, "@")
	  Reviewdocs <- tm_map(Reviewdocs, transtoSpace, "\\|")
	  Reviewdocs <- tm_map(Reviewdocs, content_transformer(tolower))
	  Reviewdocs <- tm_map(Reviewdocs, removeNumbers)
	  Reviewdocs <- tm_map(Reviewdocs, removeWords, stopwords("english"))
	  Reviewdocs <- tm_map(Reviewdocs, removePunctuation)
	  Reviewdocs <- tm_map(Reviewdocs, stripWhitespace)
	  revdtm <- TermDocumentMatrix(Reviewdocs)
	  revdtm <- revdtm[rownames(revdtm)%in%unlist(strsplit(keywords(), ",")),]
	  revm <- as.matrix(revdtm)
	  revvec <- sort(rowSums(revm),decreasing=TRUE)
	  barplot.data <- data.frame(word = names(revvec),freq=as.integer(revvec))
	  return(barplot.data)
	})

	output$word_diag = renderPlot({ 
	  if (!is.null(barplot.data())) {
	    barplot( barplot.data()$freq,names.arg= barplot.data()$word,xlab="Keyword",ylab="Frequency",col="green",    
	          main="Word Frequency Diagram", horiz = TRUE, border="black", las=2,cex.names=0.75)
	  }
	  else
	    print("No Data available")
	    
	})
	
	
	set.seed(120)
	output$word_cloud = renderWordcloud2({ 
	  wordcloud2(data = barplot.data(), size = 2,
	             color = "random-light", backgroundColor = "gray",shape="cardioid",minRotation = -pi/2, maxRotation = -pi/2)
	  
	})

	
})


