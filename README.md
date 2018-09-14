## C13PhantomSNRProtocol
#### Introduction
This code is created to allow cross-experiment testing of receive arrays for large volume phantoms. The current example shows comparison of 2 13C-tuned receive coils compared between two different sites. 
#### Experimental Protocol
We are currently using the X cm diameter dimethyl silicone phantom from GE. 
* Grab the broadband PSD: New Task -> Template -> GE -> 2D MNS FidCSI
* Prescribe an axial slice, 32 cm FOV, 2 CM slice thickness, 4s TR. 
* Calibrate the flip angle with the slice-select pulse by setting xmtaddSCAN = 0, soft = 1, pf_rf1 =3600, ia_rf1 = 32767, 

