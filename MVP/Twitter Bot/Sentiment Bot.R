
library(rtweet)
library(dplyr)
library(tidytext)
library(tidyverse)
library(ggplot2)
library(sys)
library(lubridate)
library(randomcoloR)
library(stringr)


# ________________________ ______________________________ Access Tokens & Keys ______________________________________________________
create_my_token <- function() {
  appname <- "QuantaLabsSentiment"                                         ## name assigned to created app
  key <- "szmabseQ9HceMuv0xFQjveaRq"                                       ## api key 
  secret <- "6gKES04Mrx3nhNdSbmPTtwkRW20yLmmyl1fgfpzFHeWW8pfZ5t"           ## api secret 
  token <- "1208662769438003201-C5Od4DcVEKC3YKH8x4Tm398yaqpZFi"            ## api access token
  token_secret <- "mj81VVg04Tem352M2KzTybXGV3FQRRVGYTsy95rA39geR"          ## api access token secret
  
  twitter_token <- create_token(
    app=appname,
    consumer_key=key,
    consumer_secret=secret,
    access_token=token,
    access_secret=token_secret)
  
  return(twitter_token)
}
# ______________________________________________________ Access Tokens & Keys ______________________________________________________




# ______________________________________________________ Configure Workspace ______________________________________________________
configure_workspace <- function() {
  setwd("~/Desktop/Quanta AI/Quanta_CS/MVP/Twitter Bot")
  
  # load lexicon
  nrc_lexicon <<- read.csv('./data/lexicon/nrc_lexicon.csv')
  afinn_lexicon <<- read.csv('./data/lexicon/afinn_lexicon.csv')
  bing_lexicon <<- read.csv('./data/lexicon/bing_lexicon.csv')
}
# ______________________________________________________ Configure Workspace ______________________________________________________




# ______________________________________________________ Compute Analysis ______________________________________________________
compute_analysis <- function(user_id) {
  "Return a users Sentiment Analysis Plot"
  
  clean_tweets_text <- function(dataset) {
    "Return: clean word tokens ranked by frequency of appearance"
    dataset <- dataset %>% unnest_tokens(word, text) %>% select(word)          # clean & tokenize words
    dataset <- dataset %>% anti_join(stop_words, by=c("word", "word"))         # remove stop words
    dataset <- dataset %>% count(word, sort=TRUE)                              # count word appearences
    dataset <- dataset[dataset$word != 'https',]                               # customly remove some unwanted terms
    dataset <- dataset[is.na(as.numeric(dataset$word)),]                       # remove numbers
    dataset <- dataset %>% mutate(word=reorder(word,n))                        # order (already done?)
    return(dataset)
  }
  
  
  compute_bing_sentiment <- function(word_list, lexicon=bing_lexicon) {
    "Compute the Corpus Sentiment for a given Lexicon"
    word_list <- word_list %>% inner_join(lexicon, by=c('word','word')) %>% select(word, n, sentiment) 
    word_list$pole = ifelse(word_list$sentiment == 'positive', 1, -1)
    word_list$score = word_list$pole * word_list$n
    return(word_list)
  }
  
  # get & clean data
  tweets <- get_timeline(n=10000, user=user_id)
  clean_tweets <- clean_tweets_text(tweets)
  
  
  # ________ ________ Compute Diversified Sentiment ________ ________
  diversified_sentiment_analysis <- function(word_list, nrc_lexicon=nrc_lexicon) {
    "Compute, plot & return the diversified sentiment"
    
    diversed_sentiment <- unique(word_list %>% inner_join(nrc_lexicon) %>% 
                                   group_by(sentiment) %>% mutate(sum_n = sum(n)) %>% select(sum_n))
    diversed_sentiment$proportion = diversed_sentiment$sum_n / sum(diversed_sentiment$sum_n)
    diversed_sentiment$ratio = diversed_sentiment$proportion / max(diversed_sentiment$proportion)
    rank <- data.frame(sentiment=c('positive','joy','surprise',"sadness",'disgust','negative',
                                   'anger','fear','anticipation','trust'),
                       position=c(0,1,2,3,4,5,6,7,8,9),
                       sent=c(1,1,0,-1,-1,-1,-1,-1,0,1)) 
    rank <- inner_join(diversed_sentiment, rank, by="sentiment")
    rank <- rank[order(rank$position),]
    return(rank)
  }
  
  # ____ Call Function ____
  rank <- diversified_sentiment_analysis(clean_tweets, nrc_lexicon)
  
  # ________ ________ Sentiment Rose Graph ________ ________
  plt <- ggplot(rank, aes(x=reorder(sentiment, position), y=proportion, fill=factor(sent))) + 
    geom_bar(stat='identity', show.legend=F) +
    coord_polar() + ggtitle(sprintf("Sentiment of %s's Tweets!", tweets$screen_name[1])) +
    xlab("") + ylab("") + 
    theme(legend.position = "None",
          axis.ticks.y = element_blank(),
          axis.line.y = element_blank(),
          axis.text.y = element_blank(),
          plot.title = element_text(hjust = 0.5),
          panel.background = element_rect(fill = "white"),
          panel.grid.major = element_line(colour='#DCDCDC'), 
          panel.grid.minor  = element_line(colour='#DCDCDC')) +
    scale_fill_manual(values=c(randomcoloR::randomColor(3)))
  
  
  # Store Results --?
  
  
  # return plot 
  results <- list()
  results[['username']] = tweets$screen_name[1]
  results[['plot']] = plt

  return(results)
}
# ______________________________________________________ Compute Analysis ______________________________________________________










