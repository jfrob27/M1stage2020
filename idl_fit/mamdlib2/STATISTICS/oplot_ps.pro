pro oplot_ps, map0, tab_k, spec_k, expo=expo, norm=norm, wnorm=wnorm, reso=reso, seuilk=seuilk, $
             verb=verb, notfirst=notfirst, xtitle=xtitle, ytitle=ytitle, charsize=charsize, $
             median=mediank, apodize=apodize, $
             nofit=nofit, linestyle=linestyle, color=color, mirror=mir, _Extra=extra

;------------------------------------------------------
; KEYWORDS

if not keyword_set(seuilk) then seuilk=[0., 1.]
if n_elements(seuilk) eq 1 then seuilk = [0., seuilk]
if not keyword_set(reso) then reso=1.
IF NOT keyword_set(verb) THEN verbin = 1 ELSE verbin =  verb
verbin =  verbin >  0.
if not keyword_set(xtitle) then xtitle=''
if not keyword_set(ytitle) then ytitle=''
if not keyword_set(charsize) then charsize=1.
if not keyword_set(apodize) then apodize=0.
if not keyword_set(linestyle) then linestyle=0

if keyword_set(mir) then begin
    mapm = mirror(map0)
    map_ptr = ptr_new(mapm)
endif else map_ptr = ptr_new(map0)

;------------------------------------------------------
; COMPUTE POWER SPECTRUM

;powspec_k, *map_ptr, reso, tab_k, spec_k, med_k=med_k, apod=apodize
powspec_k_nosquare, *map_ptr, reso, tab_k, spec_k, med_k=med_k, apod=apodize
if keyword_set(mediank) then spec_k = med_k

;------------------------------------------------------
; DISPLAY

if keyword_set(color) then $
oplot, tab_k, spec_k, linestyle=linestyle, color=color, _Extra=extra else $
oplot, tab_k, spec_k, linestyle=linestyle, _Extra=extra

;------------------------------------------------------
; FIT POWER LAW

if not keyword_set(nofit) then begin

ind = where(tab_k lt seuilk(1) and tab_k gt seuilk(0)) 
x = alog(tab_k(ind)) 
y = alog(spec_k(ind)) 
w = x 
w(*) = 1. 
if keyword_set(notfirst) then aa=1 else aa=0
res = polyfitw(x(aa:*), y(aa:*), w(aa:*), 1) 
expo = res(1)

if keyword_set(wnorm) then begin
    rien = min(abs(tab_k-wnorm), indmin)
    norm = spec_k(indmin(0))
    norm_plot = norm/wnorm^expo
endif else begin
    norm = exp(res(0))
    norm_plot = norm
endelse

oplot, tab_k, norm_plot*tab_k^expo, col=10
IF keyword_set(verbin) THEN begin
   print, 'exponent: ', expo
   print, 'normalisation: ', norm
ENDIF

endif

end
