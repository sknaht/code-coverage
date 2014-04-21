# Function to print fatal error message and terminate the script
error_exit()
{
	echo "${1:-"Unknown Error"}. Aborting..." 1>&2
	exit 1
}

build_one()
{

	echo "Update build verson, Server URL and AppId"
	buildFileName="${bundleName}${buildName}"

	#Update the build verson, e.g. v1.0.1u to v1.0.1
	#sed -E "s/(v[0-9]\.[0-9]\.[0-9][u \b\t]*)\([0-9]{5}\)/\1(${SVN_REVISION})/" "$pathInfoPlist" > out0.plist
	#com.stratetegy --> com.microstrategy
	sed -E "s/com\.strategy\.${oldBundleIDSuffix}/com\.${companyName}\.${bundleIDSuffix}/" "$pathInfoPlist" | sed -E "s/com\.microstrategy\.${oldBundleIDSuffix}/com\.${companyName}\.${bundleIDSuffix}/" > out_i_${buildEnv}1.plist
	
	# update the bundle ID for the entitlements file when running an Enterprise build
	sed -E "s/com\.strategy\.alert/com\.${companyName}\.alert/" "$pathEntitlements" | sed -E "s/com\.microstrategy\.alert/com\.${companyName}\.alert/" > out_i_${buildEnv}1.entitlements

	cp out_i_${buildEnv}1.entitlements "$pathEntitlements"

	#Update the build verson, e.g. v1.0.1u to v1.0.1
	sed -E "s/(v[0-9]\.[0-9]\.[0-9])[u \b\t]*\([0-9]{5}\)/\1${buildEnv} (${SVN_REVISION})/" out_i_${buildEnv}1.plist > out_i_${buildEnv}2.plist
	#update bundle version
	sed -E "s/999999/${SVN_REVISION}/" out_i_${buildEnv}2.plist > out_i_${buildEnv}3.plist
	#update fb app id
	sed -E "s/213419322014439/${FBID}/"  out_i_${buildEnv}3.plist | sed -E "s/155018221207734/${FBID}/" > out_i_${buildEnv}4.plist

	#update the bundle display name to Trela_u
	sed -E "s/${originalBundleDisplayName}/${bundleDisplayName}/" out_i_${buildEnv}4.plist  > out_i_${buildEnv}5.plist
	#update the pass type id
	sed -E "s/pass\.com\.strategy\.alert/pass\.com\.${companyName}\.alert/" out_i_${buildEnv}5.plist | sed -E "s/pass\.com\.microstrategy\.alert/pass\.com\.${companyName}\.alert/" > out_i_${buildEnv}6.plist

	# add the "application does not run in background argument".
	sed '/<dict>/a\
		<key>UIApplicationExitsOnSuspend</key>\
		<true/>\
	' out_i_${buildEnv}6.plist > out_i_${buildEnv}7.plist

	cp out_i_${buildEnv}7.plist "$pathInfoPlist"
	touch "$pathInfoPlist"
	
	#update Server URL
	sed -E "s/https:\/\/api2-uat\.alert\.com\//${buildServer}/" "$pathConfPlist" | sed -E "s/http:\/\/www2-uat\.dev\.alert\.com:8102\//${buildServer}/" | sed -E "s/https:\/\/api2-test\.alert\.com\//${buildServer}/" > out_c_${buildEnv}1.plist
	
	#update the app id
    sed -E "s/213419322014439/${FBID}/" out_c_${buildEnv}1.plist | sed -E "s/155018221207734/${FBID}/"  > out_c_${buildEnv}2.plist
	#update Paypal app id from APP-80W284485P519543T to APP-1M058802EB364740A
	sed -E "s/APP-80W284485P519543T/${PaypalID}/" out_c_${buildEnv}2.plist > out_c_${buildEnv}3.plist
	#update Paypal Environment type from PayPalEnvironment_SandBox to PayPalEnvironment_Live
	sed -E "s/PayPalEnvironment_SandBox/PayPalEnvironment_${PaypalEnv}/" out_c_${buildEnv}3.plist > out_c_${buildEnv}4.plist
	
	#update app server URL
	sed -E "s/http:\/\/apps-uat\.alert\.com\/AlertBiz\//${shopServer}/" out_c_${buildEnv}4.plist | sed -E "s/http:\/\/apps-demo\.alert\.com\/AlertBiz\//${shopServer}/" | sed -E "s/http:\/\/apps-test\.alert\.com\/AlertBiz\//${shopServer}/" > out_c_${buildEnv}5.plist
	

	cp out_c_${buildEnv}5.plist "$pathConfPlist"
	touch "$pathConfPlist"

	#build xcode project
	/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -workspace "../../Alert.xcworkspace" -scheme "${bundleName}" clean -configuration ${Configuration} || error_exit "Compilation Error"
	/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -workspace "../../Alert.xcworkspace" -scheme "${bundleName}" archive -configuration ${Configuration} GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES 'OTHER_CFLAGS=-ftest-coverage -fprofile-arcs' || error_exit "Compilation Error"
	
	rm -r "$pathPayload"
	mkdir -p "$pathPayload"
	
	#Get the latest archive folder name
	pathArchiveDate=$(ls -t ${pathArchives} | head -1)
	pathArchiveFile=$(ls -t ${pathArchives}/${pathArchiveDate} | head -1)
	pathArchiveFileFullPath="${pathArchives}/${pathArchiveDate}/${pathArchiveFile}"
	cp -r "${pathArchiveFileFullPath}/Products/Applications/${bundleName}.app" "$pathPayload"
	
	pathIPA="${buildFileName}.ipa"
	
	#cp -r "${productDir}/${bundleName}.app" "$pathPayload"
	#pathIPA="$pathAlert/build/${bundleName}${buildName}.ipa"
	#pathDSYM="$pathAlert/build/${bundleName}${buildName}_dsym.zip"


	zip -r "${pathIPA}" Payload > /dev/null
	
	pathPlist="$pathRelease/${buildFileName}.plist"
	pathOutPlist="$pathRelease/out.plist"
	mv "$pathIPA" "$pathRelease"
	
	echo "Build plist"
	sed -E "s/Alert%buildTime%/${buildFileName}/" "templateInbox.plist" > out1.plist
	sed -E "s/com\.strategy\.alert/com\.${companyName}\.${bundleIDSuffix}/" out1.plist > out2.plist
	sed -E "s/%buildMachine%/${buildMachine}/" out2.plist | sed -E "s/alert_icon\.png/${bundleName}_Icon\.png/" | sed -E "s/alert_icon2\.png/${bundleName}_Icon\@2x\.png/"  | sed -E "s/>alert</>${bundleName}</" > "$pathOutPlist"
	mv "$pathOutPlist" "$pathPlist"

	svn revert "$pathInfoPlist"
	svn revert "$pathConfPlist"
	svn revert "$pathEntitlements"

	rm *.plist
	
	echo "Making archive"
	pushd "${pathArchives}/${pathArchiveDate}"
	zip -r "${pathRelease}/${buildFileName}_dsym.zip" "${pathArchiveFile}" > /dev/null
	popd

}


