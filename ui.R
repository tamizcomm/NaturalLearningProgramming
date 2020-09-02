#import library
library("shiny")
library(wordcloud2)


shinyUI(fluidPage(
	titlePanel("Shiny-app Assignment"),

	sidebarPanel(
		fileInput("file","Upload Input File(csv)"),
		textInput('keyword',label="Enter list of keywords with separated by comma(,)")
	),

	
	mainPanel(
		tabsetPanel(type="tabs",
			    tabPanel("Overview",
			             h4(p("Data input")),
			             p("This app supports only comma separated values (.csv) data file. CSV data file should have headers and the first column of the file should have row names.",align="justify"),
			             h4('Usage of this App'),
			             p('To use this app, click on Browse button and select the input (csv) file', 
			                #span(strong("Browse button and select the input (csv) file")),
			               'to uppload and enter an list of keywords with comma separated in the text box')),
			    tabPanel("Corpus Output",h4("Keyword results"),tableOutput("keywords")),
			    tabPanel("Word Diagram",h4("Frequency Diagram"),plotOutput("word_diag")),
			    tabPanel("Word cloud",h4("Word cloud"),wordcloud2Output ("word_cloud"))
			             
		  )
	)
	
	)
)



