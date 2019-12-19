import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import bs4
import requests
import warnings
import re
import html
import unidecode

from matplotlib import rcParams

rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'arial'

#%config InlineBackend.figure_format = 'retina'
#%matplotlib inline

warnings.filterwarnings('ignore')

billboard = pd.read_csv('/Users/keaganstokoe/Spotify-Scraper/Spotify200chart.csv')
billboard.sample(1)

def clean_song(x):
    x = x.replace('-', ' ')
    x = re.sub(r'[^\w\s]','', x)
    x = unidecode.unidecode(x)
    return x

billboard[['Artist']]\
    = billboard[['Artist']].applymap(
        lambda x: x.replace('&', 'and'))

billboard[['song_clean', 'artist_clean']]\
    = billboard[['Title', 'Artist']].applymap(clean_song)

billboard.sample(1)


lyrics_list = list() # collector for lyric strings or None if no lyrics found
source_list = list() # collector for the URL from which lyrics were obtained

for index, row in billboard.iterrows():
    artist = row['artist_clean']
    artist_2 = re.sub(r'^the ', '', row['artist_clean']) # if initial round fails
    song = row['song_clean']
    source = None

    urls = list()
    metro_url = 'http://metrolyrics.com/{}-lyrics-{}.html'.format(
        song.replace(' ', '-'), artist.replace(' ', '-'))
    song_url = 'http://songlyrics.com/{}/{}-lyrics/'.format(
        artist.replace(' ', '-'), song.replace(' ', '-'))
    mode_url = 'http://www.lyricsmode.com/lyrics/{}/{}/{}.html'.format(
        artist[0], artist.replace(' ', '_'), song.replace(' ', '_'))
    genius_url = 'https://genius.com/{}-{}-lyrics'.format(
        artist.replace(' ', '-'), song.replace(' ', '-'))
    urls.extend([genius_url, song_url, mode_url, metro_url])
    if artist != artist_2:
        genius_url = 'https://genius.com/{}-{}-lyrics'.format(
            artist_2.replace(' ', '-'), song.replace(' ', '-'))
        metro_url = 'http://metrolyrics.com/{}-lyrics-{}.html'.format(
                song.replace(' ', '-'), artist_2.replace(' ', '-'))
        song_url = 'http://songlyrics.com/{}/{}-lyrics/'.format(
            artist_2.replace(' ', '-'), song.replace(' ', '-'))
        mode_url = 'http://www.lyricsmode.com/lyrics/{}/{}/{}.html'.format(
            artist_2[0], artist_2.replace(' ', '_'), song.replace(' ', '_'))
        urls.extend([genius_url, song_url, mode_url, metro_url])

# attempt scrape and parse sequence. lyrics collected as list of tokens.
    for url in urls:
        try:
            # request HTML and parse
            html = requests.get(url=url).content
            soup = bs4.BeautifulSoup(html)

            # find lyrics and pre-process
            if 'genius.com' in url:
                print(url)
                lyrics = soup\
                    .find('div', {'class': 'lyrics'})\
                    .find('p')\
                    .findAll(text=True)
                if lyrics is None:
                    raise Exception
                source = 'genius.com'

            # for songlyrics.com, if no lyrics found, a message is displayed
            # where lyrics would be. thus, we check for this message instead.
            # if 'songlyrics' in url:
            #     print(url)
            #     lyrics = soup\
            #         .find('p', {'id': 'songLyricsDiv'})\
            #         .findAll(text=True)
            #     if 'Sorry, we have no ' in lyrics[0]:
            #         lyrics = None
            #         raise Exception
            #     source = 'songlyrics.com'
            # if 'lyricsmode' in url:
            #     print(url)
            #     lyrics = soup.find('p', {'id': 'lyrics_text'})
            #     if lyrics is None:
            #         raise Exception
            #     lyrics = lyrics.text.split()
            #     source = 'lyricsmode.com'
            # if 'metrolyrics' in url:
            #     print(url)
            #     lyrics = soup.find('div', {'id': 'lyrics-body-text'})
            #     if lyrics is None:
            #         raise Exception
            #     lyrics = [line.findAll(text=True)\
            #               for line in soup.findAll('p', {'class': 'verse'})]
            #     lyrics = [item for sublist in lyrics for item in sublist]
            #     source = 'metrolyrics.com'

#             # pre-processing below only occurs if query successful
#             lyrics = ' '.join(lyrics).lower().replace('\n', '')

#             # remove apostrophes
#             lyrics = lyrics.replace('\'', '')

