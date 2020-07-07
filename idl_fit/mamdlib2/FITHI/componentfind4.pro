pro componentfind4, result, output, $
                    dcentmin=dcentmin, $
                    dsigmin=dsigmin, $
                    sigpercent=sigpercent, $
                    centpercent=centpercent, $
                    dwindow=dwindow, nbmin=nbmin

if not keyword_set(dsigmin) then dsigmin=1
if not keyword_set(dcentmin) then dcentmin=1
if not keyword_set(dwindow) then dwindow = 3
if not keyword_set(nbmin) then nbmin = floor((dwindow*2+1)^2/3.)

uniform=1

nbcomp = (size(result))(3)/3
cent = result(*,*,findgen(nbcomp)*3+1)
sig = result(*,*,findgen(nbcomp)*3+2)

si = size(cent)
xymap, si(1), si(2), xmap, ymap
x = fltarr(si(1), si(2), nbcomp)
y = x
z = x
for i=0, nbcomp-1 do begin
   x(*,*,i) = xmap
   y(*,*,i) = ymap
   z(*,*,i) = i
endfor

if not keyword_set(output) then begin
   output = fltarr(si(1), si(2), nbcomp)
   output(*) = -32768.
endif
nextval = 0
for j=0, si(2)-1 do begin
   j0 = (j-dwindow)>0 
   j1 = (j+dwindow)<(si(2)-1) 
   print, j
  for i=0, si(1)-1 do begin
     i0 = (i-dwindow)>0
     i1 = (i+dwindow)<(si(1)-1) 
     subc = cent(i0:i1,j0:j1,*)
     subs = sig(i0:i1,j0:j1,*)
     subx = x(i0:i1,j0:j1,*)
     suby = y(i0:i1,j0:j1,*)
     subz = z(i0:i1,j0:j1,*)
     subo = output(i0:i1,j0:j1,*)
     defined = where(subc ne -32768., nbdefined)
     if (nbdefined gt 0) then begin        
        subc = subc(defined)
        subs = subs(defined)
        subx = subx(defined)
        suby = suby(defined)
        subz = subz(defined)
        subo = subo(defined)    
        blob = blobfind(subc, subs, dxmin=0.5, dymin=0.05, /ypercent)
;        blob = blobfind(subc, subs, dxmin=1.0, dymin=1.0)
        ind = where(subx eq i and suby eq j, nbind)
        for k=0, nbind-1 do begin
           blobk = blob(ind(k))
           zk = subz(ind(k))
           indk = where(blob eq blobk and subo ne -32768., nbk)
           if (nbk ge 1) then begin
              tempo = subo(indk)
              ;------ new
              list = tempo(uniq(tempo, sort(tempo)))
              dist = fltarr(n_elements(list))
              occur = dist
              for kk=0, n_elements(list)-1 do begin
                 test = where(subo eq list(kk), nbtest)
                 occur[kk] = nbtest
                 if (nbtest gt 1) then $ 
;                    dist[kk] = sqrt( (median(subc(test))-subc(ind(k)))^2/stddev(subc(test))^2 + $
;                                     (median(subs(test))-subs(ind(k)))^2/stddev(subs(test))^2 ) else $
                    dist[kk] = sqrt( (median(subc(test))-subc(ind(k)))^2 + $
                                     (median(subs(test))-subs(ind(k)))^2 ) else $
                    dist[kk] = sqrt( ( subc(test)-subc(ind(k)) )^2 + $
                                     ( subs(test)-subs(ind(k)) )^2 )                                        
;                 test = where(tempo eq list(kk))
;                 dist[kk] = sqrt( (median(subc(indk(test)))-subc(ind(k)))^2 + (median(subs(indk(test)))-subs(ind(k)))^2 )
              endfor
              rien = min(dist, wmin)
              newval = list(wmin) 
;              print, list, dist, occur
;              print, newval
;              stop
              ;----- end new
;              newval = maxoccur(tempo, nbmax)
              output(i,j,zk) = newval

;--------- uniformize output in case of several blobnum             
              if keyword_set(uniform) then begin  
;                 test = where(tempo ne newval, nbtest)
;                 if (nbtest gt 0) then begin
;                    tempo = tempo(test)
;                    list = tempo(uniq(tempo, sort(tempo)))
; previous lines replaced by : 
                 distmin = 1.
                 test = where(dist le distmin and list ne newval, nbtest)
                 if (nbtest gt 0) then begin
                    list = list(test)
; end of replace
                    for kk=0, n_elements(list)-1 do begin
                       test = where(subo eq list(kk))
                       subo(test) = newval
                       test = where(output eq list(kk))
                       output(test) = newval
                    endfor
                 endif
              endif   
; ------------ end uniformize
              
           endif else begin
              nextval = nextval+1
              output(i,j,zk) = nextval
           endelse
        endfor
     endif
   endfor
endfor


;return, output

end

