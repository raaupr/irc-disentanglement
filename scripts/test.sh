
# bash scripts/infer.sh

OUTDIR="/Users/audi/Documents/GitHub/forked/irc-disentanglement/output"

echo '====== GRAPH BASED ======'
for name in ${OUTDIR}/example-run*.test.out ; do tools/format-conversion/output-from-py-to-graph.py < $name > $name.graphs ; done
src/majority_vote.py ${OUTDIR}/example-run-*.test.out.graphs --method union > ${OUTDIR}/example-run.combined.test.union
src/majority_vote.py ${OUTDIR}/example-run-*.test.out.graphs --method vote > ${OUTDIR}/example-run.combined.test.vote

total_p=0.0
total_r=0.0
total_f=0.0
for SEED in {1..10}
do
    OUTPUT=`python tools/evaluation/graph-eval.py --gold data/test/*annotation.txt --auto ${OUTDIR}/example-run-${SEED}.test.out.graphs`
    # echo ${SEED} ${OUTPUT}
    p=`echo ${OUTPUT} | cut -d' ' -f 6`
    r=`echo ${OUTPUT} | cut -d' ' -f 7`
    f=`echo ${OUTPUT} | cut -d' ' -f 8`
    total_p=`python -c "print($total_p + $p);"`
    total_r=`python -c "print($total_r + $r);"`
    total_f=`python -c "print($total_f + $f);"`
done
avg_p=`python -c "print(round($total_p / 10,2));"`
avg_r=`python -c "print(round($total_r / 10,2));"`
avg_f=`python -c "print(round($total_f / 10,2));"`
echo "AVG p/r/f: $avg_p $avg_r $avg_f"

echo '=== x10 union'
python tools/evaluation/graph-eval.py --gold data/test/*annotation.txt --auto ${OUTDIR}/example-run.combined.test.union

echo '=== x10 vote'
python tools/evaluation/graph-eval.py --gold data/test/*annotation.txt --auto ${OUTDIR}/example-run.combined.test.vote

echo '====== CLUSTER BASED ======'
for name in ${OUTDIR}/example-run*.test.out ; do tools/format-conversion/graph-to-cluster.py < $name.graphs > $name.clusters ; done

src/majority_vote.py ${OUTDIR}/example-run*.test.out.clusters --method intersect > ${OUTDIR}/example-run.combined.test.intersect

echo '===== KUMMERFELD'
python tools/format-conversion/input-to-file.py data/test/*anno*.txt > data/test/annotation.out
tools/format-conversion/output-from-py-to-graph.py < data/test/annotation.out > data/test/annotation.out.graphs
tools/format-conversion/graph-to-cluster.py < data/test/annotation.out.graphs > data/test/annotation.out.graphs.clusters

total_vi=0.0
total_11=0.0
total_p=0.0
total_r=0.0
total_f1=0.0
for SEED in {1..10}
do
    OUTPUT=`python tools/evaluation/conversation-eval.py data/test/annotation.out.graphs.clusters ${OUTDIR}/example-run-$SEED.test.out.graphs.clusters --metric vi 1-1 ex`
    # echo ${SEED} ${OUTPUT}
    vi=`echo ${OUTPUT} | cut -d' ' -f 1`
    onetoone=`echo ${OUTPUT} | cut -d' ' -f 62`
    p=`echo ${OUTPUT} | cut -d' ' -f 50`
    r=`echo ${OUTPUT} | cut -d' ' -f 54`
    f1=`echo ${OUTPUT} | cut -d' ' -f 58`
    total_vi=`python -c "print($total_vi + $vi);"`
    total_11=`python -c "print($total_11 + $onetoone);"`
    total_p=`python -c "print($total_p + $p);"`
    total_r=`python -c "print($total_r + $r);"`
    total_f1=`python -c "print($total_f1 + $f1);"`
done
avg_vi=`python -c "print(round($total_vi / 10,2));"`
avg_11=`python -c "print(round($total_11 / 10,2));"`
avg_p=`python -c "print(round($total_p / 10,2));"`
avg_r=`python -c "print(round($total_r / 10,2));"`
avg_f1=`python -c "print(round($total_f1 / 10,2));"`
echo "AVG VI: $avg_vi"
echo "AVG 1-1: $avg_11"
echo "AVG p/r/f: $avg_p $avg_r $avg_f1"

echo '=== x10 union'
tools/format-conversion/graph-to-cluster.py < ${OUTDIR}/example-run.combined.test.union > ${OUTDIR}/example-run.combined.test.union.clusters
python tools/evaluation/conversation-eval.py data/test/annotation.out.graphs.clusters ${OUTDIR}/example-run.combined.test.union.clusters --metric vi 1-1 ex

echo '=== x10 vote'
tools/format-conversion/graph-to-cluster.py < ${OUTDIR}/example-run.combined.test.vote > ${OUTDIR}/example-run.combined.test.vote.clusters
python tools/evaluation/conversation-eval.py data/test/annotation.out.graphs.clusters ${OUTDIR}/example-run.combined.test.vote.clusters --metric vi 1-1 ex

echo '=== x10 intersect'
python tools/evaluation/conversation-eval.py data/test/annotation.out.graphs.clusters ${OUTDIR}/example-run.combined.test.intersect --metric vi 1-1 ex

echo '===== DSTC8'

total_vi=0.0
total_ri=0.0
total_p=0.0
total_r=0.0
total_f1=0.0
for SEED in {1..10}
do
    OUTPUT=`python3 tools/evaluation/dstc8-evaluation.py --gold data/test/*anno*.txt --auto ${OUTDIR}/example-run-${SEED}.test.out`
    # echo ${SEED} ${OUTPUT}
    vi=`echo ${OUTPUT} | cut -d' ' -f 1`
    ri=`echo ${OUTPUT} | cut -d' ' -f 6`
    p=`echo ${OUTPUT} | cut -d' ' -f 10`
    r=`echo ${OUTPUT} | cut -d' ' -f 14`
    f1=`echo ${OUTPUT} | cut -d' ' -f 18`
    total_vi=`python -c "print($total_vi + $vi);"`
    total_ri=`python -c "print($total_ri + $ri);"`
    total_p=`python -c "print($total_p + $p);"`
    total_r=`python -c "print($total_r + $r);"`
    total_f1=`python -c "print($total_f1 + $f1);"`
done
avg_vi=`python -c "print(round($total_vi / 10,2));"`
avg_ri=`python -c "print(round($total_ri / 10,2));"`
avg_p=`python -c "print(round($total_p / 10,2));"`
avg_r=`python -c "print(round($total_r / 10,2));"`
avg_f1=`python -c "print(round($total_f1 / 10,2));"`
echo "AVG VI: $avg_vi"
echo "AVG RI: $avg_ri"
echo "AVG p/r/f: $avg_p $avg_r $avg_f1"

echo '=== x10 union'
python tools/evaluation/dstc8-evaluation.py --gold data/test/*annotation*.txt --auto ${OUTDIR}/example-run.combined.test.union

echo '=== x10 vote'
python tools/evaluation/dstc8-evaluation.py --gold data/test/*annotation*.txt --auto ${OUTDIR}/example-run.combined.test.vote