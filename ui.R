
shinyUI(fluidPage(
	
	
	tags$head(
		tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
	),
	
	# Application title
	titlePanel("Modeling Social Networks"),
	
	# Sidebar with a slider input for number of bins
	sidebarLayout(
		sidebarPanel(
			
			actionButton("introduction", "Introduction", icon = icon("toggle-right")),
			bsModal(id = "intro_window", title = "Introduction",
				   trigger = "introduction",
				   tabsetPanel( type = "pills", position = "right",
				   	tabPanel(title = "1",
				   		    htmlOutput("introduction")),
				   	tabPanel(title = "2",
				   		    htmlOutput("introduction2")),
				   	tabPanel(title = "3",
				   		    htmlOutput("introduction3"))
				   )
			),
			
			br(),
			
			radioButtons("graph_model",
					   "Type of model",
					   choices = c(
					   	"Erdos-Renyi" = "ER",
					   	"Barabasi-Albert" = "BA",
					   	"Watts-Strogatz" = "WS",
					   	"Stochastic Block Model" = "SB")),
			
			actionButton("model_explanations", "About the selected model", icon = icon("question")),
			bsModal(id = "model_window", title = "About the selected model",
				   trigger = "model_explanations", size = "large",
				   htmlOutput("model_text")
			),
			
			br(),
			
			sliderInput("nodes",
					  "Total number of nodes:",
					  min = 20, max = 100,
					  value = 50),
			bsTooltip(id = "nodes", placement = "right",
					title = "Total number of actors in the network"),
			
			conditionalPanel(condition = "input.graph_model == 'ER'",
						  
						  sliderInput("density",
						  		  "Graph density",
						  		  min = 0.05, max = 0.75, value = 0.25),
						  bsTooltip(id = "density", placement = "right",
						  		title = "How interconnected the network is")
						  
			),
			
			conditionalPanel(condition = "input.graph_model == 'BA'",
						  
						  sliderInput("connections",
						  		  "Number of connections",
						  		  min = 1, max = 3, value = 1),
						  bsTooltip(id = "connections", placement = "right",
						  		title = "The number of ties each node can have"),
						  
						  sliderInput("power",
						  		  "Hub strength",
						  		  min = 0.2, max = 1.5, value = 1),
						  bsTooltip(id = "power", placement = "right",
						  		title = "How much more likely for an existing connection to promote even more" )
			
						  ),
			conditionalPanel(condition = "input.graph_model == 'WS'",
						  
						  sliderInput("neighbors", 
						  		  "Neighbors",
						  		  min = 2, max = 5, value = 2),
						  bsTooltip(id = "neighbors", placement = "right",
						  		title = "Number of neighbors to form initial connections with."),
						  
						  sliderInput("rewire",
						  		  "Rewiring probability",
						  		  min = 0.01, max = 0.20, value = 0.1),
						  bsTooltip(id = "rewire", placement = "right",
						  		title = "Likelihood of a new random connection")
			),
			
			conditionalPanel(condition = "input.graph_model == 'SB'",
						  
						  sliderInput("clusters",
						  		  "Number of clusters:",
						  		  min = 1, max = 5,
						  		  value = 20),
						  bsTooltip(id = "clusters", placement = "right",
						  		title = "The number of distinct groups in the network."),
						  
						  sliderInput("d",
						  		  "Cluster strength:",
						  		  min = 0.20, max = 0.50,
						  		  value = 0.2),
						  bsTooltip(id = "d", placement = "right",
						  		title = "How defined the clusters are within the network")
				
				),
			
			radioButtons("node_colors",
					   "Color nodes by:",
					   choices = c("Degree: Shows most important hubs in the network" = "degree",
					   		  "Betweenness: Shows most important intermediaries in the network" = "betweenness")),
			
			actionButton("recreate_graph",
					   "Randomize network")
		),
		
		# Show a plot of the generated distribution
		mainPanel(
			fluidRow(
				plotOutput("network", width = "60%"),
				htmlOutput("statistics", inline = FALSE)
			),
			fluidRow(
				plotOutput("degree_distribution", width = "50%", height = "300px"),
				plotOutput("geodesic_distribution", width = "50%", height = "300px")
			)
		)
	)
))