#             # remove song structure tags in square brackets
#             lyrics = re.sub(r'\[.*\]' , ' ', lyrics)

#             # all other punctuations replaced with spaces
#             lyrics = re.sub(r'[^\w\s]', ' ', lyrics)

#             # replace consecutive whitespaces with single space
#             lyrics = re.sub(r'\s+', ' ', lyrics)

            break
        except:
            print('error')
lyrics_list.append(lyrics)
#source_list.append(source)

def clean_lyrics(lyrics):
    if lyrics is None:
        return lyrics

    # combine lists of tokens into single string
    lyrics = ' '.join(lyrics)

    # remove apostrophes
    lyrics = lyrics.replace('\'', '')

    # remove song structure tags or instructions in brackets
    lyrics = re.sub(r'[\*\[|\(|\{].*\n*.*[\]\)\}\*]' , ' ', lyrics)

    # remove variations of Verse 1, VERSE 2, etc...
    for verse in ['verse', 'VERSE', 'Verse']:
        lyrics = re.sub(verse+' \d*', '', lyrics)

    # some structure markers formatted as allcaps without brackets
    for word in ['OUTRO', 'INSTRUMENTAL', 'PRE', 'HOOK',
                 'PRODUCED', 'REFRAIN', 'POST', 'REPEAT', '2x', '3x', '4x',
                 'CHORUS', 'INTRO', 'INTERLUDE']:
        lyrics = lyrics.replace(word, '')

    # remove varations of Chorus
    lyrics = re.sub(r'\n*Chorus:*.*' , ' ', lyrics)
    lyrics = re.sub(r'^Chorus:*.*' , ' ', lyrics)
    lyrics = re.sub(r'\nRepeat [C|c]horus:*.*' , ' ', lyrics)

    # remove variations of Intro
    lyrics = re.sub(r'Intro[\s|\n|:].*', ' ', lyrics)

    # remove variations of Instrumental
    lyrics = re.sub(r'-+.*[i|I]nstrumental.*-+', ' ', lyrics)
    lyrics = re.sub(r'\nBrief instrumental.*\n', ' ', lyrics)
    lyrics = re.sub(r'\nInstrumental', ' ', lyrics)
    lyrics = re.sub(r'\nInstrumental break', ' ', lyrics)
    lyrics = re.sub(r'\nInstrumental--', ' ', lyrics)
    lyrics = re.sub(r'\n~Instrumental~', ' ', lyrics)

    # remove variations of Bridge
    lyrics = re.sub(r'\n\[*Bridge:\[*', ' ', lyrics)

    # remove variations of Hook
    lyrics = re.sub(r'Hook:.*', ' ', lyrics)

    # remove varations of Repeat
    lyrics = re.sub(r'Repeat\s.*', ' ', lyrics)
    lyrics = re.sub(r'\nRepeat$', ' ', lyrics)

    # remove credits
    lyrics = re.sub(r'.*[P|p]roduced [B|b]y.*', ' ', lyrics)
    lyrics = re.sub(r'.*[W|w]ritten [B|b]y.*', ' ', lyrics)

    # remove strays and typos
    lyrics = re.sub(r'\[Outro\[', ' ', lyrics)
    lyrics = re.sub(r'Sax & background & instrumental\)', ' ', lyrics)
    lyrics = re.sub(r'\nSource: ', ' ', lyrics)
    #lyrics = re.sub(r'Shotgun 2: 58 Trk 1 \n  \nJr. Walker & The All Stars '\
                #    +'\nAnd/or The Funk Brothers - instrumental \nPop Chart '\
                #    +'#4 Feb 13, 1965 \nSoul Label - 35008   \n ', ' ', lyrics)
    lyrics = re.sub(r'- musical interlude -', ' ', lyrics)
    lyrics = re.sub(r'\nRefrain:', ' ', lyrics)

    # replace all punctuations with spaces
    lyrics = re.sub(r'[^\w\s]', ' ', lyrics)

    # replace consecutive whitespaces with single space
    lyrics = re.sub(r'\s+', ' ', lyrics)

    # convert all tokens to lowercase
    lyrics = lyrics.lower()

    if lyrics[:29] == 'we do not have the lyrics for' or lyrics == 'instrumental':
        lyrics = np.nan
    return lyrics

    lyrics_list_clean = list(map(clean_lyrics, lyrics_list))
billboard['lyrics'] = lyrics_list_clean
#billboard['source'] = source_list

lyrics = billboard['lyrics'].dropna()
for each in lyrics[lyrics.str.contains('chorus')]:
    print([each])

billboard.to_csv('../data/spotify-lyrics.csv', index=False)
