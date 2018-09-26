#!/usr/bin/env python

"""
takes DIPs extracted from Archivematica via the create DIPs automation tools, and extracts the zips. 
All the files, except for the objects files and METS are deleted.

""" 

import zipfile
import os
import shutil
import sys
import argparse
                    


def move_zip(dirPath):
# move zip files to main directory
    for root, dirs, files in os.walk(dirPath):

        for name in files:
            if name.endswith(".zip"):
                try:
                    shutil.move(os.path.join(root, name), os.path.join(dirPath, name))
                except OSError as e:
                    if e.errno != errno.EEXIST:
                        raise



def delete_org_dirs(dirPath):
#deletes the original directories and contents
    for root, dirs, files in os.walk(dirPath):
        for name in dirs:
            shutil.rmtree(os.path.join(root, name))

def extract_zips_here(dirPath):
#extracts the zip files in the root directory       
    for root, dirs, files in os.walk(dirPath):
        for name in files:
            if name.endswith(".zip"):
                print "extracting" + os.path.join(root, name)
                zip=zipfile.ZipFile(os.path.join(root, name))
                zip.extractall(dirPath)

def delete_zip(dirPath):
#deletes the zip file    
    for root, dirs, files in os.walk(dirPath):
        for name in files:
            if name.endswith(".zip"):
                os.remove(os.path.join(root, name))

        


def delete_submissionDocumentation_dirs(dirPath):
#deletes the submission documentation text files        
    for root, dirs, files in os.walk(dirPath):
        for name in dirs:   
            if name == "submissionDocumentation":
                shutil.rmtree(os.path.join(root, name))



def main():
    #this function controls the script
    parser = argparse.ArgumentParser(description= 'unzips and arranges DIPs exported from Archivematica')
    parser.add_argument('inputDirectory', help='Path to the input directory.')

    numArgs = len(sys.argv)

    if numArgs > 2:
        print "ERROR. Command takes one argument: the path to the input directory. The default is to assign the current directory as the input directory"
        parser.print_help()
        sys.exit()
    elif numArgs == 1:
        dirPath = '.'
    else:
        dirPath = sys.argv[1]
        
        if not os.path.exists(dirPath):
            print 'Filepath does not exist'
            parser.print_help()
            sys.exit()
        elif not os.path.isdir(dirPath):
            print 'Filepath is not a directory'
            parser.print_help()
            sys.exit()
    
           
    move_zip(dirPath)
    delete_org_dirs(dirPath)
    extract_zips_here(dirPath)
    delete_zip(dirPath)
    delete_submissionDocumentation_dirs(dirPath)       




if __name__ == "__main__":
    main()







