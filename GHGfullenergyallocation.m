%inputs     
Feed=1.618;    
FPW =0.177;
Fuelgas=0.2595;
TE=926.632;
z = 1e6/18535;
[energy_allocation] =en_all_fuel_TE(Fuelgas,TE);
No=0;
Efficiency=.34;
% TRANSPORT AND PROCESSING
distance = 98.8;
Energyrequired = 0.0649; %mmbtu/wet ton of msw
TransportN2O=0.001 .*distance;
N2OTfull = (0.49 * Energyrequired * (0.645+1.294))./FPW + TransportN2O;
TransportCH4 = 0.424 .* distance;
CH4Tfull = 0.49 .* Energyrequired .* (205.543+2.138)./FPW + TransportCH4;
TransportCO=0.007026 .* distance;
CO_full= 0.49 .* Energyrequired .* (20.862+28.726)./FPW + TransportCO;
TransportVOC=0.056 .* distance;
VOC_full=TransportVOC + 0.49 .* Energyrequired .* (12.277+2.427)./FPW;
TransportCO2 = 374.6483 .* distance;
CO2Tfull = TransportCO2+ 0.49 .* Energyrequired .* (5906+118814)./FPW;
CO2TPfull= CO2Tfull+ 3.148* VOC_full + 1.592* CO_full;
TPGHG = CO2TPfull + 30 .* CH4Tfull + 265 .* N2OTfull; %/tonfeed stock; %FuelSpec Metric for near term climate forcers as zero
TGHG = TPGHG ./2000.* 1/18535.*1000000.*(Feed).*energy_allocation;%  grams CO2 eq per mmbtu of diesel
%% GHG FROM CONVERSION


%default Greet diesel distribution
tVOC=0.095;                 
tCO=0.433;
tNOx=1.8;
tBC=.009;
tOC=.027;
tCH4=.408;
tN2O=0.005;
tCO2=304.466;
tVOCbulk=0.207;
tVOCtransport=0.880;

%% conversion emission
%% onsite conversions
EnergygenElecInternal=0; %  0% electricity
NGinternalGen=100; %100 heat
btufuelgas=21942; %btu/lb
VOCc = ((TE.*EnergygenElecInternal ./ Efficiency+ TE.* NGinternalGen .*.0013).* 2.54) / 1e6 .* energy_allocation;
COc = ((TE.*EnergygenElecInternal ./ Efficiency+ TE.* NGinternalGen .*.0013).* 22.21) / 1e6 .* energy_allocation;
CH4c = ((TE.*EnergygenElecInternal ./ Efficiency+ TE.* NGinternalGen .*.0013)* 1.060)/1e6 .* energy_allocation;
CO2c= (((TE.*EnergygenElecInternal ./ Efficiency+ TE.* NGinternalGen .*.0013)*((1/btufuelgas)*0.758*(1/0.2727))*453.59237)-(( 0.85.*VOCc + 0.43 .* COc + 0.75 .* CH4c)/0.27)).* energy_allocation;
N20c= ((TE.*EnergygenElecInternal ./ Efficiency+ TE.* NGinternalGen .*.0013).* 0.750) / 1e6 .* energy_allocation;
%% pyrolysis
N20p= ((0.13.* TE .* energy_allocation.*(0.350)+1.418)/1e6)+ ((TE .* 0.87 .* energy_allocation.*(1.939))/1e6);
VOCp = ((0.13.* TE .* energy_allocation.*(2.540)+10.323)/1e6)+ ((TE .* 0.87 .* energy_allocation.*(14.704))/1e6);
COp = ((0.13.* TE .* energy_allocation.*(24.970)+32.051)/1e6)+ ((TE .* 0.87 .* energy_allocation.*(49.588))/1e6);
CH4p = ((0.13.* TE .* energy_allocation.*(1.060)+1.418)/1e6)+ ((TE .* 0.87 .* energy_allocation.*(207.681))/1e6);
CO2p = ((0.13.* TE .* energy_allocation.*(59362.612)+6208.303)/1e6)+ ((TE .* 0.87 .* energy_allocation.*(5906+118814))/1e6);


%% internally generated energy

iVOC = -((0.13.* TE .* energy_allocation.*(2.540+10.323)/1e6)+ ((TE .* No* 0.87 .* energy_allocation.*(14.704))/1e6));
iCO = -((0.13.* TE .* energy_allocation.*(24.970+32.051)/1e6)+ ((TE .* No* 0.87 .* energy_allocation.*(49.588))/1e6));

iCH4= -((0.13.* TE .* energy_allocation.*(1.060+151.608)/1e6)+ ((TE .*No* 0.87 .* energy_allocation.*(207.681))/1e6));
iCO2 = -((0.13.* TE .* energy_allocation.*(59362.612+6208)/1e6)+ ((TE .*No* 0.87 .* energy_allocation.*(5906+118814))/1e6));
iN20= -((0.13.* TE .* energy_allocation.*(0.350+1.418)/1e6)+ ((TE .* No.* 0.87 .* energy_allocation.*(1.939))/1e6));

%% NonCombustion Emission

CO2nc=(Feed*.86 - (0.87+ 0.21*0.87 + 0.76*(Fuelgas * 21942 - 0.13*TE)./21942 +0.125+((VOCc*0.85+COc*0.43+CH4c*0.75+CO2c*0.27)*0.002204./energy_allocation))).*453.592./0.2727.*energy_allocation;
N20nc=0.0;
CH4nc =0.0;
COnc=0.0417/0.82;
VOCnc=0.0434/.82;

%% total

CO2_wofull = (CO2c+CO2p+iCO2+CO2nc).*z + tCO2;
N2O_full= (N20c+iN20+N20nc+N20p).*z+ tN2O;
CH4_full= (CH4c+iCH4+CH4nc+CH4p).*z+ tCH4;
CO_full= (COc+iCO+COnc+COp).*z+ tCO;
VOC_full= (VOCc+iVOC+VOCnc+VOCp).*z+ tVOC;
CO2_full= CO2_wofull+ VOC_full .*3.1481 + CO_full.* 1.5923; 


% N2O_full = (1.6869./1e6.*TE.*energy_allocation+ (TE .* 0.13 .* (0.350+1418))./1e6 + 0.13.*TE.*0.750/1e6.*energy_allocation)*z+.00471;
% CH4_full = 1.808e-4 * z .* TE .* energy_allocation + ((TE .* 0.13 .* (1.060+151.608))/1e6).*z + 0.408;
% OC_full = 1.39051e-6 * z .* TE .* energy_allocation +((TE .* 0.13 .* (0.151+1.501))/1e6).*z + 0.271;
% BC_full = 5.8248e-7*z .* TE .* energy_allocation + 0.009 + ((TE .* 0.13 .* (0.579+.139))/1e6).*z;
% NOx_full = (8.380543e-5 .* TE .* energy_allocation + 0.0609).*z + 1.8+ ((TE .* 0.13 .* (40.0921+41.050))/1e6).*z;
% CO_full = (4.60288e-5 .* TE .* energy_allocation + 0.051) .* z + ((TE .* 0.13 .* (24.970+32.051))/1e6).*z + 0.433;
% VOC_full = (1.31226e-5 .*TE .* energy_allocation + 0.053) .* z + ((TE .* 0.13 .* (10.323+2.540))/1e6).*z + 0.095;


GHG = CO2_full + 3.148* VOC_full + 1.592* CO_full+ 30* CH4_full + 265* N2O_full;% + 900 * BC_full - 69* OC_full - 11 * NOx_full;

