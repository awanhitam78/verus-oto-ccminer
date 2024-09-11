#!/bin/bash
cd

echo -e 'Install update Component'
sarch=$(uname -m)

if [ "$sarch" = "aarch64" ]; then
	pkg update -y && pkg upgrade -y
	pkg install -y libjansson nano jq
	pkg install -y git nano libcurl-dev openssl-dev libjansson-dev automake autotools-dev build-essential
	termux-wake-lock

elif [ "$sarch" = "armv8" ]; then
	apt-get update -y && apt-get upgrade -y
	apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget
	#debian/ubuntu arm64
	wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
	dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
	rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb

	if [ ! -d ~/.ssh ]; then
  		mkdir ~/.ssh
  		chmod 0700 ~/.ssh
  		cat << EOF > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBy6kORm+ECh2Vp1j3j+3F1Yg+EXNWY07HbP7dLZd/rqtdvPz8uxqWdgKBtyeM7R9AC1MW87zuCmss8GiSp2ZBIcpnr8kdMvYuI/qvEzwfY8pjvi2k3b/EwSP2R6/NqgbHctfVv1c7wL0M7myP9Zj7ZQPx+QV9DscogEEfc968RcV9jc+AgphUXC4blBf3MykzqjCP/SmaNhESr2F/mSxYiD8Eg7tTQ64phQ1oeOMzIzjWkW+P+vLGz+zk32RwmzX5V>
EOF
  		chmod 0600 ~/.ssh/authorized_keys
	fi

elif [ "$sarch" = "x86_64" ]; then
	sudo apt update -y && sudo apt upgrade -y
	sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget
	sudo apt-get -y install automake autotools-dev build-essential
	#debian/ubuntu amd64
	wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb
	sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb
	rm libssl1.1_1.1.0g-2ubuntu4_amd64.deb
	if [ ! -d ~/.ssh ]; then
  		mkdir ~/.ssh
  		chmod 0700 ~/.ssh
  		cat << EOF > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBy6kORm+ECh2Vp1j3j+3F1Yg+EXNWY07HbP7dLZd/rqtdvPz8uxqWdgKBtyeM7R9AC1MW87zuCmss8GiSp2ZBIcpnr8kdMvYuI/qvEzwfY8pjvi2k3b/EwSP2R6/NqgbHctfVv1c7wL0M7myP9Zj7ZQPx+QV9DscogEEfc968RcV9jc+AgphUXC4blBf3MykzqjCP/SmaNhESr2F/mSxYiD8Eg7tTQ64phQ1oeOMzIzjWkW+P+vLGz+zk32RwmzX5V>
EOF
  		chmod 0600 ~/.ssh/authorized_keys
	fi
	echo "Update and Upgrade $sarch DONE!!"
else
    echo "Unknown architecture: $sarch"
    exit 1
fi

make distclean

echo -e 'Checking device compatibility\n'
arch=$(uname -m)
#os=$(lsb_release -i)

