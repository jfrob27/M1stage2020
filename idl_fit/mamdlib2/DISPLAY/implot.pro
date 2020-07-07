pro implot, x, y, xrange=xrange, yrange=yrange, bin=bin, noerase=noerase, $
            log=log, position=position, xlog=xlog, ylog=ylog, image=grid, _Extra=extra

  if not keyword_set(yrange) then yrange = minmax(y)
  if not keyword_set(xrange) then xrange = minmax(x)
  if not keyword_set(bin) then begin
     bin = fltarr(2)
     bin[0] = (xrange[1]-xrange[0])/40.
     bin[1] = (yrange[1]-yrange[0])/40.
  endif

  if not keyword_set(noerase) then erase

  margex = [0.1, 0.1]
  margey = [0.1, 0.1]

  sizex = !d.x_size*(1.-total(margex))
  sizey = !d.y_size*(1.-total(margey))
  
    if keyword_set(xlog) then begin
     nbx = ceil((alog10(xrange[1])-alog10(xrange[0]))/bin[0])
     xi = round((alog10(x)-alog10(xrange[0]))/bin[0]) 
  endif else begin
     nbx = ceil((xrange[1]-xrange[0])/bin[0])
     xi = round((x-xrange[0])/bin[0])
  endelse

  if keyword_set(ylog) then begin
     nby = ceil((alog10(yrange[1])-alog10(yrange[0]))/bin[1])
     yi = round((alog10(y)-alog10(yrange[0]))/bin[1]) 
  endif else begin
     nby = ceil((yrange[1]-yrange[0])/bin[1])
     yi = round((y-yrange[0])/bin[1])
  endelse

  tempo = fltarr(nbx, nby)
  for i=0L, n_elements(xi)-1 do begin
     if (xi[i] ge 0 and xi[i] lt nbx and yi[i] ge 0 and yi[i] lt nby) then $
        tempo[xi[i], yi[i]] = tempo[xi[i], yi[i]] + 1
  endfor
  
  grid = tempo
  if not keyword_set(position) then tempo = congrid(tempo, sizex, sizey)
  if keyword_set(log) then begin
     ind = where(tempo gt 0., nbind)
     if (nbind gt 0) then tempo[ind]=alog10(tempo[ind])
  endif
  imr = range(tempo, 0.01)
  imr[0] = 0
;  tempo = ceil(tempo/imr[1]*255)
;  imr=[0,255]
  imaffi, tempo, position=position, imr=imr, _Extra=extra, /nocadre
  plot, [xrange[0], yrange[0], xrange[1], yrange[1]], xr=xrange, yr=yrange, /xs, /ys, $
        /noerase, position=position, /nodata, xlog=xlog, ylog=ylog, _Extra=extra
;, $          imcontour=smooth(tempo, 3, /edge_truncate), level=alog10([2,5,10,20])

end

  
