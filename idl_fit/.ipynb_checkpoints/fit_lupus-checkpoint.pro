PRO fit_lupus

wav_k=[0.00779221, 0.01035459, 0.01375958, 0.01828427, 0.02429685, 0.03228661, 0.0429037 , 0.05701212, 0.07575993, 0.10067276, 0.1337779 , 0.17776931, 0.23622681, 0.31390742, 0.41713245, 0.55430191, 0.73657805, 0.97879371, 1.30065935, 1.728367  , 2.29672165, 3.05197352]

gauss=[8.72999370e+03,  1.03262514e+04,  1.55358819e+04,  9.60307474e+03, 7.39919335e+03,  3.08436552e+03,  9.00422737e+02,  1.60888518e+02, 6.40794889e+01,  1.21907792e+01,  4.02698344e+00,  1.45791671e+00, 2.34091076e-01,  1.15027747e-01,  6.18688362e-02,  4.40938899e-02, 3.40965444e-02,  3.63326001e-02,  4.55334279e-02, -1.20999444e-01, -4.52494852e+00, -4.56950870e+01]

coherent=[-2.35888626e-02, -2.35888626e-02, -2.35888626e-02, -2.35888626e-02, 4.21513093e+03,  8.57369732e+03,  5.66984445e+03,  2.14821142e+04, 1.39992036e+04,  1.04107928e+04,  7.69936160e+03,  4.39516265e+03, 2.50144198e+03,  1.35434112e+03,  7.94713907e+02,  4.30129402e+02, 2.39044582e+02,  1.33597123e+02,  7.77137234e+01,  4.52370984e+01, 2.87282959e+01, -8.34163693e+00, -2.59719062e+02]

A=[0.00165558, -2.03236,  0.0202255]

std_gauss= 4473.7
std_coherent=5461.8

weights_gauss = 1.0/(gauss/std_gauss)^2
weights_cohe = 1.0/(coherent/std_coherent)^2

curve_w = CURVEFIT(wav_k[10:16], gauss[10:16], weights_gauss[10:16], A, sigma, CHISQ=chisq, fita=[1,1,1], FUNCTION_NAME='power_law',itmax=1000)

print, A

END