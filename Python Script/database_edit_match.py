import sys
import sqlite3
import scipy.io
import hdf5storage
import numpy as np
from shutil import copyfile
from optparse import OptionParser
from pdb import set_trace as bp

def opening():
    parser = OptionParser()
    parser.add_option("--input_database", type="string", dest="databasetoEdit",
        help="The source database")
    parser.add_option("--output_database", type="string", dest="newdatabase",
        help="The name of the new version of the database")
    parser.add_option("--threshold_inlier", type="int", dest="threshold",
        help="Will discard all the matches and inlier matches if it has less than --threshold_inlier number of inlier matches")
    parser.add_option("--top_inlier", type="int", dest="topN",
        help="Will only keep --top_inlier connection based on number of inlier matches of each image")
    parser.add_option("--sequential_overlap", type="int", dest="overlap",
        help="Will keep the image connection based on the sequential matching algorithm")
    (options, args) = parser.parse_args()
    if options.databasetoEdit is None or options.newdatabase is None:
        print "please fill --input_database and --output_database"
        quit()

    which = [options.threshold is not None, options.topN is not None, options.overlap is not None]
    idx = [idx for idx, val in enumerate(which) if val is True]
    if len(idx) == 0:
        print "please select your method of editing matches. -h might help you" 
        quit()
    elif len(idx) > 1:
        print "please select only one method of editing matches. -h might help you"
        quit()

    if idx[0]==0:
        threshold = options.threshold
        topN = 0
        overlap = 0
    elif idx[0]==1:
        threshold = 0
        topN = options.topN
        overlap = 0
    elif idx[0]==2:
        threshold = 0
        topN = 0
        overlap = options.overlap
    else:
        print "Something wrong. Sorry"
        quit()

    print "Coppying ", options.databasetoEdit, " to a new file"
    print "Please wait. Big file may take longer to copy"
    copyfile(options.databasetoEdit, options.newdatabase)
    print "Copy finish"
    
    return options.newdatabase, threshold, topN, overlap

def thresholdMethod(database, threshold):
    print "Opening database..."
    conn = sqlite3.connect(database)
    c = conn.cursor()
    print "Database opened successfuly"
    print "Removing pair with matches less than", threshold
    c.execute("select pair_id from inlier_matches where 1")
    dataPair_id = c.fetchall()
    dataPair_id = np.asarray(dataPair_id, dtype=None)
    c.execute("select rows from inlier_matches where 1")
    dataRow = c.fetchall()
    dataRow = np.asarray(dataRow, dtype=None)
    for idx, row in enumerate(dataRow):
        if row[0] is 0 or row[0] < threshold:
            c.execute("delete from inlier_matches where pair_id=?", [dataPair_id[idx][0]])
            c.execute("delete from matches where pair_id=?",[dataPair_id[idx][0]])
    conn.commit()
    conn.close()
    print "Finish. Check your new database"

def pair_id_to_image_ids(pair_id):
    image_id2 = pair_id % 2147483647
    image_id1 = (pair_id - image_id2) / 2147483647
    return image_id1, image_id2

def image_ids_to_pair_id(image_id1, image_id2):
    if image_id1 > image_id2:
        return 2147483647 * image_id2 + image_id1
    else:
        return 2147483647 * image_id1 + image_id2

def sequential(database, overlap):
    print "Opening database..."
    conn = sqlite3.connect(database)
    c = conn.cursor()
    c.execute("select pair_id from inlier_matches where 1")
    dataPair_id = c.fetchall()
    dataPair_id = np.asarray(dataPair_id, dtype=None)
    c.execute("select rows from inlier_matches where 1")
    dataRow = c.fetchall()
    dataRow = np.asarray(dataRow, dtype=None)
    c.execute("select image_id from images where 1")
    dataImages_id = c.fetchall()
    dataImages_id = np.asarray(dataImages_id, dtype=None)
    image_length = len(dataImages_id)
    side = (overlap-1)/2
    Adj = np.triu(np.ones(image_length),-side)
    Adj = Adj - np.triu(np.ones(image_length),side+1)
    for x in range(0,image_length):
        query_ids = x+1
        delete_index = Adj[x,:] == 0
        to_delete = dataImages_id[delete_index]
        for y in to_delete:
            if y == query_ids:
                continue
            else:
                pair_id = image_ids_to_pair_id(query_ids,y)
                if 'ndarray' in str(type(pair_id)):
                    pair_id = pair_id[0]
                c.execute("delete from inlier_matches where pair_id = ?",[pair_id])
                c.execute("delete from matches where pair_id = ?",[pair_id])
    conn.commit()
    print "Finish. Please check your new database."



def topNmethod(database, topN):
    print "Opening database..."
    conn = sqlite3.connect(database)
    c = conn.cursor()
    print "Database opened successfuly"
    print "Doing some magic..."
    c.execute("select pair_id from inlier_matches where 1")
    dataPair_id = c.fetchall()
    dataPair_id = np.asarray(dataPair_id, dtype=None)
    c.execute("select rows from inlier_matches where 1")
    dataRow = c.fetchall()
    dataRow = np.asarray(dataRow, dtype=None)
    c.execute("select image_id from images where 1")
    dataImages_id = c.fetchall()
    dataImages_id = np.asarray(dataImages_id, dtype=None)
    matchDataMatrix = np.zeros((len(dataImages_id),len(dataImages_id)))
    for idx, row in enumerate(dataPair_id):
        image1, image2 = pair_id_to_image_ids(row[0])
        matchDataMatrix[image1-1, image2-1] = dataRow[idx][0]
    matchDataMatrix = np.triu(matchDataMatrix) + np.transpose(np.triu(matchDataMatrix, 1))
    
    for x in range(0,matchDataMatrix.shape[0]):
        rowmatchDataMatrix = matchDataMatrix[x, :]
        sortIndex = np.argsort(rowmatchDataMatrix)
        sortIndex = sortIndex[0:len(dataImages_id)-topN-1]
        for y in sortIndex:
            pair_id = image_ids_to_pair_id(x+1,y+1)
            c.execute("delete from inlier_matches where pair_id = ?",[pair_id])
            c.execute("delete from matches where pair_id = ?",[pair_id])
    
    conn.commit()
    print "Finish. Please check your new database."


def main():
    database, threshold, topN, overlap = opening()
    if topN is not 0:
        topNmethod(database, topN)
    elif threshold is not 0:
        thresholdMethod(database, threshold)
    elif overlap is not 0:
        sequential(database,overlap)

if __name__ == '__main__':
    main()