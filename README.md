# Introduction

## What is Data Processing and Visualization Toolbox (DPV)

DPV Toolbox is extracted from the Neurophysiology Toolbox (NPT). It is a Matlab toolbox with object-oriented programming framework. This toolbox is able to process large data sets, allows developing new analysis algorithms for user-defined objects, and provides Graphical User Interface to inspect the analysis results.
This toolbox is suitable for the data sets with hierarchy/level. The names of the items/directories in the same level should follow certain pattern.

## Structure of DPV
This toolbox consists of the following items:
* Two parent classes, @nptdata and @nptgroup;
* Assistant class @event
* Child class template @dirfiles
* Category gui
* Category miscellaneous

User may create their desired objects using the template @dirfiles, and then use parent class functions to process the data sets to obtain the object in each directory.

# Setup

First of all, make sure Matlab has been installed on the computer. Then do the following steps.
Step 1: Get a copy of the DPV.
Step 2: Create directory where you would like to store DPV and save the toolbox in that directory.
Step 3: Add path.
1. Start MATLAB
2. Change directories to the DPV directory: >> cd ~/matlab/DPV
3. Add the sub-directories to your path: >> nptAddPath
4. Go to File -> Set Path;
5. In the dialog box, click “Save” and “Close”;
1
Step 4: Set up the configuration file.
1. In the “Current Directory” Window, select the directory contains the toolbox
2. Copy the file named ConfigurationTemplate.txt
3. In “Command Window”, type

```matlab
>> cd(prefdir)
The “Current Directory” Window now shows the preference directory.
4. Paste ConfigurationTemplate.txt in the directory, and rename it to be
Configuration.txt.
5. In “Command Window”, run the function ModifyConfig.m to modify the
configuration file. You may type the following command in “Command Window” to get help on how to use this function (see Section 3.2).
>> help modifyConfig
```

# Configuration File

## Contents and Location

The configuration file created in DPV Toolbox is used to save the hierarchy (level) information:

1. nptDataDir – the root directory used to store the data sets;
2. Level names – Contains the name of each level in data hierarchy;
3. Abbreviations of level names – the abbreviations of level names used when creating directories;
4. String pattern of level names – the way to name the directory in each level. This information is useful for the program to figure out the individual directories when in a combinational directory (e.g.: the string pattern of directories in Cluster level is ‘cluster01s’);
5. Equivalent level names – in case one level has some equivalent levels.

The configuration file is saved in the preference directory, returned by the command ‘prefdir’. If more than one users share a single copy of Matlab in one computer, these users can still keep individual preferences.

Configuration file needs to be set up by the individual users respectively. A template configuration file is provided in DPV, named ‘ConfigurationTemplate.txt’. This file contains the default data hierarchy information. If user does not set up his own configuration file, the default information will be read during processing.

The default values are listed below.
nptDataDir – /var/automount/opt/data/cat;
Level names – Cluster, Group, Session, Site, Day, Days;
Abbreviations of level names – c -> Cluster; g -> Group; n -> Session; s -> Site;
2
String pattern of level names – cluster00s -> Cluster, group0000 -> Group, session00 -> Session, site00 -> Site.
Equivalent level names – Group/Sort/HighPass/Eye/EyeFilt/Lfp.

## Modifying Configuration File

The function ConfigModify.m enables the users to modify any number of the five components at one time.

### Examples
```matlab
ModifyConfig(‘nptDataDir’, ‘/var/automount/opt/data/cat’);
‘levelNames’ should be assigned as a cell array with the lowest level coming first and highest level coming last.
ModifyConfig(‘levelNames’, {‘Cluster’, ‘Group’, ‘Session’, ‘Site’, ‘Day’, ‘Days’});
```

levelAbbr’ and ‘NamePattern’ also need to be assigned in order of the levels ModifyConfig(‘levelAbbr’, ‘cgns’);
```matlab
ModifyConfig(‘NamePattern’, {‘cluster00s’, ‘group0000’, ‘session00’, ‘site00’})
```
For ‘EqualName’, the common-used name of certain level should be in the first place followed by ‘/’ and the equivalent names. The equivalent names should be separated by ‘/’ as well.
```matlab
ModifyConfig(‘EqualName’, {‘Group/Sort/HighPass/Eye/EyeFilt/Lfp’});
```
For the way of calling ModifyConfig.m, you are strongly suggested to modify one component at one time. It prevents typing long command line and making typo errors.

# Create Child Class Object
DPV Toolbox provides a child class template @dirfiles. You may simply copy this class, paste it in the proper directory, and rename the class as well as the constructor function. There are two examples in the toolbox, @checkFiles and @plusFiles.

## Contents in Child Class Template
The class @dirfiles has the following functions.
* Constructor – used to create an object with the appropriate input arguments
passed. The constructor has the same name as the class. It is able to handle three possible combinations of input arguments:
  * No input argument – the constructor should create a default object
3
  * Object input argument – if the first argument in the argument list is an object of the same class, the constructor simply returns the object
  * Data input argument – the constructor creates the object using the input data
* get.m – used to access class properties
* plus.m – used to combine two objects in the same class to get the combined object
* plot.m – used to create plot using input object and input argument for visualizing analysis results
* subsasgn.m and subsref.m – used to define the behavior of indexing for the class

Usually, only the constructor and plot.m need to be modified for user-defined object.

## Example classes
There are two tutorial classes in the toolbox, @checkFiles and @plusFiles. @checkFiles tests single analysis, and checks how much file in each directory for total number, ‘.mat’ files, ‘.bin’ files and ‘.txt’ files. @plusFiles tests combinational analysis, and checks the sum of the files in specific directories the same as @ checkFiles. The constructors of the two test classes are created strictly by modifying the template of child class constructor, and the plot,m functions are created by modifying the template of plot.m in @dirfiles.

## Modification in Constructor
There are five ways in total for template constructors to obtain the objects. Then either createEmptyObject.m or createObject.m is called.
1. Create empty object using arguments only;
2. No input arguments, create empty object;
3. If the first argument passed is just an object of the same class, return the very object;
4. If the previously saved object has the same requested arguments, load the previously saved object;
5. If none of 1), 2), 3) and 4) is satisfied, create object according to the input arguments.

In the fourth way, the proggram will do argument checking and comparison. However, some input arguments do not affect object creation, like ‘RedoLevels’ and ‘SaveLevels’. These arguments must be neglected during argument checking. You need to specify them at the beginning of the constructor.

### Example
```matlab
Args.UnimportantArgs = {'RedoLevels','SaveLevels'};
```
The main part for modification is the two functions createEmptyObject.m and createObject.m. They need to be developed carefully for object creation. If the object creation requires additional calculation before calling the two functions, the calculation should be added to where indicated by “IMPORTANT NOTICE!” in the template constructor.

## Modification of plot.m
This function provides two types of plots, individual plot and population plot. Individual plot plots one data set at a time, while population plot plots all data together. You may see the codes in the template plot.m. Please add code in where indicated by “add code for plot options here”.

# Data Processing
Two process functions are provided in DPV Toolbox, *ProcessLevel.m* and *ProcessDirs.m*.

## ProcessLevel.m
NPTDATA/PROCESSLEVEL
NPTDATA/PROCESSCOMBINATION

Checks the local directory for data to process and returns the processed object, including individual analysis and combinational analysis. For the latter, used together with *ProcessCombination.m*.

### Syntax
```matlab
[robj,data] = ProcessLevel(obj,varargin);
[robj,data] = ProcessCombination(obj,varargin);
```
