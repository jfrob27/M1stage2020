pro read_planck_monopole_dipole, monodipo, file=file

if not keyword_set(file) then file = !DATA+'/Planck/DX9/results_dipole_offset.txt'

print, 'reading file offset : ', file

f = readmamd(file)

add_to_struct, monodipo, 'freq', reform(f[0,*])
add_to_struct, monodipo, 'cmbname', reform(f[1,*])
add_to_struct, monodipo, 'rmzody', reform(f[2,*])
add_to_struct, monodipo, 'nominal', reform(f[3,*])
add_to_struct, monodipo, 'hi_coeff_nodipolerm', float(reform(f[4,*]))
add_to_struct, monodipo, 'err_hi_coeff_nodipolerm', float(reform(f[5,*]))
add_to_struct, monodipo, 'offset_nodipolerm', float(reform(f[6,*]))
add_to_struct, monodipo, 'err_offset_nodipolerm', float(reform(f[7,*]))
add_to_struct, monodipo, 'hi_coeff_dipolerm', float(reform(f[8,*]))
add_to_struct, monodipo, 'err_hi_coeff_dipolerm', float(reform(f[9,*]))
add_to_struct, monodipo, 'offset_dipolerm', float(reform(f[10,*]))
add_to_struct, monodipo, 'err_offset_dipolerm', float(reform(f[11,*]))
add_to_struct, monodipo, 'hi_dipole_coeff', float(reform(f[12,*]))
add_to_struct, monodipo, 'err_offset_dipolerm', float(reform(f[13,*]))
add_to_struct, monodipo, 'coeff857_nodipolerm', float(reform(f[14,*]))
add_to_struct, monodipo, 'err_coeff857_nodipolerm', float(reform(f[15,*]))
add_to_struct, monodipo, 'offset857_nodipolerm', float(reform(f[16,*]))
add_to_struct, monodipo, 'err_offset857_nodipolerm', float(reform(f[17,*]))
add_to_struct, monodipo, 'coeff857_dipolerm', float(reform(f[18,*]))
add_to_struct, monodipo, 'err_coeff857_dipolerm', float(reform(f[19,*]))
add_to_struct, monodipo, 'offset857_dipolerm', float(reform(f[20,*]))
add_to_struct, monodipo, 'err_offset857_dipolerm', float(reform(f[21,*]))
add_to_struct, monodipo, 'dipole_coeff', float(reform(f[22,*]))
add_to_struct, monodipo, 'err_dipole_coeff', float(reform(f[23,*]))

end
