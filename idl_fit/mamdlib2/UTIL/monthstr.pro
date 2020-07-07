function monthstr, month

  case month of
     1:m='Jan'
     2:m='Feb'
     3:m='Mar'
     4:m='Apr'
     5:m='May'
     6:m='Jun'
     7:m='Jul'
     8:m='Aug'
     9:m='Sep'
     10:m='Oct'
     11:m='Nov'
     12:m='Dec'
     'Jan':m=1
     'Feb':m=2
     'Mar':m=3
     'Apr':m=4
     'May':m=5
     'Jun':m=6
     'Jul':m=7
     'Aug':m=8
     'Sep':m=9
     'Oct':m=10
     'Nov':m=11
     'Dec':m=12
     else:m=-1
   endcase

return, m

end
