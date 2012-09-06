%% Weighted Essentially non-Oscilaroty (WENO) Routine
% to solve the scalar advection equation:
%
% du/dt + dF(u)/dx = 0
%
% where $dF/du = a$
%
% by Manuel Diaz, manuel.ade'at'gmail.com 
% Institute of Applied Mechanics, 2012.08.20

clear all; close all; clc;

%% Parameters
      a = -0.5;     % Scalar velocity in x direction
    a_p = max(0,a); % a^{+}
    a_m = min(0,a); % a^{-}
     dx = 0.01;      % Spatial step size
    cfl = 0.8;      % Courant Number
     dt = cfl*dx/abs(a); % time step size
   dtdx = dt/dx;    % precomputed to save some flops
  t_end = 0.5;      % End time
      k = 3;        % WENO Order: 1st, 2nd and 3rd Orders available.

%% Discretization of Domain
x = 1:dx:2;
t = 0:dt:t_end;

%% Initial Condition
   n = length(x);
 u_0 = ones(1,n);
 x_1 = ceil(2*n/5);
 x_2 = ceil(3*n/5);
u_0(x_1:x_2) = 2;

%% Main Loop
% Load initial condition into the domain
u = u_0; 

% Initialize vector variables 
u_next = zeros(1,n);

for kk = t
    % Compute WENO Fluxes:
    [F_l,F_r] = WENOflux1d(u,a);
    
    % Compute new Step:
    u_next = u - dtdx*(F_r - F_l); 
    
    % Update BCs: All Neumann BC's
   	u_next(1)  = u_next(4); 
    u_next(2)  = u_next(4);
    u_next(3)  = u_next(4);
    
    u_next(n  ) = u_next(n-3);
    u_next(n-1) = u_next(n-3);
    u_next(n-2) = u_next(n-3);
    
    % UPDATE info
    u = u_next;
end

%% 2. Double-Sided Upwind
u_upwind = u_0;
for k = t
    for j = 2:n-1
    u_next(j) = u_upwind(j) - a_p*dt/dx*(u_upwind(j) - u_upwind(j-1)) ...
        - a_m*dt/dx*(u_upwind(j+1) - u_upwind(j));
    end
    u_upwind = u_next;
    % BC
    u_upwind(1) = u_next(2);
    u_upwind(n) = u_next(n-1);
end
u_next = zeros(1,n);

%% 3. Lax-Wendroff
u_LW = u_0;
for k = t
    for j = 2:n-1
    u_next(j) = u_LW(j) - 1/2*a*dt/dx*(u_LW(j+1)-u_LW(j-1)) + ...
        1/2*(cfl^2)*(u_LW(j+1)-2*u_LW(j)+u_LW(j-1));
    end
    u_LW = u_next;
    % BC
    u_LW(1) = u_next(2);
    u_LW(n) = u_next(n-1);
end
u_next = zeros(1,n);

%% Exact Solution
x_exact_1 = 1.4 + a*t_end;
x_exact_2 = 1.6 + a*t_end;
u_exact = zeros(1,n);
for j = 1:n
    if x(j) >= x_exact_1 && x(j) <= x_exact_2
    u_exact(j) = 2;
    else
    u_exact(j) = 1;
    end
end
    
%% Plot Results
subplot(311);
hold on
plot(x,u_upwind,'.'); plot(x,u_exact,'k'); xlabel('X-Coordinate [-]'); ylabel('U-state [-]'); yLim([0.5,2.5]); title 'Double-Sided Upwind'; 
hold off
subplot(312);
hold on
plot(x,u_LW,'.'); plot(x,u_exact,'k'); xlabel('X-Coordinate [-]'); ylabel('U-state [-]'); yLim([0.5,2.5]); title 'Lax-wendroff';
hold off
subplot(313);
hold on
plot(x,u,'.'); plot(x,u_exact,'k'); xlabel('X-Coordinate [-]'); ylabel('U-state [-]'); yLim([0.5,2.5]); title 'WENO3';
hold off