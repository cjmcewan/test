functioncode=$1
username=$2
$adminuser=$3
sudo adduser $username --disabled-password --gecos GECOS
sudo mkdir /home/$username/.ssh
echo $functioncode >> /home/$adminuser/functioncode.txt
