#Average Degree of Tweets Hashtag Graph:

  The purpose of the program is to form a graph of hashtags and to compute the average degree (total degree/ number of vertices) for a given time window. But before doing this tweets have to be cleaned so that it has only ascii characters and no escape sequences, for simplicity tabs and new-line characters are converted into single space.
  
  As per requirement this is split into 2 scripts (1) To clean the inout tweets and print the number that is dirty at the end (2) Forms a graph with tweets over the given time window and prints the average degree for every new tweet. There are few assumptions in forming our graph:
1. There are no self links. 
2. The graph is not weighted i.e. two inputs #A #B and #A and #B has no effect on the graph (except updating the times)
3. The graph system in mainted for tweets only in the time-windows. This is done just to save memory but can be easily modified.
4. Solution should be single-threaded.
  
  With these assumptions in mind the same graph is represented using 2 structures (1) Adjacency matrix (2) Time graph.

##Adjacency Matrix:
  As per assumption (1) adj matrix is represented as an array of vertices pair vs time in epoch (instead of weight coz the graph not weighted). So for an input tweet that has 3 hash tags "#A #B #C" on time "Thu Oct 29 17:51:50 +0000 2015" then there will be 3 entries in the data-structure 
  '''
        #A#B = 1446141110 
        #A#C = 1446141110 
        #B#C = 1446141110
  '''
  At any given point the degree of the graph is 2 times the no of entries in out adj matrix structure and the avg degree is (2 * 3)/3 = 6. 
  So now if a new entry "#A #C #D" comes on time "Thu Oct 29 17:51:51 +0000 2015". As per assumption (1) and (2) the adj matrix has the following entries:
        #A#B = 1446141110
        #A#C = 1446141111 (updated time, no duplicates)
        #B#C = 1446141110
        #C#D = 1446141111
  Now the degree is 4 * 2 = 8 and avg is 8 / 4 = 2.
  
##Time Graph:
  Theoritically time graph is one graph per time bucket (bucket = min time unit of measure of input, 1 second in this case). So for entry "#A #B #C" on time "Thu Oct 29 17:51:50 +0000 2015" the time graph is:
        1446141110 = [#A#B, #A#C, #B#C]
  And for the new input "#A #C #D" on time "Thu Oct 29 17:51:51 +0000 2015":
        1446141110 = [#A#B, #B#C]
        1446141111 = [#A#C, #C#D]
  making the degree same for both representations.
  
##Need for 2 Strucutres:
  We need 2 strucutres because of assumption (3). We need to maintain vertices that fall into the time frame window and purge rest of them from the graph. This is done by recording last tweet arrival time. To find this we use our time graph and sync adj matrix. Also as per assumption (2) new vettex combination if already exists should get an update in time, this is done using adj matrix and then moving the entry from one time to another in time graph.
  
##Scalability:
  The program is written to run on a single thread as per assumption (4), but can be easily extended to run on multi-threads or in a distributed system. The model supports a function called "combine" that can be used to combine multiple graph systems into one for a fraction of time take to create one. So multi threaded or a distributed system we can split the input feeds across multiple program and then combine them into one at the end, to get the unified avg degree.
  
##Execution:
  To execute the program run "run.sh" from the higher level directory this reads the tweets.txt file from tweets_input directory and produces 2 output files in tweets_output directory. 
  "tests" directory has both unit tests and scalability tests. tests.sh executes all of them and displays the result on screen.
  
