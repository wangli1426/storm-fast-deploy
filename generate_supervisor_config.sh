
function print_help {
  echo "help info:"
  echo "-c NUM set the CPU budget"
  echo "-f PATH set the storm home path"
  echo "-n IP set numbus ip"
  echo "-z IP set the zookeeper ip [default = nimbus ip]"
}

STORM_HOME=apache-storm-0.11.0-SNAPSHOT

while getopts hn:c:z: option
do
    case "${option}"
    in
      h) print_help;;
      n) NIMBUS_IP=${OPTARG};;
      z) ZOOKEEPER_IP=${OPTARG};;
      c) CORES=${OPTARG};;
      f) STORM_HOME=${OPTARG};;
    esac
done

#test if the example file exists.
if ! [ -a storm.yaml.example ]
  then
    echo "file storm.yaml.example does not exist!"
    exit 2
fi

if [ -z $NIMBUS_IP ]; then
  echo "specify nimbus ip by -n IP"
  exit 2;
fi

if [ -z $ZOOKEEPER_IP ]; then
  ZOOKEEPER_IP=$NIMBUS_IP;
  echo "zookeeper ip is not specified. To Specify, use -z IP. Use nimbus is as the zookeeper ip."
fi

cp storm.yaml.example storm.yaml


IP=`bash get_ip.sh`
sed -i "s/zookeeper1/$ZOOKEEPER_IP/g" storm.yaml
sed -i "s/nimbus_host/$NIMBUS_IP/g" storm.yaml
sed -i "s/slave_ip/$IP/g" storm.yaml

sed -i "/EnableAutomaticScaling:/d" storm.yaml 
sed -i "/EnableIntraExecutorLoadBalancing/d" storm.yaml

if ! [ -z $CORES ]; then
  sed -i "s/[#]* elasticity.cpu.budget: [0-9]*/ elasticity.cpu.budget: $CORES/" storm.yaml
fi

echo "storm.yaml is generated for the supervisor"

if [ -a $STORM_HOME ]; then
  mv storm.yaml $STORM_HOME/conf
  echo "storm.yaml is updated in $STORM_HOME/conf"
else
  echo "storm.yaml cannot be updated, as $STORM_HOME does not exist."
fi"
