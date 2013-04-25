#!/bin/bash

if test $# != 1
then
	echo "Generates summary report in XML for a sequencing run"
	echo "usage:"
	echo "Count-Sequences.sh directoryWithProjects"
	exit
fi

inputDirectory=$1
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"


echo "<samples>"

echo -e "\t<metaData>"
echo -e "\t\t<user>$(whoami)</user>"
echo -e "\t\t<path>$(pwd)</path>"
echo -e "\t\t<computer>$(hostname)</computer>"
echo -e "\t\t<time>$(date)</time>"
echo -e "\t</metaData>"

allSequences=0

for projectName in $(ls $inputDirectory|grep Project_ ; ls $inputDirectory | grep Undetermined_)
do
	for sampleName in $(ls $inputDirectory/$projectName)
	do

		echo -e "\t<sample>"
		echo -e "\t\t<projectName>$projectName</projectName>"
		echo -e "\t\t<sampleName>$sampleName</sampleName>"
		
		echo -e "\t\t<files>"

		totalSequences=0

		for sequenceFile in $(ls $inputDirectory/$projectName/$sampleName|grep .fastq.gz| sort )
		do
			path=$inputDirectory/$projectName/$sampleName/$sequenceFile
			sequences=$(($(zcat $path | wc -l) / 4))
			sha1Sum=$(sha1sum $path | awk '{print $1}')
			readLength=$(echo -n $(zcat $path | head -n2 | tail -n1) | wc -c | awk '{print $1}')

			echo -e "\t\t\t<file>"
			echo -e "\t\t\t\t<name>$sequenceFile</name>"
			echo -e "\t\t\t\t<sequences>$sequences</sequences>"
			echo -e "\t\t\t\t<readLength>$readLength</readLength>"
			echo -e "\t\t\t\t<sha1Sum>$sha1Sum</sha1Sum>"
			echo -e "\t\t\t</file>"

			totalSequences=$(($totalSequences + $sequences))
		done

		allSequences=$(($allSequences + $totalSequences))

		echo -e "\t\t</files>"

		echo -e "\t\t<sequences>$totalSequences</sequences>"

		echo "	</sample>"
	done
done

echo -e "\t<sequences>$allSequences</sequences>"

echo "</samples>"
