FUNCTION mosiris, header_in, band=band, weight=weight, catname=catname, dir=dir, $
                  silent=silent, fwhm=fwhm, clip=clip, hcon=hcon, noise=noise, _Extra=extra

;+
; NAME:
;      mosiris
; PURPOSE:
;      creates a mosaic of IRIS images
; CATEGORY:
;      IRIS - image projection
; CALLING SEQUENCE:
;      im=mosiris(h, [band=, weight=, catname=, dir=, fwhm=fwhm, /silent])
; INPUTS:
;      header - header on which projection has to be done
; OPTIONAL INPUTS:
;      band - IRAS band for which the filenames have to be
;               returned (1=12 mic to 4=100 mic)
;      catname - filname of the catalog (default is !IRISPRO/info_issa_map4.txt)
;      dir - directory where are the IRIS maps (default is !IRISDATA)
;
; OUTPUTS:
;      im  = image corresponding to h
; OPTIONAL OUTPUTS:
;      weight = weight map for im
; PROCEDURE:
;      get_equinox, extast, sxpar, sxaddpar, xy2ad, ad2xy, euler, readcol,
;      get_cootype, mprecess, nan2undef, get_iris, my_bilinear2
;
; MODIFICATION HISTORY:
;      Created August 10 2005 by M.A. Miville-Deschenes (IAS)
;-

if not keyword_set(band) then band=4
if not keyword_set(hcon) then hcon=0
if not keyword_set(noise) then noise=0
if not keyword_set(silent) then silent=0
if not keyword_set(dir) then dir=!IRISDATA

; If FWHM is set we first project on a ISSA grid (1.5'/pixel), make
; a convolution by a beam of FWHM and then project on the final grid
if keyword_set(fwhm) then begin
    header = header_in
    fx = abs(sxpar(header_in, 'CDELT1') / (1.5/60.))
    fy = abs(sxpar(header_in, 'CDELT2') / (1.5/60.))
    sxaddpar, header, 'CDELT1', -1.5/60.
    sxaddpar, header, 'CDELT2', 1.5/60.
    extrax = fix( sxpar(header_in, 'NAXIS1') * fx * 0.05 )
    extray = fix( sxpar(header_in, 'NAXIS1') * fy * 0.05 )
    sxaddpar, header, 'NAXIS1', sxpar(header_in, 'NAXIS1') * fx + extrax
    sxaddpar, header, 'NAXIS2', sxpar(header_in, 'NAXIS2') * fy + extray
    sxaddpar, header, 'CRPIX1', sxpar(header_in, 'CRPIX1') * fx + extrax/2.
    sxaddpar, header, 'CRPIX2', sxpar(header_in, 'CRPIX2') * fy + extray/2.
endif else begin
    header = header_in
endelse


equinox = get_equinox(header)
extast, header, astr

; pixel coordinates map 
xsize = sxpar(header, 'NAXIS1')
ysize = sxpar(header, 'NAXIS2')
x = findgen(xsize)#replicate(1,ysize)
y = replicate(1,xsize)#findgen(ysize)

; sky coordinates map 
xy2ad, x, y, astr, alpha, delta

; Transform sky coordinates in Celestial (RA,DEC) B1950
sysco = get_cootype(astr)
if (sysco eq 2) then equinox = 1950 ; force to arrive in B1950 if galactic coordinates
if (equinox eq 1950) then fk4=1 else fk4=0
case sysco of
    2: begin
        print, 'convert coordinates from Galactic to Celestial B1950'
        EULER, alpha, delta, select=2, /fk4     ; Galactic
    end
    3: begin
        print, 'convert coordinates from Ecliptic to Celestial'
        EULER, alpha, delta, select=4, /fk4 ; Ecliptic
    end
    else :
endcase
if (equinox eq 2000) then begin
    print, 'precess coordinates from J2000 to B1950'
    mprecess, alpha, delta, 2000, 1950
endif
nan2undef, alpha, undef=-32768.
nan2undef, delta, undef=-32768.

; Intialise output map
result = fltarr(xsize, ysize)
weight = result

; READ CATALOG
if not keyword_set(catname) then catname = !IRISPRO+'/info_issa_map4.txt'
readcol, catname, inum, ramin, ramax, raavg, demin, demax, deavg, $
  medval, noise_key, format='(i3, f12.6, f12.6,  f12.6, f12.6, f12.6, f12.6, f12.6, i2)'

; IDENTIFY IRIS MAPS THAT HAVE A COMMON AREA WITH THE INPUT HEADER
nb = n_elements(inum)
id_good = intarr(nb)
print, 'Check for ISSA maps that intersect with the given header'

ind = where(alpha ne -32768. and delta ne -32768.)
c1min = min(alpha(ind))
c1max = max(alpha(ind))
c2min = min(delta(ind))
c2max = max(delta(ind))
for i=0, nb-1 do begin
  if (c1min ge ramin(i) and c1min le ramax(i) and c2min ge demin(i) and c2min le demax(i)) then id_good(i) = 1
  if (c1min ge ramin(i) and c1min le ramax(i) and c2max ge demin(i) and c2max le demax(i)) then id_good(i) = 1
  if (c1max ge ramin(i) and c1max le ramax(i) and c2max ge demin(i) and c2max le demax(i)) then id_good(i) = 1
  if (c1max ge ramin(i) and c1max le ramax(i) and c2min ge demin(i) and c2min le demax(i)) then id_good(i) = 1
  if (ramin(i) ge c1min and ramin(i) le c1max and demin(i) ge c2min and demin(i) le c2max) then id_good(i) = 1
  if (ramax(i) ge c1min and ramax(i) le c1max and demin(i) ge c2min and demin(i) le c2max) then id_good(i) = 1
  if (ramin(i) ge c1min and ramin(i) le c1max and demax(i) ge c2min and demax(i) le c2max) then id_good(i) = 1
  if (ramax(i) ge c1min and ramax(i) le c1max and demax(i) ge c2min and demax(i) le c2max) then id_good(i) = 1
endfor

ind = where(id_good gt 0, nbind)
if (nbind eq 0) then begin
    print, 'No ISSA map corresponds to the header given'
    return, -1
endif 
print, nbind, ' ISSA maps will be combined to produce the mosaic'
print, 'PLATE NUMBERS: ' , inum(ind)

; PROJECT ALL THE SELECTED ISSA MAPS ON THE INPUT HEADER
for i=0, nbind-1 do begin 
    mapi = get_iris(inum(ind(i)), header=hi, dir=dir, band=band, silent=silent, hcon=hcon, noise=noise)
    if keyword_set(hi) then begin
       extast, hi, astri
       ad2xy, alpha, delta, astri, xi, yi
       tempo = mbilinear(mapi,xi,yi,silent=silent)
       indw = where(tempo ne -32768, nbindw)
       if (nbindw gt 0) then begin
          weight(indw) = weight(indw)+1.
          result(indw) = result(indw)+tempo(indw)
       endif
    endif
endfor

indw  = where(weight gt 0., nbindw, complement=indempty, ncomplement=nindempty)
if (nbindw gt 0) then begin
    result(indw) = result(indw)/weight(indw)
endif
if (nindempty gt 0) then result(indempty) = -32768.


if keyword_set(clip) then result = clip_source(result, _Extra=extra)

if keyword_set(fwhm) then begin
    nn = fwhm/1.5*5
    if (nn mod 2 eq 0) then nn=nn+1
    kernel = gauss2d(nn, fwhm/1.5/2.354)
    kernel = kernel/total(kernel)
    result = la_convol(result, kernel, /edge_truncate)
    result = mproj(result, header, header_in)
endif


RETURN,result

END
