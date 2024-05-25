bash path.sh

tier=$1
n=$2

bash data/hupa/"$tier"_tier/random/hupa_random_same_utt_spk$n.sh

utils/fix_data_dir.sh data/hupa/"$tier"_tier/random/train$n
utils/fix_data_dir.sh data/hupa/"$tier"_tier/random/dev$n

bash data/hupa/"$tier"_tier/random/hupa_random_same_compute_mfcc$n.sh

bash utils/prepare_lang.sh data/hupa/local/dict "<UNK>" data/hupa/local/lang data/hupa/lang

lm_order=3

echo $lm_order

echo
echo "===== LANGUAGE MODEL CREATION ====="
echo "===== MAKING lm.arpa ====="
echo
loc=`which ngram-count`;
if [ -z $loc ]; then
        if uname -a | grep 64 >/dev/null; then
                sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
        else
                        sdir=$KALDI_ROOT/tools/srilm/bin/i686
        fi
        if [ -f $sdir/ngram-count ]; then
                        echo "Using SRILM language modelling tool from $sdir"
                        export PATH=$PATH:$sdir
        else
                        echo "SRILM toolkit is probably not installed.
                                Instructions: tools/install_srilm.sh"
                        exit 1
        fi
fi

mkdir data/hupa/"$tier"_tier/random/train$n/local
local=data/hupa/"$tier"_tier/random/train$n/local

## Base language model, i.e., language model trained from only transcripts of training data
mkdir $local/tmp_base
ngram-count -order $lm_order -write-vocab $local/tmp_base/vocab-full.txt -wbdiscount -text data/hupa/"$tier"_tier/random/train$n/corpus.1 -lm $local/tmp_base/lm.arpa
echo
echo "===== MAKING G.fst ====="
echo
original_lang=data/hupa/lang

mkdir data/hupa/"$tier"_tier/random/train$n/lang_base
cp -R $original_lang/* data/hupa/"$tier"_tier/random/train$n/lang_base/

lang=data/hupa/"$tier"_tier/random/train$n/lang_base
src/lmbin/arpa2fst --disambig-symbol=#0 --read-symbol-table=$original_lang/words.txt $local/tmp_base/lm.arpa $lang/G.fst


## Largest language model, i.e., language model trained from the concatenation of transcripts of training data and all the external text
cat data/hupa/"$tier"_tier/random/train$n/corpus.1 data/hupa/local/hupa_texts.txt > data/hupa/"$tier"_tier/random/train$n/local/corpus.txt

mkdir $local/tmp_large

ngram-count -order $lm_order -write-vocab $local/tmp_large/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp_large/lm.arpa
echo
echo "===== MAKING G.fst ====="
echo
original_lang=data/hupa/lang

mkdir data/hupa/"$tier"_tier/random/train$n/lang_large
cp -R $original_lang/* data/hupa/"$tier"_tier/random/train$n/lang_large/

lang=data/hupa/"$tier"_tier/random/train$n/lang_large
src/lmbin/arpa2fst --disambig-symbol=#0 --read-symbol-table=$original_lang/words.txt $local/tmp_large/lm.arpa $lang/G.fst
