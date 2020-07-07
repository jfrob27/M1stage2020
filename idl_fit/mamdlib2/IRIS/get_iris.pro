FUNCTION get_iris, ii, header=header, band=band, silent=silent, dir=dir, hcon=hcon, iras_number=iras_number, file=file, noise=noise

;+
; NAME:  GET_IRIS
;
; PURPOSE:  function that returns the IRIS map number ii
;
; CALLING SEQUENCE:
;  map = get_iris(ii, header=header, band=band, /silent, dir=dir)
; 
; INPUTS:
;  ii : the ISSA map number
;
; KEYWORDS:
;  silent : silent
;
; OUTPUTS:
;  map : the ISSA map corresponding to the number ii 
;
; OPTIONAL INPUTS:
;  band: the IRAS band number (1: 12 micron, 2: 25 micron, 
;                              3: 60 micron, 4:100 micron)
;                              default value is 4
;  hcon : HCON number (default is 0 which is the co-added map)
;  dir: directory where the IRIS data are stored (default is !IRISDATA)
;
; OPTIONAL OUTPUTS:
;  header: the header of the map
; 
; PROCEDURE:
;  readfits, sxaddpar
;
; MODIFICATION HISTORY:
;  MAMD October 8 2003 Creation
;  MAMD/GL November 25 2003 : put undefined values to -32768.
;  MAMD 10-Aug-2005 : adapted for IRIS
;-

if not keyword_set(ii) then begin
    PRINT, 'Syntax - map = get_iris(issa_number, [band=, header=, /SILENT, dir=, hcon=])'
    return, -1
endif

;------------ initialization---------------
if not keyword_set(dir) then dir = !IRISDATA

;------------ IRAS BAND--------------------
IF NOT keyword_set(band) then band = 4
bd = strcompress(string(band), /rem)

;---------- ISSA NUMBER -----------------
iras_number = strcompress(string(ii), /rem)  
if (ii lt 100) then iras_number = '0' + iras_number  
if (ii lt 10) then iras_number = '0' + iras_number  

;---------- HCON NUMBER ------------------
if not keyword_set(hcon) then hcon=0
hnum = strcompress(string(fix(hcon)), /rem)

;----------- READ ISSA MAP------------------
if keyword_set(noise) then file_description = dir+'/n'+iras_number+'b'+bd+'.*' $
;   else file_description = dir+'/?'+iras_number+'?'+bd+'?'+hnum+'.*'
   else file_description = dir+'/?'+iras_number+'*'+bd+'?'+hnum+'.*'
result = FINDFILE(file_description, count=count)
IF (count gt 0) THEN BEGIN 
    map = readfits(result(0), header, silent=silent) 
    sxaddpar, header, 'LONPOLE', 180.
    bad=where(map LT -5 or map eq 0., nbbad)
    if (nbbad gt 0) then map(bad)=-32768
    if not keyword_set(silent) then print, 'Read data file '+result(0)
    file = result(0)
ENDIF ELSE BEGIN
    map = -1
    if not keyword_set(silent) then print, 'Could not find data file for ISSA number ' + iras_number + ' and IRAS band ' + bd
ENDELSE    

;---------------END------------------
return, map

END


