% LAST UPDATED: Aug. 25, 2022

function [spike, V] = smallDRG_DIV0(amp, duration, stim_on, stim_length)
with_noise = 1;

%% Cell Properties
% Cell Morphology:
r = 11.63; % [um] cell radius
CellArea = 4*pi*(r^2);   % [um2] cell area (sphere)
SAV = 3/(r*10^-4);% surface area to volume ratio (um to cm)

% Cell Capacitance:
Cr = 17; %[pF] 
C = (Cr/CellArea)*100;  % [uF/cm^2]

% Cell Resistance:
% Rr = 2.5; % real cell resistance in [GOhms]
% R = (Rr * CellArea)*10; % model cell resistance in [Ohms*cm^2]

% Reversal Potential [mV]:
Ena = 50; 
Ek = -90;
ELeak = -62.5; % [mV] mean RMP of DIV0 neurons = -62.5196 after JP correction(+15mV)


%**** BASELINE: rheo = 17pA
gLeak = 0.025; %(1/Rr)/CellArea*(10^2); % [mS/cm2] normalized by cell area
gAHP =  2.5; 
gKm = 0.05;
gKdr = 3.5; 
beta_z_AHP = 5;% [mV]
gamma_z =  4; % [mV] - same for gAHP and gM
tau_z = 100; 

%** Na conductances:
g_nav1p3 = 0; 
g_nav1p8 = 30;% native
g_nav1p7 = 3; % native 
% g_nav1p9 = 0; 

%**** PHARMACOLOGY
% g_nav1p8 = 4; % 90% block - rheo = 17pA

%**** DYNAMIC CLAMP EXPERIMENT
% g_nav1p7 = 40; % rheo = 6 pA

%% Stimulus parameters
dt = 0.01;  % time step for forward euler method
loop  = duration/dt;   % no. of iterations of euler
stim_off = stim_on + stim_length; % [ms]

%% Noise parameters
mu_noise = 0;
tau_noise = 5; % (ms)
sigma_noise = 0.05; %.1; % ~ sigma(noise) ~ 0.5 uA/cm2

%% Initialize empty vectors for storing currents and gating variables
V = zeros(1,loop);

INaV1p3 = zeros(1,loop); 
INaV1p7 = zeros(1,loop);
INaV1p8 = zeros(1,loop);
IKdr = zeros(1,loop);
IKm = zeros(1,loop);
ILeak = zeros(1,loop);
IAHP = zeros(1,loop);
Ihold = -3;
Istim = zeros(1,loop)+(Ihold*10^-6)/(CellArea*10^-8); % convert pA to um/cm2
Inoise = zeros(1,loop);

m3 = zeros(1,loop); 
m7 = zeros(1,loop);
h7 = zeros(1,loop); 
h3 = zeros(1,loop); 
m8 = zeros(1,loop);
h8 = zeros(1,loop);

ndr = zeros(1,loop);
ldr = zeros(1,loop);
nm = zeros(1,loop);

z_AHP = zeros(1,loop); % Prescott et al. 2008

spike = zeros(1,loop);
ref = zeros(1,loop);

%% Set initial values:
m3(1) = 0; 
m7(1) = 0;
m8(1) = 0;
h3(1) = 0; 
h7(1) = 0; 
h8(1) = 0.9952;

ndr(1) =  0;
ldr(1) = 0.6487;
nm(1) =  0.0014;

V(1) = -69.5;



%% Run simulation
Istim(stim_on/dt:stim_off/dt) = Istim(stim_on/dt:stim_off/dt)+(amp*10^-6)/(CellArea*10^-8); % convert pA to um/cm2

