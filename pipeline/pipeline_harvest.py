#!/usr/bin/python

import getopt
import glob
import sys
import zmq

def main():
    prefix = ""
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], "p:", ["prefix"])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)

    # get prefix option, example: -p /data_home/user_epn/user_exp/analysis/sample        
    for o, a in opts:
        if o in ("-p", "--prefix"):
            prefix = str(a)

    harvestPDBFile(prefix)


def harvestPDBFile(prefix):
    
    file_list = glob.glob(prefix + '*-1.pdb')
    search = 'Total excluded DAM volume'
    for file_path in file_list:
        pdbfile = open(file_path, 'r')
        for line in pdbfile:
            if line.find(search) > -1:
                # extract value
                value = line.split(':')[1].strip(' ')
                # debug codes
                outfile = open(file_path+'.txt', 'w')
                outfile.write(value)
                outfile.close()
                # save value to database

                #To send data to the database, something like this is required.
                #Where values reside in the database, and the connection string need to be finalised
                context = zmq.Context()
                pub = context.socket(zmq.PUB)
                pub.connect("tcp://127.0.0.1:1998")
                pub.send_pyobj({"command":"insert_DAM", "value":value})
                pub.close()
                
                
                break
        pdbfile.close()
        

def usage():
    print 'Usage: %s [OPTIONS] -p /data_home/user_epn/user_exp/analysis/sample  \n' % (sys.argv[0])
    print '''
-p --prefix    Prefix to prepend to output filenames (*-1.pdb). Should include 
               absolute paths, all directory components must exist.


'''
  

if __name__ == "__main__":
    main()
        