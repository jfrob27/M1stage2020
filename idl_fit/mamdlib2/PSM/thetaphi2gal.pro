pro thetaphi2gal, theta, phi, glon, glat

; GLON, GLAT : galactic coordinates given in degrees, north pole is GLAT=90
;    Theta : angle (along meridian), in [0,Pi], theta=0 : north pole,
;    Phi   : angle (along parallel), in [0,2*Pi]
;
; 09/09/2011 : Marc-Antoine Miville-Deschenes

glat = 90.-theta*180./!pi
glon = phi*180./!pi

end
