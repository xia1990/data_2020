#!/bin/bash
##lihaiyan@wind-mobi.com 20180821 +++
############################################################################################################################
##note: need copy code from /wind/custom/NOHLOS befor compile
##compile all with copy:  	./build_n.sh all fc
##compile all just:		./build_n.sh all 
##other compile command:        ./build_n.sh  [ mpss | boot | tz | rpm | adsp ]  <fc>
############################################################################################################################
##lihaiyan@wind-mobi.com 20180821 ---
Base_path=`pwd`
MY_NAME=`whoami`
LOG_PATH=$WsRootDir/build-log

mod=$1
command_array=($1 $2 $3)

##lihaiyan@wind-mobi.com 20180821 +++
function copy_custom_files()
{
    cd $Base_path/..
	echo `pwd`
    echo "Start copy custom files..."
    cp -av ./wind/custom_files/NOHLOS/* ./NOHLOS/
    echo "Copy custom files finish!"
	cd $Base_path
	echo `pwd`
}
##lihaiyan@wind-mobi.com 20180821 ---
			
			
function main()
{

    for command in ${command_array[*]}; do
        ### set VARIANT
        if  [ x$command == x"fc" ] || [ x$command == x"FC" ]  ;then
			copy_custom_files
		elif [ x$command == x"all" ] || [ x$command == x"ALL" ] ;then
			mod=$command
		fi
	done		
	
    echo "1You choose is $mod"
    if [ x$mod == x"" ] ; then
        echo "Module name error!!!"
        exit 0
    fi
    
    if [ x$mod == x"all" ] || [ x$mod == x"ALL" ] ;then
        echo "You choose is ALL"
        # BOOT
        build_BOOT
        # MPSS
        build_MPSS
        # RPM
        build_RPM
        # TZ
        build_TZ
        # ADSP
        build_ADSP
    elif [ x$mod == x"mpss" ] || [ x$mod == x"MPSS" ] ;then
        build_MPSS
    elif [ x$mod == x"boot" ] || [ x$mod == x"BOOT" ] ;then
        build_BOOT
    elif [ x$mod == x"tz" ] || [ x$mod == x"TZ" ] ;then
        build_TZ
    elif [ x$mod == x"rpm" ] || [ x$mod == x"RPM" ] ;then
        build_RPM
    elif [ x$mod == x"adsp" ] || [ x$mod == x"ADSP" ] ;then
        build_ADSP
    else
        echo "check you choose is right?"
        exit 0
    fi
    echo "Please copy android HLOS!!!"
    echo "******************************************"
    echo "* Run cpn script after copy finished !!! *"
    echo "******************************************"
}

# MPSS
function build_MPSS()
{
    echo "You choose is MPSS"
	if [ -d "$Base_path/MPSS.TA.2.3/modem_proc/build/ms" ];then
    	cd $Base_path/MPSS.TA.2.3/modem_proc/build/ms
    		source setenv.sh
    		./build.sh 8953.gen.prod -c && ./build.sh 8953.gen.prod -k | tee "$LOG_PATH"/MPSS.log 2>&1
			[ "${PIPESTATUS[0]}" != "0" ] && echo -e "\033[31m build MPSS error\033[0m" && exit 1
		cd -
	else
		echo "\033[31m $Base_path/MPSS.TA.2.3/modem_proc/build/ms:no such file and directory! \033[0m"
		exit 1
	fi
}

# BOOT
function build_BOOT()
{
    echo "You choose is BOOT"
	if [ -d "$Base_path/BOOT.BF.3.3/boot_images/build/ms/" ];then	
    	cd $Base_path/BOOT.BF.3.3/boot_images/build/ms/
    	source setenv.sh
    	./build.sh TARGET_FAMILY=8953 --prod -c && ./build.sh TARGET_FAMILY=8953 --prod | tee "$LOG_PATH"/BOOT.log 2>&1
		[ "${PIPESTATUS[0]}" != "0" ] && echo -e "\033[31m build BOOT error \033[0m" && exit 1
	else
		echo "\033[31m $Base_path/BOOT.BF.3.3/boot_images/build/ms/:no such file and directory! \033[0m"
		exit 1
	fi
}

# TZ
function build_TZ()
{
    echo "You choose is TZ"
	if [ -d "$Base_path/TZ.BF.4.0.5/trustzone_images/build/ms" ];then
    cd $Base_path/TZ.BF.4.0.5/trustzone_images/build/ms
    	source setenv.sh
    	./build.sh CHIPSET=msm8953 devcfg sampleapp -c && ./build.sh CHIPSET=msm8953 devcfg sampleapp | tee "$LOG_PATH"/TZ.log 2>&1
		[ "${PIPESTATUS[0]}" != "0" ] && echo -e "\033[31m build TZ error\033[0m" && exit 1
	else
		echo "\033[31m $Base_path/TZ.BF.4.0.5/trustzone_images/build/ms:no such file and directory! \033[0m"
		exit 1
	fi
}

# RPM
function build_RPM()
{
    echo "You choose is RPM"
	if [ -d "$Base_path/RPM.BF.2.4/rpm_proc/build" ];then
    	cd $Base_path/RPM.BF.2.4/rpm_proc/build
    	source setenv.sh
    	./build_8953.sh -c && ./build_8953.sh | tee "$LOG_PATH"/RPM.log 2>&1
		[ "${PIPESTATUS[0]}" != "0" ] && echo -e "\033[31m build RPM error\033[0m" && exit 1	
	else
		echo "\033[31m $Base_path/RPM.BF.2.4/rpm_proc/build:no such file and directory! \033[0m"
		exit 1
	fi
}

# ADSP
function build_ADSP()
{
    echo "You choose is ADSP"
	if [ -d "$Base_path/ADSP.8953.2.8.4/adsp_proc" ];then
    	cd $Base_path/ADSP.8953.2.8.4/adsp_proc
    	source ./build/ms/setenv.sh
    	python ./build/build.py -c msm8953 -o clean && python ./build/build.py -c msm8953 -o all | tee "$LOG_PATH"/ADSP.log 2>&1
		[ "${PIPESTATUS[0]}" != "0" ] && echo -e "\033[31m build ADSP error\033[0m" && exit 1
	else
		echo "\033[31m $Base_path/ADSP.8953.2.8.4/adsp_proc:no such file and directory! \033[0m"
		exit 1
	fi
}

main $1 2>&1 | tee $mod.log
