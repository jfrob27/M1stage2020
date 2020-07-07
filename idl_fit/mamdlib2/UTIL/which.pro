pro which,filename
;+
; NAME:  
;              which
;
; PURPOSE:     Prints a list of all directory pathnames which match a
;              given idl procedure name.  The directory precedence is
;              set by the system variable !path.  The file name may
;              contain any wild card characters understood by the
;              operating system.  In the case that a given procedure
;              is found in more than one directory, the first listed
;              pathname is the one compiled by the IDL interpreter in
;              response to a .run statement.
;
; USEAGE:      which,filename
;
; INPUT:    
;   filename   name of idl procedure (may include wild cards)
;
; KEYWORD INPUT:  none
;
; OUTPUT:         none
;  
; EXAMPLE:  
;               which,'str*'  ; produces this output:
;
;               /local/idl/user_contrib/esrg/strip_fn.pro
;               /local/idl/user_contrib/esrg/strmatch.pro
;               /local/idl/user_contrib/esrg/strpack.pro
;               /local/idl/user_contrib/esrg/strwhere.pro
;               /local/idl/lib/color/stretch.pro
;               /local/idl/lib/prog/str_sep.pro
;
;
; AUTHOR:   Paul Ricchiazzi                        19 Nov 97
;           Institute for Computational Earth System Science
;           University of California, Santa Barbara
;           paul@icess.ucsb.edu
;
; REVISIONS:
;
;-
;

fff='/'+filename
ppp=str_sep(!path,':')+fff
for i=0,n_elements(ppp)-1 do begin
  f=findfile(ppp(i))
  if f(0) ne "" then n=n_elements(f) else n=0
  for j=0,n-1 do print,f(j)
endfor

return
end
