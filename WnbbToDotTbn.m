function DotTbn = WnbbToDotTbn( wnbb,Tbn )
%ʹ��wnbb���������̬�����΢��
%20170319 Salamander

Omega=[ 0,-wnbb(3),wnbb(2);
        wnbb(3),0,-wnbb(1);
        -wnbb(2),wnbb(1),0];
DotTbn=Tbn*Omega;

end

