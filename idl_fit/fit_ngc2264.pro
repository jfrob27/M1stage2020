PRO fit_ngc2264

wav_k=[0.01071428, 0.01423756, 0.01891942, 0.02514087, 0.03340817, 0.04439408, 0.05899259, 0.07839166, 0.10416991, 0.13842505, 0.18394462, 0.2444328 , 0.32481186, 0.4316227 , 0.57355712, 0.76216512, 1.01279481, 1.34584135, 1.78840661, 2.37650462, 3.15799226]

gauss=[8.00970106e+04,  1.03365055e+05,  8.76037389e+04,  1.15934842e+05, 6.90837154e+04,  4.74423266e+04,  6.11652452e+03,  9.49344149e+02, 7.22893753e+02,  1.40459949e+02,  5.18952301e+01,  1.46342795e+01, 3.43221803e+00,  9.04186969e-01,  3.65474885e-01,  1.20555502e-01, -1.56019887e-01, -1.54893691e+00, -2.10515245e+01, -1.43118625e+02, -1.37588817e+03]

coherent=[-1.97397876e-02, -1.97397876e-02, -1.97397876e-02, -1.97397876e-02, -1.99320433e-02,  1.28821178e+04,  3.20512635e+04,  1.78302681e+04, 1.11333130e+04,  8.24230700e+03,  4.91335697e+03,  1.87205350e+03, 8.30772257e+02,  3.84500130e+02,  2.01628875e+02,  1.20015451e+02, 8.92441993e+01,  5.88836758e+01,  4.53111123e+01, -8.94347970e+01, -1.36033821e+03]

A=[335.670, -1.43023, 6.33016]

std_gauss= 39577.6
std_coherent=8031.2

weights_gauss = 1.0/(gauss/std_gauss)^2
weights_cohe = 1.0/(coherent/std_coherent)^2

curve_w = CURVEFIT(wav_k[8:15], gauss[8:15], weights_gauss[8:15], A, sigma, CHISQ=chisq, fita=[1,1,1], FUNCTION_NAME='power_law',itmax=1000)

print, A

END