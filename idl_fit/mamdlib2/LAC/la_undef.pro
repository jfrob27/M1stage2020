FUNCTION LA_UNDEF, type
;+ 
; NAME: LA_UNDEF
; PURPOSE:
;   return value considered as undefined for a given type   
;   if type is outside the range 1-5, return the empty string 
; CALLING SEQUENCE: 
;   output=LA_UNDEF(type)
; MANDATORY INPUTS:
;   none 
; OPTIONAL INPUT PARAMETERS:
;   type         -- integer with IDL scalar type (1 to 5), default is 2
; KEYED INPUTS:
;   none 
; OUTPUTS: 
;   output       -- undefined value
; OPTIONAL OUTPUT PARAMETERS:
;   none 
; EXAMPLE:
;   ICE> help, la_undef()
;   <Expression>    INT       =   -32768
; ALGORITHM:
;   straightforward 
; DEPENDENCIES:
;   none 
; SIDE EFFECTS:
;   none 
; RESTRICTIONS:
;   do not accept IDL types : complex and structure (6 and 8)
; CALLED PROCEDURES AND FUNCTIONS:
;   none 
; MODIFICATION HISTORY: 
;    18-Apr-1994  written with template_gen         FV IAS
;     5-Oct-1994  V.1.0 for configuration control   FV IAS
;    25-Apr-2008 remove session control / now independant of ICE  MAMD IAS
;-
 
 
;------------------------------------------------------------
; initialization
;------------------------------------------------------------
 
 output=''

;------------------------------------------------------------
; function body
;------------------------------------------------------------

 IF n_elements(type) EQ 0 THEN type =2

 CASE type OF
      1 : output = 255b
      2 : output = fix(-32768)
      3 : output = -32768l
      4 : output = -32768.
      5 : output = -32768d
      7 :
 ENDCASE

;------------------------------------------------------------
; closing
;------------------------------------------------------------
 
 CLOSING:
 
  RETURN, output
 
 END
