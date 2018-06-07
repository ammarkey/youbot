#!/bin/bash

checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;77mPlease, run this program as root!\n\e[0m"
    exit 1
fi
}
checkroot
if [[ -z $1 ]]; then
printf "\e[1;92m[*] Usage: sudo ./youbot.sh url \e[0m\n"
exit 1
fi

dependencies() {
command -v tor > /dev/null 2>&1 || { echo >&2 "I require tor but it's not installed. Run apt-get install Tor. Aborting."; exit 1; }
command -v proxychains > /dev/null 2>&1 || { echo >&2 "I require proxychains but it's not installed. Run apt-get install proxychains. Aborting."; exit 1; }
command -v xdotool > /dev/null 2>&1 || { echo >&2 "I require xdotool but it's not installed. Run apt-get install xdotool. Aborting."; exit 1; }
command -v firefox > /dev/null 2>&1 || { echo >&2 "I require firefox but it's not installed. Aborting."; exit 1; }
}
dependencies

checktor() {

check=$(curl --socks5-hostname localhost:9050 -s https://check.torproject.org > /dev/null; echo $?)

if [[ "$check" -gt 0 ]]; then
printf "\e[1;91mPlease, check your TOR Connection! Just type tor or service tor start\n\e[0m"
exit 1
fi

}
checktor

createprofile() {

if [ ! -d /root/.mozilla/firefox/*.bot/ ]; then
firefox -CreateProfile -no-remote bot
echo "user_pref("browser.tabs.warnOnClose", false);" > /root/.mozilla/firefox/*.bot/prefs.js
fi
}
createprofile
while  true; do
proxychains firefox -P bot $1 $1 $1 $1 > /dev/null 2>&1 &
sleep 40
wind=`xdotool search "Mozilla Firefox" | head -1`
xdotool windowactivate --sync $wind key ctrl+r
sleep 30
xdotool windowactivate --sync $wind key ctrl+r
sleep 20
xdotool windowactivate --sync $wind key alt+F4
sleep 5
killall -HUP tor
done
