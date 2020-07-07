function build_phase, sim

dim = n_elements(sim)

case dim of
    2: begin
        nx = sim(0)
        ny = sim(1)
        if (nx mod 2) eq 0 then nx = nx + 1
        if (ny mod 2) eq 0 then ny = ny + 1        
        phase = fltarr( nx, ny )
        phase(*) = -32768.

        p1 = 2.0*(!pi)*randomu(seed, nx, (ny-1)/2. )-(!pi)
        phase(*,(ny-1)/2.+1:*) = p1
        phase(*,0:(ny-1)/2.-1) = -1*rotate(p1, 2)
        line = 2.0*(!pi)*randomu(seed, (nx-1)/2.+1 )-(!pi)
        phase(0:(nx-1)/2., (ny-1)/2.) = line
        phase((nx-1)/2.:*, (ny-1)/2.) = -1*reverse(line)
    end
    else : begin
        print, 'rien'
    endelse
endcase

return, phase

end
