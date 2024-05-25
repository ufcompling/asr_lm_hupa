#!/bin/bash

numBpeMergeOps=$1
tier=$2
split=random
n=$3
size=$4

mkdir data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps
mkdir data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n
mkdir data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n


echo 'copying wav.scp, utt2spk; making spk2utt'
cp data_lexicon/hupa/"$tier"_tier/"$split"/train$n/wav.scp data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n/
cp data_lexicon/hupa/"$tier"_tier/"$split"/train$n/utt2spk data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n/
utils/utt2spk_to_spk2utt.pl data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n/utt2spk > data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n/spk2utt

cp data_lexicon/hupa/"$tier"_tier/"$split"/dev$n/wav.scp data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n/
cp data_lexicon/hupa/"$tier"_tier/"$split"/dev$n/utt2spk data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n/
utils/utt2spk_to_spk2utt.pl data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n/utt2spk > data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n/spk2utt

utils/fix_data_dir.sh data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n
utils/fix_data_dir.sh data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n

echo 'compute mfcc for train dev...'
for dir in data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/train$n data_lexicon/hupa/"$tier"_tier/"$split"_"$size"_bpe_$numBpeMergeOps/dev$n
do
	steps/make_mfcc.sh --nj 4 $dir exp/make_mfcc/$dir $dir/mfcc
	steps/compute_cmvn_stats.sh $dir exp/make_mfcc/$dir $dir/mfcc
done


