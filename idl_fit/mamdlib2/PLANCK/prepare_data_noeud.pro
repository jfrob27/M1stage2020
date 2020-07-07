pro prepare_data_noeud, fitconfig, nbnoeud, onlyinstnoise=onlyinstnoise
;, nside, fwhm, type, version, dataversion=dataversion

;if not keyword_set(dataversion) then dataversion='DX9'

  nside = fitconfig.nside
  fwhm = fitconfig.fwhm
  type = fitconfig.type
  version = fitconfig.version
  dataversion = fitconfig.dataversion
  allfreq = fitconfig.freq

  prepare_data, fitconfig, allmaps, allnoise, onlyinstnoise=onlyinstnoise;, betamap

if not keyword_set(nbnoeud) then nbnoeud = 1

nbpix = nside2npix(nside)
nbeach = ceil(1.*nbpix/nbnoeud)
nbfreq = n_elements(allfreq)
for noeud=0, nbnoeud-1 do begin
   list = lindgen(nbeach)+noeud*nbeach
   ind = where(list lt nbpix, nbind)
   list = list[ind]
   maps_noeud = fltarr(nbind, nbfreq)
   noise_noeud = fltarr(nbind, nbfreq)
   for j=0, nbfreq-1 do begin
      tmpmaps = allmaps[*,j]
      maps_noeud[*,j] = tmpmaps[list]
      tmpnoise = allnoise[*,j]
      noise_noeud[*,j] = tmpnoise[list]
   endfor
   filename = !DATA+'/Planck/'+dataversion+'/TMPDATA/data_ns'+strc(nside)+'_'+type+'_noeud_'+strc(noeud)+$
              '_fwhm'+strc(fwhm,format='(F5.1)')+'_'+version+'.idl'

   ind = where(allfreq ge 3000 and allfreq le 3010, nbind)
   if (nbind gt 0) then allfreq[ind] = 3000
   betamap = fitconfig.betamap
   if keyword_set(betamap) then begin
      beta = betamap[list]
      save, allfreq, maps_noeud, noise_noeud, list, beta, file=filename 
   endif else begin
      save, allfreq, maps_noeud, noise_noeud, list, file=filename
   endelse

endfor

end
