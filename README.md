## C13PhantomSNRProtocol
#### Introduction
This code is created to allow cross-experiment testing of receive arrays for large volume phantoms. The current example shows comparison of 2 13C-tuned receive coils compared between different sites. 
#### Experimental Protocol
We are currently using the 18 cm diameter dimethyl silicone (DMS) sphere phantom from GE. 
* Grab the broadband PSD: New Task -> Template -> GE -> 2D MNS FidCSI
* Prescribe an axial slice, 32 cm FOV, 2 cm slice thickness, 4s TR. 
* Calibrate the flip angle with the slice-select pulse by setting xmtaddSCAN = 0 (or a value appropriate for a specific coil), soft = 1, pf_rf1 =3600, and ia_rf1 = 32767. Enter the SpectroPrescan screen, and set the center frequency to that of the DMS resonance (which should be 2kHz lower than that of ethylene glycol at 3T). Note the TG value which gives a signal null
* copy and paste the sequence and change the following CVs:
	- TR  = 500 ms 
	- cv0 = 5000 (receive bandwidth in Hz)
	- cv1 = 256 (number of frequency samples)
 	- cv3 = 1
 	- cv5 = 16 (X resolution)
 	- cv6 = 16 (Y resolution). This should give 2cm voxels on a side
* set NEX = 2
* Save, download, note the center frequency remains the same, and set the TG to TGnull - 60 (for a 90 degree pulse), and then ia_rf1 = 8192 (for a 22.5 degree pulse) 		  
 

