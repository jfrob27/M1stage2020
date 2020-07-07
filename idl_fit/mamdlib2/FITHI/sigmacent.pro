pro sigmacent, result, _extra=Extra, sigrange=sigrange, centrange=centrange

sigcent = syntres(result, sigrange=sigrange, centrange=centrange, _extra=Extra)
;if not keyword_set(sigrange) then sigrange = minmax(allsig)
;if not keyword_set(centrange) then centrange = minmax(allcent)

imaffi, sigcent, axe=[centrange[0], sigrange[0], centrange[1], sigrange[1]], $
        _extra=Extra, xtitle='centroid (channel)', ytitle='sigma (channel)'

end
