# -*- coding: utf-8 -*-
"""
Created on Sat Mar 17 18:19:27 2018

@author: Puneeth Gandla, Roll No - 17BM6JP35
Course : Information Retrieval(CS60092), Assignment 2
"""

#### write function based on threshold, method and Topic
#def get)summary(topic, algorithm, threshold)
#get_summary(threshold = 0.1, method = 'degree_centrality', topic = 'topic3')



###############################################################################
# Inputs required :
topic = 'Topic1' # Topics - 'Topic1', 'Topic2', 'Topic3', 'Topic4', and 'Topic5'
algorithm = 'text_rank' # algorithms - 'degree_centrality' and 'text_rank'
threshold = 0.3 # possible thresholds - 0.1, 0.2 and 0.3 
###############################################################################



# Run the rest of the code to get output printed

# load libraries
from bs4 import BeautifulSoup # import beautiful soup to read files
from pathlib import Path
#import networkx as nx
from sklearn.feature_extraction.text import TfidfTransformer, CountVectorizer
from rouge import Rouge # import Rouge package to calculate scores
import numpy as np


# define function 'getText' to read text/sentences from files
def getText(path_in_str):
    file_open = open(path_in_str, encoding = 'utf-8') # open each file 
    file_read = file_open.read() # read each file
    file_open.close() # close each file
    soup = BeautifulSoup(file_read, "lxml").find_all('p') # get content for attributes 'p'
    sentences = [] # initialize string
    for i in soup: # for loop to read all senteces with attribute 'p'
        sentences.append(i.text.strip()) # strip and get text
    sentences = ' '.join(sentences).replace('\n', ' ') # join the sentences and remove "/n"
    return sentences

# provide link to directory in which inputs files exist
dir_path = 'D:/DA/PGDBA/IIT/CS60092_INFORMATION_RETRIEVAL/ass/assignment_2/'
directory_in_str = dir_path + topic # path to the particualr topic
pathlist = Path(directory_in_str).glob('*') # read all files in this directory
result = [] # initialize string

for path in pathlist:
    path_in_str = str(path) # convert path into string object
    result.append(getText(path_in_str)) # combile sentences from all files
result = ''.join(result).replace('\n', ' ') # join the sentences and remove '\n'



# Tokenize the sentences
from nltk.tokenize import sent_tokenize
sentences = sent_tokenize(result) # returns list of all sentences


# Build tf-idf matrix for all these sentences
# step 1 - construct matrix with rows as sentences and each columns as a word
count_matrix = CountVectorizer().fit_transform(sentences) 
# step 2 - using this count matrix create tf-idf matrix and normalize it
# tf-idf(d, t) = tf(t) * idf(d, t); idf(d, t) = log [ n / df(d, t) ] + 1
# where n is the total number of documents; df(d, t) is the document frequency
# and tf(t) is the term frequency
# And the document frequency is the number of documents d that contain term t
normalized = TfidfTransformer().fit_transform(count_matrix)


# construct similarity graph from normalized tf-idf matrix
# multiply matrix with its transpose
#similarity_matrix = normalized * normalized.T

# convert the existing sparse 'normalized' matrix to its dense form
normalized_dense = normalized.todense()
# compute similarity matrix using the normalized matrices
similarity_matrix = normalized_dense * normalized_dense.T

# check for 'nan' values in the similarity matrix, if any
np.argwhere(np.isnan(similarity_matrix)) # no nan values found in this matrix


# Create adjacency matrix based on the similarity between sentences such that, 
# if the similarity is greater than threshold value, replace with '1'. 
# If not, replace with '0'.

num_sent = len(sentences) # total number of sentences 
adj_matrix = np.zeros((num_sent, num_sent)) # initialize adjacency matrix
for row in range(num_sent):
    for col in range(num_sent):
        if  similarity_matrix[row, col] >= threshold:
            adj_matrix[row, col] = 1
        else :
            adj_matrix[row, col] = 0
# adjacency matrix - 'adj_matrix' is created 

# convert 'adjacency matrix' into 'transition matrix'
#diagonal_entries = [sum(adj_matrix[row]) for row in range(adj_matrix.shape[0])]
#np.where(diagonal_entries == 0)[0] # check if degree of any sentence is zero
#D = np.diag(diagonal_entries)
#D_inv = np.linalg.inv(D)
#trans_matrix = np.dot(adj_matrix, D_inv)
    # transition matrix = Adjacency matrix / Degree of each sentence

np.seterr(divide='ignore', invalid='ignore') 
    # ignore warnings due to 'nan' elements in the matrix
    # this issue is resolved in the following lines..
trans_matrix = adj_matrix/adj_matrix.sum(axis=1, keepdims=True)


# Check if transition matrix is a stochastic matrix
# Check if any row of transition matrix has 'nan' elements in them (shouldn't happen)
# if so, delete these sentences from the original list of sentences
# Also, check if sum of any row is zero (shouldn't happen)
sum_rows = np.array([sum(trans_matrix[row]) for row in
                     range(trans_matrix.shape[0])])

zero_sent = np.where(sum_rows == 0)[0] # rows/sentences with zero similarities
nan_sent = np.where(np.isnan(sum_rows))[0] # rows/sentences with 'nan' values
del_sent =  np.concatenate([zero_sent, nan_sent]) # all sentences to be deleted
for i in sorted(del_sent, reverse=True): # delete the sentences
    del sentences[i]
    # delete rows/sentences which cause 'nan' elements in transition matrix


