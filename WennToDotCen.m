function DotCen = WennToDotCen( wenn,Cen )
%ʹ��wenn��Cen����Cen�ı仯��
%20170323SalamandeR
DotCen=-[0,-wenn(3),wenn(2);
        wenn(3),0,-wenn(1);
        -wenn(2),wenn(1),0]*Cen;
end

