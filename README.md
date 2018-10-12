# archivematica-to-islandora



This is a series of scripts that massage DIPs extracted from Archivematica via the [DIP creation automation tools](https://github.com/artefactual/automation-tools#dip-creation) into the structure required for ingest into Islandora via the [Islandora Rest Ingestor](https://github.com/SFULibrary/islandora_rest_ingester) This is a prototype workflow for a proof-of-concept.

###  step 1: extract zips

`extract_zips.py` extracts the zip in the DIP that is exported from Archivematica  and deletes everything except for the object files and METs files. The resulting structure looks like this:

```
main-directory/
|---single-object/
|	|--obj.tif
|	|--METS.xml
|---complex-object/
|	|--foo/
|	|	|--obj.tif
|	|	|--obj.png
|	|	|--obj.pdf
|	|--METS.xml
|---newspaper-issue/
|	|--bar/
|	|	|--p1.tif
|	|	|--p2.tif
|	|	|--p3.tif
|	|--METS.xml
```

### step 2: transform METS to MODS

`mets_to_mods.xsl` is a xslt file that transforms the archivematica METS.xml to MODS.xml. I use this xslt file in [Oxygen XML Editor](https://www.oxygenxml.com/) as part of a transformation scenario.

### step 3:  massage folder structure for ingest into Islandora

`get_ready_for_islandora_ingest.py` alters the folder structure for ingest into Islandora. It takes two optional arguments" `--input[/path/to/dir]` to enter the path to the input directory, and `--theses`, which flags that objects in directory are theses. The script is written to assume that, after the first two steps, the folder structure looks like this:

```
main-directory/
|---single-object/
|	|--obj.tif
|	|--METS.xml
|	|--MODS.xml
|---complex-object/
|	|--foo/
|	|	|--obj.tif
|	|	|--obj.png
|	|	|--obj.pdf
|	|--METS.xml
|	|--MODS.xml
|---newspaper-issue/
|	|--bar/
|	|	|--p1.tif
|	|	|--p2.tif
|	|	|--p3.tif
|	|--METS.xml
|	|--MODS.xml
```

The script  deletes the METS.xml files, creates a seperate subfolder and MODS.xml for each file in a complex object. The seperate MODS.xml files are the same as the MODS.xml files for the entire object, except the title field is derived from the filename using regular expressions. All the filenames(except for the MODS.xml files) are changed to OBJ.ext. The resulting folder structure looks like this:

```
main-directory/
|---single-object/
|	|--OBJ.tif
|	|--MODS.xml
|---complex-object/
|	|--foo/
|	|	|--1/
|	|	|	|--OBJ.tif
|	|	|	|--MODS.xml
|	|	|--2/
|	|	|	|--OBJ.png
|	|	|	|--MODS.xml
|	|	|--3/
|	|	|	|--OBJ.pdf
|	|	|	|--MODS.xml
|	|--MODS.xml
|---newspaper-issue/
|	|--bar/
|	|	|--1/
|	|	|  |--OBJ.tif
|	|	|  |--MODS.xml
|	|	|--2/
|	|	|	|--OBJ.tif
|	|	|	|--MODS.xml
|	|	|--3/
|	|	|	|--OBJ.tif
|	|	|	|--MODS.xml
|	|--MODS.xml
```

After this step, the objects are ready for ingest via the Islandora Rest Ingestor.  








