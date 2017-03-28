%���岻��λ�ƣ�ͨ�������ǲ���ֵ������̬��
%20170309 Salamander
%������������нǶ�һ��ʹ�û���Ϊ��λ��ֻ����������׶��漰���뻡��ת��
%20170316 ������Ԫ������,ʹ��fscanf���ж������ݶ�����һ����ȫ�����룬ģ��ʵ���������
%20170322 ��ʼ����γ���붫�����ٶ�
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
vn=[0;0;0];
g=AccuG(lati,h);

fileID = fopen('E:\Documents\�ߵ�ʵ��\data20110913\imu_ENU.txt','r');
formatSpec = '%f%f%f%f%f%f%f%[^\n\r]';
[IMUSource,FlagRead]=fscanf(fileID,formatSpec);
if FlagRead~=7
    disp('���ݶ�ȡʧ��')
    stop
end
wibb=[IMUSource(5);IMUSource(6);IMUSource(7)];
nepoch=65000;
ResOffer=zeros(nepoch,10);
ResOffer=mat2dataset(ResOffer,'VarNames',{'time','psi','theta','gama','ve','vn','vu','lati','longti','h'});

DeltaT=0.01;
DeltaTOfTbn=2;%Tbn������̬�ĸ�������=DeltaTOfTbn*DeltaT ʹ���Ľ���������������Դ˴���̬���ݵĸ���������������������ڵ�2��
DeltaTOfV=10;%ÿ���DeltaTOfV�������������һ���ٶ�
DeltaTOfNoQ=10;%ÿ��DeltaTOfNoQ�����������һ��һ����Ԫ��
DeltaTOfPo=50;%ÿ��DeltaTOfPo�������������һ��λ��
FlagMiddleRefresh=0;


%% �����ʼwinb wnbb Tbn

%��wenb
Rm=Re*(1-2*f+3*f*(sin(lati))^2);
Rn=Re*(1+f*(sin(lati))^2);
wenn=[  -vn(2)/(Rm+h);
        vn(1)/(Rm+h);
        vn(1)*tan(lati)/(Rn+h)];
[Tbn,FlagFunc]=AttiToTbn(AttitudeIni);%��b��n��ת������bΪ�±�nΪ�ϱ�
[Q,FlagFun]=AttiToQuater(AttitudeIni);%����̬�Ǽ�����Ԫ��Q
if FlagFunc~=0
    stop
