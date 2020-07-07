pro sedfit_planck_iras, allmaps, allnoise, allfreq, param, err_param, chi2, fixed=fixed, beta=beta, $
                        statistic_error=statistic_error, tbg=tbg, twobeta=twobeta, ciba=ciba

  if not keyword_set(fixed) then fixed=[0,0,0]
  if not keyword_set(beta) then beta=1.6

  si = size(allmaps)
  npix = si[1]
  lambda = 3.e5/allfreq
  nbfreq = n_elements(allfreq)

;-------- LOAD FILTERS FOR COLOR CORRECTION --------
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

;-------- PIXEL BY PIXEL FIT ----------

  nbparam=3
  fixed_use = fixed
  if keyword_set(twobeta) then begin
     nbparam = 5 
     fixed_use = [fixed, 1, 0]  ; fix frequency of beta change
  endif 
  if keyword_set(ciba) then begin
     nbparam = 6
     fixed_use = [fixed, [0,1,1]]
     T_CIBA = 19.
     BETA_CIBA = 1.2
  endif

  param = fltarr(npix, nbparam)
  err_param = param
  chi2 = fltarr(npix)

  for i=0L, npix-1 do begin
     print, i, npix
     data =  reform(allmaps[i,*])
     error = reform(allnoise[i,*])

     if (n_elements(beta) eq 1) then beta0=beta else beta0 = beta[i]
     if not keyword_set(tbg) then begin
        ratio = data[0]/data[1] ; use two frequencies to guess temperature
        T0 = dustcolor(3.e5/allfreq[0], 3.e5/allfreq[1], ratio, beta=beta0)
     endif else begin
        if (n_elements(tbg) eq 1) then T0=tbg else T0 = tbg[i]
     endelse
     a0 = data[0]/ ( 1.e20*lambda[0]^(-1*Beta0)*bnu_planck(lambda[0], T0) )
     guess = [a0, T0, Beta0]
     if keyword_set(twobeta) then guess = [a0, T0, beta0, 850., beta0]
     if keyword_set(ciba) then guess = [a0, T0, beta0, 0., T_CIBA, BETA_CIBA]

     if (n_elements(guess) eq 5) then twobeta=1 else twobeta=0
     if (n_elements(guess) eq 6) then twombb=1 else twombb=0
     res = fitbg(lambda, data, guess, errordata=error, perror=perror, chi2=chi2val, $
                 fixed=fixed_use, CCMAPS=CCMAPS, BETAVEC=BETAVEC, TDVEC=TDVEC, $
                 twobeta=twobeta, twombb=twombb)
     param[i,*] = res
     err_param[i,*] = perror
     chi2[i] = chi2val

  endfor


end



