function [Tbn,flag] = AttiToTbn( attitude )
%���÷�λ�����������������ϵn������ϵb��ת������
%20170309 Salamander
%   attitude=[  psi;
%               theta
%               gama];
% ��λ������
%flag=0��ʾ����
%�Ƕȷ�Χ���
Tbn=zeros(3,3);
flag=1;
psi=attitude(1);
theta=attitude(2);
gama=attitude(3);
if psi<0||psi>2*pi||theta<-0.5*pi||theta>0.5*pi||gama<-pi||gama>pi
    disp('������AttiToTbn ������̬�ǳ���');
    return
else
    Tbn=[cos(gama)*cos(psi)-sin(gama)*sin(theta)*sin(psi),-cos(theta)*sin(psi),sin(gama)*cos(psi)+cos(gama)*sin(theta)*sin(psi);
         cos(gama)*sin(psi)+sin(gama)*sin(theta)*cos(psi), cos(theta)*cos(psi),sin(gama)*sin(psi)-cos(gama)*sin(theta)*cos(psi);
         -sin(gama)*cos(theta),                            sin(theta),         cos(gama)*cos(theta)                            ];
    flag=0;
end
end

