for SEED in 1 2 3 4 5 6 7 8 9 10
do
  echo ${SEED}
  python3 src/disentangle.py \
  output/example-run-${SEED} \
  --model output/example-train-${SEED}.dy.model \
  --test data/test/*annotation* \
  --test-start 1000 \
  --test-end 2000 \
  --hidden 512 \
  --layers 2 \
  --nonlin softsign \
  --word-vectors data/glove-ubuntu.txt \
  > output/example-run-${SEED}.test.out 
done
