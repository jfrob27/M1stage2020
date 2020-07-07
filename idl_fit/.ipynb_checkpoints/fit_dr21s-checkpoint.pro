PRO fit_dr21s

wav_k=[0.01071428, 0.01423756, 0.01891942, 0.02514087, 0.03340817, 0.04439408, 0.05899259, 0.07839166, 0.10416991, 0.13842505, 0.18394462, 0.57355712, 0.76216512, 1.01279481, 1.34584135, 1.78840661, 2.37650462, 3.15799226]

gauss=[5.93707727e+04,  4.16585232e+04,  3.11448460e+04,  6.15652486e+04, 5.90816371e+04,  4.63543927e+04,  9.24792519e+03,  3.96149992e+03, 1.20983030e+03,  5.28185932e+02,  1.29945205e+02,  7.15539870e+01, 2.89830225e+01,  1.22541034e+01,  6.04813665e+00,  1.94590577e+00, -1.11675898e+00, -1.16977754e+01, -1.56038611e+02, -1.03527370e+03, -9.87631780e+03]

coherent=[-1.41652651e-01, -1.41652651e-01, -1.41652651e-01, -1.41652651e-01, -1.43032277e-01,  8.94258436e+03,  4.54804507e+04,  3.70867171e+04, 2.37172816e+04,  1.67151943e+04,  1.14763750e+04, 2.45522724e+03,  1.50828684e+03, 9.35371607e+02,  6.91093642e+02,  5.32496710e+02, -6.03980678e+02, -9.67601253e+03]

A=[1323.75, -1.43021, 2485.41]

std_gauss= 23382.1
std_coherent=12980.9

weights_gauss = 1.0/(gauss/std_gauss)^2
weights_cohe = 1.0/(coherent/std_coherent)^2

curve_w = CURVEFIT(wav_k[7:15], coherent[7:15], weights_cohe[7:15], A, sigma, CHISQ=chisq, fita=[1,1,1], FUNCTION_NAME='power_law',itmax=1000)

print, A

END