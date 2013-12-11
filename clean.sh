TRAINING='training_data.csv'
TESTING='test_data.csv'

python dos2unix.py $TRAINING $TRAINING
python dos2unix.py $TESTING $TESTING

sed -i.bak 's/female/-1/' $TRAINING
sed -i.bak 's/male/1/' $TRAINING
sed -i.bak 's/TRUE/1/' $TRAINING
sed -i.bak 's/FALSE/2/' $TRAINING

sed -i.bak 's/female/-1/' $TESTING
sed -i.bak 's/male/1/' $TESTING

rm *.bak