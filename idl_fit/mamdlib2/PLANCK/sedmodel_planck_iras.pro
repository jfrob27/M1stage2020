;function sedmodel_planck_iras, allfreq, amp, t, beta
function sedmodel_planck_iras, allfreq, param

nbfreq = n_elements(allfreq)
npix = n_elements(param[*,0])
lambda = 3.e5/allfreq

;-------- LOAD FILTERS FOR COLOR CORRECTION --------
;dirv201 = '/Users/mamd/idl/Planck/DataAnalysis/FIlterAndCalibration/filter_v2.01/HFI_UC_CC'
;!PATH = !PATH+':'+dirv201
;version = 'v201'
;bp = hfi_read_bandpass(version, /rimo, path_rimo=dirv201+'/') 

;restore, 'col_cor_hfi_iras_dirbe.idl'
restore, !DATA+'/Planck/DX9/COLCOR/'+!COLCORFILE, /ver
tnames = tag_names(cc)
betavec = cc.beta
tdvec = cc.td
freq_cc = cc.freq
filters_cc = cc.filters
ccmaps = fltarr(n_elements(tdvec), n_elements(betavec), n_elements(allfreq))
for i=0, nbfreq-1 do begin
   ind = where(freq_cc eq allfreq[i])
   label = filters_cc[ind[0]]
   ind = where(strcmp(tnames, label, /fold_case) eq 1)
   ccmaps[*,*,i] = cc.(ind[0])
endfor

; compute the model of the data
allmodel = fltarr(npix, nbfreq)
for i=0L, npix-1 do begin
   print, i
;   a = [amp[i], t[i], beta[i]]
   a = reform(param[i,*])
   model = bg(lambda, a, tdvec=tdvec, betavec=betavec, ccmaps=ccmaps)

; colour correction
;   ii = interpol(indgen(n_elements(tdvec)), tdvec, a[1])
;   jj = interpol(indgen(n_elements(betavec)), betavec, a[2])
;   kk = indgen(n_elements(lambda))
;   cc = interpolate(ccmaps, ii, jj, kk, /grid)
;   model = model*reform(cc)

   allmodel[i,*] = model
endfor



return, allmodel

end
