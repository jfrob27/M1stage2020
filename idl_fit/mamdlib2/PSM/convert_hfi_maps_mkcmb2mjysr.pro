;+
; NAME:
;       convert_hfi_maps_mkcmb2mjysr
;
; PURPOSE:
;      converts Planck/HFI maps from mK CMB into MJy/sr at a
;      given frequency, with the spectrum convention
;      nuInu=constant. The values used here are computed by G. Lagache.
;
; CALLING SEQUENCE:
;      convert_hfi_maps_mkcmb2mjysr, freq, mkcmb2MJysr
;
; INPUTS:
;      freq: integer: HFI frequency in GHz
;
; OUTPUTS:
;      mkcmb2MJysr: FLOAT: factor to apply to convert mK CMB -> MJy/sr
;      with nuInu=cst
;
; EXAMPLE:
;     convert_hfi_maps_mkcmb2mjysr, 143, mkcmb2MJysr143
;     mymap_MJysr = map143(K_CMB) * 1.e3 * mkcmb2MJysr143
;
; MODIFICATION HISTORY:
;   16-June-2010 Written Herve Dole, IAS
;-
PRO convert_hfi_maps_mkcmb2mjysr, freq, mkcmb2MJysr

; Values from file unit_conversion_GL.txt, circulated by G. Lagache on June 6th, 2010
; values convert mK CMB -> MJy/sr with nuInu=cst spectrum
 factors100 = [ 0.237434,     0.240722,     0.241665,     0.239899,     0.244365,     0.238442,     0.244261,     0.245106]
 factors143 = [ 0.364308,     0.368905,     0.365765,     0.369629,     0.359633,     0.365408,     0.370364,     0.368637,     0.378126,     0.372106,     0.379908,     0.374702]
 factors217 = [ 0.484903,     0.485195,     0.485833,     0.484913,     0.478299,     0.479308,     0.479006,     0.479302,     0.479735,     0.478733,     0.478627,     0.479665]
 factors353 = [ 0.288592,     0.287988,     0.289227,     0.289382,     0.286728,     0.286766,     0.290042,     0.289957,     0.288922,     0.292803,     0.285685,     0.283882]
 factors545 = [ 0.0573780,    0.0590470,    0.0583120,    0.0582840]
 factors857 = [ 0.00218100,   0.00232800,   0.00219300,   0.00239500]

; take mean 
 factor100 = MEAN(factors100)
 factor143 = MEAN(factors143)
 factor217 = MEAN(factors217)
 factor353 = MEAN(factors353)
 factor545 = MEAN(factors545)
 factor857 = MEAN(factors857)

; select channel and outputs factor
 strfreq = STRING(freq, FORMAT='(I3.3)')
 a = EXECUTE(' mkcmb2MJysr = factor' + strfreq)

END
