psa_dir=/opt/oracle/psft/home/psadm2/bin/test
psa_git=https://github.com/psadmin-io/psadmin-plus.git 

yum -y install git
git clone --single-branch --branch python $psa_git $psa_dir

