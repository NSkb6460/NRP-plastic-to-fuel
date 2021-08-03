
NPVF=[];
capacity=20833;
wasteHDPE_price = 0.022;
% IRR=0.1;
k=0.5:0.01:0.95;

for IRR=0.5:0.01:0.95

    %Fractions of gas outlets
methanef =.0481;
ethylenef=0.2037;
propylenef=0.1899;
propanef=0.0323;
butanef=0.065;
butenef=0.3367;
pentanef=0.0327;
pentenef=0.0485;
C1_C4=0.9168;
C5_C29=(1-C1_C4);
aliphatic=.1267;
%

methane_purged=capacity.*C1_C4.*methanef;
ethylene_amount = capacity.*C1_C4.*(1-methanef).*ethylenef;
propylene_amount= capacity.*C1_C4.*(1-methanef).*(1-ethylenef).*(propylenef);
%aromatics_A300 section
deprop_A2to300= capacity.*C1_C4.*(1-methanef).*(1-ethylenef).*(1-propanef-propylenef);
propfract_A2to300=capacity.*C1_C4.*(1-methanef).*(1-ethylenef).*(propanef);
cond_A1to300=  capacity.*C5_C29;
A300input=(deprop_A2to300+cond_A1to300);
A300to400= cond_A1to300.*(1-(aliphatic+butanef+pentanef+pentanef+butenef));
Debutanizer_input=(cond_A1to300 - A300to400)+ deprop_A2to300;
A300to400_2=capacity.*(butenef+butanef);%check
A300to400_3=capacity*(pentanef+pentenef);%check
A400input=A300to400+ A300to400_2+ A300to400_3 + propfract_A2to300 + A300input.*aliphatic;    
aromatics_amount=A300input -A300to400 - A300to400_2 - A300to400_3 - A300input.*aliphatic;
%A400
lmw_amount=A400input.*0.9;
hmw_amount=A400input.*0.1;

%prices
ethylene_price=0.61;
propylene_price=0.97;
aromatics_price=1.02;
lmw_price=0.86;
hmw_price=0.84;
% wasteHDPE_price=0.022;
electricity=0.069;
naturalgas=3.95;
water=0.053;
hydrogen=2.83;
helium=42.81;
% Equipmentprice newcap,oldcap,oldprice
pyro_price= adjustedprice(capacity,20833,8.76e6);
furnace_price=adjustedprice(capacity/20833*74588,74588,1.56e6);
PSA_price=adjustedprice(capacity/20833*25444,25444,2.6e6);
TPEC=(27.49e6-8.76e6-1.56e6-2.6e6)+pyro_price+furnace_price+PSA_price;


FCI=4.31.*TPEC;
VOC= capacity.*8400.*wasteHDPE_price + capacity./20833.*29.74e6; 
WC=0.15.*3.12.*TPEC+1.23.*TPEC;
FOC=7.76e6 + .02*7.76e6.* capacity/20833;
Revenue= 24*350* (ethylene_price.*ethylene_amount + propylene_price.*propylene_amount +aromatics_amount .*aromatics_price + lmw_price .* lmw_amount+ hmw_price .* hmw_amount)+1e6;
OneRev=Revenue*0.5;
twoRev=Revenue*0.9;
Revenue(1:1,1:16) = Revenue; %making an array
Revenue = [OneRev,twoRev,Revenue];
discount_factor=[];
for i=0:20
df=(1+IRR)^(-i); % IRR
discount_factor = [discount_factor,df];
end
discount_factor=discount_factor(4:21);
Investment_3y = Revenue(1)- FOC - 0.5* VOC;
Investment_4y = Revenue(2) - FOC - 0.9* VOC;
Investment_rest= Revenue(3) - FOC - VOC;
Investment_rest(1:1,1:16)= Investment_rest;
Gross_Profit=[Investment_3y, Investment_4y, Investment_rest];
%Gross_Profit=Gross_Profit'; %for checking
MACRS_7y= [14.29; 24.49; 17.49; 12.49; 8.93; 8.92; 8.93; 4.46; 0; 0; 0; 0; 0; 0; 0; 0;0;0];
[Depreciation] = FCI/100. *[MACRS_7y]; 
Taxable_income= Gross_Profit - Depreciation'; 
Taxes_paid= Taxable_income .*.21;
Cash_flow3 = Gross_Profit(1)-Taxes_paid(1)-WC;
Cashflow_rest= Gross_Profit(2:18)-Taxes_paid(2:18);
Cashflow= [Cash_flow3, Cashflow_rest];
Present_Value=discount_factor .* Cashflow;
SumP= sum(Present_Value);
NPV = -(FCI - SumP);

NPVF=[NPVF,NPV];
end
plot (k,NPVF);
