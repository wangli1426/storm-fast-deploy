
function print_help {
  echo "help info:"
  echo "-s" enable scaling [default = disable]
  echo "-l" enable intra-executor load balance [default = disable]
}

while getopts hslc: option
do
    case "${option}"
    in
      h) print_help;;
      s) SCALING_FLAG=1;;
      l) LOAD_BALANCE_FLAG=1;;
      c) CORES=${OPTARG};;
    esac
done

#test if the example file exists.
if ! [ -a storm.yaml.example ]
  then
    echo "file storm.yaml.example does not exist!"
    exit 2
fi

cp storm.yaml.example storm.yaml


IP=`bash get_ip.sh`
sed -i "s/zookeeper1/$IP/g" storm.yaml
sed -i "s/nimbus_host/$IP/g" storm.yaml
sed -i "s/slave_ip/$IP/g" storm.yaml

if ! [ -z $SCALING_FLAG ]; then
  sed -i "s/[#]* elasticity.EnableAutomaticScaling: 0/ elasticity.EnableAutomaticScaling: 1/" storm.yaml 
fi

if ! [ -z $LOAD_BALANCE_FLAG ]; then
  sed -i "s/[#]* elasticity.EnableIntraExecutorLoadBalancing: 0/ elasticity.EnableIntraExecutorLoadBalancing: 1/" storm.yaml
fi


if ! [ -z $CORES ]; then
  sed -i "s/[#]* elasticity.cpu.budget: [0-9]*/ elasticity.cpu.budget: $CORES/" storm.yaml
fi

echo "storm.yaml is generated"
