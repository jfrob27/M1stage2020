function split_string, column, input


;---------------------------------------------
; 
; SPLIT_STRING
;
; from an line ("input") read in the IRAS PSC catalog, 
; split_string returns the characters of the
; columns specified by the "column" vector
;
; The result is thus an array of string with the
; same number of elements than "column"
;
; mamd 23/09/2001
;
;-------------------------------------------


nbc = [11, 2, 2, 3, 1, 2, 2, 2, 3, 3, 3, 2, 9, 9, 9, 9, 1, 1, 1, 1, 2, 2, 3, 3, 3, 3, $
       5, 5, 5, 5, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 2, 1, 2, $
       4, 4, 4, 4]

value_out = strarr(n_elements(column))
encore = 1
i=0
j=0
while (encore eq 1 and j lt n_elements(column)) do begin & $
    ntogo = strlen(input) & $
    if (ntogo ge nbc(i)) then begin & $
      tempo = strmid(input, 0, nbc(i)) & $
      if (i eq column(j)) then begin & $
        value_out(j) = tempo & $
        j = j+1 & $
      endif & $
      input = strmid(input, nbc(i), ntogo-nbc(i)) & $
      i = i+1 & $
      if (i eq n_elements(nbc)) then encore=0 & $
      endif else encore = 0 & $
endwhile


return, value_out

end


;-----------------------------------------------
;-----------------------------------------------
;-----------------------------------------------

pro extract_iras_psc, lvec, bvec, flux12, flux25, flux60, flux100

;---------------------------------------------------------
;
; IRAS_PSC_HEALPIX
;
; Procedure that extract the position (in l,b) of each source in the
; IRAS PSC. 
;
; MAMD 07/02/2008
;
;------------------------------------------------------------


format=['a11', 'i2', 'i2', 'i3', 'a1', 'i2', 'i2', 'i2', 'i3', 'i3', 'i3', 'i2', 'e9.3', 'e9.3', 'e9.3', $
        'e9.3', 'i1', 'i1', 'i1', 'i1', 'i2', 'a2', 'i3', 'i3', 'i3', 'i3', 'i5', 'i5', 'i5', 'i5', 'a1', 'a1', $
        'a1', 'a1', 'i2', 'a1', 'a1', 'i1', 'i1', 'i1', 'i1', 'i1', 'i1', 'i1', 'i1', 'i1', 'i1', 'a1', $
        'i1', 'i1', 'i3', 'i2', 'i1', 'i2', 'i4', 'i4', 'i4', 'i4']

column = [1,2,3,4,5,6,7,12,13,14,15]
format2 = '(f,f,f,f,f,f)'
inunit = 1
openr, inunit, !HOME+'/idl/iras/PSC/main.dat'

input = ' '
readf, inunit, input
value_out = split_string(column, input)

lvec=[0.]
bvec=[0.]
flux12 = [0.]
flux25 = [0.]
flux60 = [0.]
flux100 = [0.]
WHILE NOT EOF(inunit) DO BEGIN 
    if (strcompress(value_out(3), /rem) eq '-') then sign=-1. else sign=1.
; the seconds in RA are given with three numbers (I3) to
; give the tenths of seconds. Therefore, the number extracted from the
; file must divided by 10. That is why the seconds are divided by
; 36000 in RA and 3600 in DEC.
    ra = (float(value_out(0)) + float(value_out(1))/60. + float(value_out(2))/36000.) * 15.
    dec = (float(value_out(4)) + float(value_out(5))/60. + float(value_out(6))/3600.) * sign
    euler, ra, dec, l, b, 1, /fk4
    lvec = [lvec, l];*!pi/180.]
    bvec = [bvec, b];*!pi/180.]
    flux12 = [flux12, float(value_out(7))]
    flux25 = [flux25, float(value_out(8))]
    flux60 = [flux60, float(value_out(9))]
    flux100 = [flux100, float(value_out(10))]
    readf, inunit, input
    value_out = split_string(column, input)
endwhile
lvec = lvec(1:*)
bvec = bvec(1:*)
flux12 = flux12(1:*)
flux25 = flux25(1:*)
flux60 = flux60(1:*)
flux100 = flux100(1:*)
close, inunit

end




