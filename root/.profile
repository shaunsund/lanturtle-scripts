# ash shell
alias ll="ls -la"

## functions
pulldeploy() {
  if [ -f /root/main.zip ]
  then
    rm /root/main.zip
  fi
  wget https://github.com/shaunsund/lanturtle-scripts/archive/refs/heads/main.zip
  unzip main.zip
  cd lanturtle-scripts-main
  ./deploy.sh
}

deploycleanup() {
  if [ -f /root/main.zip ]
  then
    rm /root/main.zip
  fi

  if [ -d /root/lanturtle-scripts-main ]
  then
    rm -rfv /root/lanturtle-scripts-main
  fi
}