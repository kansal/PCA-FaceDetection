
function faceReco_CMU(row,col,numEigenVec, nk)
global w C;
load CMU-PIE/CMUPIEData.mat;
Indices = crossvalind('Kfold', 2856, 4);
totalAcc=0;
totalAcc_SVM = 0;
for i=1:4
    disp(['Computing fold-' num2str(i)])
    trainData=[];
    testData=[];
    trainLabels=[];
    testLabels=[];
    test=(Indices==i);
    for j=1:2856
        if(test(j) ~= 1)
            temp=imresize(CMUPIEData(j).pixels,[1 row*col]);
            trainData=cat(2,trainData,temp');
            trainLabels=cat(1,trainLabels,CMUPIEData(j).label);
        else
           temp=imresize(CMUPIEData(j).pixels,[1 row*col]);
           testData=cat(2,testData,temp');
           testLabels=cat(1,testLabels,CMUPIEData(j).label);
        end
    end
%     disp(size(trainData))
%     disp(size(testData))
    trainWeight=featureExtractionTrain(trainData,numEigenVec);
    testWeight=featureExtractionTest(testData);
% size(trainData)
% size(testData)
% size(trainWeight)
% size(testWeight)

mdl = ClassificationKNN.fit(trainWeight,trainLabels,'NumNeighbors',nk);
[ans1,score] =predict(mdl,testWeight);

count=0;
% size(testLabels,1)
for i=1:size(testLabels,1)
    if(testLabels(i)== ans1(i)  )
        count=count+1;
    end
end
acc=count/size(testLabels,1);
totalAcc=totalAcc+acc;

    minimums = min(trainWeight, [], 1);
    ranges = max(trainWeight, [], 1) - minimums;
    trainWeight = (trainWeight - repmat(minimums, size(trainWeight, 1), 1)) ./ repmat(ranges, size(trainWeight, 1), 1);
    testWeight = (testWeight - repmat(minimums, size(testWeight, 1), 1)) ./ repmat(ranges, size(testWeight, 1), 1);

    fileID = fopen('train.txt','w');
    for i=1:size(trainLabels, 1)
        fprintf(fileID, '%d ', trainLabels(i));
        for j=1:numEigenVec
            fprintf(fileID, '%d:%f ', j, trainWeight(i, j));
        end
        fprintf(fileID, '\n');
    end
    fclose(fileID);

    fileID = fopen('test.txt','w');
    for i=1:size(testLabels, 1)
        fprintf(fileID, '%d ', testLabels(i));
        for j=1:numEigenVec
            fprintf(fileID, '%d:%f ', j, testWeight(i, j));
        end
    fprintf(fileID, '\n');
    end
    fclose(fileID);

    [train_label, train_inst] = libsvmread('train.txt');
    train_model = svmtrain(train_label, train_inst, '-q');
    [test_label, test_inst] = libsvmread('test.txt');
    [predict_label, accuracy, dec_values] = svmpredict(test_label , test_inst, train_model);
    totalAcc_SVM = totalAcc_SVM + accuracy(1, 1);
    disp(['Accuracy = ' num2str(acc * 100)])

end
disp(['Average KNN Accuracy = ' num2str((totalAcc * 100)/ 4)])
disp(['Average SVM Accuracy = ' num2str(totalAcc_SVM / 4)])
exit
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

for i=5:numEigenVec+4
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

