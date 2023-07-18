% TRM VALUATION WITH JUMPS (GEOMETRIC BROWNIAN MOTION + POISSON
% PROCESS)

clear all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%DATOS Y SIMULACIONES DIARIAS%%%%%%%%%%%%%%%%
%DATA UNDERLINE ASSET

    ST=4527.5
    r=0.0175 % tasa RF
    Volat=0.111 %volat anual
    Days_to_mat=360*3 % Steps (Days of the full period 1Y=360, 2Y=720) 
    stepsPerYear=360*3 %Base Days * #Years
    Simul=1000
    dt= 1/stepsPerYear %size each step between the time horizont (t1-t0) time years  DT
    H=5000 %Higter Bound Barrer 
    L=3000 %Lower Bound Barrer 
   % A=Days_to_mat/360 %time to maturity in years

        
 % POISSON PROCESS DATA
 
    Lambda_Per_Year=1.5 %Poisson process arrival rate (Lampda) per year. ( We expect 1.5 jumps in one year of data 1 year =252 days)
    Lambda= (Days_to_mat*Lambda_Per_Year)/stepsPerYear %Lambda for the simulation period
    mu=0 %drift of log jump
    v=0.06 %Std of log jump
                
 % PROJECCION TIME HORIZONT
 
 ts(Days_to_mat,1)=zeros
 ts(1,1)=0
 for i=1:Days_to_mat
     ts(i+1,1)= ts(i,1)+dt
 end
      
 % POISSON PROCESS JUMP SIMULATION
 
 %we use poisson and uniform distribution in order to determinate the number of jumps 
 %and we use Normal distribution for quantify the jump size , we also include drift and volatility in the jump size modelling. 
 
 N=poissrnd(Lambda,Simul,1) % it generates ramdom numbers with poisson distribution (lammda for the period,col,rows)
 Jumps(Days_to_mat,1)=zeros
 Jumps_Poisson_Process=[]
 
for i=1:Simul

  t=rand(N(i),1) % we generate a matriz with ramdom numbers according with the number obtained in N(j).
  t=sort(t) % we sort previous matrix
 
  % simulate jump size
  S=mu+v*randn(N(i),1)
  S=[0;S]
  CumS=cumsum(S) % cumulative sum of previous matrix S 1+2+3+4+5+...
  
    for j=1:length(ts)
        ts(j)
        Events=sum(t<=ts(j)) % it counts the values t < ts  using a loop from 1 to 250. returns 1 true if t<ts in each day.
        Jumps(j,1)=CumS(Events+1)  
    end
  
    Jumps_Poisson_Process=[Jumps_Poisson_Process;Jumps'] % it keeps all simulations in a big table.
   
end

% B. MONTECARLO SIMULATION GBM

%example 10 simulations

GBM=ones(Simul,1)*1 % initial Value ST

for t = 1:Days_to_mat 
    
GBM(:,t+1)= GBM(:,t).*exp(((r-((Volat^2)/2))*dt)+ (Volat.*(sqrt(dt).*randn(Simul,1))))
  
end

% C. JUMP DIFUSSION MODEL (GEOMETRIC BROWNIAM MOTION + POISON PROCESS)

Jump_Difussion_Model=Jumps_Poisson_Process+GBM

% D. JUMP DIFUSSION MODEL FOR PRICES (GEOMETRIC BROWNIAM MOTION + POISON PROCESS)

Jump_Difussion_Model_Prices=Jump_Difussion_Model*ST


% ajuste segun los limites
max=max(Jump_Difussion_Model_Prices')
max=max'
min=min(Jump_Difussion_Model_Prices')
min=min'

c=1

for i=1:Simul
if max(i,1)<=H && min(i,1)>= L
    RTA(c,:)=Jump_Difussion_Model_Prices(i,:)
    c=c+1
end
end

%%%Graphs
subplot(2,2,1)
plot(Jumps_Poisson_Process'), title('Jumps Poisson Process')
subplot(2,2,2)
plot(GBM'), title('Geometric Brownian Motion')
subplot(2,2,3)
plot(Jump_Difussion_Model_Prices'), title('Jump Difussion Model Prices')
hold on
plot(ones(1,length(ts))*H,'k','LineWidth',2)
plot(ones(1,length(ts))*L,'k','LineWidth',2)
legend('Lower Bound')
hold off
subplot(2,2,4)
plot(RTA'), title('Jump Difussion Model Prices')

% generar cortes mensuales
c=1
M=[1:30:stepsPerYear]
for i=1:length(M)
MES_PY(:,c)=RTA(:,M(i))
c=c+1
end

figure 
PY=prctile(MES_PY,[5 50 95],1)
plot(PY','LineWidth',2), title('Senda Mensual Percentiles 5,50,95')

PY
xlswrite('Resultados.xlsx',PY)

save('Variables_fijas Datos Diarios')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


