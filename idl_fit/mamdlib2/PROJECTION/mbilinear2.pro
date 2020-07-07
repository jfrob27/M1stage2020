FUNCTION mbilinear, array, x, y ,silent=silent, no_remove_indef=no_remove_indef, $
  missing=missing

;+
; NAME:
;        mbilinear
; PURPOSE:
;       same as bilinear of user library but can deal with big arrays
; CATEGORY:
;       Coordinates conversions
; CALLING SEQUENCE: 
;	mbilinear , array, x, y
; INPUTS:
;	array = array (2D) in which interpolation is to be made
;	x, y = 2D array of x and y values (must be of same size)
; OPTIONAL INPUT PARAMETERS:
;       missing - value of missing data (default is !indef or -32768.)
; OUTPUTS:
;	function output=interpolated array (same size as x and y)
; SIDE EFFECTS:
;	x and y values not in the target image (outside array)
;	are changed to 0 or -1
; PROCEDURE:
;	BILINEAR (users library)
;	indef values are difficult to handle. Here values in the
;	interpolated values which values are smaller than the smaller
;	defined value in the original array are set to indef. This works
;	for a highly <0 indef (e.g indef=-32768.) and generally >0 image
; MODIFICATION HISTORY:
;      14-Aug-1992, Written by Jean-Philippe Bernard, Nagoya Univ.
;      10-Aug-2005, M.A.Miville-Deschenes (IAS) : add missing keyword
;-

;---------------------------------------------------------------
; parameter check
;---------------------------------------------------------------
IF N_PARAMS(0) LT 3 THEN BEGIN
  PRINT,'Calling sequence: res=my_bilinear(array, x, y)'
  PRINT,'K words:              [/silent]'
  GOTO, closing
ENDIF

six=SIZE(x)
siy=SIZE(y)
siA=SIZE(array)
IF six(0) NE 2 OR siy(0) NE 2 THEN BEGIN
  print,'x and y should be 2D arrays'
  goto,closing
ENDIF
IF six(1) NE siy(1) OR six(2) NE siy(2) THEN BEGIN
  print,'Incompatible x and y array dimensions'
  goto,closing
ENDIF
IF siA(0) NE 2 THEN BEGIN
  print,'array should be a 2D array'
  goto,closing
ENDIF

if not keyword_set(missing) then begin
    if keyword_set(!indef) then missing=!indef else missing=-32768.
endif

;---------------------------------------------------------------
; calculations
;---------------------------------------------------------------

Nax=siA(1)
Nay=siA(2)
Nx=six(1)
Ny=six(2)

output=fltarr(Nx,Ny) & output(*,*)=missing

min_array=min(array)
ind=where(array ne missing,count)
IF count NE 0 THEN min_array=min(array(ind))

indbad=where(x LT 0 OR x GT nax-1 OR y LT 0 or y GT nay-1,countbad)
inter_percent=1.*(Nx*Ny-countbad)/Nx/Ny*100.
IF not keyword_set(silent) THEN BEGIN
  print,'Images intersection=',inter_percent,' %'
ENDIF

FOR j=0L,Ny-1 DO BEGIN
  ind=where(x(*,j) GE 0 AND x(*,j) LE Nax-1 AND $
	    y(*,j) GE 0 AND y(*,j) LE Nay-1,count)
  IF count NE 0 THEN BEGIN
    xx=fltarr(count,2) & xx(*,0)=x(ind,j)
    yy=fltarr(count,2) & yy(*,0)=y(ind,j)
    truc=bilinear(array,xx,yy)
    output(ind,j)=truc(*,0)
  ENDIF
ENDFOR

;remove values affected by indef values (for highly <0 indef and generaly>0 im)
IF not keyword_set(no_remove_indef) THEN BEGIN
  ind=where(output LT min_array,count)
  IF count NE 0 THEN output(ind)=missing
ENDIF

return,output
CLOSING:
END
