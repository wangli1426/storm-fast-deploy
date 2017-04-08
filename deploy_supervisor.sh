function print_help {
  echo "help info:"
  echo "-c NUM set the CPU budget"
  echo "-n IP set numbus ip"
  echo "-z IP set the zookeeper ip [default = nimbus ip]"
  echo "-x copy storm binary folder from nimbus"
}

STORM_HOME=apache-storm-0.11.0-SNAPSHOT

while getopts hn:c:z:x option
do
    case "${option}"
    in
      h) print_help;;
      n) NIMBUS_IP=${OPTARG};;
      z) ZOOKEEPER_IP=${OPTARG};;
      c) CORES=${OPTARG};;
      f) STORM_HOME=${OPTARG};;
      x) NO_COMPILE=1
    esac
done

if [ -z $NIMBUS_IP ]; then
  echo "specify nimbus_ip by -n IP"
  exit 2;
fi

if [ -z $ZOOKEEPER_IP ]; then
  echo "supervisor ip is not specified, use nimbus ip $NIMBUS_IP as default."
  ZOOKEEPER_IP=$NIMBUS_IP
fi

sudo apt-get update


echo "installing maven and openjdk-8..."
sudo apt-get install -y maven
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install -y python
git clone -b intra-task-parallelism --depth=1  https://github.com/wangli1426/storm

if [ -z $NO_COMPILE ]; then
  ROOT_PATH=`pwd`
  echo "start to compile storm from source file..."
  cd storm
  git fetch origin
  git merge origin/intra-task-parallelism
  mvn install -DskipTests
  cd storm-dist/binary/
  mvn clean package
  mvn clean package -Dgpg.skip
  cp target/apache-storm-0.11.0-SNAPSHOT.tar.gz $ROOT_PATH

  cd $ROOT_PATH
  echo "extracting the binary code..."
  tar xvf apache-storm-0.11.0-SNAPSHOT.tar.gz
else
 # cd $ROOT_PATH
  echo "copy apache binary folder from nimbus ($NIMBUS_IP)"
  scp -r ubuntu@$NIMBUS_IP:/home/ubuntu/storm-fast-deploy/apache-storm-0.11.0-SNAPSHOT ./  
  echo "$PWD"
fi
bash generate_supervisor_config.sh -n $NIMBUS_IP -z $ZOOKEEPER_IP