# repeat procedure to determine transition matrix with modified sentence list
count_matrix = CountVectorizer().fit_transform(sentences) 
normalized = TfidfTransformer().fit_transform(count_matrix)
normalized_dense = normalized.todense()
similarity_matrix = normalized_dense * normalized_dense.T
np.argwhere(np.isnan(similarity_matrix)) # no nan values found in this matrix
num_sent = len(sentences) # total number of sentences 
adj_matrix = np.zeros((num_sent, num_sent)) # initialize adjacency matrix
for row in range(num_sent):
    for col in range(num_sent):
        if  similarity_matrix[row, col] >= threshold:
            adj_matrix[row, col] = 1
        else :
            adj_matrix[row, col] = 0
trans_matrix = adj_matrix/adj_matrix.sum(axis=1, keepdims=True)
    # transition matrix with modified sentence list is created

sum_rows = np.array([sum(trans_matrix[row]) for row in
                     range(trans_matrix.shape[0])])
zero_sent = np.where(sum_rows == 0)[0] # rows/sentences with zero similarities
nan_sent = np.where(np.isnan(sum_rows))[0] # rows/sentences with 'nan' values
del_sent =  np.concatenate([zero_sent, nan_sent]) # all sentences to be deleted
len(del_sent) # this transition matrix is a stochastic matrix as sum of
#  each row is '1' and there are no rows with 'nan' values


# Power method to calculate eigen vector of transition matrix and hence 
# text-rank of all the sentences
M = trans_matrix # stochastic matrix
N = trans_matrix.shape[0] # matrix size (N x N)
tolerance = 1E-10 # to achieve convergence for power method

# Power method to solve for largest eigen vector of transition matrix based on 
# tolerance value
eigen_vector = np.ones(N)/N # initialize eigen vector
delta = tolerance/10 # initialize with value less than tolerance
i = 1

while delta < tolerance: # till the tolerance value is reached
    pt = M.dot(eigen_vector)/np.linalg.norm(eigen_vector) 
    # matrix vector multiplication and normalize
    delta = np.linalg.norm(pt - eigen_vector) # gain vector
    eigen_vector = pt # assign new value to variable 'eigen_vector'
    i += 1
i
eigen_vector

# Another way to solve for largest eigen vector of transition matrix using 
# power method using a function and stop loop based on 
# number of iterations to run
def power_method(mat, start, maxit):
    eigen_vector = start
    for i in range(maxit):
        eigen_vector = mat.dot(eigen_vector)/np.linalg.norm(eigen_vector)
    return eigen_vector

eigen_vector = power_method(mat = M, start = eigen_vector, maxit = 100000)


# elements of this 'largest_eigen_vector' represent the respective tex-rank of 
# the sentences
# return indices/sentence IDs of the 'largest_eigen_vector' based on their score 
text_rank = eigen_vector.argsort()
#top_10 = text_rank[0:9] # top 10 sentence IDs
ranked_text = ' '.join([sentences[i] for i in text_rank])# sentences in ranked order.
    # join the sentences in the ranked order to for summary 

# Extract the 250 word summary and print it
smry_txt_rank = ' '.join(ranked_text.split()[:250]) # 250-word summary
print(' ' + '\n' + 
      'Summary of ' + topic + ' based on ' + algorithm + 
      ' algorithm and using threshold of ' + str(threshold) + ' :' + 
      '\n' +
      '##########################' + '\n' + smry_txt_rank + '\n' 
      + '##########################')


# Read ground truth
path_ground_truth = dir_path + 'GroundTruth/' + topic + '.1'
smry_ground_truth = getText(path_ground_truth)


# Evaluate generated summaries and print them
rouge = Rouge()
scores_txt_rank = rouge.get_scores(smry_ground_truth, smry_txt_rank)[0]
print('Rouge scores for the summary are :' + '\n' + 
      '##########################'  + '\n' + 
      'Rouge-1 f-score is ' + str(scores_txt_rank['rouge-1']["f"])  + '\n' + 
      'Rouge-1 p-score is ' + str(scores_txt_rank['rouge-1']["p"])  + '\n' + 
      'Rouge-1 r-score is ' + str(scores_txt_rank['rouge-1']["r"])  + '\n' + 
      'Rouge-2 f-score is ' + str(scores_txt_rank['rouge-2']["f"])  + '\n' + 
      'Rouge-2 p-score is ' + str(scores_txt_rank['rouge-2']["p"])  + '\n' + 
      'Rouge-2 r-score is ' + str(scores_txt_rank['rouge-2']["r"])  + '\n' + 
      'Rouge-l f-score is ' + str(scores_txt_rank['rouge-l']["f"])  + '\n' + 
      'Rouge-l p-score is ' + str(scores_txt_rank['rouge-l']["p"])  + '\n' + 
      'Rouge-l r-score is ' + str(scores_txt_rank['rouge-l']["r"])  + '\n' + 
      '##########################')


# save scores into a file



# function to implement textrank algorithm
#def textrank(document):
#    
#    # Sentence Splitting
#    sentences = sent_tokenize(result) # this gives us a list of sentences
# 
#    # Build tf-idf vectors and construct the graph
#    count_matrix = CountVectorizer().fit_transform(sentences)
#    normalized = TfidfTransformer().fit_transform(count_matrix)
#    
#    similarity_matrix = normalized * normalized.T
#    
#    # Pagerank
#    nx_graph = nx.from_scipy_sparse_matrix(similarity_matrix)
#    scores = nx.pagerank(nx_graph)
#    return sorted(((scores[i],s) for i,s in enumerate(sentences)),
#                  reverse=True)