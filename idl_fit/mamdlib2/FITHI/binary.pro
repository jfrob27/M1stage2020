; return binary representation of an integer
; result is a variable size array of 1's and 0's
FUNCTION binary, int, arrsize=arrsize

  if int ne 0 then begin
     val = 1
     val_array = [1]
     
     WHILE val LE int DO BEGIN
        val = val * 2
        val_array = [val, val_array]
     ENDWHILE 

     val_array = val_array[1:*]
     array = intarr(n_elements(val_array))
     array[0] = 1

     FOR i=1,n_elements(array)-1 DO BEGIN 
        array[i] = 1
        IF total(array * val_array) GT int THEN array[i]=0
     ENDFOR

  endif else begin 
     array = [0]
  endelse

  IF NOT keyword_set(arrsize) THEN arrsize=n_elements(array)

  IF n_elements(array) LT arrsize THEN BEGIN
     array0 = array
     array = intarr(arrsize)
     index = arrsize - n_elements(array0)
     array[index:*] = array0
  ENDIF

  RETURN, array

END
