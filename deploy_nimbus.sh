sudo apt-get update
sudo apt-get install -y zookeeper
sudo /usr/share/zookeeper/bin/zkServer.sh restart


echo "installing maven and openjdk-8..."
sudo apt-get install -y maven
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install -y python

ROOT_PATH=`pwd`

git clone -b intra-task-parallelism --depth=1  https://github.com/wangli1426/storm

echo "start to compile storm from source file..."
cd storm
git fetch origin
git merge origin/intra-task-parallelism
mvn install -DskipTests
cd storm-dist/binary/
mvn clean package -Dgpg.skip
cd target
tar xvf apache-storm-0.11.0-SNAPSHOT.tar.gz
ln -s $PWD/apache-storm-0.11.0-SNAPSHOT $ROOT_PATH/apache-storm-0.11.0-SNAPSHOT
#cp target/apache-storm-0.11.0-SNAPSHOT.tar.gz $ROOT_PATH

cd $ROOT_PATH
#echo "extracting the binary code..."
#tar xvf apache-storm-0.11.0-SNAPSHOT.tar.gz

bash generate_nimbus_config.sh
