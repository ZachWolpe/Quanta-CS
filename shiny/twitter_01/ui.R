

library(shiny)
library(rtweet)
library(dplyr)

# ############################################### Get Users Data ###############################################
# 
# 
# # users
# users <- c('WarrenIngram', 'TradersCorner', 'paul_vestact', 'SimonPB', 'Richards_Karin', 'JP_Verster', 'Nerina_Visser',
#            'AdrianSaville', 'chrishartZA', 'davidshapiro61')
# 
# #users
# jse <- lookup_users('jse')
# 
# 
# # lookup_users(users[1])
# 
# 
# # download their timeline
# jse_influencers <- get_timeline(users, n=1000)
# 
# #lookup_users
# 
# 
# 
# ############################################### Clean Text Data ###############################################
# 
# 
# # import lexicon
# setwd("~/Desktop/Quanta_CS/shiny/twitter_01")
# nrc_lexicon = read.csv('data/lexicon/nrc_lexicon.csv')
# afinn_lexicon = read.csv('data/lexicon/afinn_lexicon.csv')
# 
# 
# text <- jse_influencers %>% group_by(screen_name) %>% filter(screen_name=="WarrenIngram") %>% select(text)
# #text$text
# 
# 
# 
# 
# 
# 
# ############################################### INFLUENCE REPORT ############################################### 
# 
# # number of tweets, no. followers, no. following (friends),
# jse_influencers %>% group_by(screen_name) %>% summarise(n_tweets=n(),
#                                                         followers=unique(followers_count),
#                                                         following=unique(friends_count),
#                                                         average_retweets_per_tweet=mean(retweet_count),
#                                                         average_likes_per_tweet=mean(favourites_count),
#                                                         average_retweets=mean(retweet_count)
#                                                         # dedication_of_followers_prop_likes_per_tweet=
#                                                         # average_likes_per_tweet/n_tweets
#                                                         )
# 
# 
# 
# 
# # compute net sentiment
# jse_influencers %>% group_by(screen_name) %>% select(text) %>% filter(screen_name=="WarrenIngram")
# 
# 
# ############################################### COMBINED INFLUENCE ###############################################
# 
# 
# # followers
# # get_followers((users))


############################################### App UI ###############################################

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Twitter Financial Influencers"),
    
    # get usernames


    
    sidebarLayout(
        position='right',
        sidebarPanel(
            
            textInput('users', "Twitter usernames",value="example: jse"),
            submitButton(   text      = "Update"),
        ),

        # Show a plot of the generated distribution
        mainPanel(
            textOutput('username')
        )
    )
))











