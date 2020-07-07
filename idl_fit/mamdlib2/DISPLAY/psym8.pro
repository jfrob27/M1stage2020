pro psym8, fill=fill, radius=radius

if not keyword_set(fill) then fill=0
if not keyword_set(radius) then radius=1.

A =  findgen(36) * (!pi*2/35)
usersym, radius*cos(a), radius*sin(a), fill=fill

end
