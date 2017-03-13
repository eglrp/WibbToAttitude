%���岻��λ�ƣ�ͨ�������ǲ���ֵ������̬��
%20170309 Salamander
%������������нǶ�һ��ʹ�û���Ϊ��λ��ֻ����������׶��漰���뻡��ת��

clc
clear

%% Ԥ�ù̶�����
Re=6378137.0;
f=1.0/298.257;
wiee=[  0;
        0;
        7.2722e-5];

%% ��ʼֵ
AttitudeIni=[89.850004;1.9113951;1.0572407]*pi/180;
lati=39.813330*pi/180;
longti=116.15326*pi/180;
h=70.0;
vn=[0,0,0];

IMUSource=importIMUfile('E:\Documents\�ߵ�ʵ��\����ϵͳ��Ƴ�������\data20110913\imu_ENU.txt');
wibb_ini=[-1.7630406e-003;-1.2578430e-004;-2.6035600e-005];
nepoch=size(IMUSource);
AttitudeOffer=zeros(ceil(nepoch(1)/2),4);
DeltaT=0.02;%����ʹ���Ľ���������������Դ˴��������������DeltaT��ʵ��������������ڵ�2��
FlagMiddleRefresh=0;

%%����
method=4;%΢�ַ��̽ⷨѡ��
%% �����ʼwinb wnbb Tbn

%��wenb
Rm=Re*(1-2*f+3*f*(sin(lati))^2);
Rn=Re*(1+f*(sin(lati))^2);
wenn=[  -vn(2)/(Rm+h);
        vn(1)/(Rm+h);
        vn(1)*tan(lati)/(Rn+h)];
[Tbn_pre,FlagFunc]=AttiToTbn(AttitudeIni);%��b��n��ת������bΪ�±�nΪ�ϱ�
if FlagFunc~=0
    stop
end
wenb=Tbn_pre'*wenn;
%��wieb
Cen=LatiLongtiToCen(lati,longti);
wien=Cen*wiee;
wieb=Tbn_pre'*wien;
%��winb
winb_pre=wieb+wenb;
wnbb_pre=wibb_ini-winb_pre;

%% ��ʼ��ȡ�۲�
for i=1:nepoch(1)
    wibb=[IMUSource.wibbx(i);IMUSource.wibby(i);IMUSource.wibbz(i)];
    if mod(i,2)~=0
        wnbb_middle=wibb-winb_pre;
        FlagMiddleRefresh=1;
        continue
    end
    AttitudeOffer(i/2,1)=IMUSource.time(i);
    wnbb_now=wibb-winb_pre;
    %�Ľ����������Tbn
    if FlagMiddleRefresh==0
        disp('�Ľ�����������޷�ʵʩ��wnbb_middleֵδ����')
        continue
    end
    if method==4
        
        K1=WnbbToDotTbn(wnbb_pre,Tbn_pre);
        K2=WnbbToDotTbn(wnbb_middle,Tbn_pre+K1*DeltaT/2);
        K3=WnbbToDotTbn(wnbb_middle,Tbn_pre+K2*DeltaT/2);
        K4=WnbbToDotTbn(wnbb_now,Tbn_pre+K3*DeltaT);
        Tbn_now=Tbn_pre+DeltaT*(K1+2*K2+2*K3+K4)/6;
    end
   
    %������һ��ѭ��ʹ�õ�����,�˴���̬�����ݲ�����wien�ĸ���
    winb_pre=Tbn_now'*wien+Tbn_now'*wenn;
    wnbb_pre=wibb-winb_pre;
    Tbn_pre=Tbn_now;
    FlagMiddleRefresh=0;

    %�����̬��
    [AttitudeOffer(i/2,2:4), FlagFunc]=TbnToAttitude(Tbn_now);
    if FlagFunc~=0
        disp('Tbn���󲻿ɿ�����̬��δ����')  
        if(i<=2)
            AttitudeOffer(i/2)=AttitudeIni;
        else
            AttitudeOffer(i/2)=AttitudeOffer(i/2-1);
        end
     end
    
    
end
%����Ƕ��Զ�Ϊ��λ    
AttitudeOffer(:,2:4)=AttitudeOffer(:,2:4)*180/pi;
save('ResOfWibbToAttitude','AttitudeOffer');

%% �ȶԳ���WibbToAttitude����õ�����̬��ins_c.txt�еĲο���̬����


INSSource=imporINSCtfile('E:\Documents\�ߵ�ʵ��\����ϵͳ��Ƴ�������\data20110913\ins_c.txt');
index=(AttitudeOffer(:,1)~=0);
subplot(3,1,1)
plot(AttitudeOffer(index,1),AttitudeOffer(index,2),'.');
hold on
plot(INSSource.time,INSSource.psi,'.r')
hold off
subplot(3,1,2)
plot(AttitudeOffer(index,1),AttitudeOffer(index,3),'.');    
hold on
plot(INSSource.time,INSSource.theta,'.r')
hold off
subplot(3,1,3)
plot(AttitudeOffer(index,1),AttitudeOffer(index,4),'.');
hold on
plot(INSSource.time,INSSource.gama,'.r')
hold off

