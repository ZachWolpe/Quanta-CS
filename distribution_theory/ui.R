#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)






# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    
    titlePanel("Understand Twitter Networks"),
    
    sidebarLayout(
        position='right',
        sidebarPanel(
            #textOutput(inputId='dist_1', "Distribution 1"),
            sliderInput(inputId='mean_1',label='Mean 1',min=-6,max=6,value=0,step=0.1),
            sliderInput(inputId='std_1',label='Std 1',min=0,max=3,value=1,step=0.1),
        
            sliderInput(inputId='mean_2',label='Mean 2',min=-6,max=6,value=4,step=0.1),
            sliderInput(inputId='std_2',label='Std 2',min=0,max=3,value=2,step=0.1),
            
            sliderInput(inputId='bins',label='Number of Bins',min=1,max=100,value=50,step=0.1),
            
            
            dateRangeInput(
                inputId='dates', 
                label="Search Dates",
                start='2010-01-01',
                end=Sys.Date(),
                min='2006-03-21'),
        ),
        mainPanel(
            #textOutput(outputId='main_text', "Finally a Product")
            plotOutput("distplot")
        )
    )
    



    # # Sidebar with a slider input for number of bins
    # sidebarLayout(
    #     sidebarPanel(
    #         sliderInput("bins",
    #                     "Number of bins:",
    #                     min = 1,
    #                     max = 50,
    #                     value = 30)
    #     ),
    # 
    #     # Show a plot of the generated distribution
    #     mainPanel(
    #         plotOutput("distPlot")
    #     )
    # )
))
