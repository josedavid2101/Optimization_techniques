%-------------------------Battery Design Project---------------------------
% Filename: optimize_battery.m
% Authors: Jose Nino, Sterling Baird, Chris Adair
% Date: 2019-02-05
%
%--------------------------------------------------------------------------
function [xopt, fopt, exitflag, output] = optimize_battery()
%global cathcct anP cathccP anccP ELM T Bcomp v area ...
%    Srho Lirho Crho Brho seprho ELrho cathccrho anccrho ...
%    Sspcost Cspcost sepspcost ELspcost Lispcost cathcctspcost ancctspcost ...
%    spcapfn
global spcapfn objtype

    % ------------Starting point and bounds------------
    %   [catht (m), sept (m), ant (m), cathP, sepP, Scomp]
    x0 =[50E-6,    500E-6,    100E-6,   0.75,  0.75,  0.7];
    %spE
    %x0 = [4.871663323203450e-05,9.270496335072882e-04,8.579569076818079e-05,0.733164179032830,0.805003391848841,0.767870448685762];
    %x0 = [7.297812390072940e-05,2.510269534061027e-04,1.330635592563322e-04,0.778488718004170,0.896515215971017,0.754941528929382];
    %costE
    %x0 =[1.923638807910668e-05,1.002457301643861e-06,1.018225080746526e-06,0.899934182836080,0.200051383657770,0.750055395362228];
    ub =[1E-3,      1E-3,     1E-3,    0.90,  0.90,  0.899];
    lb =[1E-6,      1E-6,     1E-6,    0.10,  0.20,  0.01];
    %^^^^^^^^^^^^^Starting point and bounds^^^^^^^^^^^^

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    %^^^^^^^^^^^^^Linear constraints^^^^^^^^^^^^
    
    %---Specific Capacity---
    % Interpolated data for ELS, LS, and CS to compute spcap

    load('ELS_LS_CS_spcap.mat','ELS_LS_CS_spcap');
    pts = ELS_LS_CS_spcap(:,1:3);
    vals = ELS_LS_CS_spcap(:,4);
    spcapfn = scatteredInterpolant(pts,vals,'natural','linear');
    %usage: spcap = spcapfn(ELS,LS,CS), units of spcap: mAh/g
    %^^^Specific Capacity^^^
    
    %objcon(x0)
    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        
        objtype = 1; %1 == spE (drone), 2 == VE (cell-phone), 3 == costE (solar battery storage)
        
        %-----------Design Variables------------
        catht  =   x(1);
        sept   =   x(2);
        ant    =   x(3);
        cathP  =   x(4);
        sepP   =   x(5);
        Scomp  =   x(6);
        %^^^^^^^^^^^Design Variables^^^^^^^^^^^^
        
        %-------------Analysis Variables------------
        %values for cathcct and anccttemp from doi: 10.1149/2.0611506jes
        cathcct = 20E-6;    %Thickness of cathode current collector, m
        anccttemp = 8E-6;   %Thickness of anode current collector, m
        anP = 0.1;          %Porosity of anode
        cathccP = 0;        %Porosity of cathode current collector
        anccP = 0;          %Porosity of anode current collector
        ELM = 1;            %Electrolyte Molarity, M
        T = 23;             %Operation temperature, deg-C
        Bcomp = 0.1;        %Cathode binder mass composition, (mass fraction)
        v = 2.15;           %Nominal voltage of each cell, Volts
        area = 1;           %Superficial area of components, m^2      

        %-------Densities-------
        % unit: kg/m^3 (g/cm^3 = mg/mm^3 = 1E-9 mg/um^3 = 1E-12 g/um^3 = 1000 kg/m^3)
        Srho = 2E3;         %Sulfur
        Lirho = 0.534E3;    %Lithium
        Crho = 2.26E3;      %Carbon
        Brho = 1.78E3;      %Binder, assuming PVdF
        seprho = 0.946E3;   %Separator, assuming polypropylene (PP)
        ELrho = 1.14E3;     %Electrolyte, assuming 1M LiTFSI in 1:1 v:v DME:DIOX
        cathccrho = 2.7E3;  %Cathode current collector
        anccrho = 8.96E3;   %Anode current collector
        %^^^^^^^Densities^^^^^^^

        %-----Specific Cost-----
        % unit: $/kg
        % data obtained from doi: 10.1149/2.0611506jes
        Sspcost = 0.22;                         %Sulfur
        Cspcost = 15;                           %Carbon
        Bspcost = 10;                           %Binder
        sepspcost = 2;                          %Separator
        ELspcost = 12*1000/ELrho;               %Electrolyte, ($/L = 1000$/m^3)
        Lispcost = 100;                         %Lithium
        cathccspcost = 1.8/cathcct/cathccrho;   %Cathode current collector ($/m^2/m = $/m^3)
        anccspcost = 0.8/anccttemp/anccrho;     %Anode current collector
        %^^^^^Specific Cost^^^^^

        %^^^^^^^^^^^^^Analysis Variables^^^^^^^^^^^^

        
        %----------Analysis Functions-----------
        Ccomp = 1-Scomp-Bcomp; %Cathode carbon composition
        
        %------Volume------
        %unit: m^3
        cathV = catht*area;                         %cathode
        cathccV = cathcct*area;                     %cathode current collector
        sepV = sept*area;                           %separator
        anV = ant*area;                             %anode             
        %--free/open--
        cathFV = cathP*(cathV-cathccV*(1-cathccP)); %cathode
        sepFV = sepP*sepV;                          %separator
        %^^free/open^^
        Vtot = cathV+sepV+anV;                      %battery
        %^^^^^^Volume^^^^^^
        
        %-------Mass-------
        %unit: kg
        cathccm = (cathccV*(1-cathccP))/cathccrho;
        
        %----Sulfur----
        %solution obtained using Mathematica
        %---eqns---
        %eqn1: Sm/Srho+Cm/Crho+Bm/Brho == (cathV-cathFV-cathccV);
        %eqn2: Sm+Cm+Bm == cathm-cathccm;
        %eqn3: Sm/Cm == Scomp/Ccomp;
        %eqn4: Sm/Bm == Scomp/Bcomp;
        %^^^eqns^^^
        
        Sm = Brho*(-cathccV+cathV)*Crho*Scomp*Srho/...
            (Brho*Crho*Scomp+Brho*Ccomp*Srho+Bcomp*Crho*Srho);   %sulfur

        %^^^^Sulfur^^^^
        
        cathm = Sm/Scomp+cathccm;       %cathode
        Cm = cathm*Ccomp;               %Carbon
        Bm = cathm*Bcomp;               %Binder
        sepm = (sepV-sepFV)/seprho;     %Separator

        CS = Cm/Sm;                     %Carbon to sulfur mass ratio
        
        %-----Anode----
        if ant <= 20E-6
            anccttemp = 6.25E-6;        %Anode current collector
        else
            anccttemp = 0;
        end
        
        Limtemp = (ant-anccttemp)*area*Lirho;   %Lithium (temporary)
        LStemp = Limtemp/Sm;                    %Li:S mass ratio (temporary)
        
        %Add current collector if anode thickness is too low or Li:S
        %ratio is too low, otherwise no current collector
        if ant <= 20E-6 || LStemp <= 0.67
            ancct = 6.25E-6;
        else
            ancct = 0;
        end
        Lit = ant-ancct;
        Lim = Lit*area*Lirho;               %Lithium (final)
        anccV = ancct*area;                 %Anode current collector volume
        anccm = (anccV*(1-anccP))/anccrho;  %Anode current collector
        anm = Lim+anccm;                    %Anode
        %^^^^^Anode^^^^
        
        %------EL------
        anFV = anP*(anV-anccV*(1-anccP));   %anode, fixed dependency issue
        FVtot = cathFV+sepFV+anFV;
        ELV = FVtot;                        %electrolyte (assume no excess)
        ELm = ELV*ELrho;                    %Electrolyte
        %^^^^^^EL^^^^^^
        
        ELS = ELm/Sm;                       %Electrolyte to sulfur mass ratio
        LS = Lim/Sm;                        %Li:S mass ratio (final)
        
        mtot = cathm+sepm+ELm+anm;          %Full battery, excluding housing
        %^^^^^^^Mass^^^^^^^
        
        i = 502.513*(mtot)/v;           %current, A (i.e. W/kg*kg/V = A)
        spcap = spcapfn(ELS,LS,CS);     %specific capacity, Ah/kg
        
        switch objtype
            case 1
                spcap = spcap*0.3;      %reduced because such a high current used
            case 2
                spcap = spcap*0.85;     %reduced because moderate current used
            case 3
                spcap = spcap*1.0;      %not reduced because low current used
        end

        E = spcap*Sm*v;                 %Energy, Wh
        spE = E/mtot;                   %Specific energy, Wh/kg
        VE = E/Vtot/1000;               %volumetric energy density, Wh/L
        
        %-------Cost-------
        cathcost = Sm*Sspcost+Cm*Cspcost+...
            Bm*Bspcost+cathccm*cathccspcost;        %cathode
        sepcost= sepm*sepspcost;                    %separator
        ELcost = ELm*ELspcost;                      %electrolyte
        ancost = Lim*Lispcost+anccm*anccspcost;     %anode
        costtot = cathcost+sepcost+ELcost+ancost;   %battery
        %^^^^^^^Cost^^^^^^^
        Ecost = E/(costtot*1000);
        costE = 1/Ecost;  %Energy cost, $/kWh
        
        %^^^^^^^^^^Analysis Functions^^^^^^^^^^^
        
        %----------Objective Function-----------
        switch objtype
            case 1
                f = -spE;
            case 2
                f = -VE;
            case 3
                f = costE;
        end
        %^^^^^^^^^^Objective Function^^^^^^^^^^^
        
        %-------------Constraints---------------
        c(1) = ELS-20;  % ELS <= 20
        c(2) = 1-ELS;   % 1 <= ELS
        c(3) = CS-0.2;  % CS <= 0.2
        c(4) = 0.01-CS; % 0.01 <= ELS
        c(5) = LS-3;    % LS <= 3
        c(6) = 0.33-LS; % 0.33 <= LS        
        %^^^^^^^^^^^^^Constraints^^^^^^^^^^^^^^^
        
        %equality constraints (ceq=0)
        ceq = [];
    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon, 'display', 'iter-detailed');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    
    xopt;
    if objtype ~= 3
        fopt = -fopt;
    end
    exitflag;
    output;
    switch objtype
        case 1
            'Maximize Specific Energy, Wh/kg (drone)'
        case 2
            'Maximize Vol. Energy Density, Wh/L (cell phone)'
        case 3
            'Minimize Energy Cost $/kWh (solar battery storage)'
            %Maximize Energy Value?
    end
    
    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x)
            [f, ~, ~] = objcon(x);
            f
    end
    function [c, ceq] = con(x)
            [~, c, ceq] = objcon(x);
            c
            
    end
end