set -x


pathAlert=".."
pathEntitlements="${pathAlert}/Alert.entitlements"
buildTime=`date +"%Y%m%d_%H%M"`
pathPayload="Payload" 
pathArchives="${HOME}/Library/Developer/Xcode/Archives"
pathRelease="${HOME}/Working"
oldBundleIDSuffix="alert4business"
originalBundleDisplayName="Trela_dev"
SVN_REVISION="54422"

#svn_version=`svn info "${pathAlert}" | grep  "Last Changed Rev: " | grep -o '[0-9]\+'`

#svn revert "$pathInfoPlist"
#svn revert "$pathConfPlist"


#copy icons
cp "../../skins/${bundleName}/Icon.png" "${pathRelease}/${bundleName}_Icon.png"
cp "../../skins/${bundleName}/Icon@2x.png" "${pathRelease}/${bundleName}_Icon@2x.png"


echo "Step 4: build Trela for Demo"
bundleName="Trela"
pathInfoPlist="${pathAlert}/Trela-Info.plist"
pathConfPlist="${pathAlert}/config.plist"
buildName="${buildTime}_v350_${SVN_REVISION}d"
buildEnv="d"
buildServer="https:\/\/api2-demo\.alert\.com\/"
shopServer="http:\/\/apps-demo\.alert\.com\/AlertBiz\/"
FBID="155018221207734"
PaypalID="APP-80W284485P519543T"
PaypalEnv="SandBox"
Configuration="Release"
companyName="microstrategy"
bundleIDSuffix="alert4businessdcc"
bundleDisplayName="Trela_d_cc"

build_one

echo "Step 6: build Trela for Test"
bundleName="Trela"
pathInfoPlist="${pathAlert}/Trela-Info.plist"
pathConfPlist="${pathAlert}/config.plist"
buildName="${buildTime}_v350_${SVN_REVISION}t"
buildEnv="t"
buildServer="https:\/\/api2-test\.alert\.com\/"
shopServer="http:\/\/apps-test\.alert\.com\/AlertBiz\/"
FBID="213419322014439"
PaypalID="APP-80W284485P519543T"
PaypalEnv="SandBox"
Configuration="Release"
companyName="microstrategy"
bundleIDSuffix="alert4businesstcc"
bundleDisplayName="Trela_t_cc"

build_one


echo "Step 2: build for Prod Mirror"
bundleName="Trela"
pathInfoPlist="${pathAlert}/Trela-Info.plist"
pathConfPlist="${pathAlert}/config.plist"
buildName="${buildTime}_v350_${SVN_REVISION}m"
buildEnv="m"
buildServer="https:\/\/api2-mirror\.alert\.com\/"
shopServer="http:\/\/apps-demo\.alert\.com\/AlertBiz\/"
FBID="155018221207734"
PaypalID="APP-80W284485P519543T"
PaypalEnv="SandBox"
Configuration="Release"
companyName="microstrategy"
bundleIDSuffix="alert4businessmcc"
bundleDisplayName="Trela_m_cc"

build_one

