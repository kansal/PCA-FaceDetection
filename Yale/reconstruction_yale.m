function reconstruction_yale(row,col,numEigenVec,image)
global w C
files=['files_1';'files_2';'files_3';'files_4'];
labelsFiles=['Labels_1';'Labels_2';'Labels_3';'Labels_3'];
totalAcc=0;
%-------------------------
filename = [];
trainLabels = [];
for j=1:4
    filename = vertcat(filename, importdata(files(j, :)));
    trainLabels = vertcat(trainLabels, importdata(labelsFiles(j, :)));
end
trainWeight=featureExtractionTrain(filename,row,col,numEigenVec);
reconstruction(image,row,col);
end

function reconstruction(image,row,col)
global w C;
im=rgb2gray(imread(image));
size(im)
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

function weight=featureExtractionTrain(filename,row,col,numEigenVec)
global w C
A=[];
for i=1:size(filename,1)
    im=imread(filename{i});
    im=imresize(im,[row col]);
    im=reshape(im,row*col,1);
    A=cat(2,A,im);
end

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
[eigenValSort, index]=sort(eigenVal,'descend');
C=[];
for i=1:numEigenVec
    C= cat(2,C,double(A) * double(V(:,index(i))));
end
C=normc(C);
% size(C)
weight= (A') *(C); %projecting each image to new face space
% weight = (C'*A)';
end