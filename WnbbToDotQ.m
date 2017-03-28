function DotQ = WnbbToDotQ( wnbb,Q )
%ʹ��wnbbs������Ԫ����΢��
%20170316Salamander
Omega=[ 0,      -wnbb(1),-wnbb(2),  -wnbb(3);
        wnbb(1),0,       wnbb(3),   -wnbb(2);
        wnbb(2),-wnbb(3),0,         wnbb(1);
        wnbb(3),wnbb(2),-wnbb(1),   0];
DotQ=0.5*Omega*Q;



end