# _________________________________________________________ Post Tweet _________________________________________________________
post_user_sentiment <- function(twitter_token, screen_name, plt) {
  
  # ___ ___ ___ to make it run ___ ___ ___ 
  is_tweet_length <- function(.x, n = 280) {
    .x <- gsub("https?://[[:graph:]]+\\s?", "", .x)
    while (grepl("^@\\S+\\s+", .x)) {
      .x <- sub("^@\\S+\\s+", "", .x)
    }
    !(nchar(.x) <= n)   # here's the fix
  }
  assignInNamespace("is_tweet_length", is_tweet_length, ns = "rtweet")
  # ___ ___ ___ to make it run ___ ___ ___ 
  
  # post tweet
  post_tweet(status=paste('Hey @', screen_name, "! Here's your sentiment:", sep=""), 
             media=plt, 
             token=twitter_token)
}
# _________________________________________________________ Post Tweet _________________________________________________________







# ________________________________________________ Automate Twittersphere Engagement ________________________________________________
# trends <- get_trends("South Africa")
# trends['trend']
# ________________________________________________ Automate Twittersphere Engagement ________________________________________________





# ___________________________________________________ Communicate with User: DM ___________________________________________________
compute_on_DMs <- function(twitter_token, compute_analysis) {
  
  # Get DM's
  dm <- direct_messages(token=twitter_token)
  
  # for each row (message)
  for (i in (1:dim(dm$events)[1])) {
    
    # check if message contains string
    if (str_detect(dm$events$message_create[i,]$message_data$text, 
                   regex("please compute my sentiment", ignore_case=TRUE))) {
      
      # set user ID
      user_id <- dm$events$message_create[i,]$sender_id
      
      # check if user has NOT already been accounted for (send reply after posted users)
      if  (any(!str_detect(dm$events$message_create$message_data$text[dm$events$message_create$target$recipient_id == user_id],
                           regex("Done! Check my Feed!", ignore_case=TRUE)))
      ) {
        
        # ____ compute sentiment graph ____
        res <- compute_analysis(user_id)
        
        # save plot
        sentiment_image_path <- ggsave(filename="temp_sentiment_path.png", plot=res[['plot']])
        
        # ____ create post ____
        post_user_sentiment(twitter_token=twitter_token,
                            screen_name=res$username, 
                            plt='temp_sentiment_path.png')
      }
    }
  }
  return(res)
}
# ___________________________________________________ Communicate with User: DM ___________________________________________________


# 
# data("midwest", package = "ggplot2") 
# 
# # Init Ggplot
# plt <- ggplot(midwest, aes(x=area, y=poptotal)) 
# 
# 
# x = seq(1:100)
# y = runif(100, min=-3, max=3)*x
# data = data.frame(x=x, y=y)
# 
# plt <- ggplot(data, aes(x=x, y=y)) + geom_point()
#   
# 
# ggsave(filename="temp_sentiment_path.png", plot=plt)



# _____________________________________________________                        _____________________________________________________
# _____________________________________________________ Call Full Computation  _____________________________________________________
# _____________________________________________________                        _____________________________________________________

# create token
twitter_token <- create_my_token()

# configure workspace
configure_workspace()

# compute results 
res <- compute_on_DMs(twitter_token, compute_analysis)

# _____________________________________________________                        _____________________________________________________
# _____________________________________________________ Call Full Computation  _____________________________________________________
# _____________________________________________________                        _____________________________________________________
 






















# 
# 
# # ________ ________ Compute Net Sentiment over the Period ________ ________
# tweets$created_at <- as.Date(tweets$created_at)                                             # Convert Dates
# tweets <- tweets %>% filter(created_at >= Sys.Date() - years(3))                            # go for the last 3 years
# dates <- seq(from=(Sys.Date() - years(3)), to=Sys.Date(), by='week')                        # create date timeline
# 
# sent <- c()
# for (w in (1:(length(dates)-2))) {
#   rt <- tweets %>% filter(created_at>=dates[w], created_at<dates[w+1])
#   clean <- clean_tweets_text(rt)
#   net_sentment <- mean(compute_bing_sentiment(clean, bing_lexicon)[['score']])
#   
#   # Store Results 
#   sent <- rbind(
#     sent,
#     data.frame(net_sentiment=net_sentment, since=dates[w], until=dates[w+1])
#   )
# }
# 
# 
# 
# 
# dm <- direct_messages(n=10, token=twitter_token)
# 
# 
# 
# # _______________________________________________________ Using twitteR _______________________________________________________
# library(twitteR)
# setup_twitter_oauth(consumer_key=key, consumer_secret=secret, access_token=token, access_secret=token_secret)
# dm <- dmGet()
# 



