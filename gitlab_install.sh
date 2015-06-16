
sudo yum install curl openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh
sudo yum install gitlab-ce
sudo gitlab-ctl reconfigure

Username: root 
Password: 5iveL!fe

