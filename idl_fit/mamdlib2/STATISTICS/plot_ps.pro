pro plot_ps, map0, tab_k, spec_k, expo=expo, norm=norm, knorm=knorm, reso=reso, seuilk=seuilk, $
             verb=verb,  fcolor=fcolor, flinestyle=flinestyle, nodisplay=nodisplay, $
             mediank=mediank, apodize=apodize, dres=dres, noaverage=noaverage, $
             nofit=nofit,  _Extra=extra, efit=efit, errplot=errp, notfirst=notfirst, mirror=mir, fthick=fthick

;+
; NAME:
;    PLOT_PS
;
; PURPOSE:
;    Display the power spectrum of an image (compute with powspec_k)
;
; CALLING SEQUENCE:
;   plot_ps, map0, tab_k, spec_k
;
; INPUTS:
;------
;  map0 (2D fltarr): a square image
;
; KEYWORD PARAMETERS:
;--------------------
;  APODIZE (float between 0 and 1): the apodize factor (see
;                                  POWSPEC_K). Default: no apodization
;  EFIT (keyword): if set, the two power laws corresponding to the
;                        error on the power law fit are overplotted.
;  ERRPLOT (keyword) if set, the error bar on the power spectrum are displayed.
;  FCOLOR (integer): color of the fit line.
;  FLINESTYLE (integer): linestyle of the fit line.
;  KNORM (float): the K value where the normalisation is taken (if not
;                    given, the normalisation is computed from the
;                    power law for K=0).
;  MIRROR (keyword): If set, the image is mirrored to avoid top/bottom
;                    and left/right discontinuities.
;  NOFIT (keyword): if set, the power law fitting is not done.
;  RESO (float): the resolution of the pixel (in angular coordinate
;                  (arcminutes, ...). Default: reso=1.
;  SEUILK (fltarr of 2 values): the minimum and maximum K values
;                                     between which the power law is
;                                     fitted. Default: seuilk=[0,1]
;  VERB: verbose mode (print the result of the power law fit).
;
; OUTPUTS:
;--------
;   TAB_K (1D fltarr): wave_number (k) vector. Units are in pixel^-1
;                          or angular coordinate (arcmin^-1, ...) if
;                          RESO is given.
;   SPEC_K (1D fltarr): power spectrum
;
; OPTIONAL OUTPUTS:
;----------------
;   EXPO (float): power law exponent
;   NORM (float): power law normalisation
;   MEDIANK (1D fltarr): power spectrum computed with the median value
;                              (and not the mean) for each K bin.
;   
; RESTRICTIONS:
;   must be done on a square image with no undefined values
;
; PROCEDURE:
;    powspec_k, reglin
;
; EXAMPLE:
;    plot_ps, map, seuilk=[0.01, 0.1], reso=1.5, apod=0.95, /efit
;
; MODIFICATION HISTORY:
;    mamd 17/12/2001
;-

;------------------------------------------------------
; KEYWORDS

if not keyword_set(fcolor) then fcolor=10
if not keyword_set(flinestyle) then flinestyle=0
if not keyword_set(fthick) then fthick=1.
if not keyword_set(seuilk) then seuilk=[0., 1.]
if n_elements(seuilk) eq 1 then seuilk = [0., seuilk]
if not keyword_set(reso) then reso=1.
if not keyword_set(apodize) then apodize=0.
if not keyword_set(noaverage) then noaverage=0.

if keyword_set(mir) then begin
    mapm = mirror(map0)
    map_ptr = ptr_new(mapm)
endif else map_ptr = ptr_new(map0)


;------------------------------------------------------
; COMPUTE POWER SPECTRUM

powspec_k_nosquare, *map_ptr, reso, tab_k, spec_k, med_k=med_k, apod=apodize, sig_k=sig_k, noaverage=noaverage
;powspec_k, *map_ptr, reso, tab_k, spec_k, med_k=med_k, apod=apodize, sig_k=sig_k
if keyword_set(mediank) then spec_k = med_k

;------------------------------------------------------
; FIT POWER LAW

;stop

if not keyword_set(nofit) then begin

    ind = where(tab_k lt seuilk(1) and tab_k gt seuilk(0)) 
    x = alog(tab_k(ind)) 
    y = alog(spec_k(ind)) 
    if keyword_set(notfirst) then aa=1 else aa=0
    dy = sig_k(ind) / spec_k(ind)
;junk = reglin(x(aa:*), y(aa:*), dy(aa:*), coeff=res, dcoeff=dres)
    junk = reglin(x(aa:*), y(aa:*), coeff=res, dcoeff=dres)
    expo = res(1)

    if keyword_set(knorm) then begin
        rien = min(abs(tab_k-knorm), indmin)
        norm = spec_k(indmin(0))
        norm_plot = norm/knorm^expo
    endif else begin
        norm = exp(res(0))
        norm_plot = norm
    endelse

endif

;------------------------------------------------------
; DISPLAY

if not keyword_set(nodisplay) then begin
; plot power spectrum
    plot, tab_k, spec_k, /xlog, /ylog, _Extra=extra

; plot error bar
    if keyword_set(errp) then errplot, tab_k, spec_k-sig_k, spec_k+sig_k

; plot power law fit
    if not keyword_set(nofit) then oplot, tab_k, norm_plot*tab_k^expo, col=fcolor, linestyle=flinestyle, thick=fthick

; overplot the two power law obtained from the error calculation
    IF keyword_set(efit) then begin
        oplot, [seuilk(0), seuilk(0)], minmax(spec_k), col=50
        oplot, [seuilk(1), seuilk(1)], minmax(spec_k), col=50
        expo1 = res(1)+dres(1)
        expo2 = res(1)-dres(1)
        norm1 = exp( avg(y - expo1*x) )
        norm2 = exp( avg(y - expo2*x) )
        oplot, tab_k, norm1*tab_k^expo1, col=50, linestyle=2
        oplot, tab_k, norm2*tab_k^expo2, col=50, linestyle=2
    endif

endif

; VERBOSE
IF NOT keyword_set(verb) THEN verbin = 1 ELSE verbin =  verb
verbin =  verbin >  0.
IF keyword_set(verbin) and not keyword_set(nofit) THEN begin
    print, 'exponent: ', expo, dres(1)
    print, 'normalisation: ', norm, dres(0)
ENDIF


end
