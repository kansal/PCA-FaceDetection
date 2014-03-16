#!/usr/bin/bash
rm -f files
for i in CroppedYale/yale*
do
        ls $i/*P00A* |  awk '{printf "%s %s %s\n", $0, substr($0, 33, 4), substr($0, 38, 3)} ' > List

        echo "Entering ${i}..."

        count=0;
        angle=25;

        while (( $count < 20 ))
        do
            count=0;
            angle=`expr $angle + 5`;

            rm -f tmp
            while read line
            do
                values=($line)
                declare -p values > /dev/null
                x="${values[1]}"
                y="${values[2]}"
                while [[ ${x:1:1} = "0" ]]; do x="${x:0:1}${x:2}"; done
                while [[ ${y:1:1} = "0" ]]; do y="${y:0:1}${y:2}"; done
                if [ "$x" == "+" -o "$x" == "-" ]; then x="$x""0" ;fi
                if [ "$y" == "+" -o "$y" == "-" ]; then y="$y""0" ;fi
                x=$((x))
                y=$((y))
                if (( x <= $angle && x >= -$angle && y <= $angle && y >= -$angle ))
                then
                    count=`expr $count + 1`;
                    echo $(echo $line | awk '{print $1}') $(echo $line | cut -d'/' -f2) >> tmp
                    if (($count == 20)); then break; fi
                fi
            done < "List"
        done
        cat tmp >> files
        rm -f tmp
done

rm -f List

echo "Randomizing for 4 cross validation..."
python slicer.py

rm -f files

for i in {5..100..5}
do
    echo "Number of Eigen Vectors = "$i
    matlab -nodesktop -nosplash -r "faceReco(80, 80, $i, 5)" >> Yale.log 2>&1
done
