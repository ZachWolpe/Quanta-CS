

# __________________________ Download NLP Lexicon __________________________


library(tidytext)
library(textdata)

# set location
setwd("~/Desktop/Quanta_CS/shiny/twitter_01")


# download lexicon
nrc_lexicon = get_sentiments("nrc")
afinn_lexicon = get_sentiments("afinn")

# save lexicon
write.csv(nrc_lexicon, 'data/lexicon/nrc_lexicon.csv')
write.csv(afinn_lexicon, 'data/lexicon/afinn_lexicon.csv')














# ______________________________________________ Citations + Resources ______________________________________________


# ___________ rTweet ___________
# vignette("intro", package = "rtweet")



# ___________ NLP ___________

# Resources: https://www.tidytextmining.com/index.html

# Lixcon Citation
# article{mohammad13,
#     author = {Mohammad, Saif M. and Turney, Peter D.},
#     title = {Crowdsourcing a Word-Emotion Association Lexicon},
#     journal = {Computational Intelligence},
#     volume = {29},
#     number = {3},
#     pages = {436-465},
#     doi = {10.1111/j.1467-8640.2012.00460.x},
#     url = {https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1467-8640.2012.00460.x},
#     eprint = {https://onlinelibrary.wiley.com/doi/pdf/10.1111/j.1467-8640.2012.00460.x},
#     year = {2013}
# }

















