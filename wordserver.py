import optparse
import threading
import OSC
import string
from nltk.classify import NaiveBayesClassifier
from nltk.corpus import subjectivity
from nltk.sentiment import SentimentAnalyzer
from nltk.sentiment.util import *
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from nltk import tokenize

"""
Resources not found.
Please use the NLTK Downloader to obtain the resource:

>>> import nltk
>>> nltk.download('subjectivity')
>> nltk.download('vader_lexicon')

"""


# code from here - http://www.nltk.org/howto/sentiment.html
def setupNLP():
    n_instances = 100
    subj_docs = [(sent, 'subj') for sent in subjectivity.sents(categories='subj')[:n_instances]]
    obj_docs = [(sent, 'obj') for sent in subjectivity.sents(categories='obj')[:n_instances]]

    train_subj_docs = subj_docs[:80]
    test_subj_docs = subj_docs[80:100]
    train_obj_docs = obj_docs[:80]
    test_obj_docs = obj_docs[80:100]
    training_docs = train_subj_docs+train_obj_docs
    testing_docs = test_subj_docs+test_obj_docs

    sentim_analyzer = SentimentAnalyzer()
    all_words_neg = sentim_analyzer.all_words([mark_negation(doc) for doc in training_docs])

    unigram_feats = sentim_analyzer.unigram_word_feats(all_words_neg, min_freq=4)
    sentim_analyzer.add_feat_extractor(extract_unigram_feats, unigrams=unigram_feats)

    training_set = sentim_analyzer.apply_features(training_docs)
    test_set = sentim_analyzer.apply_features(testing_docs)

    trainer = NaiveBayesClassifier.train
    classifier = sentim_analyzer.train(trainer, training_set)

    for key,value in sorted(sentim_analyzer.evaluate(test_set).items()):
        print('{0}: {1}'.format(key, value))

    sentences = ["VADER is smart, handsome, and funny.", # positive sentence example
       "VADER is smart, handsome, and funny!", # punctuation emphasis handled correctly (sentiment intensity adjusted)
       "VADER is very smart, handsome, and funny.",  # booster words handled correctly (sentiment intensity adjusted)
       "VADER is VERY SMART, handsome, and FUNNY.",  # emphasis for ALLCAPS handled
       "VADER is VERY SMART, handsome, and FUNNY!!!",# combination of signals - VADER appropriately adjusts intensity
       "VADER is VERY SMART, really handsome, and INCREDIBLY FUNNY!!!",# booster words & punctuation make this close to ceiling for score
       "The book was good.",         # positive sentence
       "The book was kind of good.", # qualified positive sentence is handled correctly (intensity adjusted)
       "The plot was good, but the characters are uncompelling and the dialog is not great.", # mixed negation sentence
       "A really bad, horrible book.",       # negative sentence with booster words
       "At least it isn't a horrible book.", # negated negative sentence with contraction
       ":) and :D",     # emoticons handled
       "",              # an empty string is correctly handled
       "Today sux",     #  negative slang handled
       "Today sux!",    #  negative slang with punctuation emphasis handled
       "Today SUX!",    #  negative slang with capitalization emphasis
       "Today kinda sux! But I'll get by, lol" # mixed sentiment example with slang and constrastive conjunction "but"
    ]

    paragraph = "It was one of the worst movies I've seen, despite good reviews. \
    Unbelievably bad acting!! Poor direction. VERY poor production. \
    The movie was bad. Very bad movie. VERY bad movie. VERY BAD movie. VERY BAD movie!"


    lines_list = tokenize.sent_tokenize(paragraph)
    sentences.extend(lines_list)

    tricky_sentences = [
       "Most automated sentiment analysis tools are shit.",
       "VADER sentiment analysis is the shit.",
       "Sentiment analysis has never been good.",
       "Sentiment analysis with VADER has never been this good.",
       "Warren Beatty has never been so entertaining.",
       "I won't say that the movie is astounding and I wouldn't claim that \
       the movie is too banal either.",
       "I like to hate Michael Bay films, but I couldn't fault this one",
       "It's one thing to watch an Uwe Boll film, but another thing entirely \
       to pay for it",
       "The movie was too good",
       "This movie was actually neither that funny, nor super witty.",
       "This movie doesn't care about cleverness, wit or any other kind of \
       intelligent humor.",
       "Those who find ugly meanings in beautiful things are corrupt without \
       being charming.",
       "There are slow and repetitive parts, BUT it has just enough spice to \
       keep it interesting.",
       "The script is not fantastic, but the acting is decent and the cinematography \
       is EXCELLENT!",
       "Roger Dodger is one of the most compelling variations on this theme.",
       "Roger Dodger is one of the least compelling variations on this theme.",
       "Roger Dodger is at least compelling as a variation on the theme.",
       "they fall in love with the product",
       "but then it breaks",
       "usually around the time the 90 day warranty expires",
       "the twin towers collapsed today",
       "However, Mr. Carter solemnly argues, his client carried out the kidnapping \
       under orders and in the ''least offensive way possible.''"
    ]

    sentences.extend(tricky_sentences)
    sid = SentimentIntensityAnalyzer()
    for sentence in sentences:
        print(sentence)
        ss = sid.polarity_scores(sentence)
        for k in sorted(ss):
            print('{0}: {1}, '.format(k, ss[k]))
        print  