end
wenb=Tbn'*wenn;
%��wieb
Cen=LatiLongtiToCen(lati,longti);
DotCen=WennToDotCen(wenn,Cen);
wien=Cen*wiee;
wieb=Tbn'*wien;
%��winb
winb=wieb+wenb;
wnbb_pre=wibb-winb;
%���ʼ����ϵ�µļ��ٶ�DotVn_pre
fb_ini=[IMUSource(2);IMUSource(3);IMUSource(4)];
fn_ini=Tbn*fb_ini;
DotVn=fn_ini-cross(2*wien+wenn,vn)+[0;0;-g];%�˴�g֮ǰ�Ƿ�Ӧ���Ӹ��ţ�
%% ��ʼ��ȡ�۲�
for i=1:nepoch
    [IMUSource,FlagRead]=fscanf(fileID,formatSpec);
    if FlagRead~=7
        info=sprintf('%s%d','���ݶ�ȡʧ�ܻ�����ļ�β������ѭ�����Ѷ�ȡ������',i);
        disp(info)
        fclose(fileID);
        break
    end
    wibb=[IMUSource(5);IMUSource(6);IMUSource(7)];
    ResOffer.time(i)=IMUSource(1);
    %% ������̬
    
    if mod(ResOffer.time(i),DeltaTOfTbn)~=0
        wnbb_middle=wibb-winb;
        FlagMiddleRefresh=1;
    elseif FlagMiddleRefresh==1
        wnbb_now=wibb-winb;
        %�Ľ������������Ԫ��Q
        K1=WnbbToDotQ(wnbb_pre,Q);
        K2=WnbbToDotQ(wnbb_middle,Q+K1*DeltaT*DeltaTOfTbn/2);
        K3=WnbbToDotQ(wnbb_middle,Q+K2*DeltaT*DeltaTOfTbn/2);
        K4=WnbbToDotQ(wnbb_now,Q+K3*DeltaT*DeltaTOfTbn);
        Q=Q+DeltaT*DeltaTOfTbn*(K1+2*K2+2*K3+K4)/6;
        %��Ԫ����һ��
        if mod(ResOffer.time(i),DeltaTOfNoQ)==0
            Q=Q/norm(Q);
        end

        %����Ԫ������Tbn
        Tbn=QToTbn(Q);
        %�����̬��
        [ResOffer.psi(i),ResOffer.theta(i),ResOffer.gama(i),FlagFunc]=TbnToAttitude(Tbn);
        if FlagFunc~=0
            disp('Tbn���󲻿ɿ�����̬��δ����')  
            if(i<=DeltaTOfTbn)
                ResOffer(i,2:4)=AttitudeIni;
            else
                ResOffer(i,2:4)=ResOffer(i-DeltaTOfTbn,2:4);
            end
        end
    end
    %% �����ٶ�
    
    if mod(ResOffer.time(i),DeltaTOfV)==0
        fb=[IMUSource(2);IMUSource(3);IMUSource(4)];
        fn=Tbn*fb;
        %������������������ٶ�
        K1=DotVn;
        wenn=[  -(vn(2)+K1(2)*DeltaTOfV*DeltaT)/(Rm+h);
        (vn(1)+K1(1)*DeltaTOfV*DeltaT)/(Rm+h);
        (vn(1)+K1(1)*DeltaTOfV*DeltaT)*tan(lati)/(Rn+h)];
        K2=fn-cross(2*wien+wenn,vn+K1*DeltaTOfV*DeltaT)+[0;0;-g];
        vn=vn+(K1+K2)*DeltaTOfV*DeltaT/2;
        %��������
        wenn=[  -vn(2)/(Rm+h);
                vn(1)/(Rm+h);
                vn(1)*tan(lati)/(Rn+h)];
        DotVn=fn-cross(2*wien+wenn,vn)+[0;0;-g];
        ResOffer.ve(i)=vn(1);
        ResOffer.vn(i)=vn(2);
        ResOffer.vu(i)=vn(3);
    end
    %% ���¾�γ��
    
    if mod(ResOffer.time(i),DeltaTOfPo)==0
        Cen=Cen+DeltaTOfPo*DeltaT*DotCen;
        DotCen=WennToDotCen(wenn,Cen);
        [lati,longti]=CenToLaLon(Cen);
        %������������
        Rm=Re*(1-2*f+3*f*(sin(lati))^2);
        Rn=Re*(1+f*(sin(lati))^2);
        wenn=[  -vn(2)/(Rm+h);
        vn(1)/(Rm+h);
        vn(1)*tan(lati)/(Rn+h)];
        wien=Cen*wiee;
        ResOffer.lati(i)=lati;
        ResOffer.longti(i)=longti;
        
    end
        
    %% ����wnbb_pre
    if mod(ResOffer.time(i),DeltaTOfTbn)==0&&FlagMiddleRefresh==1
        winb=Tbn'*(wien+wenn);
        wnbb_pre=wibb-winb;
        FlagMiddleRefresh=0;
    end
    
end
%����Ƕ��Զ�Ϊ��λ    
ResOffer.psi=ResOffer.psi*180/pi;
ResOffer.theta=ResOffer.theta*180/pi;
ResOffer.gama=ResOffer.gama*180/pi;
ResOffer.lati=ResOffer.lati*180/pi;
ResOffer.longti=ResOffer.longti*180/pi;
save('ResOfWibbToAttitude','ResOffer');

%% �ȶԳ���WibbToAttitude����õ�����̬��ins_c.txt�еĲο���̬����
INSSource=imporINSCtfile('E:\Documents\�ߵ�ʵ��\data20110913\ins_c.txt');
index=(ResOffer.psi~=0);
subplot(3,3,1)
plot(ResOffer.time(index),ResOffer.psi(index),'.');
hold on
plot(INSSource.time,INSSource.psi,'.r')
hold off
subplot(3,3,2)
plot(ResOffer.time(index),ResOffer.theta(index),'.');    
hold on
plot(INSSource.time,INSSource.theta,'.r')
hold off
subplot(3,3,3)
plot(ResOffer.time(index),ResOffer.gama(index),'.');
hold on
plot(INSSource.time,INSSource.gama,'.r')
hold off
index_v=(ResOffer.ve~=0);
subplot(3,3,4)
plot(ResOffer.time(index_v),ResOffer.ve(index_v),'.');
hold on
plot(INSSource.time,INSSource.Ve,'.r')
hold off
subplot(3,3,5)
plot(ResOffer.time(index_v),ResOffer.vn(index_v),'.');
hold on
plot(INSSource.time,INSSource.Vn,'.r')
hold off
index_p=(ResOffer.lati~=0);
subplot(3,3,7)
plot(ResOffer.time(index_p),ResOffer.lati(index_p),'.');
hold on
plot(INSSource.time,INSSource.lati,'.r')
hold off
subplot(3,3,8)
plot(ResOffer.time(index_p),ResOffer.longti(index_p),'.');
hold on
plot(INSSource.time,INSSource.longti,'.r')
hold off


