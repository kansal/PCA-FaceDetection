for i in {5..100..5}
do
    echo "Number of Eigen Vectors = "$i
    matlab -nodesktop -nosplash -r "faceReco_CMU(80, 80, 5, $i)" >> CMU.log 2>&1
done
