program str2df90

implicit none

!integer,parameter::lag_max=20,ordre_max=2,indef=-32768
integer::lag_max,ordre_max,indef
integer::dim_im1,dim_im2,i,j,k
!integer::indshift(2)
integer,allocatable,dimension(:,:)::binaire,binaire1,binaire2
real(1),allocatable,dimension(:,:)::image,image1,image2
real(2),allocatable,dimension(:,:)::nbpoint2d
real(2),allocatable,dimension(:,:,:)::str2d
!real(2)::nbpoint2d(lag_max,2*lag_max+1)
!real(2)::str2d(lag_max,2*lag_max+1,ordre_max-1)

open(1,file='imagestr.dat',status='old')
read(1,*) dim_im1, dim_im2, lag_max, ordre_max, indef
allocate(image(dim_im1,dim_im2))
allocate(nbpoint2d(lag_max+1,2*lag_max+1))
allocate(str2d(lag_max+1,2*lag_max+1,ordre_max-1))
read(1,*) image
close(1)

allocate(binaire(dim_im1,dim_im2))
allocate(binaire1(2*dim_im1,3*dim_im2))
allocate(binaire2(2*dim_im1,3*dim_im2))
allocate(image1(2*dim_im1,3*dim_im2))
allocate(image2(2*dim_im1,3*dim_im2))
image1=0
binaire1=0
image2=0
binaire2=0
binaire=0
where (image /= indef) binaire=1
image1(1:dim_im1,1:dim_im2)=image
binaire1(1:dim_im1,1:dim_im2)=binaire

do j=-lag_max, lag_max 
   print*, j
!   indshift(2) = j 
   binaire2 = cshift(binaire1,j,2)
   image2 = cshift(image1,j,2)
   do i=1, lag_max+1
!      indshift(1) = i 
!      nbpoint2d(i,lag_max+j+1)=sum(binaire*cshift(binaire1,indshift))
!      nbpoint2d(i,lag_max-j+1)=sum(binaire*cshift(cshift(binaire1,i,1),-j,2))
      nbpoint2d(i,lag_max+j+1)=sum(binaire1*cshift(binaire2,i,1))
!      nbpoint2d(i,lag_max-j+1)=sum(binaire*cshift(cshift(binaire1,i,1),-j,2))
      do k=2,ordre_max
!         str2d(i,lag_max+j+1,k-1)=sum((image1-cshift(image1,indshift))**k &
!         *binaire1*(cshift(binaire1,indshift)))
         str2d(i,lag_max+j+1,k-1)=sum((image1-cshift(image2,i,1))**k*binaire1*cshift(binaire2,i,1))
      end do
   end do
end do

do i=1,ordre_max-1
!   tempo = str2d(:,:,i)
   where (nbpoint2d /= 0) str2d(:,:,i)=str2d(:,:,i)/nbpoint2d
!   str2d(:,:,i) = tempo(where nbpoint2d /= 0)/nbpoint2d(where nbpoint2d /= 0)
end do

open(1,file='str2d.dat')

do k=1,ordre_max-1
   do j=1,size(str2d,2) 
      do i=1,size(str2d,1) 
         write(1,*) str2d(i,j,k)
      end do
   end do
end do

close(1)

end program str2df90


