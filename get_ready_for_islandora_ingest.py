#!/usr/bin/env python

"""
prepares objects for ingest through the Islandora api rest ingestor. This is the third step in transfering files from archivematica to islandora, and comes after crosswalking the 
METS files from Archivematica to MODS for Islandora. This script creates numbered subdirectories for compound objects like newspapers, etc and create a simple mods file for each file
in the numbered subfolder with just the title field populated with information from the filename. All the files are renamed to OBJ as specified for the Islandora Rest Ingestor and empty directories
are deleted. 

"""

import os
import shutil
import fnmatch
import errno
import sys
import xml.etree.ElementTree as ET
import re
import sys
import argparse




def delete_mets(dirPath):
# removes METS files from directories
    for root, dirs, files in os.walk(dirPath):
         for name in files:
            if name.startswith('METS'):
                os.remove(os.path.join(root, name))

def find_sub_folders(dirPath):
    #finds complex and multi-page objects and makes individual sub folders for each file and adds a mods fine for each individual file
    pattern = dirPath + '/*/*'

    for root, dirs, files in os.walk(dirPath):
        for dirname in dirs:
            current_dir = (os.path.join(root, dirname))
            up_one_dir = (os.path.split(current_dir))[0]
            if fnmatch.fnmatch(current_dir, pattern):
                if os.listdir(current_dir):
                    list_of_files = os.listdir(current_dir)    
                    number_of_files = len(list_of_files)

                    if number_of_files < 2:
                        pass
                    else:   
                        folder_name = 0
                        while folder_name < number_of_files:
                                folder_name = folder_name + 1
                                numbered_sub_folder = up_one_dir + "/" +str(folder_name)
                                make_sub_folders(numbered_sub_folder)
                                current_file = list_of_files[folder_name - 1]
                                shutil.move(current_dir + "/" + current_file, numbered_sub_folder)
                                shutil.copy(up_one_dir + "/MODS.xml", numbered_sub_folder + "/MODS.xml")
                                #create_xml(current_file, numbered_sub_folder)
                                write_to_xml(current_file, numbered_sub_folder)
                                #print current_dir + "/" + list_of_files[folder_name - 1], numbered_sub_folder
                        shutil.rmtree(current_dir)


def make_sub_folders(new_dir_name):
# makes the numbered sub folders
   if not os.path.exists(new_dir_name):
        try:
            os.mkdir(new_dir_name, 0o777)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise

def write_to_xml(current_file, numbered_sub_folder):
# creates a title for the file in the subfolder using regex regular expressions to include either a string following a 
#capitalized word or a page number. This is not perfect so check the titles as they are printed out. Replaces the objects
#parent title with the title for filename in the MODS.xml. All other metadata stays the same.
    ns = {'mods' : 'http://www.loc.gov/mods/v3'}


    regex = '([A-Z])\w+[^.]*|p\d{2,3}|pg\d{2,3}'
    title_of_file = re.search(regex, current_file)
    print "the title of " + current_file + " is " + title_of_file.group(0)
    #read and write to the MODS.xml
    MD = ET.parse(numbered_sub_folder + "/MODS.xml")
    for prefix, uri in ns.iteritems():
            ET.register_namespace(prefix, uri)
    title = MD.find('mods:titleInfo/mods:title', ns)
    title.text = title_of_file.group(0)
    MD.write(numbered_sub_folder + '/MODS.xml')


def change_all_filenames(dirPath):
    #changes all filenames to OBJ.ext, as specified for ingest into Islandora by the Islandora Rest Ingestor
    new_file_name = 'OBJ'
    blacklist_ext = ['*.xml', '*.py', '*.xsl', '*.xpr']
    for root, dirs, files in os.walk(dirPath):
        for name in files:
            if fnmatch.fnmatch(name, '*.xml') or fnmatch.fnmatch(name, '*.py') or fnmatch.fnmatch(name, '*.xsl') or fnmatch.fnmatch(name, '*.xpr'):
                pass
            else:
                current_file = os.path.join(root, name)
                filepath = os.path.split(current_file)[0]
                current_ext = os.path.splitext(name)[1]
                #print "change " + current_file + "to " + filepath + '/' + new_file_name + current_ext
                try:
                    os.rename(current_file, filepath + '/' + new_file_name + current_ext)
                except OSError as e:
                    if e.errno != errno.EEXIST:
                        raise
                




def main():
    #this function controls the script
    
    #add parser arguments
    parser = argparse.ArgumentParser(description= 'arranges objects and associated metadata for ingest into islandora via the islandora rest ingestor')
    parser.add_argument('inputDirectory', help='Path to the input directory.')

    numArgs = len(sys.argv)

    if numArgs > 2:
        print "ERROR. Command takes one argument: the path to the input directory. The default is to assign the current directory as the input directory"
        parser.print_help()
        sys.exit()
    elif numArgs == 1:
        enteredPath = '.'
    else:
        enteredPath = sys.argv[1]
        
        if not os.path.exists(enteredPath):
            print 'Filepath does not exist'
            parser.print_help()
            sys.exit()
        elif not os.path.isdir(enteredPath):
            print 'Filepath is not a directory'
            parser.print_help()
            sys.exit()
    
    #normalize path name
    dirPath = os.path.abspath(enteredPath)
    
    delete_mets(dirPath)
    find_sub_folders(dirPath)
    change_all_filenames(dirPath)



if __name__ == "__main__":
    main()