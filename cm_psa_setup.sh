# vars
cwd=`pwd`
io_dir=/opt/psadmin-io
psa_dir=$io_dir/psadmin-plus
psa_git=https://github.com/psadmin-io/psadmin-plus.git
bin=/opt/oracle/psft/home/psadm2/bin

# install git
sudo yum -y install git

# install psadmin-plus
sudo mkdir -p $io_dir
sudo git clone $psa_git $psa_dir
cd $psa_dir
sudo git fetch
sudo git checkout python

# add psa to bin directory
sudo -H -u psadm2 bash -c "mkdir -p $bin"
sudo -H -u psadm2 bash -c "ln -s $psa_dir/psa $bin/psa"

# cleanup
cd $cwd
