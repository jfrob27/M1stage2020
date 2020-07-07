PRO Greek_Example, UNICODE=unicode

    Compile_Opt hidden
    
    ; The 24 Greek letters.
    letter = [  'alpha', 'beta', 'gamma', 'delta', 'epsilon',  'zeta', $
                'eta', 'theta', 'iota', 'kappa', 'lambda', 'mu', $
                'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', $
                'upsilon', 'phi', 'chi', 'psi', 'omega' ]
    
    ; Output positions.
    x = [0.25, 0.6]
    y = Reverse((Indgen(12) + 1) * (1.0 / 13))
    
    ; Create a window, if needed.
    IF (!D.Flags AND 256) NE 0 THEN BEGIN
        thisWindow = !D.Window
        Window, XSIZE=600, YSIZE=500, /Free
        ERASE, COLOR=cgColor('white')
    ENDIF
    
    ; Output the letters.
    FOR j=0,11 DO BEGIN
        XYOuts, x[0], y[j], letter[j] + ': ' + $
            Greek(letter[j], UNICODE=unicode) + Greek(letter[j], /CAPITAL, UNICODE=unicode), $
            /NORMAL, COLOR=cgColor('Black'), CHARSIZE=1.5
        XYOuts, x[1], y[j], letter[j+12] + ': ' + $
            Greek(letter[j+12], UNICODE=unicode) + Greek(letter[j+12], /CAPITAL, UNICODE=unicode), $
            /NORMAL, COLOR=cgColor('Black'), CHARSIZE=1.5
    ENDFOR
    
    ; Restore the users window.
    IF N_Elements(thisWindow) NE 0 THEN BEGIN
       IF thisWindow GE 0 THEN WSet, thisWindow
    ENDIF
    
END ; --------------------------------------------------------------------------------------


