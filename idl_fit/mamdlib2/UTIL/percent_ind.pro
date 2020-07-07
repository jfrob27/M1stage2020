function percent_ind, input, percent, indef=indef
;+
; NAME:
;          PERCENT_IND
;
; PURPOSE:
;          Return the index of a variable but excluding
;          the first and last "percent values" and the undefined values.
;
; CALLING SEQUENCE:
;         res = percent_ind( input, percent, indef=)
;
; INPUTS:
;         input : an array of any dimension (>0)
;
; OPTIONAL INPUTS:
;         percent : two value array (bottom and top percent to be
;         excluded). If percent has only one value, the same value is
;         taken for both the bottom and top.
;
; KEYWORD PARAMETERS:
;         indef : the undefined value (default value is -32768.)
;
; OUTPUTS:
;        result : an array of index
;
; EXAMPLE:
;        result = percent_ind( input, 10., indef=-32768.)
;
; MODIFICATION HISTORY:
;        17/10/2003; MAMD; creation
;-


if not keyword_set(percent) then percent = [0., 0.]
if n_elements(percent) eq 1 then puse = [percent, percent] else puse=percent

if not keyword_set(indef) then indef=-32768.
ind = where(input ne indef, nbind)
if nbind eq 0 then begin
    print, 'No define values in input'
    return, -1
endif

tempo = input(ind)
nmin = fix(1.*puse/100.*nbind)

indsort = sort(tempo)
n1 = nmin(0)
n2 = n_elements(tempo)-nmin(1)

return, ind(indsort(n1:n2))

end

