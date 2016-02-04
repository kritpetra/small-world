
shinyServer(function(input, output) {
	
	
	output$introduction <- renderText({
		readChar("www/introduction.html", file.info("www/introduction.html")$size)
	})
	
	output$introduction2 <- renderText({
		readChar("www/introduction2.html", file.info("www/introduction2.html")$size)
	})
	
	output$introduction3 <- renderText({
		readChar("www/introduction3.html", file.info("www/introduction3.html")$size)
	})
	
	output$model_text <- renderText({
		if(input$graph_model == "ER") {
			readChar("www/ErdosRenyi.html", file.info("www/ErdosRenyi.html")$size)
		} else if (input$graph_model == "BA") {
			readChar("www/BarabasiAlbert.html", file.info("www/BarabasiAlbert.html")$size)
		} else if (input$graph_model == "WS") {
			readChar("www/WattsStrogatz.html", file.info("www/WattsStrogatz.html")$size)
		} else if (input$graph_model == "SB") {
			readChar("www/StochasticBlock.html", file.info("www/StochasticBlock.html")$size)
		}
		
		
		
		
		
		})
	

################################################################################

	Graph <- reactive({
		
		input$recreate_graph # Makes the Graph refresh whenever the button is pressed

		if (input$graph_model == "ER") {
			
			sample_gnp(
				n = input$nodes,
				p = input$density # Graph density
				)
			
		} else if( input$graph_model == "WS" ) {

		sample_smallworld(
			dim = 1, # Use 1 for this.
			size = input$nodes,
			nei = input$neighbors, # Size of neighborhood
			p = input$rewire # what's the probability of getting to know another person?
			)
		
		} else if ( input$graph_model == "BA" ) {
			
			# Scale-free model
			sample_pa(
				n = input$nodes,
				power = input$power, # How strong the hubs are in relation to others
				m = input$connections,
				directed = FALSE)
			
		} else if ( input$graph_model == "SB") {
			
			# Erdos-Renyi + weak-ties model
			# Input: total size, partitions , density, relative num of weak ties
			
			num_groups <- input$clusters
			cluster_size <- input$nodes/num_groups
			edge_prob <- input$d
			num_weak_ties <- floor(cluster_size/5/input$d)
			
			sample_islands(
				islands.n = num_groups,
				islands.size = cluster_size,
				islands.pin = edge_prob,
				n.inter = num_weak_ties)	
		}
		
	})

	output$network <- renderPlot({
		
		degree_palette <- colorRampPalette(c("darkgrey", "red"))
		betweenness_palette <- colorRampPalette(c("darkgrey", "blue"))
# 		closeness_palette <- colorRampPalette(c("darkgrey", "green"))
		
		node_colors <- {
			
			if (input$node_colors == "degree") {
				degree_palette(20)[as.numeric(cut(degree(Graph()), breaks = 20))]
				
			} else if (input$node_colors == "betweenness") {
				betweenness_palette(20)[as.numeric(cut(betweenness(Graph()), breaks = 20))]
				
# 			} else if (input$node_colors == "closeness") {
# 				closeness_palette(20)[as.numeric(cut(closeness(Graph()), breaks = 20))]
# 				
			}
		}
		
		plot(Graph(),
			layout = layout.kamada.kawai,
			vertex.size = 10, vertex.color = node_colors, vertex.label = NA)
	})

	
	output$degree_distribution <- renderPlot({
		
		degrees <- data.frame( 
			"Degree" = (1:length(degree_distribution(Graph())))-1,
			"Frequency" = degree_distribution(Graph()))
		
		ggplot(degrees, aes(x = Degree, y = Frequency)) + 
			geom_bar(stat = "identity") + 
			labs(title = "Degree Distribution") + 
# 			scale_fill_gradient(low = "darkgrey", high = "red", 
# 							limits = range(degrees$Degree[degrees$Frequency!=0])) + 
			scale_x_discrete()
		####### scale needs to start at 0 instead of 1
	})

	output$geodesic_distribution <- renderPlot({

		geodesic.dist <- distance_table(Graph(), directed = FALSE)$res
		geodesics <- data.frame(
			"Separation" = 1:length(geodesic.dist),
			"Frequency" = geodesic.dist)
		
		ggplot(geodesics, aes(x = Separation, y = Frequency)) + 
			geom_bar(stat = "identity") +
			labs(title = "Degrees of separation") +
# 			scale_fill_gradient(low = "darkgrey", high = "blue", 
# 							limits = range(geodesics$Separation[geodesics$Frequency!=0])) +
			scale_x_discrete()
	})

output$statistics <- renderText({
	
	density <- transitivity( Graph() ) %>% format(digits = 3)
	
	mean_degree <- mean( degree( Graph() ) ) %>% format(digits = 3)
	
	graph_dist <- distances( Graph() )
	is.na(graph_dist) <- do.call(cbind,lapply(graph_dist, is.infinite))
	mean_sep <- mean( graph_dist, na.rm = TRUE) %>% format(digits = 3)
	
	paste0(
		  "<div class='statistics'><h4 class = 'bold'>Average distance</h3><h4>", mean_sep, "</h4><br/>",
		  "<h4 class = 'bold'>Clustering coefficient</h3><h4>", density, "</h4><br/>",
		  "<h4 class = 'bold'>Mean degree</h3><h4>", mean_degree, "</h4></div>"
		  )
	
})

})
