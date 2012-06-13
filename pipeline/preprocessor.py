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

    # get datfile option, example: -f /full/path/to/sample.dat        
    for o, a in opts:
        if o in ("-f", "--file"):
            datfile = str(a)

    if not datfile.endswith('.dat'):
        print "ERROR: *.dat file is expected as input file."
        sys.exit(2)

    processDatFile(datfile)


def processDatFile(datfile):
  
    print '#--------- autorg ------------------#'
    process = subprocess.Popen(['autorg', '-f', 'ssv', datfile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, errorOutput) = process.communicate()
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
    outfile = datfile.replace('.dat', '.out')
    process = subprocess.Popen(['datgnom', '-r', str(rg), '-s', str(skip), '-o', outfile, datfile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, errorOutput) = process.communicate()
    # Output file: gnom .out file
    print output
      
    print '#--------- datporod ----------------#' 
    process = subprocess.Popen(['datporod', outfile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, errorOutput) = process.communicate()
    print output
  
    print '#--------- dammif in slow mode -----#'
    # copy .out file
    if datfile.endswith('.dat'):
        filename = datfile[:-4] #example: filename = "/path/sample" if input file is /path/sample.dat
    dammif_outfile = str(filename) + "_dammif.out" #example: dammif_outfile = "/path/sample_dammif.out" if input file is /path/sample.dat
    shutil.copyfile(outfile, dammif_outfile)
    # dammif modelling
    dammif_slow_outfile_prefix = str(filename) + "_0" #example: dammif_slow_outfile_prefix = "/path/sample_0" if input file is /path/sample.dat
    process = subprocess.Popen(['dammif', '--prefix=%s' % dammif_slow_outfile_prefix, '--mode=slow', '--symmetry=P1', '--unit=n', dammif_outfile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, errorOutput) = process.communicate()
    # remove random seed line from "/path/sample_0.in" output file if input file is /path/sample.dat
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
        