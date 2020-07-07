function compute_cloud, amplitude, phase

imRE = amplitude * cos(phase)
imIM = amplitude * sin(phase)
imfft = complex( imRE, imIM )
image = float( fft(imfft, 1) )

return, image

end
