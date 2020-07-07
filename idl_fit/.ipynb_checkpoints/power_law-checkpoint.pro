PRO power_law, X, A, F,pder
	
  F = A[0]*X^A[1]+A[2]
  
;If the procedure is called with four parameters, calculate the partial derivatives.  
  IF N_PARAMS() GE 4 THEN $  
    pder = [[X^A[1]], [A[0]*X^A[1]*alog(X)], [replicate(1.0, N_ELEMENTS(X))]]
END