#!/usr/bin/python


import getopt
import shutil
import subprocess
import sys


def main():
    datfile = ""
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], "f:", ["file"])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
        
    for o, a in opts:
        if o in ("-f", "--file"):
            datfile = a

    processDatFile(datfile)


def processDatFile(datfile):
  
    print '#--------- autorg ------------------#'
    
    process = subprocess.Popen(['autorg', '-f', 'ssv', str(datfile)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,errorOutput = process.communicate()
    print output
        
    print '#--------- datgnom -----------------#'     
    valuePoints = output.split(" ")
    rg = valuePoints[0]
    skip = valuePoints[4]
    try:
        skip = int(skip)
        skip = skip - 1
    except ValueError:
        print "Error happened when converting skip value into integer."
    process = subprocess.Popen(['datgnom', '-r', str(rg), '-s', str(skip), str(datfile)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,errorOutput = process.communicate()
    # Output file: gnom .out file
    print output
      
    print '#--------- datporod ----------------#' 
    filename = datfile.split(".")[0]
    outfile = str(filename) + ".out"
    process = subprocess.Popen(['datporod', outfile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,errorOutput = process.communicate()
    print output
  
    print '#--------- dammif_slow -------------#'
    # dammif modelling in slow mode
    # duplicate .out file
    dammif_outfile = str(filename) + "_dammif.out" #example: sample_dammif.out
    shutil.copyfile(outfile, dammif_outfile)
    # dammif 
    dammif_slow_outfile_prefix = str(filename) + "_0" #example: sample_0
    process = subprocess.Popen(['dammif', '--prefix=%s' % dammif_slow_outfile_prefix, '--mode=slow', '--symmetry=P1', '--unit=n', dammif_outfile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,errorOutput = process.communicate()
    # remove random seed line from .in file, example: sample_0.in
    dammif_slow_infile = '%s.in' % dammif_slow_outfile_prefix
    lines = open(dammif_slow_infile, 'r').readlines()
    new_lines = []
    for line in lines:
        if (line.find('initial random seed') != -1):
            new_lines.append('\n')
        else:
            new_lines.append(line)
    open(dammif_slow_infile, 'w').writelines(new_lines)



def usage():
    print 'Usage: %s [OPTIONS] -f filename.dat \n' % (sys.argv[0])
    print '''
-f --file      DAT file name which is the full name of file to be used for models.


'''
  

if __name__ == "__main__":
    main()
        