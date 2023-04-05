%design variables
        d = 0.0724;  %wire diameter (in)
        D = 0.6776;  %coil diameter (in)
        n = 7.5928;
        hf = 1.3691;
        
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