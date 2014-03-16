#!/usr/bin/bash
rm -f files labels
VALID_STUDENTS=$(for i in Images/* ; do echo $i | cut -d'_' -f1 ; done  | sort | uniq -c | sort -k1rn | awk '{if ($1>=5) print $2}')
VALID_IMAGES=$(for i in $VALID_STUDENTS ; do ls ${i}* ; done)
for i in $VALID_IMAGES; do echo $i >> files ; done
for i in $VALID_IMAGES; do echo $i | cut -d '_' -f1 | cut -d'/' -f2 >> labels ; done

for i in 10 20 30 40 50 60 70 80 90 100
do
    echo "Number of Eigen Vectors = "$i
    matlab -nodesktop -nosplash -r "Students(80, 80, 10, $i)" >> Students.log 2>&1
done

