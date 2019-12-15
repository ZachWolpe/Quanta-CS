#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$distplot <- renderPlot({
        # generate data
        x1 <- rnorm(n=1500, mean=input$mean_1, sd=input$std_1)
        x2 <- rnorm(n=1000, mean=input$mean_2, sd=input$std_2)
        x <- rbind(x1,x2)
        
        hist(x, main="mixture distribution",breaks=input$bins,col='lightblue')
    })
})






# shinyServer(function(input, output) {
# 
#     output$distPlot <- renderPlot({
# 
#         # generate bins based on input$bins from ui.R
#         x    <- faithful[, 2]
#         bins <- seq(min(x), max(x), length.out = input$bins + 1)
# 
#         # draw the histogram with the specified number of bins
#         hist(x, breaks = bins, col = 'darkgray', border = 'white')
# 
#     })
# 
# })





