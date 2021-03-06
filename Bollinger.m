%function [finVal,totMargin,APR]=Mean_Rev_Opt(Y,X,winMA,thY,thX,thYcl,thXcl)
function [APR,sortinoRatio,finVal,totMargin,sharpeRatio,netVal,margin]=Bollinger(Y,X,ZScore,thY,thX,thYcl,thXcl,beta1)
% delta=0.0002; % delta=0 allows no change (like traditional linear regression).
% Ve=0.001;
% Check number of inputs.

K=0.002; %Transaction Cost

T=length(Y);

% if nargin==7
%     beta1=ones(T,1);
% end

val=100;   %market value of each position

pos=zeros(T,2);

PnL=zeros(T,1);
for t=2:T
    if (ZScore(t)<thY)&&(ZScore(t-1)>=thY)&&(pos(t-1,1)<=0)
        pos(t,:)=[val/Y(t) , -val*beta1(t)./X(t)];
%         pos(t,:)=[val/Y(t) , -val*abs(beta(1,t))/X(t)];
%         pos(t,:)=[val/Y(t) , -val/Y(t)*beta1(t)];
%         position(t,:)=[val/Y(t) , 0];
%         curPosPnL=0;
    elseif (ZScore(t)>thX)&&(ZScore(t-1)<=thX)&&(pos(t-1,1)>=0) 
        pos(t,:)=[-val/Y(t) , val*beta1(t)./X(t)];
%         pos(t,:)=[-val/Y(t) , val/Y(t)*beta1(t)];
%         position(t,:)=[0 , val/X(t)];
%         position(t,:)=[0 , 0];
%         position(t,:)=[0 , sign(beta(1,t))*val/ETH(t)];
%         curPosPnL=0;
    elseif (ZScore(t)<thYcl)&&(pos(t-1,1)>0)
        pos(t,:)=[0 , 0];
%         curPosPnL=0;
    elseif (ZScore(t)>thXcl)&&(pos(t-1,1)<0)
        pos(t,:)=[0 , 0];
%         curPosPnL=0;
    else        
        pos(t,:)=pos(t-1,:);
    end
%     PnL(t)=pos(t-1,1).*(Y(t)-Y(t-1)) + pos(t-1,2).*(X(t)-X(t-1))...
%         -K/2*abs(pos(t,1)-pos(t-1,1)).*Y(t-1)-K/2*abs(pos(t,2)-pos(t-1,2)).*X(t-1);
%     curPosPnL=curPosPnL+PnL(t);
end

PnL(2:end)=pos(1:end-1,1).*(Y(2:end)-Y(1:end-1)) + pos(1:end-1,2).*(X(2:end)-X(1:end-1))...
-K/2*abs(pos(2:end,1)-pos(1:end-1,1)).*Y(1:end-1)-K/2*abs(pos(2:end,2)-pos(1:end-1,2)).*X(1:end-1);



netVal=cumsum(PnL);
finVal=sum(PnL);
lev=1; %Leverage
margin=[0;1/lev*(abs(pos(1:end-1,1)).*Y(2:end)+abs(pos(1:end-1,2)).*X(2:end))-min(netVal(2:end),0)];
totMargin=max(margin);
APR=finVal/totMargin;
ret=PnL./margin;
sharpeRatio=mean(ret,'omitnan')/std(ret,'omitnan');
m=mean(ret,'omitnan');
sortinoRatio=m/sqrt(mean(min(ret-m,0).^2,'omitnan'));
