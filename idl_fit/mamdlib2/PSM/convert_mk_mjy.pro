; Copyright 2007 IAS

;+
;  Convert mK, either themodynamic or Rayleigh-Jeans in MJy/sr
; 
;
;  @param lam {in}{required}{type=float} wavelength in micron
;  @keyword sig_mK{in}{required}{type=float} signal in mK
;  @keyword sig_Mjy{in}{optional}{type=float} ...
;  @keyword RJ{in}{optional}{type=boolean} ...
;  @keyword CMB_TH{in}{optional}{type=boolean} ...
;
;  @history <p> Written Guilaine Lagache, 2001</p>
;-

pro convert_mk_mjy, lam, sig_mk, sig_Mjy, RJ=RJ, CMB_TH = CMB_TH

IF KEYWORD_SET(RJ) THEN $
  ; mK Rayleigh-Jeans
  sig_Mjy=sig_mk*1.e-3*2*1.38e-23*1e20/(lam*1.e-6)^2.

IF KEYWORD_SET(CMB_TH) THEN BEGIN
  ; mK thermodynamique
  PLANCK_VALUES=  planck_function(2.726,lam,dBdT_VALUES,units='micron',/MJY)
  sig_Mjy=sig_mk*dbdt_values*1.e-3
ENDIF


END

