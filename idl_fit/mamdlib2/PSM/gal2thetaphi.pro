pro gal2thetaphi, glon, glat, theta, phi

; GLON, GLAT : galactic coordinates given in degrees, north pole is GLAT=90
;    Theta : angle (along meridian), in [0,Pi], theta=0 : north pole,
;    Phi   : angle (along parallel), in [0,2*Pi]
;
; 09/09/2011 : Marc-Antoine Miville-Deschenes

theta = (90-glat)*!pi/180.
phi = glon*!pi/180.

end