for step = 1:loop-1 % Euler method
    %% Voltage Calculation
    dV_dt = (Istim(step) + Inoise(step) - INaV1p3(step) - INaV1p7(step) - INaV1p8(step)-IKdr(step)-IKm(step)-ILeak(step)-IAHP(step))/C;
    V(step+1) = V(step) + dV_dt*dt;
    
    %% Current Equations
    % Sodium currents
    %%%%% NaV1p3 (modified from Nav1.7)
    dm3_dt = nav1p3_alpm_1p7(V(step))*(1-m3(step))-nav1p3_betm_1p7(V(step))*m3(step);
    m3(step+1) = m3(step) + dm3_dt*dt;
    dh3_dt = nav1p3_alph_1p7(V(step))*(1-h3(step))-nav1p3_beth_1p7(V(step))*h3(step);
    h3(step+1) = h3(step) + dh3_dt*dt;
    INaV1p3(step+1) = g_nav1p3*m3(step)^3*h3(step)*(V(step)-Ena);
    
    %%%%% NaV1p7
    dm7_dt = nav1p7_alpm(V(step))*(1-m7(step))-nav1p7_betm(V(step))*m7(step);
    m7(step+1) = m7(step) + dm7_dt*dt;
    dh7_dt = nav1p7_alph(V(step))*(1-h7(step))-nav1p7_beth(V(step))*h7(step);
    h7(step+1) = h7(step) + dh7_dt*dt;
    INaV1p7(step+1) = g_nav1p7*m7(step)^3*h7(step)*(V(step)-Ena);
    
    %%%%% NaV1p8
    dm8_dt = nav1p8_alpm(V(step))*(1-m8(step))-nav1p8_betm(V(step))*m8(step);
    m8(step+1) = m8(step) + dm8_dt*dt;
    dh8_dt = nav1p8_alph(V(step))*(1-h8(step))-nav1p8_beth(V(step))*h8(step);
    h8(step+1) = h8(step) + dh8_dt*dt;
    INaV1p8(step+1) = g_nav1p8*m8(step)^3*h8(step)*(V(step)-Ena);
    
    
    % Potassium
    %%%%% Kdr - activation(n), inactivation(l)
    q10=3^((25-30)/10);
    ninf = 1/(1+kdr_alpn(V(step)));
    taun = kdr_betn(V(step))/(q10*0.03*(1+kdr_alpn(V(step))));
    linf = 1/(1+kdr_alpl(V(step)));
    taul = kdr_betl(V(step))/(q10*0.001*(1 + kdr_alpl(V(step))));
    
    dndr_dt = (ninf - ndr(step))/taun;
    ndr(step+1) = ndr(step) + dndr_dt*dt;
    dldr_dt = (linf - ldr(step))/taul;
    ldr(step+1) = ldr(step) + dldr_dt*dt; 
    IKdr(step+1) = gKdr*ndr(step)^3*ldr(step)*(V(step)-Ek);
    
    %%%%% Km
    dn_dt = (km_ninf(V(step))-nm(step))/km_ntau(V(step));
    nm(step+1) = nm(step) + dn_dt*dt;
    IKm(step+1) = gKm*nm(step)*(V(step)-Ek);
    
    %%%%% AHP
    dz_AHP_dt = (1/(1+exp((beta_z_AHP-V(step))/gamma_z))-z_AHP(step))/tau_z;
    z_AHP(step+1) = z_AHP(step) + dt*dz_AHP_dt; % forward Euler equation
    IAHP(step+1) = gAHP*z_AHP(step)^1*(V(step)-Ek); % modified
    
    % Leak current
    ILeak(step+1) = gLeak*(V(step)-ELeak);
    

    % Noise (Ornstein-Uhlenbeck process)
    di_noise_dt = -1/tau_noise*(Inoise(step)-mu_noise)+ sigma_noise/sqrt(dt)*sqrt(2/tau_noise)*randn;
    
    if with_noise == 1
        Inoise(step+1) = Inoise(step)+dt*di_noise_dt;
    else
        Inoise(step+1) = 0;
    end
    
    spike(step) = (V(step) > 0).*(~ref(step));
    ref(step+1) = (V(step) > 0);
end

close all;

figure
plot(0:dt:duration-dt,V,'-k')
xlim([0 duration]); ylim([-100 60]); 
box off;
set(gca,'TickDir','out','FontSize',15)
% set(gcf,'position',[1053 457 719 212])
set(gcf,'position',[191   650   371   198]) % Nov8-2020
xlabel('Time (ms)'); ylabel('Voltage (mV)')
xlim([400 1700])



figure
plot(V,m7.^3.*h7*100,'g'); hold on
plot(V,m8.^3.*h8*100,'b')
% plot(V(1:553/dt),m7(1:553/dt).^3.*h7(1:553/dt)*100,'g'); hold on
% plot(V(1:553/dt),m8(1:553/dt).^3.*h8(1:553/dt)*100,'b')

