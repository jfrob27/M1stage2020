pro deltavar, image, lag, result, indef=indef

sim = size(image)
N = min(sim(1:2))
lag = findgen(N)+1.
result = fltarr(N)

for i=0, N do begin
    
