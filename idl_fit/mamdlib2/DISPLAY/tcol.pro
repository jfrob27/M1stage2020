function tcol, colorname

; Returns the long scalar corresponding to a given color
;
; This can only be used in decomposed=1 mode
;

if not keyword_set(colorname) then goto, sortie

case colorname of

    'black':  color = '000000'XL

    'magenta':  color = 'FF00FF'XL

    'cyan':  color = 'FFFF00'XL

    'yellow':  color = '00FFFF'XL

    'green':  color = '00FF00'XL

    'red':  color = '0000FF'XL

    'blue':  color = 'FF0000'XL

    'white':  color = 'FFFFFF'XL

    'navy':  color = '730000'XL

    'gold':  color = '00BBFF'XL

    'pink':  color = '7F7FFF'XL

    'aquamarine':  color = '93DB70'XL

    'orchid':  color = 'DB70DB'XL

    'gray':  color = '7F7F7F'XL

    'sky':  color = 'FFA300'XL

    'beige':  color = '7FABFF'XL

    else: begin
        print, colorname, ': Unknown color'
        goto, sortie
    endelse
endcase

return, color

sortie:

print, 'The known colors are:'
print, 'black, magenta, cyan, yellow, green, red, blue, beige'
print, 'white, navy, gold, pink, aquamarine, orchid, gray, sky'

end

;    'red': begin
;        r = 255L
;        g = 0L
;        b = 0L
;    end

;    'blue': begin
;        r = 0L
;        g = 0L
;        b = 255L
;    end

;    'green': begin
;        r = 0L
;        g = 255L
;        b = 0L
;    end

;color = r + (g * 256L) + (b * 256L^2)