ylabel('Availability (%)')
% plot(V,m7.^3.*h7*g_nav1p7,'g'); hold on
% plot(V,m8.^3.*h8*g_nav1p8,'b')
% ylabel('g (nS/cm^{2})')
pbaspect([1 1 1])
xlabel('Voltage'); 
set(gca,'TickDir','out','FontSize',15); box off;


% Added on May19-2021 to compare INa vs IK
figure
x_range = [450 600];

subplot(2,1,1)
plot(0:dt:duration-dt,V)
ylabel('Voltage (mV)');
set(gca,'TickDir','out','FontSize',15); box off
xlim(x_range); ylim([-100 50])

subplot(2,1,2)
plot(0:dt:duration-dt,INaV1p3+INaV1p7+INaV1p8,'r')
hold on
plot(0:dt:duration-dt,IKdr+IKm+IAHP,'b')
legend Na K
set(gca,'TickDir','out','FontSize',15); box off
ylabel('Current (uA/cm2)'); xlabel('Time (ms)')
xlim(x_range); ylim([-250 250])
set(gcf,'position',[ 680   312   370   666])




figure
% y_range = [450 600]; % default
% y_range = [490 520]; % 1st spike
y_range = [519 625]; % 2nd spike
V_color = jet( numel(y_range(1)/dt:y_range(2)/dt));

x_range = [-100 60];

subplot(3,1,1) % spike
plot(V(y_range(1)/dt:y_range(2)/dt),y_range(1):dt:y_range(2))% flipped
xlim(x_range); ylim(y_range); 
set(gca,'TickDir','out','FontSize',15); set(gca,'xticklabel',[])
ylabel('Time (ms)') %xlabel('Voltage (mV)');
pbaspect([1 1 1]); box off; 
set(gca, 'YDir', 'reverse')

subplot(3,1,2) % Activation curve
v = -100:1:60;
malpha = zeros(size(v,2),1);
mbeta = zeros(size(v,2),1);
halpha = zeros(size(v,2),1);
hbeta = zeros(size(v,2),1);

for i =1:size(v,2)
    malpha(i) = nav1p8_alpm(v(i)); % dynamic clamp config   
    mbeta(i) = nav1p8_betm(v(i)); % dynamic clamp config
    
    halpha(i) = nav1p8_alph(v(i)); %dynamic clamp config
    hbeta(i) = nav1p8_beth(v(i)); % dynamic clamp config
end

m = malpha./(malpha + mbeta);
h = halpha./(halpha + hbeta);

m = m.^3;

plot(v,m,'b')
% hold on
% plot(vh_p,malpha(find(v==vh_p)),'r*') % plotting V1/2
% hold on
% plot(v,h,'b')
% plot(vh_q,halpha(find(v==vh_q)),'b*')

pbaspect([1 1 1]); box off;
 ylabel('% Activation') %xlabel('Voltage(mV)');
xlim(x_range); ylim([0 1])
set(gca,'TickDir','out','FontSize',15); set(gca,'xticklabel',[])
hold off



subplot(3,1,3) % phase plot
plot(V(y_range(1)/dt:y_range(2)/dt),m7(y_range(1)/dt:y_range(2)/dt).^3.*h7(y_range(1)/dt:y_range(2)/dt)*100,'g'); hold on
% plot(V(y_range(1)/dt:y_range(2)/dt),m8(y_range(1)/dt:y_range(2)/dt).^3.*h8(y_range(1)/dt:y_range(2)/dt)*100,'b')
% plot(V(1:560/dt),m7(1:560/dt).^3.*h7(1:560/dt)*100,'g'); hold on
% plot(V(1:560/dt),m8(1:560/dt).^3.*h8(1:560/dt)*100,'b')


X = V(y_range(1)/dt:y_range(2)/dt);
Y = m8(y_range(1)/dt:y_range(2)/dt).^3.*h8(y_range(1)/dt:y_range(2)/dt)*100;
for i = 1: length(V_color)-1
    line('XData',X(i:i+1), 'YData', Y(i:i+1), 'Color',V_color(i,:));
end

