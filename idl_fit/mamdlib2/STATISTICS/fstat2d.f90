program fstatd2d

implicit none

integer,parameter::lag_max=20,ordre_max=2,indef=-32768
integer::dim_im1,dim_im2,i,j,k
integer,allocatable,dimension(:,:)::binaire,binaire1
real(2)::nbpoint2d(2*lag_max+1,2*lag_max+1)
real(2)::str2d(2*lag_max+1,2*lag_max+1,ordre_max-1)
real(1),allocatable,dimension(:,:)::image,image1

open(1,file='image.dat',status='old')
read(1,*) dim_im1,dim_im2
allocate(image(dim_im1,dim_im2))
read(1,*) image
close(1)

allocate(binaire(dim_im1,dim_im2))
allocate(binaire1(3*dim_im1,3*dim_im2))
allocate(image1(3*dim_im1,3*dim_im2))
image1=0
binaire1=0
binaire=0
where (image /= indef) binaire=1
image1(dim_im1+1:2*dim_im1,dim_im2+1:2*dim_im2)=image
binaire1(dim_im1+1:2*dim_im1,dim_im2+1:2*dim_im2)=binaire

do j=-lag_max+1,lag_max-1 
   do i=0,lag_max-1
      nbpoint2d(lag_max+i,lag_max+j)=sum(binaire*cshift(cshift(binaire1,i,1),j,2))
      nbpoint2d(lag_max-i,lag_max-j)=nbpoint2d(lag_max+i,lag_max+j)
      do k=2,ordre_max
         str2d(lag_max+i,lag_max+j,k-1)=sum((image1-cshift(cshift(image1,i,1),j,2))**k &
         *binaire1*cshift(cshift(binaire1,i,1),j,2))
         str2d(lag_max-i,lag_max-j,k-1)=str2d(lag_max+i,lag_max+j,k-1)
      end do
   end do
end do

do i=1,ordre_max-1
   str2d(:,:,i)=str2d(:,:,i)/nbpoint2d
end do

open(1,file='str2d.dat')

do k=1,ordre_max-1
   write(1,*) ((str2d(i,j,k),i=1,size(str2d,1)),j=1,size(str2d,2))
end do

close(1)

end program fstatd2d
