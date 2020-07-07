pro plotresfit, x, spectre, result, color=color, posx=posx, posy=posy, $
                nodecompose=nodecompose, xtitle=xtitle, ytitle=ytitle, title=title, $
                charsize=charsize, xrange=xrange, yrange=yrange, position=position, $
                posspectre=posspectre, thick=thick, linecolor=linecolor, arrow=arrow, $
                notitle=notitle, xcharsize=xcharsize, ycharsize=ycharsize, noerase=noerase, $
                xticks=xticks, yticks=yticks, xtickv=xtickv, ytickv=ytickv, noplotsum=noplotsum, $
                linestyle=linestyle, sinc=sinc, _Extra=extra


if not keyword_set(sinc) then sinc=0
if not keyword_set(noplotsum) then noplotsum=0
if not keyword_set(color) then color=0
if not keyword_set(linecolor) then linecolor=0
if not keyword_set(thick) then thick=1
if not keyword_set(xtitle) then xtitle=''
if not keyword_set(ytitle) then ytitle=''
if not keyword_set(title) then begin
    if keyword_set(notitle) or (not keyword_set(posx) and not keyword_set(posy)) then title='' $
    else title = string(posx, posy, '("x: ", F5.1, "   y: ", F5.1)')
endif
if not keyword_set(xticks) then xticks=0
if not keyword_set(yticks) then yticks=0
if not keyword_set(xtickv) then xtickv=0
if not keyword_set(ytickv) then ytickv=0
if not keyword_set(charsize) then charsize=1
if not keyword_set(xcharsize) then xcharsize=charsize
if not keyword_set(ycharsize) then ycharsize=charsize
if not keyword_set(nodecompose) then nodecompose=0
if not keyword_set(xrange) then begin
    xrange=[0,0]
    xstyle=0
endif else xstyle=1
if not keyword_set(yrange) then begin
    yrange=[0,0]
    ystyle=0
endif else ystyle=1
if not keyword_set(ystyle) then ystyle=0
if not keyword_set(xstyle) then xstyle=0
if not keyword_set(position) then begin
    position= 0
    noerase = 0
    normal=0
endif else noerase = 1
if not keyword_set(linestyle) then linestyle=0

spectre = reform(spectre)
si_spectre = size(spectre)
if (si_spectre(0) ne 1) then begin
    if not keyword_set(posx) then posx=0
    if not keyword_set(posy) then posy=0
    spectre2 = spectre(posx, posy,*)
endif else spectre2 = spectre

if keyword_set(position) then $
  plot, x, spectre2, xtitle=xtitle, ytitle=ytitle, title=title, $
  charsize=charsize, xrange=xrange, yrange=yrange, position=position, normal=normal, $
  noerase=noerase, ystyle=ystyle, xstyle=xstyle, xcharsize=xcharsize, ycharsize=ycharsize, xticks=xticks, $
  yticks=yticks, xtickv=xtickv, ytickv=ytickv, psym=10, thick=thick, _Extra=extra $
else $
  plot, x, spectre2, xtitle=xtitle, ytitle=ytitle, title=title, $
  charsize=charsize, xrange=xrange, yrange=yrange, $
  noerase=noerase, ystyle=ystyle, xstyle=xstyle, xcharsize=xcharsize, ycharsize=ycharsize, xticks=xticks, $
  yticks=yticks, xtickv=xtickv, ytickv=ytickv, thick=thick, psym=10, _Extra=extra

oplotresfit, x, result, color=color, posx=posx, posy=posy, nodecompose=nodecompose, noplotsum=noplotsum, $
  linestyle=linestyle, thick=thick

if keyword_set(posspectre) then begin
    lines=2
    distance = fltarr(4)
    k = 0
    for i=0, 2, 2 do begin
        for j=1, 3, 2 do begin
            distance(k) = sqrt((position(i)-posspectre(0))^2+(position(j)-posspectre(1))^2)
            k = k+1
        endfor
    endfor
    ind = sort(distance)
    case ind(0) of
        0: begin
            if not keyword_set(arrow) then $
            plots, [position(0), posspectre(0)], [position(1), posspectre(1)], /normal, $
              lines=lines, thick=thick, color=linecolor $
            else  arrow, position(0), position(1), posspectre(0), posspectre(1), /normal, color=linecolor, thick=thick
        end
        1: begin
            if not keyword_set(arrow) then $
            plots, [position(0), posspectre(0)], [position(3), posspectre(1)], /normal, $
              lines=lines, thick=thick, color=linecolor $
            else arrow, position(0), position(3), posspectre(0), posspectre(1), /normal, color=linecolor, thick=thick
        end
        2: begin
            if not keyword_set(arrow) then $
            plots, [position(2), posspectre(0)], [position(1), posspectre(1)], /normal, $
              lines=lines, thick=thick, color=linecolor $
            else arrow, position(2), position(1), posspectre(0), posspectre(1), /normal, color=linecolor, thick=thick
        end
        3: begin
            if not keyword_set(arrow) then $
            plots, [position(2), posspectre(0)], [position(3), posspectre(1)], /normal, $
              lines=lines, thick=thick, color=linecolor $
            else arrow, position(2), position(3), posspectre(0), posspectre(1), /normal, color=linecolor, thick=thick
        end
    endcase
endif

end

