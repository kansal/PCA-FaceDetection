function faceReco_(row,col,numEigenVec, nk)
global w C;
% status=unix('sh script.sh');  %creates the data files and the label files
files=['files_1';'files_2';'files_3';'files_4'];
labelsFiles=['Labels_1';'Labels_2';'Labels_3';'Labels_3'];
totalAcc=0;
totalAcc_SVM=0;
for i=1:4
    %-------------------------
    disp(['Computing fold-' num2str(i)])
    filename = [];
    trainLabels = [];
    for j=1:4
        if (j ~= i)
            filename = vertcat(filename, importdata(files(j, :)));
            trainLabels = vertcat(trainLabels, importdata(labelsFiles(j, :)));
        end
    end
    trainWeight=featureExtractionTrain(filename,row,col,numEigenVec);

    filename1=importdata(files(i, :));
    testLabels=importdata(labelsFiles(i, :));
    testWeight=featureExtractionTest(filename1,row,col);

    % mdl = ClassificationKNN.fit(trainWeight,trainLabels,'NumNeighbors',5);
    % [ans1,score] =predict(mdl,testWeight);

    ans1=knnclassify(testWeight,trainWeight,trainLabels, nk);
    % ans1=myknnclassify(trainWeight,trainLabels,testWeight,5);
    count=0;
    for i=1:size(testLabels,1)
        if(testLabels(i) == ans1(i))
            count=count+1;
        end
    end
    acc=count/size(testLabels,1);
    totalAcc = totalAcc + acc;

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
disp(['Average KNN Accuracy = ' num2str((totalAcc * 100 ) / 4)])
disp(['Average SVM Accuracy = ' num2str((totalAcc_SVM) / 4)])
exit
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
for i=5:numEigenVec+4
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

function testLabel=myknnclassify(trainingData,trainingLabels,testingData,k)
distMat=pdist2(testingData,trainingData,'euclidean');
testLabel={};
for i=1:size(testingData,1)
    arr=[];
    [ans index]=sort(distMat(i,:));
    for j=1:k
        arr=cat(2,arr,trainingLabels(index(j)));
    end
    [unique_strings, ~, string_map]=unique(arr);
    most_common_string=unique_strings(mode(string_map));
    testLabel(i)=most_common_string;
end
end
