function verificationCMU(row,col,numEigenVec)
load CMU-PIE/CMUPIEData.mat;
trainData=[];
trainLabels=[];
for i=1:2856
    temp=imresize(CMUPIEData(i).pixels,[1 row*col]);
    trainData=cat(2,trainData,temp');
    trainLabels=cat(1,trainLabels,CMUPIEData(i).label);
end
 trainWeight=featureExtractionTrain(trainData,numEigenVec);
 size(trainWeight);
 distance=[];
 ROC_labels=[];
 for i=1:42:2856-42
     for j=i:i+42
         distance=cat(2,distance,norm(trainWeight(i,:)-trainWeight(j,:)));
         ROC_labels=cat(2,ROC_labels,0);
     end
 end
 for i=1:42:2856-84
     for j=i+42:i+84
         distance=cat(2,distance,norm(trainWeight(i,:)-trainWeight(j,:)));
         ROC_labels=cat(2,ROC_labels,1);
     end
 end
 [x, y, t, k, opt] = perfcurve(ROC_labels,distance,1);
 plot(x,y);
thresh=t(find(x==opt(1) & y==opt(2)))

testData=[];
testLabels=[];
% for i=1:100
%     temp=imresize(CMUPIEData(i).pixels,[1 row*col]);
%     testData=cat(2,testData,temp');
%     testLabels=cat(2,testLabels,CMUPIEData(i).label);
% end
temp=imresize(CMUPIEData(i).pixels,[1 row*col]);
testData=temp';
size(testData)
testLabels=CMUPIEData(2147).label
testWeight=featureExtractionTest(testData);
%     
% testLabels=testLabels(randperm(length(testLabels)));

for i=1:size(testWeight,1)
    flag=0;
    for j=1:size(trainWeight,1)
        if (norm(trainWeight(j,:)-testWeight(i,:)) <= thresh && trainLabels(j)==testLabels(i))
           disp(norm(trainWeight(j,:)-testWeight(i,:)))
            disp('yes')
            flag=1;
            break;
        end
    end
    if (flag==0)
        disp('no')
    end
end
end


function weight=featureExtractionTrain(A,numEigenVec)
global w C;
w=mean(A,2);
w=double(w);
A=double(A);
% disp('displaying size of w')
% size(w)
%disp('displaying size of A')
% disp(size(A))
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

function weight=featureExtractionTest(A)
global w C;
A=double(A);
A=A-repmat(w, 1, size(A, 2));
weight=double(A')*double(C);
end