function [xopt, fopt, exitflag, output] = optimize_template()

    % ------------Starting point and bounds------------
    x0 = [0.05, 0.5, 10, 1.5]; % d,D,n,hf
    ub = [0.2, 10, 100, 15];
    lb = [0.01, 0.01, 1, 0.15];

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        
%         %design variables
%         d = x(1);  %wire diameter (in)
%         D = x(2);  %coil diameter (in)
%         n = x(3);  %number of coils in the spring
%         hf = x(4);  %free height (in)
        
        %%make design variables of class valder
        d = valder(x(1),[1 0 0 0]);
        D = valder(x(2),[0 1 0 0]);  %coil diameter (in)
        n = valder(x(3),[0 0 1 0]);  %number of coils in the spring
        hf = valder(x(4),[0 0 0 1]);  %free height (in)
        
        %other analysis variables
        delta_o = 0.4;    %deflection from preload height
        hs = n*d; %solid height (in)
        ho = 1; %preload height (in)
        
        G = 12E6; % (psi)
        Se = 45000; % (psi)
        w = 0.18;
        Sf = 1.5;
        Q = 150000; % (psi)
        
        %analysis functions
        
        hdef = ho - delta_o;
        k = (G*(d^4))/(8*(D^3)*n); %spring stiffness
        F_max = k*(hf-(hdef));
        F_min = k*(hf-ho); %Force at Preload height
        F_hs = k*(hf-hs);
        K = ((4*D-d)/(4*(D-d)))+((0.62*d)/D); %Wahl factor
        
        tao_max = ((8*F_max*D)/(pi*(d^3)))*K;  
        tao_min = ((8*F_min*D)/(pi*(d^3)))*K;
        tao_hs = ((8*F_hs*D)/(pi*(d^3)))*K;
        
        tao_m = (tao_max + tao_min)/2; %mean shear stress
        tao_a = (tao_max - tao_min)/2; %alternating shear stress
        
        Sy = (0.44*Q)/(d^w); %yield strength
        ca = hdef - hs; %Clash Allowance

        %objective function
        f = -F_min;
        
        %inequality constraints (c<=0)
%         c = zeros(3,1);         % create column vector
        c(1) = -(Se/Sf)+tao_a;   % tao_a <= Se/Sf
        c(2) = -(Sy/Sf)+(tao_a + tao_m);  % tao_a + tao_m <= Sy/Sf
        c(3) = 4-(D/d);  % 4 <= (D/d)
        c(4) = (D/d)-16;  %(D/d) <= 16
        c(5) = (D+d)-0.75;  %(D+d) <= 0.75in
        c(6) = 0.05-ca;  %0.05 <= ca
        c(7) = tao_hs-Sy  - hdef;  %tao_hs <= Sy
        
        %equality constraints (ceq=0)
        ceq = [];
        
        %return functions and variables
        func = [ca.val, Sy.val, tao_a.val, tao_m.val tao_hs.val, tao_min.val, tao_max.val, F_min.val F_max.val];
        grad = [ca.der; Sy.der; tao_a.der; tao_m.der; tao_hs.der; tao_min.der; tao_max.der; F_min.der; F_max.der];
        grad = grad';
        
    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon, 'display', 'iter-detailed');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    -fopt
    
    
    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x)
            [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x)
            [~, c, ceq] = objcon(x)
    end
end