setupNLP()

# try: 
#     maxServer = OSC.OSCServer(('127.0.0.1', 6002))
#     maxServerThread = threading.Thread(target=maxServer.serve_forever)
#     maxServerThread.daemon = False
#     maxServerThread.start()

#     maxClient = OSC.OSCClient()
#     maxClient.connect(('127.0.0.1', 1234))

#     def sendOSCMessage( addr, *msgArgs):
#         msg = OSC.OSCMessage()
#         msg.setAddress(addr)
#         msg.append(*msgArgs)
#         maxClient.send(msg)


#     paradiseLostFull = open('paradiseLost.txt').read().replace('\r', "").split('\n')

#     def isTextLine(line):
#         return len([s for s in line if s in string.ascii_lowercase]) > 0

#     pdCleanedLines = [line for line in paradiseLostFull if isTextLine(line)]

#     lineCounter = 0

#     def getLine(addr, tags, stuff, source):
#         print 'sending new line', [pdCleanedLines[stuff[0]]]
#         sendOSCMessage("/nextLine", [pdCleanedLines[stuff[0]]])

#     maxServer.addMsgHandler("/getLine", getLine)

#     def closeServer(addr, tags, stuff, source):
#         maxServer.close()

#     maxServer.addMsgHandler("/close", closeServer)

# except:
#     print "closing"
#     maxServer.close()




# class LemurBounce2:
#     def __init__(self):
#         self.superColliderServer = OSC.OSCServer(('127.0.0.1', 7100))
#         self.SCServerThread = threading.Thread(target=self.superColliderServer.serve_forever)
#         self.SCServerThread.daemon = False
#         self.SCServerThread.start()

#         self.superColliderClient = OSC.OSCClient()
#         self.superColliderClient.connect(('127.0.0.1', 57120))

#         self.superColliderServer.addMsgHandler("/funcTrigger", self.funcTriggerResponder)

#         self.visualsServer = OSC.OSCServer(('127.0.0.1', 57121))
#         self.vizServerThread = threading.Thread(target=self.visualsServer.serve_forever)
#         self.vizServerThread.daemon = False
#         self.vizServerThread.start()

#         self.visualsClient = OSC.OSCClient()
#         self.visualsClient.connect(('127.0.0.1', 7400))

#         self.visualsServer.addMsgHandler("/hello", self.testResponder)
#         self.visualsServer.addMsgHandler("/toSC", self.toSCResponder)

#         self.printLog = False;

#         self.triggerFunctions = {}


#     def funcTriggerResponder(self, addr, tags, stuff, source):
#         if stuff[0] in self.triggerFunctions:
#             self.triggerFunctions[stuff[0]]()


#     def sendOSCMessage(self, addr, client=0, *msgArgs):
#         msg = OSC.OSCMessage()
#         msg.setAddress(addr)
#         msg.append(*msgArgs)
#         if (client == 0):
#             self.superColliderClient.send(msg)
#         else:
#             self.visualsClient.send(msg)

#     def toSCResponder(self, addr, tags, stuff, source):
#         address = stuff[0]
#         args = stuff[1:]
#         if self.printLog:
#             print address
#             print args
#         self.sendOSCMessage(address, 0, args)

#     def testResponder(self, addr, tags, stuff, source):
#         print stuff
#         self.sendOSCMessage('/test', 1, ['Did you get this message?', 'Didja?'])

