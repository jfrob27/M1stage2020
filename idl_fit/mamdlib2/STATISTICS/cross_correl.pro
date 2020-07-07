PRO CROSS_CORREL, a_in1, a_in2, reso, tab_k, spec_k, APODIZE=radius, $
                  GO_ABOVE_NYQUIST=go_above_nyquist, med_k=med_k, sig_k=sig_k

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
;       a (2D fltarr): the input map (must be square)
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
; PROCEDURE CALLS: APODIZE
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

sz=SIZE(a_in1)
IF sz(1) NE sz(2) THEN BEGIN
    WRITE_ERROR,'POWSPEC_K/FATAL : Input is not a square map' 
ENDIF

na = sz(1) 		 
nf = na
nel = N_ELEMENTS(a_in1)

; Apodizing the input image to avoid problems with non-periodic BC
; ----------------------------------------------------------------
tapper=1. & aponorm =1.         ; case when no apodizing

IF(KEYWORD_SET(radius) ) THEN BEGIN
    IF(radius GT 1.) THEN BEGIN
        WRITE_ERROR, 'POWSPEC/FATAL : Apodizing radius must be ' + $
          'smaller than and 1' 
    ENDIF
    IF (radius EQ -1.) 	THEN BEGIN
        tap1d = 0.5*(1.+COS( !PI*(1.+2.*INDGEN( na )/(na-1)) ))
        tapper=FLTARR(na, na)
        FOR i=0, na-1 DO tapper(*,i) =tap1d
        FOR i=0, na-1 DO tapper(i,*) =tapper(i,*)*tap1d
    ENDIF
               ; apodize returns a cosine tapper (w IF N_PARAMS(0) LT 2 THEN R = 0)
    IF (radius EQ 1.) 	THEN tapper = APODIZE(na, na, 0.9999) $
    ELSE tapper = APODIZE(na, na, radius) 
    aponorm = FLOAT(na)^2/TOTAL(tapper^2)
    ;PRINT, " Powspec_k: aponorm =", aponorm
ENDIF

a_n = a_in1
a_n = a_n-median(a_n)
a_n1  = a_n * tapper 

a_n = a_in2
a_n = a_n-median(a_n)
a_n2  = a_n * tapper 
tapper = 0 ; release the memory for tapper
a_n = 0

; Fourier Transform 
; ------------------
;p2   = ( ABS(FFT(a_n,-1)) )^2 * nel  ; normalisation by number of
;elements in the map
f1 = fft(a_n1)
f2 = fft(a_n2)
p2 = ( float(f1)*float(f2) + imaginary(f1)*imaginary(f2) ) * nel
;p2   = ( ABS(FFT(a_n,-1)) )^2 * nel  ; normalisation by number of elements in the map
a_n1  = 0.                       ; free memory
a_n2 = 0.

; separate treatment if reentering the routine for the same map size and k_maxi
; -----------------------------------------------------------------------------
IF KEYWORD_SET(go_above_nyquist) THEN k_maxi=nf ELSE k_maxi = 0.5*nf

; Set-up the k-bins 
; -----------------
k_mod = DIST(nf) 
k_mod(0,0)=0.1
k_crit = nf/2                   ; Keep all possible low k values (|k| < k_crit)

hval1 = HISTOGRAM(ROUND(k_mod), MIN=1, MAX=k_crit, REVERSE_INDICES=r1)

kval1 = FLTARR(nf)
kpow1 = FLTARR(nf) 
med_k = FLTARR(nf)
sig_k = FLTARR(nf)

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

; tab_k is converted into units: X -1 where reso is in  X/pixel (X can be arcmin, degrees, ...)
tab_k   = kval / (k_crit * 2.* reso) 

RETURN

END









