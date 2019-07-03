# Dynamical

cloned from https://gitlab.umich.edu/lsa-ts-rsp/dynamical

## TO DO

From what I can tell, the large part of the import/parsing process is in the +dynamical/+math/amd.m file, in which the nex file is read and measurements are extracted.
I need to modify this to determine whether a nex file or a spike file is being used.

There is a python package to read in spike2 files
https://scientificallysound.org/2018/04/05/import-spike2-into-python/
https://github.com/MartinHeroux/ScientificallySound_files/blob/master/neo/io/spike2io.py

Can I port these into Matlab?
I don't have to! I can interface between python and matlab!!
https://nl.mathworks.com/help/matlab/call-python-libraries.html

neo dependencies:
quantities https://files.pythonhosted.org/packages/89/44/a875b723f70935b022d6b7a02c12a020e3b1777aa7bfc6fc243a908bc650/quantities-0.12.3.tar.gz

Functions I need to make SPIKE2 ports for

These already work fine!
opennexfile -> openfile
closenexfile -> closefile

listintervalnames
readfileheader
getneurondata
getintervaltimes

