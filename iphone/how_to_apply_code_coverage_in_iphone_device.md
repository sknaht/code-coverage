## Background Knowledge

### Tools
#### [gcov](http://gcc.gnu.org/onlinedocs/gcc/Gcov.html)
gcov is a coverage component program of gcc compiler. 
#### [lcov](http://ltp.sourceforge.net/coverage/lcov.php)
lcov is a tool used to analysis the code coverage data files and generate friendly reporting file.

### Terminology
gcov uses two files for profiling. The names of these files are derived from the original object file by substituting the file suffix with either .gcno, or .gcda. All of these files are placed in the same directory as the object file (for device, the gcda files are generated and placed on device instead of the folder where object file stored.), and contain data stored in a platform-independent format.
#### gcno
The **.gcno** file is generated when the source file is compiled with the GCC ***-ftest-coverage*** option. It contains information to reconstruct the basic block graphs and assign source line numbers to blocks.
#### gcda
The **.gcda** file is generated when a program containing object files built with the GCC ***-fprofile-arcs*** option is executed. A separate .gcda file is created for each object file compiled with this option. It contains arc transition counts, and some summary information.
derived data folder
is where object file of your project stored. gcno files are also placed there.
Open the Organizer and found your project under the Projects tab, and you will see where the derived data folder is.
 
## Steps to enable code coverage on iOS device.

### Step 1. Turn on compiling options
Select the target you want to apply code coverage and set the **Generate Test Coverage Files** and **Instrument Program Flow** flags in *Build Settings* to **YES**

### Step 2. Modification of main.m
Add these code into the main.m file of your project. The purpose of doing so is to set the proper environment variants in your program and make the gcda file in the app's document folder on the device.

	const char *prefix = "GCOV_PREFIX";
	const char *prefixValue = [[NSHomeDirectory() 	stringByAppendingPathComponent:@"Documents"] 	cStringUsingEncoding:NSASCIIStringEncoding]; // This gets the filepath to the app's 	Documents directory
	const char *prefixStrip = "GCOV_PREFIX_STRIP";
	const char *prefixStripValue = "1";
	setenv(prefix, prefixValue, 1); // This sets an environment variable which tells gcov where to put the .gcda files.
	setenv(prefixStrip, prefixStripValue, 1); // This tells gcov to strip the default prefix, and use the filepath that we just declared.
	
Add them in *main* and before:

	@autoreleasepool {
		NSString* appClass = @"UIApplicationWithEvents"; 
                int retVal = UIApplicationMain(argc, argv, appClass, nil);
                return retVal;
    }
    
- If you want to apply the code coverage just on simulator, you can skip this step.

### Step 3. Set the app not run in background
Usually, the gcda file only generated when the program exits normally. So we need to set the app won't run in background to let it exit when we put it to background, otherwise we can not got the code coverage data files.
In the Info of the target, add an extra row and select Application does not run in background then set its value to YES.


## Profiling

### Generate code coverage data files (*.gcda)
After doing the above steps and compiling and installing the app on your device, you can run and test the app just normally do. Press the Home button when you finished testing to let the program exit and code coverage data files be generated.
Connect the device to Mac and find it under the Devices tab of Organizer. Find your app in the Applications and you will see in the Document there will be code coverage data file folder (similar path with the derived data). Copy this data folder to the derived data folder by iFunbox or other tool.

### Copy the gcda files to the folder where gcno files placed
Normally, the folder path where the gcno files stored is: [derived data folder]/Build/Intermediates/[Project].build/Debug-iphonesimulator/[Target].build/Objects-normal/i386
Here we name it as [code coverage data folder].
The gcno files are generated with object files when compiling the project.
Make sure that all the gcda files on the device have been copied to the [code coverage data folder], then you can use the lcov to generate code coverage report.

### Generate code coverage report

	[lcov folder] > ./bin/lcov --capture -i [code coverage data folder] -o test.info
	[lcov folder] > ./bin/genhtml test.info -o [output folder]
	
replace the test.info to any other destination path.
By running the above two command, the report will be generated under the [output folder] folder. You can check the results from the index html file.

### Combining code coverage data together
Running different testings on different device and want to see their combined coverage?

	[lcov folder] > ./bin/lcov --capture -i [code coverage data folder 1] -o test1.info
	[lcov folder] > ./bin/lcov --capture -i [code coverage data folder 2] -o test2.info
	...
	[lcov folder] > ./bin/lcov --add-trace test1.info --add-trace test2.info ... -o test.info
	[lcov folder] > ./bin/genhtml test.info -o [output folder]
	
You just need to put the gcda files from different devices into different folders and copy gcno files to these folders, and then generate output files separatedly. lcov provides the function of --add-trace to accumulate different code coverage data together.