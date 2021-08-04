function[square]=square2d(xl,xh,yl,yh,m,n)
square=zeros(m,n);
xl = round(xl);
xh = round(xh);
yl = round(yl);
yh = round(yh);

for x=1:m
  for y=1:n
    if ((x>=xl)&&(x<=xh)&&(y>=yl)&&(y<=yh))
        square(x,y)=1;
    end
  end
end
end