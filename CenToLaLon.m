function [ lati,lonti ] = CenToLaLon( Cen )
%ʹ���ɵ���ϵeת������ϵn�ķ������Ҿ���Cen����γ��lati����lati��ָ����λϵͳ�����������ɷ�λ��
%Cenָ����λϵͳ��λ���Ҿ���
%lati γ�� ��λ������
%lonti ���� ��λ������
%���������Cen�����Եļ���
lati=asin(Cen(3,3));
lonti=atan(Cen(3,2)/Cen(3,1));
if Cen(3,1)<0
    if lonti>0
        lonti=lonti-pi;
    else
        lonti=lonti+pi;
    end
end



end

