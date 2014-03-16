function verification(row,col,numEigenVec)
% fileIDS=fopen('same');
% sameImg = textscan(fileIDS,'%s %s');
% fclose(fileIDS);
% sameImg{2}
% fileIDD=fopen('diff');
% diffImg=textscan(fileIDD,'%s %s');
% for i=1:190
%     sameWeight
% end
% fclose(fileIDD);  
filename=importdata('files_1');
label=importdata('Labels_1');
trainWeight=featureExtractionTrain(filename,row,col,numEigenVec);
distance=[];
ROC_labels=[];
size(filename)

for i=1:4:size(filename,1)-5
    for j=i:i+4
        distance=cat(2,distance,norm(trainWeight(i,:)-trainWeight(j,:)));
        if(strcmp(label{i},label{j}))
            ROC_labels=cat(2,ROC_labels,0);
        else
            ROC_labels=cat(2,ROC_labels,1);
        end
    end
end

for i=1:5:size(filename,1)-10
    for j=i+5:i+9
        distance=cat(2,distance,norm(trainWeight(i,:)-trainWeight(j,:)));
        if(strcmp(label{i},label{j}))
            ROC_labels=cat(2,ROC_labels,0);
        else
            ROC_labels=cat(2,ROC_labels,1);
        end
    end
end
% size(trainWeight)   
% size(ROC_labels)
% size(distance)

% ROC_labels
% distance

[x, y, t, ~, opt] = perfcurve(ROC_labels,distance,1)

format shortg
thresh=t(find(x==opt(1) & y==opt(2)))
plot(x,y)
filename=importdata('randomFiles');
testLabels=importdata('random');
testWeight=featureExtractionTest(filename,row,col);
for i=1:size(testWeight,1)
    flag=0;
    for j=1:size(trainWeight,1)
        if (norm(trainWeight(j,:)-testWeight(i,:)) <= thresh && strcmp(label(j),testLabels(i))==1)
%             disp(testLabels(i));
%             disp(label(j));
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
[~, index]=sort(eigenVal,'descend');
C=[];
for i=1:numEigenVec
    C= cat(2,C,double(A) * double(V(:,index(i))));
end
C=normc(C);
% size(C)
weight= (A') *(C); %projecting each image to new face space
% weight = (C'*A)';
end


function weight=featureExtractionTest(filename,row,col)
global w C;
A=[];
for i=1:size(filename,1)
    im=imread(filename{i});
    im=imresize(im,[row col]);
    im=reshape(im,row*col,1);
    A=cat(2,A,im);
end
A=double(A);
A=A-repmat(w, 1, size(A, 2));
weight=double(A')*double(C);
end
