pro blobplot, x, y, blobnum

plot, x, y, /xs, /ys, /nodata
nbblob = max(blobnum)-min(blobnum)+1
ib = findgen(nbblob)+1
col = mcol("blue")
for i=0, nbblob-1 do begin
   ind = where(blobnum eq ib(i))
   oplot, x(ind), y(ind), psym=1, col=10*i
endfor

end
