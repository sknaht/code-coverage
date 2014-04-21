feature="unname"
deriveddDataPath="/Users/Zhenyu/Library/Developer/xcode/deriveddata/Alert-blvnnpxoxsegbohbweknqcdatpok"
gcdaDataPath="/Users/Zhenyu/IntermediateBuildFilesPath"

generate_report()
{
	# copy the *.gcda files to the derivedData folder
	echo "Step 1. Copy *.gcda files to derivedData folder."
	cp ${sourcefolder}/* ${destinefolder}

	# generate the info file.
	echo "Step 2. Generate info file."
	lcov --capture \
	--directory ${destinefolder} \
	--output-file ./test/${outname}.info

	# process the info file.
	echo "Step 3. Process the info file and reduce unnecessary folders/files."
	python process_info_file.py test/${outname}.info tmp.info
	cp tmp.info ./test/${outname}.info
	# rm tmp.info

	# generate the html report files.
	echo "Step 4. Generate the HTML report files."
	genhtml ./test/${outname}.info -o ./test/${outname} \
	--ignore-errors source --quiet -t ${outname}
}

if [ x$1 != x ]
then
	feature=$1
fi
echo ${feature}
# generate report for Alert project
outname="alert-${feature}"
folderPath="Alert.build/Release-iphoneos/Trela.build"
sourcefolder="${gcdaDataPath}/${folderPath}/Objects-normal/armv7"
destinefolder="${deriveddDataPath}/Build/Intermediates/ArchiveIntermediates/Trela/IntermediateBuildFilesPath/${folderPath}/Objects-normal/armv7"
generate_report

# generate report for Alertcore
outname="Alertcore-${feature}"
folderPath="AlertCore.build/Release-iphoneos/AlertCore.build"
sourcefolder="${gcdaDataPath}/${folderPath}/Objects-normal/armv7"
destinefolder="${deriveddDataPath}/Build/Intermediates/ArchiveIntermediates/Trela/IntermediateBuildFilesPath/${folderPath}/Objects-normal/armv7"
generate_report


