mkdir output

for SEED in 1 2 3 4 5 6 7 8 9 10
do
	PREFIX="output/example-train-${SEED}"
	python3 src/disentangle.py \
	  ${PREFIX} \
	  --train data/train/*annotation.txt \
	  --dev data/dev/*annotation.txt \
	  --hidden 512 \
	  --layers 2 \
	  --nonlin softsign \
	  --word-vectors data/glove-ubuntu.txt \
	  --epochs 20 \
	  --dynet-autobatch \
	  --drop 0 \
	  --learning-rate 0.018804 \
	  --learning-decay-rate 0.103 \
	  --seed ${SEED} \
	  --clip 3.740 \
	  --weight-decay 1e-07 \
	  --opt sgd \
	  --outfile ${PREFIX}.out
done
