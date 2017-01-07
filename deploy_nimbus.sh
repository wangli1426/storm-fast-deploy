sudo apt-get update
sudo apt-get install -y zookeeper
sudo /usr/share/zookeeper/bin/zkServer.sh restart


echo "installing maven and openjdk-8..."
sudo apt-get install -y maven
sudo apt-get install -y openjdk-8-jdk

git clone -b intra-task-parallelism --depth=1  https://github.com/wangli1426/storm

ROOT_PATH=`pwd`
echo "start to compile storm from source file..."
cd storm
mvn install -DskipTests
cd storm-dist/binary/
mvn clean package
mvn clean package -Dgpg.skip
cp target/apache-storm-0.11.0-SNAPSHOT.tar.gz $ROOT_PATH

echo "extracting the binary code..."
tar xvf apache-storm-0.11.0-SNAPSHOT.tar.gz

