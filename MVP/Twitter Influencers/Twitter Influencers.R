
# Do Certain People Yeild Supreme Influence on Twitter?

# Score Influence

# Can we compute metrics to _"rank"_ the influencial power of particular members on twitter?
  
  
# ________________________________________________________ Configure Workspace ________________________________________________________
  load_packages <- function() {
    library(tidytext)
    library(textdata)
    library(rtweet)
    library(dplyr)
    library(lubridate)
    library(ggplot2)
    library(stringr)
    library(tidyr)
    library(shiny)
    library(wordcloud)
    library(reshape2)
    
    setwd("~/Desktop/Quanta AI/Final/Sentiment Analysis App")
  }
# ________________________________________________________ Configure Workspace ________________________________________________________
  


    
  

  
  
# ___________________________________________________ Influence Summary Statistics ___________________________________________________
  
# initial influencial users
users <- c('WarrenIngram', 'TradersCorner', 'paul_vestact', 'SimonPB', 'Richards_Karin', 
           'JP_Verster', 'Nerina_Visser','AdrianSaville', 'chrishartZA', 'davidshapiro61')
  
# download their timelines
jse_influencers <- get_timeline(users, n=2500)
  

#  ____ INFLUENCE REPORT ____

# number of tweets, no. followers, no. following (friends),
user_summaries <- jse_influencers %>% group_by(screen_name) %>% 
  summarise(n_tweets=n(), 
            followers=unique(followers_count),
            following=unique(friends_count),
            # average_retweets_per_tweet=mean(retweet_count),
            average_likes_per_tweet=mean(favourites_count),
            average_retweets=mean(retweet_count)
            # dedication_of_followers_prop_likes_per_tweet=# average_likes_per_tweet/n_tweets
  )

user_summaries
# ___________________________________________________ Influence Summary Statistics ___________________________________________________











# ________________________________________________________ Clean Twitter Text  ________________________________________________________

clean_tweets_text <- function(dataset, plot=FALSE) {
  "Return: clean word tokens ranked by frequency of appearance"

  dataset <- dataset %>% unnest_tokens(word, text) %>% select(word)                        # clean & tokenize words
  dataset <- dataset %>% anti_join(stop_words, by=c("word", "word"))                       # remove stop words
  dataset <- dataset %>% count(word, sort=TRUE)                                            # count word appearences
  dataset <- dataset[dataset$word != 'https',]                                             # customly remove some unwanted terms
  dataset <- dataset[is.na(as.numeric(dataset$word)),]                                     # remove numbers
  dataset <- dataset %>% mutate(word=reorder(word,n))                                      # order (already done?)
  
  if (plot) {
    # Most Used Words
    plt <- dataset[1:15,] %>% 
      ggplot(aes(word,n,fill=word)) + ggtitle("Most Common Words") + 
      geom_col() + xlab(NULL) + coord_flip()
    print(plt)
  }
  
  return(dataset)
}
# ________________________________________________________ Clean Twitter Text  ________________________________________________________












# ___________________________________________________ Download Sentiment Lexicon's ___________________________________________________

# set location
getwd()
setwd("/Users/zachwolpe/Desktop/Quanta AI/Quanta_CS/MVP/Twitter Influencers")
setwd("~/Desktop/Quanta AI/Quanta_CS/MVP/Twitter Influencers")

# download lexicon
# nrc_lexicon = get_sentiments("nrc")
# afinn_lexicon = get_sentiments("afinn")
# bing_lexicon = get_sentiments("bing")

# save lexicon
# write.csv(nrc_lexicon, 'data/lexicons/nrc_lexicon.csv')
# write.csv(afinn_lexicon, 'data/lexicons/afinn_lexicon.csv')
# write.csv(bing_lexicon, 'data/lexicons/bing_lexicon.csv')

# load lexicon
nrc_lexicon = read.csv('data/lexicons/nrc_lexicon.csv')
afinn_lexicon = read.csv('data/lexicons/afinn_lexicon.csv')
bing_lexicon = read.csv('data/lexicons/bing_lexicon.csv')
# ___________________________________________________ Download Sentiment Lexicon's ___________________________________________________












# ________________________________________________ Bing: Polarized Sentiment Analysis ________________________________________________

# Compute the sentiment of each word in a polarized fashion (_'positive'_ or _'negative'_)

compute_bing_sentiment <- function(word_list, lexicon=bing_lexicon, show_plots=FALSE, word_size=30, printt=F) {
  "Compute the Corpus Sentiment for a given Lexicon"
  
  
  word_list <- word_list %>% inner_join(lexicon, by=c('word','word')) %>% select(word, n, sentiment)     # get bing sentiment    
  
  word_list$pole = ifelse(word_list$sentiment == 'positive', 1, -1)                                      # compute for visualization
  word_list$score = word_list$pole * word_list$n
  
  
  # visualize
  if (show_plots) {
    net_sent <- ggplot(word_list, aes(word, score, fill=pole)) + geom_col() + 
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.position = 'none')
    print(net_sent)
    plt <- pie(x=c(mean(word_list$sentiment=="negative"),mean(word_list$sentiment=="positive")),
               labels=c("negative",'positive'), col=c("darkblue", "lightblue"))
    print(plt)
    
    # Visualize Most Common Positive vs Negative Words
    plt <- word_list %>% group_by(sentiment) %>% top_n(n=10, wt=n) %>% mutate(word=reorder(word,n)) %>%
      ggplot(aes(reorder(word,n), n, fill=sentiment)) + geom_col(show.legend=FALSE) + 
      facet_wrap(~sentiment, scales="free_y") + labs(y = "Contribution to Sentiment", x = NULL) + coord_flip()
    print(plt)
    
    
    # generate wordcloud by sentiment colours  
    group = c(word_list$sentiment)
    basecolours = c('darkgreen','darkred')
    colourlist = basecolours[match(group,unique(group))]
    
    plt <- wordcloud(words=word_list$word, freq=word_list$n, colors=colourlist, 
                     ordered.colors=T, max.words=word_size)
    print(plt)
    
    # Structured sentiment word cloud
    plt <- word_list %>% acast(word ~ sentiment, value.var="n", fill=0) %>% 
      comparison.cloud(colors=c("darkred",'darkgreen'), 
                       max.words=word_size)
    print(plt)
    
  }
  
  if (printt) {
    print(paste("Proportion of POSITIVE sentiment words: ", mean(word_list$sentiment=="positive")))
    print(paste("Proportion of NEGATIVE sentiment words: ", mean(word_list$sentiment=="negative")))
    print(paste("Proportion of NEUTRAL sentiment words: ", mean(word_list$sentiment=="neutral")))
  }
  
  return(word_list)
}

# ________________________________________________ Bing: Polarized Sentiment Analysis ________________________________________________






bing_sent <- compute_bing_sentiment(clean, bing_lexicon, TRUE)
head(bing_sent)






ref_class <- setRefClass(Class = 'myClass',fields ='a',
                         li
                        )












  
  
  
  
  
  
  
  
  
  
  
  