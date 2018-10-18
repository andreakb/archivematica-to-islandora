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

def redirect_to_file(text, dirPath):
# add title change statement to a log   
    original = sys.stdout
    sys.stdout = open(dirPath + '/title_log.txt', 'a')
    print(text)
    sys.stdout = original
    print text


def delete_mets(dirPath):
# removes METS files from directories
    for root, dirs, files in os.walk(dirPath):
         for name in files:
            if name.startswith('METS'):
                os.remove(os.path.join(root, name))

def find_sub_folders(dirPath, theses):
    #finds compound and multi-page objects and makes individual sub folders for each file and adds a mods fine for each individual file
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
                        break
                    else:   
                        folder_name = 0
                        while folder_name < number_of_files:
                                folder_name = folder_name + 1
                                numbered_sub_folder = up_one_dir + "/" +str(folder_name)
                                make_sub_folders(numbered_sub_folder)
                                current_file = list_of_files[folder_name - 1]
                                shutil.move(current_dir + "/" + current_file, numbered_sub_folder)
                                shutil.copy(up_one_dir + "/MODS.xml", numbered_sub_folder + "/MODS.xml")
                                write_to_xml(current_file, numbered_sub_folder, theses, dirPath)
                        shutil.rmtree(current_dir)


def make_sub_folders(new_dir_name):
# makes the numbered sub folders
   if not os.path.exists(new_dir_name):
        try:
            os.mkdir(new_dir_name, 0o777)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise

def write_to_xml(current_file, numbered_sub_folder, theses, dirPath):
# creates a title for the file in the subfolder using regex regular expressions to include either a string following a 
#capitalized word or a page number. This is not perfect so check the titles as they are printed out. Replaces the objects
#parent title with the title for filename in the MODS.xml. All other metadata stays the same. 
#TO DO: MAKE GENRE/CMODEL/PATTERN A DICTIONARY; MAKE XML HANDLING A CLASS 
    ns = {'mods' : 'http://www.loc.gov/mods/v3',
          'edt' :  'http://www.ndltd.org/standards/metadata/etdms/1.0'}
    #regular expression to find words in a filename to change to a tile
    #title_regex = '([A-Z])\w+[^.]*|p\d{2,3}|pg\d{2,3}'
    title_regex = '([A-Z])\w+[^.]*|p\d{2,3}|pg\d{2,3}(?!_)'
    #pattern for title of RPI thesis file derived from Proquest deliveries
    thesis_pattern = '*_rpi_*.pdf'
    #name of thesis content model in Islandora
    thesis_text = "ir:thesisCModel" 

    
    title_of_file = re.search(title_regex, current_file)
    redirect_to_file("the title of " + current_file + " is " + title_of_file.group(0), dirPath)
    #read and write to the MODS.xml
    MD = ET.parse(numbered_sub_folder + "/MODS.xml")
    for prefix, uri in ns.iteritems():
            ET.register_namespace(prefix, uri)
    title = MD.find('mods:titleInfo/mods:title', ns)
    title.text = title_of_file.group(0)
    MD.write(numbered_sub_folder + '/MODS.xml')
    # handles compound objects that are theses by adding a cmodel.txt to the directory of a thesis pdf and changing the title of the file to thesis
    if theses == True:
        if fnmatch.fnmatch(current_file, thesis_pattern):
            title.text = 'thesis'
            MD.write(numbered_sub_folder + '/MODS.xml')
            redirect_to_file("changing title of " + title_of_file.group(0) + " to " + title.text, dirPath)
            cmodel_dot_txt = open(numbered_sub_folder + "/cmodel.txt", "w")
            cmodel_dot_txt.write(thesis_text)
            cmodel_dot_txt.close()


def change_all_filenames(dirPath):
    #changes all filenames to OBJ.ext, as specified for ingest into Islandora by the Islandora Rest Ingestor
 
    new_file_name = 'OBJ'
    # the blacklist filenames and extenstions won't be changed to OBJ.ext
    blacklist = ['MODS.xml', 'cmodel.txt', '*.py', '*.xsl', '*.xpr', 'title_log.txt', '*.md']
    for root, dirs, files in os.walk(dirPath):
        for name in files:
            for ignorable in blacklist:
                if fnmatch.fnmatch(name, ignorable):
                    break
            else:
                current_file = os.path.join(root, name)
                filepath = os.path.split(current_file)[0]
                current_ext = os.path.splitext(name)[1]
                try:
                    os.rename(current_file, filepath + '/' + new_file_name + current_ext)
                except OSError as e:
                    if e.errno != errno.EEXIST:
                        raise
                




def main():
    #this function controls the script
    parser = argparse.ArgumentParser(description= 'arranges objects and associated metadata for ingest into islandora via the islandora rest ingestor')
    #parser.add_argument('inputDirectory', help='Path to the input directory.')
    parser.add_argument('--input', '-i', default='.', help='Path to the input directory. Default is the current directory')
    parser.add_argument('--theses', '--thesis','-t', default=False, help='flags objects in directory as theses', action="store_true")
    

    args = parser.parse_args()
    
    if not os.path.exists(args.input):
        print 'Filepath does not exist'
        parser.print_help()
        sys.exit()
    elif not os.path.isdir(args.input):
        print 'Filepath is not a directory'
        parser.print_help()
        sys.exit()
    #normalize path name
    dirPath = os.path.abspath(args.input)

    
    delete_mets(dirPath)
    find_sub_folders(dirPath, args.theses)
    change_all_filenames(dirPath)



if __name__ == "__main__":
    main()