
function reconstruction_CMU(row,col,numEigenVec,image)
global w C;
load CMU-PIE/CMUPIEData.mat;
trainData=[];
trainLabels=[];
for j=1:2856
    temp=imresize(CMUPIEData(j).pixels,[1 row*col]);
    trainData=cat(2,trainData,temp');
    trainLabels=cat(1,trainLabels,CMUPIEData(j).label);
end
trainWeight=featureExtractionTrain(trainData,numEigenVec);
reconstruction(image,row,col);
end

function reconstruction(image,row,col)
global w C;
im=(imread(image));
figure,imshow(im);
im=imresize(im,[row col]);
im=reshape(im,row*col,1);
weight=double(im')*double(C);
size(weight)
size(C)
imnew=double(C)*(weight');
imnew=reshape(imnew,row,col);
figure,imagesc(imnew);
colormap(gray);
end


function weight=featureExtractionTrain(A,numEigenVec)
global w C;
w=mean(A,2);
w=double(w);
A=double(A);
A=A-repmat(w, 1, size(A, 2));
B = (A')*(A);
[V D]=eig(B);
eigenVal=[];

for i=1:size(D,1)
    eigenVal=cat(2,eigenVal,D(i,i));
end

[~, index]=sort(eigenVal,'descend');
C=[];

for i=3:numEigenVec+2
    C= cat(2,C,double(A) * double(V(:,index(i))));
end
C=normc(C);
% size(C)
weight= (A') *(C); %projecting each image to new face space
end