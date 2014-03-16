Example: how to load image no. 1, 2, 200:

>> load CMUPIEData
>> whos
  Name            Size                 Bytes  Class     Attributes

  CMUPIEData      1x2856            24059072  struct              

>> I=CMUPIEData(1).pixels;
>> I=reshape(I,[32 32]);
>> imshow(I)
>> imshow(I,[0 255])
>> CMUPIEData(1).label

ans =

     1

>> CMUPIEData(2).label

ans =

     1

>> I=CMUPIEData(2).pixels;
>> I=reshape(I,[32 32]);
>> imshow(I,[0 255])
>> I=CMUPIEData(200).pixels;
>> I=reshape(I,[32 32]);
>> imshow(I,[0 255])
***************************************************************************
In case any doubt mail me: anand.mishra@research.iiit.ac.in
