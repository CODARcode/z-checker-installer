
if [ $# -lt 1 ]
then
	echo "Usage: ./resetZCCase.sh <case name>"
	exit
fi

./removeZCCase.sh $1
./createZCCase.sh $1