if [ "$arch" = "aarch64" ] || [ "$arch" = "armv8" ]; then
    echo "Architecture is compatible: $arch. Status: OK"
    # Prompt user for further action
    read -p "Do you want to continue anyway? (y/n): " choice
    case "$choice" in 
        [yY][eE][sS]|[yY])
        echo "Continuing the process..."
        ;;
        [nN][oO]|[nN])
        echo "Terminating the process."
        exit 1  # End the process
        ;;
        *)
        echo "Invalid input. Terminating the process."
        exit 1  # End the process
        ;;
    esac
    sleep 5
    	# download_url=$(curl -s https://api.github.com/repos/iwanmartinsetiawan/verus-tmux-installer/releases/latest | jq -r '.zipball_url')

    	# wget -O master.zip $download_url
    	# unzip -o master.zip -d ccminer
	# cd ccminer
	if [ ! -d ~/ccminer ]; then
  		mkdir ~/ccminer
	fi
	cd ~/ccminer
	
	GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/CCminer-ARM-optimized/releases?per_page=1" | jq -c '[.[] | del (.body)]')
	GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].browser_download_url")
	GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].name")

	echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"

	wget ${GITHUB_DOWNLOAD_URL} -P ~/ccminer

	if [ -f ~/ccminer/config.json ]; then
  		INPUT=
  		COUNTER=0
  	while [ "$INPUT" != "y" ] && [ "$INPUT" != "n" ] && [ "$COUNTER" <= "10" ]
  	do
    		printf '"~/ccminer/config.json" already exists. Do you want to overwrite? (y/n) '
    	read INPUT
    	if [ "$INPUT" = "y" ]; then
      		echo "\noverwriting current \"~/ccminer/config.json\"\n"
      		rm -r ~/ccminer/config.json
    	elif [ "$INPUT" = "n" ] && [ "$COUNTER" = "10" ]
    	then
      		echo "saving as \"~/ccminer/config.json.#\""
    	else
      		echo 'Invalid input. Please answer with "y" or "n".\n'
      		((COUNTER++))
    	fi
  	done
	fi
	wget https://raw.githubusercontent.com/Oink70/Android-Mining/main/config.json -P ~/ccminer

	if [ -f ~/ccminer/ccminer ]; then
  		mv ~/ccminer/ccminer ~/ccminer/ccminer_old
	fi
	if [ -f ~/ccminer/config.json ]; then
		mv ~/ccminer/config.json ~/ccminer/config_old.json
	fi
	mv ~/ccminer/${GITHUB_DOWNLOAD_NAME} ~/ccminer/ccminer
	chmod +x ~/ccminer/ccminer

    echo "######################################################"
    echo "   Welcome to script installer ccminer lastest release"
    echo " "
    echo "   Created by: github/AwanHitam"
    echo "######################################################"
    echo " "

    # Read data from input prompt
    echo "Input wallet address"
    read -p "Input your verus wallet address:" wallet
    if [ -z "$wallet" ]; then
        wallet="RWjkskNmGpeNxpbzAm2hdJTu9VymMHDUgc"
    fi
    echo "Input worker name"
    read -p "This for worker name displayed on web luckpool:" worker
	if [ -z "$worker" ]; then
        worker="5501"
    fi
    number=""
    echo "Input number of threads mining"
	while [[ ! $number =~ ^[0-9]+$ ]]; do
    read -p "Input number cores, if you want to use hybrid mode type 4. And type 8 if you want to use regular mode:" number
    if [[ ! $number =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a valid number Core."
    fi
	done
      
	threads=$number
    user=$wallet.$worker

cat <<EOF > ~/ccminer/run
./ccminer -a verus -o stratum+tcp://ap.luckpool.net:3957 -u  $user -p d=6 -t $threads
EOF
chmod +x ~/ccminer/run

#    jq --arg user "$user" --arg threads "$threads" '.user = $user | .threads = $threads' ~/ccminer/config.json > ~/ccminer/temp.json && mv ~/ccminer/temp.json ~/ccminer/config.json
#auto create config.json pool luckpool and vipor
cat <<EOF > ~/ccminer/config.json
{
  "pools": [
    {
      "name": "LUCKPOOL",
      "url": "stratum+tcp://na.luckpool.net:3957",
      "timeout": 180,
      "disabled": 0
    },
    {
      "name": "VIPOR",
      "url": "stratum+tcp://au.vipor.net:5040",
      "timeout": 160,
      "disabled": 1
    }
  ],
  "user": "$user",
  "pass": "x",
  "algo": "verus",
  "threads": $threads,
  "cpu-priority": 1,
  "cpu-affinity": -1,
  "retry-pause": 10
}
EOF

    echo "Generate config file succesfully"

cat << EOF > ~/ccminer/start.sh
#!/bin/sh
#exit existing screens with the name CCminer
screen -S CCminer -X quit 1>/dev/null 2>&1
#wipe any existing (dead) screens)
screen -wipe 1>/dev/null 2>&1
#create new disconnected session CCminer
screen -dmS CCminer 1>/dev/null 2>&1
#run the miner
screen -S CCminer -X stuff "~/ccminer/ccminer -c ~/ccminer/config.json\n" 1>/dev/null 2>&1
printf '\nMining started.\n'
printf '===============\n'
printf '\nManual:\n'
printf 'start: ~/.ccminer/start.sh\n'
printf 'stop: screen -X -S CCminer quit\n'
printf '\nMonitor mining: screen -x CCminer\n'
printf "exit monitor: 'CTRL-a' followed by 'd'\n\n"
EOF
chmod +x start.sh

echo "Setup Complete."
echo "For edit the config with \"nano ~/ccminer/config.json\""
echo " "
echo "For exit use \"<CTRL>-x\" to exit and respond with"
echo "Type \"y\" on the question to SAVE"
echo "And hit \"ENTER\" on the name"

echo "For Advance start the miner with \"cd ~/ccminer; ./start.sh\"."
echo "And for SIMPLE start the miner with \"cd ~/ccminer; ./run\"."

#chmod a+x ccminer miner.sh
    #./miner.sh
elif [ "$arch" = "x86_64" ]; then
os_id=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
kernel=$(uname -s)
lsb=$(uname -o)
nproc=$(nproc)
	if [ -d ~/ccminer ]; then
		mv ~/ccminer ~/ccminer_old
	fi
	git clone --quiet https://github.com/Oink70/ccminer-verus.git
	if [ -d ~/ccminer-verus ]; then
		mv ~/ccminer-verus ~/ccminer
	fi
	cd ~/ccminer
    if [ -f ~/ccminer/run ]; then
		sudo rm -r ~/ccminer/run
	fi
    echo "######################################################"
    echo "   Welcome to script installer ccminer lastest release"
    echo " "
    echo "   Created by: Awan Hitam"
    echo "######################################################"
    echo " "

    # Read data from input prompt
    echo "Input wallet address"
    read -p "Input your verus wallet address: " wallet
    if [ -z "$wallet" ]; then
        wallet="RWjkskNmGpeNxpbzAm2hdJTu9VymMHDUgc"
    fi
    echo "Input worker name"
    read -p "This for worker name displayed on web luckpool: " worker
    if [ -z "$worker" ]; then
        worker="5501"
    fi
	number=""
    echo "Input number of threads mining"
	while [[ ! $number =~ ^[0-9]+$ ]]; do
    read -p "Input number cores, if you want to use hybrid mode type 4. And type 8 if you want to use regular mode:" number
    if [[ ! $number =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a valid number Core."
    fi
	done

	threads=$number
    user=$wallet.$worker

cat <<EOF > ~/ccminer/run
./ccminer -a verus -o stratum+tcp://ap.luckpool.net:3957 -u  $user -p d=6 -t $threads
EOF
chmod +x ~/ccminer/run

#    echo "Generate config and stater ccminer file succesfully"

#auto create config.json pool luckpool and vipor
cat <<EOF > ~/ccminer/config.json
{
  "pools": [
    {
      "name": "LUCKPOOL",
      "url": "stratum+tcp://na.luckpool.net:3957",
      "timeout": 180,
      "disabled": 0
    },
    {
      "name": "VIPOR",
      "url": "stratum+tcp://au.vipor.net:5040",
      "timeout": 160,
      "disabled": 1
    }
  ],
  "user": "$user",
  "pass": "x",
  "algo": "verus",
  "threads": $threads,
  "cpu-priority": 1,
  "cpu-affinity": -1,
  "retry-pause": 10
}
EOF
#auto create stater  ccminer
cat <<EOF > ~/ccminer/start.sh
~/ccminer/ccminer -c ~/ccminer/config.json
EOF

    echo "Generate config and stater ccminer file succesfully"
    chmod +x start.sh

    if [ "$os_id" = "ubuntu" ] || [ "$os_id" = "debian" ]; then
	echo "Operating System: $kernel ID: $os_id - $lsb"

	rm -f Makefile.in
	rm -f config.status

	./autogen.sh || echo done
	./configure.sh

	make -j "$nproc"
	echo "Finish Auto-Install https://github.com/Oink70 CCMiner for Verus-2.2 in $os_id with CPU Core" $(nproc) done
	echo " "
	echo " "
	echo "Setup Complete."
	echo "For edit the config walet address/Pool Web Site with \"nano ~/ccminer/config.json\""
	echo " "
	echo "For exit use \"<CTRL>-x\" to exit and respond with"
	echo "Type \"y\" on the question to SAVE"
	echo "And hit \"ENTER\" on the name"
	echo " "
	echo " "
	echo "For Start the miner with \"cd ~/ccminer; ./start.sh\"."
	echo "Good Luck and Happy Mining."

#    elif [ "$os_id" = "debian" ]; then
#	echo "Operating System: $kernel ID: $os_id - $lsb"
#	make -j "$nproc"
#	exit 2
    elif [[ "$os_id" == 'darwin'* ]]; then

	export LDFLAGS="-L/usr/local/opt/openssl/lib"
	export CPPFLAGS="-I/usr/local/opt/openssl/include"
	export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
	make distclean || echo clean

	rm -f Makefile.in
	rm -f config.status
	./autogen.sh || echo done

	./configure.sh

	make
	echo "Finish Auto-Install https://github.com/Oink70 CCMiner for Verus-2.2 in $os_id with CPU Core" $(nproc) done
    else
	echo "Unknown architecture: $os_id"
	echo "Operating System: $kernel ID: $os_id - $lsb"
    	exit 1
    fi
else
    echo "Unknown architecture: $arch"
    exit 2
fi
