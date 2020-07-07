function synfast_cxx, cl, nside, fwhm_arcmin=fwhm_arcmin, beam=beam, $
                      lmax=lmax, seed=seed, simul_type = simul_type, $
                      almsfile=almsfile, plmfile=plmfile, verbose=verbose, $
                      maps_fits_out = maps_fits_out, apply_windows = apply_windows, $
                      no_output_map=no_output_map, polar=polar
;+
; NAME:  SYNFAST_CXX
;
; PURPOSE:
;    launch the syn_alm_cxx and alm2map_cxx HEALPix C++ softwares.
;    simulate a Gaussian random field map
;
; CATEGORY:
;    CMB simulation
;
; CALLING SEQUENCE:
; map = synfast_cxx(cl, nside,[fwhm_arcmin=fwhm_arcmin, beam=beam, $'
;                          lmax=lmax, seed=seed, simul_type = simul_type, $'
;                          almsfile=almsfile, plmfile=plmfile, verbose=verbose, $'
;                          maps_fits_out = maps_fits_out]'
;
; INPUTS:
;    cl    : power spectrum model (structure {ClT,ClE,ClB,ClExT})
;    nside : HEALPix nside value
;
; OPTIONAL INPUTS:
;    fwhm   : beam fwhm (in arcmin)
;    beam   : Legendre window function of the circular beam (disable fwhm)
;    lmax : maximum value in l (must be < 3*nside-1)
;    seed : random seed to be used for the generation of the alm
;    almsfile : input filename for a file containing alm for constrained realisations
;    plms : input filename for a file containing precompute Legendre polynomials Plm
;
; KEYWORD PARAMETERS:
;    /verbose      : print the log file of synfast
;
; OUTPUTS:
;    a map computed as realisations of random Gaussian fields
;
; MODIFICATION HISTORY:
;    + MAMD 08/03/2007 : modification of synfast.pro 
;    + Jacques Delabrouille, 02/12/2008 : now default is simple
;    precision, set /double for double precision
;    + MAMD 08/09/2011 : remove tmpdir obsolete keyword (use GETENV(IDL_TMPDIR))
;-

if n_params() ne 2 then begin
    message, /info, 'Call is : '
    message, /info, 'map = synfast_cxx(cl, nside,'
    message, /info, ' [fwhm_arcmin=fwhm_arcmin, beam=beam, $'
    message, /info, ' lmax=lmax, seed=seed, simul_type = simul_type, $'
    message, /info, ' almsfile=almsfile, plmfile=plmfile, verbose=verbose, $'
    message, /info, ' maps_fits_out = maps_fits_out, double=double]'
    map = -1
    goto, exit
endif

;create files

machin = long(randomu(theseed,1)*1e6)
truc   = strtrim(machin,2)
fitsmap  = gettmpfilename('tmpmap')
fitsalm  = gettmpfilename('tmpalm')
fitscl   = gettmpfilename('tmpcl')
txtfile1  = gettmpfilename('txt1', suffix= '.txt')
txtfile2  = gettmpfilename('txt2', suffix= '.txt')
beamfile = gettmpfilename('beam')

spawn,'rm -f '+fitsmap+' '+fitscl+' '+fitsalm+' '+txtfile1+' '+txtfile2

if not keyword_set(simul_type) then simul_type = 1
if (keyword_set(polar) or simul_type gt 1) then polarisation='true' else polarisation='false'
;if not keyword_set(almsfile) then almsfile=''
if not keyword_set(seed) then seed=machin
if not keyword_set(fwhm_arcmin) then fwhm_arcmin=0.0
if not keyword_set(lmax) then lmax=n_elements(cl)-1

if lmax gt 3*nside-1 then begin
    lmax=3*nside-1
    message, /info, 'lmax too high !'
    message, /info, 'lmax = '+strtrim(lmax,2)
endif

;write the beam
if keyword_set(beam) then mwrfits, beam, beamfile, header, /create

;fill the powerspectrum structure
struct={ClT:0d,ClE:0d,ClB:0d,ClExT:0d}
powerspectrum=replicate(struct,n_elements(cl))
;if not keyword_set(polarisation) then begin
if ( (simul_type eq 1) or (simul_type eq 3) or (simul_type eq 4)) then begin
    powerspectrum.ClT   = cl
    powerspectrum.ClE   = dblarr( n_elements(cl))
    powerspectrum.ClB   = dblarr( n_elements(cl))
    powerspectrum.ClExT = dblarr( n_elements(cl))
endif else begin
    powerspectrum.ClT   = cl.(0)
    powerspectrum.ClE   = cl.(1)
    powerspectrum.ClB   = cl.(2)
    powerspectrum.ClExT = cl.(3)    
endelse

;put the structure in the fitsfile
mwrfits, powerspectrum, fitscl, ascii='D:E15.7', /create

if keyword_set( maps_fits_out) then fitsmap = maps_fits_out

;write the datacard
close,1
openw,1,txtfile1
printf, 1, 'nlmax = '+strtrim(lmax,2)
printf, 1, 'nmmax = '+strtrim(lmax,2)
printf, 1, 'infile = '+fitscl
printf, 1, 'outfile = '+fitsalm
printf, 1, 'rand_seed = '+strtrim(-seed,2)
printf, 1, 'fwhm_arcmin = '+strtrim(fwhm_arcmin,2)
printf, 1, 'polarisation = '+polarisation
if keyword_set(double) then printf, 1, "double_precision = true"
close,1

;write the datacard
close,1
openw,1,txtfile2
printf, 1, 'nlmax = '+strtrim(lmax,2)
printf, 1, 'nmmax = '+strtrim(lmax,2)
printf, 1, 'infile = '+fitsalm
printf, 1, 'outfile = '+fitsmap
printf, 1, 'nside = '+strtrim(nside,2)
printf, 1, 'polarisation = '+polarisation
printf, 1, 'fwhm_arcmin = '+strtrim(fwhm_arcmin,2)
if keyword_set(apply_windows) then printf, 1, "pixel_window = .true." else printf, 1, "pixel_window = .false."
if keyword_set(double) then printf, 1, "double_precision = true"
close,1

;launch syn_alm_cxx and alm2map_cxx
if not keyword_set(no_output_map) then begin
   spawn, 'syn_alm_cxx '+txtfile1
   spawn, 'alm2map_cxx '+txtfile2

;read the output map
;map = mrdfits(fitsmap,1,h)
;if not keyword_set(polarisation) then $
;   map = reform(map.temperature, n_elements(map.temperature))
    read_fits_map, fitsmap, map

;clean the tmp directory
    if not keyword_set(maps_fits_out) then $
       spawn,'rm -f '+fitsmap+' '+fitscl+' '+fitsalm+' '+txtfile1+' '+txtfile2
endif

exit:
return, map

end
