PRO POWSPEC_K_NOSQUARE, a_in, reso, tab_k, spec_k, histo, bin=bin, APODIZE=radius, $
              med_k=med_k, sig_k=sig_k, noaverage=noaverage

;------------------------------------------------------------------------------
;+
; NAME:	POWSPEC_K
;
; PURPOSE: this routine computes the power spectrum of a map
; 	it is made according to Nearest Grid Point scheme
;
; CALLING SEQUENCE: POWSPEC, a, reso, tab_k, spec_k, APODIZE=r
;
; INPUTS: 
;       a (2D fltarr): the input map 
;       reso (float):  the physical resolution (X/pixel where X is
;                                                         degree, or arcmin or ...)
;
; OUTPUTS: 
;        tab_k (1D fltarr): contains k in unit of X^(-1)
;        spec_k (1D fltarr): contains power spectrum
; 
; KEYWORDS: apodize = R will weight the map with a cosine tapper 
;                     equal to 1 for radii < R ( 0 < R < 1 required)
;
; PROCEDURE CALLS: APODIZE, XYMAP
;
; METHOD: Estimates the power spectrum from an FFT analysis. Reso is needed
;         to convert wave-number in angular-1 units.
; 
; HISTORY: 1994	V1.0 Eric HIVON      
;          1994 V1.1 Richard GISPERT (RG) : Remove 2**n extension
;   03-MAR-1995 V1.2 Francois BOUCHET (FRB): Apodizing introduced, Fourier 
;                    grid size = 2n, cut at Nyquist, and Furiously Faster 
;                    using HISTOGRAM.
;   05-JUN-1995 V1.3 RG : clean call to APODIZE
;   17-JUL-1995 V1.4 FRB: BANDWIDTH keyword Added
;   28-NOV-1995	V1.5 RG : store histogram in common to speed up
;	             long series of computations on the same map size
;   11-JUN-1996 V1.6 RG : normalize input to maximum to avoid underflow
;   08-JAN-1997 V1.7 FRB: Properly normalize when apodization is required
;   20-JAN-1997 V1.8 FRB: New binning, add keyword go_above_nyquist
;   02-NOV-1998      G Lagache et H Dole: power spectrum in K
;   30-Nov-98 H. Dole: good pow spec in k:  k in unit of X^(-1)
;   02-Dec-98 H. Dole: normalisation in SQRT(N) with Parseval, add
;                      stop keyword
;-
;------------------------------------------------------------------------------

sz=SIZE(a_in)
;IF sz(1) NE sz(2) THEN BEGIN
;    WRITE_ERROR,'POWSPEC_K/FATAL : Input is not a square map' 
;ENDIF

na = sz(1) 	
nb = sz(2)	 
nf = max([na, nb])

nel = N_ELEMENTS(a_in)

; Apodizing the input image to avoid problems with non-periodic BC
; ----------------------------------------------------------------
tapper=1.         ; case when no apodizing

IF(KEYWORD_SET(radius) ) THEN BEGIN
    IF(radius GE 1.) THEN BEGIN
        print, 'POWSPEC/FATAL : Apodizing radius must be smaller than 1' 
        return
    ENDIF ELSE tapper = APODIZE(na, nb, radius) 
ENDIF

a_n = a_in
a_n = a_n-median(a_n)
a_n  = a_n * tapper 
tapper = 0 ; release the memory for tapper

; Fourier Transform 
; ------------------
p2   = ( ABS(FFT(a_n,-1)) )^2 * nel  ; normalisation by number of elements in the map
a_n  = 0.                       ; free memory


; separate treatment if reentering the routine for the same map size and k_maxi
; -----------------------------------------------------------------------------
; IF KEYWORD_SET(go_above_nyquist) THEN k_maxi=nf ELSE k_maxi = 0.5*nf

; Set-up the k-bins 
; -----------------
k_crit = nf/2      ; Keep all possible low k values (|k| < k_crit)        
k_min = 1
;bin = 1
xymap, na, nb, xmap, ymap

if (na mod 2) eq 0 then begin
    xmap = ( 1.*xmap - na/2. ) / na
    shiftx = na/2 
endif else begin
    xmap = ( 1.*xmap - (na - 1)/2. ) / na
    shiftx = (na-1.)/2.+1
endelse
if (nb mod 2) eq 0 then begin
    ymap = ( 1.*ymap - nb/2.) / nb
    shifty = nb/2 
endif else begin
    ymap = ( 1.*ymap - (nb - 1)/2.) / nb
    shifty = (nb-1.)/2.+1
endelse

k_mat = sqrt(xmap^2 + ymap^2)
k_mat = k_mat * nf 
k_mod = shift(k_mat, shiftx, shifty )
;k_mod(0,0)=k_min

if not keyword_set(noaverage) then begin

hval1 = HISTOGRAM(round(k_mod), MIN=k_min, MAX=k_crit, REVERSE_INDICES=r1, BIN=bin)

kval1 = FLTARR(nf)
kpow1 = FLTARR(nf) 
med_k = FLTARR(nf)
sig_k = FLTARR(nf)
k_xy = intarr(na,nb)

; Average values in same k bin
; ----------------------------
j  =-1
FOR i=0, r1(0)-2 DO BEGIN       ; average values in k-bins 
    IF r1(i) NE r1(i+1) THEN BEGIN ; keep only non-empty bins
        j = j+1
        kval1(j) = TOTAL( (k_mod)(r1(r1(i):r1(i+1)-1)) ) / hval1(i)   ; K value
        kpow1(j) = TOTAL(    (p2)(r1(r1(i):r1(i+1)-1)) ) / hval1(i)    ; AVG of Amplitude in K bin
        med_k(j) = median(    (p2)(r1(r1(i):r1(i+1)-1)) )                 ; Median of Amplitude in K bin
        sig_k(j) = stdev(    (p2)(r1(r1(i):r1(i+1)-1)) )                     ; Sigma of amplitude in K bin
    ENDIF
ENDFOR
j1 = j

kval =  kval1(0:j1)
spec_k =  kpow1(0:j1)   
med_k = med_k(0:j1)
sig_k = sig_k(0:j1)

openw,1,"nbpoints.txt"
printf,1,hval1
close,1
histo = hval1

endif else begin
    ind = where(k_mod le k_crit)
    spec_k = p2(ind)
    kval = k_mod(ind)
    med_k = 0
    sig_k = 0
endelse

openw,1,"kval.txt"
printf,1,kval
close,1

; tab_k is converted into units: X -1 where reso is in  X/pixel (X can be arcmin, degrees, ...)
tab_k   = kval / (k_crit * 2.* reso) 
;tab_k   = kval / (reso) 

RETURN

END









