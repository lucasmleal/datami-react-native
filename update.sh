#!/bin/bash
CUR_DIR=`pwd`;
CUR_DIR=$CUR_DIR"/../";

grep -lr "defaultSessionConfiguration" $CUR_DIR --include=*.m  --include=*.mm | while read -r line ; do
	# echo $line;
	if grep -qi 'smisdk' "$line"; ##note the space after the string you are searching for
	then
		echo $line" is already updated by plugin. Skipping ..."
	else
		cp $line $line".backup"
		initalLineCount=`<$line wc -l`;
		sed -i.bak 's|\[NSURLSessionConfiguration defaultSessionConfiguration\]|aConfig|g' $line
		linenum=`awk '/aConfig/{ print NR; exit }' $line`;
			sed -i.bak ''"$linenum"'i\
			[SmiSdk registerAppConfiguration:aConfig];\
		' $line;
		sed -i.bak ''"$linenum"'i\
			NSURLSessionConfiguration *aConfig = [NSURLSessionConfiguration defaultSessionConfiguration];\
		' $line;

		if [[ $line = *"react-native/React"* ]]; then
				echo '#import "SmiSdk.h"' > temp.txt
				cat $line >> temp.txt
				rm $line
				mv temp.txt $line
			 	#echo '#import "SmiSdk.h"' | cat - $line | tee $line >> /dev/null
			 else
			 	echo '#import <React/SmiSdk.h>' > temp.txt
				cat $line >> temp.txt
				rm $line
				mv temp.txt $line
			 	# echo '#import <React/SmiSdk.h>' | cat - $line | tee $line >> /dev/null
			fi
		finalLineCount=`<$line wc -l`;
		if (( $finalLineCount > $initalLineCount )); then
	    	echo "File Good to Go ==> $line"
	    else
	    	cp $line".backup" $line
	    	echo "Retrying file ==> $line"
	    	sed -i.bak 's|\[NSURLSessionConfiguration defaultSessionConfiguration\]|aConfig|g' $line
			linenum=`awk '/aConfig/{ print NR; exit }' $line`;
				sed -i.bak ''"$linenum"'i\
				[SmiSdk registerAppConfiguration:aConfig];\
			' $line;
			sed -i.bak ''"$linenum"'i\
				NSURLSessionConfiguration *aConfig = [NSURLSessionConfiguration defaultSessionConfiguration];\
			' $line;

			echo '#import "SmiSdk.h"' > temp.txt
			cat $line >> temp.txt
			rm $line
			mv temp.txt $line
			#echo '#import "SmiSdk.h"' | cat - $line | tee $line >> /dev/null
		fi
	fi

done
# echo "========================================"
# echo $CUR_DIR;
CUR_DIR=$CUR_DIR"react-native/React/third-party.xcconfig";
# echo $CUR_DIR
# echo "========================================"
if grep -qi 'smisdk-ios-plugin' "$CUR_DIR"; ##note the space after the string you are searching for
then
	echo $CUR_DIR" already has updated HEADER_SEARCH_PATHS";
else	
	sed -i.bak 's|HEADER_SEARCH_PATHS =|HEADER_SEARCH_PATHS = $(SRCROOT)/../../react-native-smisdk-plugin/smisdk-ios-plugin|g' $CUR_DIR;
fi
# grep -n "HEADER_SEARCH_PATHS = (" $CUR_DIR | grep -Eo '^[^:]+' | while read -r line ; do
# 	echo $line;
# 	sed -i.bak ''"$line"'i\
# 		"$(SRCROOT)/../../react-native-smisdk-plugin/smisdk-ios-plugin",\
# 	' $CUR_DIR;

# done