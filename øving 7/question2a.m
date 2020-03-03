K_1 = 1;
K_2 = 1;
K_3 = 1;
T = 0.1;
x_0 = [5 1]';
x_hat_o = [6 0]';

Ad = [1 T; -K_2*T 1-K_1*T];
bd = [0 K_3*T]';


Q = [4 0; 0 4];
R = 1;


[K, S, e] = dlqr(Ad,bd,0.5*Q,0.5*R,[]);
