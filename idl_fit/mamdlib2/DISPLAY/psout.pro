pro psout, print=print

;------------------------------------------
;
; PSOUT
;
; Ferme le postcript et remet les parametres
; du device 'PS' aux valeurs par defaut.
;
; MAMD 17/04/98
;
;----------------------------------------

device, /close
if (!MAMDLIB.DEVICE eq 'X') then set_plot,'x'

; THICK
!X.THICK = !MAMDLIB.X_THICK
!Y.THICK = !MAMDLIB.X_THICK

; FOREGROUND AND BACKGROUND COLOR
!P.BACKGROUND = !MAMDLIB.BACKGROUND
!P.COLOR = !MAMDLIB.COLOR

end
