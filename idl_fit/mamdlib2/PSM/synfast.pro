function synfast, cl, nside, fwhm_arcmin=fwhm_arcmin, beam=beam, $
                  lmax=lmax, seed=seed, simul_type = simul_type, $
                  almsfile=almsfile, plmfile=plmfile, verbose=verbose, $
                  maps_fits_out = maps_fits_out, apply_windows = apply_windows, $
                  tmpdir = tmpdir, no_output_map=no_output_map
;+
; NAME:  SYNFAST
;
; PURPOSE:
;    launch the synfast HEALPix Fortran software.
;    simulate a CMB map.
;
; CATEGORY:
;    CMB simulation
;
; CALLING SEQUENCE:
; map = synfast(cl, nside,[fwhm_arcmin=fwhm_arcmin, beam=beam, $'
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
;    + created by Matthieu Tristram    - dec 2002 -
;    + Updated to match HEALpix_2.00 and further. Kept /polar and
;      maps_fits_out for compatibility with previous version, NP,
;      Feb. 17th, 2006
;    + added /apply_windows, NP, Feb. 24th, 2006
;    + removed /polar to avoid inteferences with simul_type, NP,
;    August 30th, 2006
;    + Nov 15th, 2006, NP : added /tmpdir and no_output_map when i
;    just want to save the synfast parameter file to feed a bach job
;    later on.
;-

if n_params() ne 2 then begin
    message, /info, 'Call is : '
    message, /info, 'map = synfast(cl, nside,'
    message, /info, ' [fwhm_arcmin=fwhm_arcmin, beam=beam, $'
    message, /info, ' lmax=lmax, seed=seed, simul_type = simul_type, $'
    message, /info, ' almsfile=almsfile, plmfile=plmfile, verbose=verbose, $'
    message, /info, ' maps_fits_out = maps_fits_out]'
    map = -1
    goto, exit
endif

;create files
if not keyword_set(tmpdir) then tmpdir='/tmp/'
machin = long(randomu(theseed,1)*1e6)
truc   = strtrim(machin,2)
fitsmap  = tmpdir+'tmpmap'+truc[0]+'.fits'
fitscl   = tmpdir+'tmpcl'+truc[0]+'.fits'
txtfile  = tmpdir+'txt'+truc[0]+'.txt'
beamfile = tmpdir+'beam'+truc[0]+'.fits'
spawn,'rm -f '+fitsmap+' '+fitscl+' '+txtfile

if not keyword_set(simul_type) then simul_type = 1
;if not keyword_set(almsfile) then almsfile=''
if not keyword_set(seed) then seed=machin
if not keyword_set(fwhm_arcmin) then fwhm_arcmin=0d0
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
openw,1,txtfile
printf, 1, 'simul_type = '+strtrim(simul_type,2)
printf, 1, 'nsmax = '+strtrim(nside,2)
printf, 1, 'nlmax = '+strtrim(lmax,2)
printf, 1, 'infile = '+fitscl
printf, 1, 'iseed = '+strtrim(-seed,2)
printf, 1, 'fwhm_arcmin = '+strtrim(fwhm_arcmin,2)
if keyword_set(beam) then printf, 1, 'beam_file = '+beamfile else printf, 1, "beam_file = ''"
if keyword_set(almsfile) then printf, 1, 'almsfile = '+almsfile else printf, 1, "almsfile = ''"
if keyword_set(apply_windows) then printf, 1, "apply_windows = .true." else printf, 1, "apply_windows = .false."
if keyword_set(plmfile) then printf, 1, 'plmfile = '+plmfile else printf, 1, "plmfile = ''"
printf, 1, 'outfile = !'+fitsmap
close,1

;launch synfast


if not keyword_set(no_output_map) then begin
    if keyword_set(verbose) then begin 
        spawn, 'synfast '+txtfile
    endif else begin
        tmpfile=tmpdir+'tmp'+truc(0)+'.txt'
        spawn, 'synfast '+txtfile+' >! '+tmpfile
        spawn,'rm -f '+tmpfile
    endelse

;read the output map
;map = mrdfits(fitsmap,1,h)
;if not keyword_set(polarisation) then $
;   map = reform(map.temperature, n_elements(map.temperature))
    read_fits_map, fitsmap, map

;clean the tmp directory
    if not keyword_set(maps_fits_out) then $
      spawn,'rm -f '+fitsmap+' '+fitscl+' '+txtfile
endif

exit:
return, map

end
