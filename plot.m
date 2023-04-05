% This program constructs a contour plot for the two-bar truss
% constants
clear; close all;

n = 7.5928;
hf = 1.3691;
delta_o = 0.4;    %deflection from preload height

ho = 1; %preload height (in)

G = 12E6; % (psi)
Se = 45000; % (psi)
w = 0.18;
Sf = 1.5;
Q = 150000; % (psi)

% design variables at mesh points
% [D,d] = meshgrid(0:0.1:3,0:0.05:0.1);
[d,D] = meshgrid(0.015:0.001:0.075,0.25:0.01:0.75);
 
% equations
hs = n.*d; %solid height (in)
hdef = ho - delta_o;
k = (G.*(d.^4))./(8.*(D.^3).*n); %spring stiffness
F_max = k.*(hf-(hdef));
F_min = k.*(hf-ho); %Force at Preload height
F_hs = k.*(hf-hs);
K = ((4.*D-d)./(4.*(D-d)))+((0.62.*d)./D); %Wahl factor

tao_max = ((8*F_max.*D)./(pi.*(d.^3))).*K;  
tao_min = ((8.*F_min.*D)./(pi.*(d.^3))).*K;
tao_hs = ((8.*F_hs.*D)./(pi.*(d.^3))).*K;

tao_m = (tao_max + tao_min)./2; %mean shear stress
tao_a = (tao_max - tao_min)./2; %alternating shear stress

Sy = (0.44.*Q)./(d.^w); %yield strength
ca = hdef - hs; %Clash Allowance
ratio = D/d;

T_test = [t_test,t_test.^2,t_test.^3,t_test.^4,t_test.^5,t_test.^6,t.^7,t.^8,t.^9,t.^10,t.^11,t.^12,t.^13,t.^14,t.^15,t.^16,t.^17,t.^18,t.^19];


 
% figure(1)
% [C,h] = contour(d,D,F_min,1:2:20,'k-');
% clabel(C,h,'Labelspacing',250);
% title('Spring Design Plot');
% xlabel('Wire diameter');
% ylabel('Coil diameter');
% hold on;
% 
% % solid lines to show constraint boundaries
% contour(d,D,(-(Se/Sf)+tao_a),[0,0],'g-','LineWidth',2); % tao_a <= Se/Sf
% contour(d,D,(-(Sy/Sf)+(tao_a + tao_m)),[0,0],'r-','LineWidth',2);
% contour(d,D,(4-(D./d)),[0,0],'y-','LineWidth',2);
% contour(d,D,((D./d)-16),[0.0,0.0],'c-','LineWidth',2);
% contour(d,D,((D+d)-0.75),[0.0,0.0],'m-','LineWidth',2);
% contour(d,D,(0.05-ca),[0.0,0.0],'b-','LineWidth',2);
% contour(d,D,(tao_hs-Sy  - hdef),[0.0,0.0],'k-','LineWidth',2);

figure(1)
[C,h] = contour(D,d,F_min,1:2:20,'k-');
clabel(C,h,'Labelspacing',250);
title('Spring Design Plot');
xlabel('Coil diameter');
ylabel('Wire diameter');
hold on;

% solid lines to show constraint boundaries
contour(D,d,(-(Se/Sf)+tao_a),[0,0],'g-','LineWidth',2); % tao_a <= Se/Sf
contour(D,d,(-(Sy/Sf)+(tao_a + tao_m)),[0,0],'r-','LineWidth',2);
contour(D,d,(4-(D./d)),[0,0],'y-','LineWidth',2);
contour(D,d,((D./d)-16),[0.0,0.0],'c-','LineWidth',2);
contour(D,d,((D+d)-0.75),[0.0,0.0],'m-','LineWidth',2);
contour(D,d,(0.05-ca),[0.0,0.0],'b-','LineWidth',2);
contour(D,d,(tao_hs-Sy  - hdef),[0.0,0.0],'k-','LineWidth',2);

% show a legend
legend('Force','tao_a<=Se/Sf','tao_a+tao_m<=Sy/Sf','4<=D/d','D/d<=16','D+d<=0.75','0.05<=ca','tao_hs<=Sy')
hold off;