xlabel('Voltage(mV)'); ylabel('Availability (%)')
set(gca,'TickDir','out','FontSize',15); 
pbaspect([1 1 1]); box off;
xlim([x_range])
set(gcf,'position',[680    85   372   893])

end

% Nav1.3 (modified from nav1.7)
function [alpm] = nav1p3_alpm_1p7(v)
jp = 4.2;% voltage shift for inactivation
alpm = 10.22/(1+exp((v-(-7.19-jp-12))/-15.43)); % Vclamp data
end
function [betm] = nav1p3_betm_1p7(v)
jp = 4.2;% voltage shift for inactivation
betm = 23.76/(1+exp((v-(-70.37-jp-12))/14.53));  % Vclamp data
end
function [alph] = nav1p3_alph_1p7(v)
jp = 4.2;% voltage shift for inactivation
alph = 0.0744/(1+exp((v-(-99.76-jp))/11.07)); % <<<<<<<
end
function [beth] = nav1p3_beth_1p7(v)
jp = 4.2;% voltage shift for inactivation
beth = 2.54/(1+exp((v-(-7.8-jp))/-10.68));
end

%% NaV1.7 from Vasylyev et al. 2014
function [alpm] = nav1p7_alpm(v)
alpm = 10.22/(1+exp((v-(-7.19-4.2))/-15.43)); % junction potential = 4.3
end

function [betm] = nav1p7_betm(v)
betm = 23.76/(1+exp((v-(-70.37-4.2))/14.53)); % junction potential = 4.3
end

function [alph] = nav1p7_alph(v)
alph = 0.0744/(1+exp((v-(-99.76-4.2))/11.07)); % junction potential = 4.3 mV
end

function [beth] = nav1p7_beth(v)
beth = 2.54/(1+exp((v-(-7.8-4.2))/-10.68));   % junction potential = 4.3 mV
end  

%% NaV1.8 from Han et al., 2015. J Neurophysiol 113: 3172�3185.
% doi:10.1152/jn.00113.2015.
function [alpm] = nav1p8_alpm(v)
% alpm = 7.21/(1+exp((v-0.063)/-7.86)); % original
alpm = 7.21/(1+exp((v-(0.063-5.3))/-7.86)); % after JP correction (+5.3mV)
end

function [betm] = nav1p8_betm(v)
% betm = 7.4/(1+exp((v+53.06)/19.34)); % original
betm = 7.4/(1+exp((v-(-53.06-5.3))/19.34)); % after JP correction (+5.3mV)
end

function [alph] = nav1p8_alph(v)
% alph = 1.63/(1+exp((v+68.5)/10.01)); % original
alph = 1.63/(1+exp((v-(-68.5-5.3))/10.01)); % after JP correction (+5.3mV)
end

function [beth] = nav1p8_beth(v)
% beth = 0.81/(1+exp((v-11.44)/-13.12)); % original
beth = 0.81/(1+exp((v-(11.44-5.3))/-13.12)); % after JP correction (+5.3mV)
end

%% Delayed rectifier (Kdr) from Borg-Graham 1987 (ref. in Sundt et al. 2015)
function [alpn] = kdr_alpn(v)
alpn = exp(1.e-3*-5*(v+32)*9.648e4/(8.315*(273.16+25))); % original
end

function [betn] = kdr_betn(v)
gmn= 0.4 ;
betn = exp(1.e-3*-5*gmn*(v+32)*9.648e4/(8.315*(273.16+25)));  % original
end

function [alpl] = kdr_alpl(v)
alpl = exp(1.e-3*2*(v-(-61))*9.648e4/(8.315*(273.16+25)));
end

function [betl] = kdr_betl(v)
gml=1.0;
betl = exp(1.e-3*2*gml*(v-(-61))*9.648e4/(8.315*(273.16+25)));
end


%% M-type (Km) from
function [ntau] = km_ntau(v)
celsius = 25;
tadj = 3^((celsius-23.5)/10);
% ntau = 1000.0/(3.3*(exp((v-(-35))/20)+exp(-(v+35)/20))) / tadj;%original
ntau = 1000.0/(3.3*(exp((v-(-35))/10)+exp(-(v+35)/10))) / tadj;
end

function [ninf] = km_ninf(v)
ninf = 1.0 / (1+exp(-(v-(-35))/5));
end
