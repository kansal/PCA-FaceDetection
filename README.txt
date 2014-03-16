CMU Dataset:

Step 1:
$ cd CMU
$ cp -rv /path/to/CMU-PIE .
$ bash CMU.sh

Step 2:
$ matlab -r "reconstruction_CMU(row, col, numEigenVector, inputImage)";

Step 3:
$ matlab -r "verification_CMU(row, col, numEigenVector)";

Yale Dataset:

Step 1:
$ cd Yale
$ cp -rv /path/to/CroppedYale .
$ bash Yale.sh

Step 2:
$ matlab -r "reconstruction_yale(row, col, numEigenVector, inputImage)";

Step 3:
$ matlab -r "verification(row, col, numEigenVector)";

Students Dataset:

Step 1:
$ cd Students
$ cp -rv /path/to/SMAIDB/* Images
$ bash Students.sh
