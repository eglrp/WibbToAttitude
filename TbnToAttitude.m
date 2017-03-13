function [ attitude,flag ] = TbnToAttitude( Tbn )
%ʹ��������ϵbת��Ϊ����ϵn�����Tbn���������̬��
%20170310Salamander
%flag=0��ʾ����
attitude=zeros(3);
flag=1;
%��������������Tbn��������ʵʩ����
psi=atan(-Tbn(1,2)/Tbn(2,2));
if Tbn(2,2)>0
    if psi<0
        psi=psi+2*pi;
    end
else
    psi=psi+pi;
end
theta=asin(Tbn(3,2));
gama=atan(-Tbn(3,1)/Tbn(3,3));
attitude=[psi,theta,gama];
flag=0;


end

