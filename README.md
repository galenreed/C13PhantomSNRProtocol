## C13PhantomSNRProtocol
### Introduction
This code is created to allow cross-experiment testing of receive arrays for large volume phantoms. The current example shows comparison of 2 13C-tuned receive coils compared between different sites. 
### Experimental Protocol
We are currently using the 18 cm diameter dimethyl silicone (DMS) sphere phantom from GE. 
* Grab the broadband PSD: New Task -> Template -> GE -> 2D MNS FidCSI
* Prescribe an axial slice, 32 cm FOV, 2 cm slice thickness, 4s TR.

|     X      |head coil | torso protocol |
| :-------: |:--------------:| :-----------:|
| FOV      | 32 | 48 |
| slice thickness     | 2 cm        |   3cm |
| voxel edge size |2 cm       |    3 cm|

* Calibrate the flip angle with the slice-select pulse by setting xmtaddSCAN = 0 (or a value appropriate for a specific coil), soft = 1, pf_rf1 =3600, and ia_rf1 = 32767. Enter the SpectroPrescan screen, and set the center frequency to that of the DMS resonance (which should be 2kHz lower than that of ethylene glycol at 3T). Note the TG value which gives a signal null
* copy and paste the sequence and change the following CVs:
	- TR  = 500 ms 
	- cv0 = 5000 (receive bandwidth in Hz)
	- cv1 = 1024 (number of frequency samples)
 	- cv3 = 1
 	- cv5 = 16 (X resolution)
 	- cv6 = 16 (Y resolution). This should give 2cm voxels on a side
* set NEX = 2
* Save, download, note the center frequency remains the same, and set
  the TG to TGnull - 60 (for a 90 degree pulse), and then ia_rf1 =
  8192 (for a 22.5 degree pulse)

For the script to run correctly, be sure to
- center the FOV on the phantom
- center the frequency at the center of the DMS peak quartet. 

###  Processing

####  Executing the scripts
To run the processing scripts, open createSNRImages.m. Make sure the
path pointing to the read_MR folder is correct (to obtain access to
the GE PFile reading scripts, see instructions below). Update the cell array 'files'
with the relative path to your files. There are several reconstruction
parameters here. These are the default values. 
- params.integrationWindow = 450; % [Hz] spectra integration width for
  generating image. This parameter seems to comfortably cover the DMS
  splitting with adequate buffer to not be too shim-sensitive. 
- params.lineBroadening = 3; % [Hz] line broadening filter width 
- params.noiseRegionSize = 10; % [pixels] noise calculated from a square with this edge size
- params.reconMode = 0; % 0 for multiple images in SNR units, 1 for B1 mapping. 
- params.doPlot = 1;% make a plot of the summed spectra with
  integration limits. This is a good sanity check to make sure the
  spectra are fully covered in the integration window. 

To run this script in octave, the image package
to be installed and loaded
```
pkg load image
```


####  Obtain the GE pfile I/O matlab scripts
The processing scripts provided here require the pfile reader provided
with the most up-to-date verion of the EPIC SDK. To obtain this, go to
https://collaborate.mr.gehealthcare.com/community/downloads/epic and
download the latest EPIC SDK. Unpack the .tar.gz file, and inside you
will find the main rpm file, with a name like
"RX27.0_R02_ESElinux-1831-a.rpm." Extract the contents of this file
(in mac, double clicking opens the unarchiver app) and create a new
subfolder to unpack, for instance called "unpack." This will create a
.cpio file in this subfolder. Now, from the terminal, you can extract
the contents of this file by running
```
cpio -idv < [outfile]
```
For example,
```
cpio -idv < RX27.0_R02_ESElinux.cpio
```
In the folder [ESE_release]/tools/matlab,  there will be a folder called "read_MR."
Add this folder to your matlab path. 


