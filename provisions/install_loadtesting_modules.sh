
# pylot 
sudo yum install -y unzip
sudo pip install -U  numpy
sudo pip install -U  python-dev
sudo yum install -y numpy-1.7.1-10.el7.src.rpm
sudo yum install -y numpy
sudo yum install -y  Matplotlib
sudo yum install -y python-matplotlib

wget http://pylt.googlecode.com/files/pylot_1.26.zip 
sudo unzip -o pylot_1.26.zip  -d /opt/


# siege 
wget http://download.joedog.org/siege/siege-latest.tar.gz
tar -zxvf siege-latest.tar.gz
cd siege-*/
sudo ./configure
sudo make
sudo make install


### gatling ( new )  
wget  https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/2.1.7/gatling-charts-highcharts-bundle-2.1.7-bundle.zip 
sudo unzip -o gatling-charts-highcharts-bundle-2.1.7-bundle.zip  -d /opt/
#sudo ln -s /opt/gatling-charts-highcharts-bundle-*/bin/gatling.sh   /opt/gatling.sh


# jmeter 
wget http://mirror.olnevhost.net/pub/apache//jmeter/binaries/apache-jmeter-2.13.zip 
sudo unzip -o apache-jmeter*.zip -d /opt/
#sudo ln -s /opt/apache-jmeter*/bin/jmeter.sh  /opt/jmeter.sh


# robot framework 
sudo pip install  robotframework






















