%% Assignment 5, Problem 2 b)
%  MPC with quadprog. Perfect model.
%  Tor Aksel N. Heirung, April 2013.

%% Problem data
% System matrices, model
A = [0     0     0    ;
      0     0     1    ;
      0.1  -0.79  1.78];
B = [1 0 0.1]';
C = [0 0 1];

x0 = [0 0 1]'; % Initial state

N = 30; % Length of time horizon
nx = size(A,2); % number of states (equals the number of rows in A)
nu = size(B,2); % number of controls (equals the number of rows in B)

% Cost function
I_N = eye(N);
Qt = 2*diag([0, 0, 1]);
Q = kron(I_N, Qt);
Rt = 2*1;
R = kron(I_N, Rt);
G = blkdiag(Q, R);

% Equality constraint
Aeq_c1 = eye(N*nx);                         % Component 1 of A_eq
Aeq_c2 = kron(diag(ones(N-1,1),-1), -A);    % Component 2 of A_eq
Aeq_c3 = kron(I_N, -B);                     % Component 3 of A_eq
Aeq = [Aeq_c1 + Aeq_c2, Aeq_c3];
% b_eq varies with time


% Inequality constraint
x_lb = -Inf(N*nx,1);    % Lower bound on x
x_ub =  Inf(N*nx,1);    % Upper bound on x
u_lb = -ones(N*nu,1);   % Lower bound on u
u_ub =  ones(N*nu,1);   % Upper bound on u
lb = [x_lb; u_lb];      % Lower bound on z
ub = [x_ub; u_ub];      % Upper bound on z

%% MPC

opt = optimset('Display','off', 'Diagnostics','off', 'LargeScale','off', 'Algorithm', 'interior-point-convex');

u = NaN(nu,N);
x = NaN(nx,N+1);
x(:,1) = x0;

% Initialize beq
beq = [zeros(nx,1); zeros((N-1)*nx,1)];

% Simulate and solve optimization problem at each step
for t = 1:N
    
    % Update equality constraint with latest measurement x_t = x(:,t)
    beq(1:nx) = A*x(:,t);
    
    % Solve optimization problem
    [z,fval,exitflag,output,lambda] = quadprog(G,[],[],[],Aeq,beq,lb,ub,[],opt);
    
    % Extract optimal control from solution z
    u_ol = z(N*nx+1:N*nx+N*nu);    % Control, open-loop optimal
    u(t) = u_ol(1:nu); % Only first element is used
    
    % Simulate system one step ahead
    x(:,t+1) = A*x(:,t) + B*u(t);
    
end

y = C*x;

%% Plot
t_vec = 1:N; % Time vector

% Plot optimal trajectory
figure(1);
subplot(2,1,1);
plot([0,t_vec],y,'-o');
grid('on');
box('on');
ylim([-0.5, 2.5]);
ylabel('y_t');
subplot(2,1,2);
plot(t_vec-1,u,'-o');
box('on');
grid('on');
ylim([-1.5, 0.5]);
xlabel('t');
ylabel('u_t');
