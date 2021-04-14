#!/bin/bash

ali_suffix=
#_correct_oov_v2
combi_suffix=_combi_wsj_si284
lang=../wsj_s5/data/lang_nosp
lang_sp=../wsj_s5/data/lang
fold_id=2
fold_affix=
#train_data=data_for_kaldi_partition/train${ali_suffix}${combi_suffix}
#train_data_ocancer=data_for_kaldi_partition/train
#test_data=data_for_kaldi_partition/test
#train_fmllr_data=data_fmllr_for_kaldi_partition/train${ali_suffix}${combi_suffix}
#test_fmllr_data=data_fmllr_for_kaldi_partition/test
stage=0
stop_stage=11
do_decode=false
nj=3
decode_nj=3
num_threads_decode=3
lda_mllt_leaves=3500
lda_mllt_gausses=18000
sat_leaves=6300
sat_gausses=60000
deltas_leaves=2000
deltas_gausses=10000
expdir_suffix=_all # can be subset10000, subset5000, subset 15000 likewise
. ./cmd.sh
. ./path.sh
. utils/parse_options.sh

train_data=data_for_kaldi_partition_5fold/$fold_id/train${combi_suffix}
train_data_ocancer=data_for_kaldi_partition_5fold/$fold_id/train
test_data=data_for_kaldi_partition_5fold/$fold_id/test
train_fmllr_data=data_fmllr_for_kaldi_partition_5fold/${fold_id}${fold_affix}/train${combi_suffix}
test_fmllr_data=data_fmllr_for_kaldi_partition_5fold/${fold_id}${fold_affix}/test


expdir=exp_for_kaldi/GMM_HMM_training_deltas_${deltas_leaves}_${deltas_gausses}_lda_${lda_mllt_leaves}_${lda_mllt_gausses}_sat_${sat_leaves}_${sat_gausses}${expdir_suffix}/${fold_id}${fold_affix}/
#expdir=exp_for_kaldi/GMM_HMM_training_lda_${lda_mllt_leaves}_${lda_mllt_gausses}_sat_${sat_leaves}_${sat_gausses}${expdir_suffix}/
# extract MFCC features
#exp_for_kaldi/GMM_HMM_training_lda_${lda_mllt_leaves}_${lda_mllt_gausses}_sat_${sat_leaves}_${sat_gausses}_combi_wsj_si284${expdir_suffix} 
#if [ $stage -le 0 ]; then
#  steps/make_mfcc.sh --nj $nj  $train_data || exit 1;
#  steps/compute_cmvn_stats.sh $train_data || exit 1;
#
#  steps/make_mfcc.sh --nj $nj $test_data || exit 1;
#  steps/compute_cmvn_stats.sh $test_data || exit 1;
#
#fi
# monophone training
mkdir -p $expdir || exit 1;
  if [ $stage -le 1 ] && [ $stop_stage -gt 1 ] ; then
    steps/train_mono.sh --nj $nj $train_data $lang $expdir/mono0a || exit 1;
  fi
  if $do_decode && [ $stage -le 1 ] && [ $stop_stage -gt 1 ] ; then
    utils/mkgraph.sh ${lang}_test_tgpr $expdir/mono0a $expdir/mono0a/graph_nosp_tgpr
    nspk=$(wc -l <$test_data/spk2utt)
    [ "$nspk" -gt "$decode_nj" ] && nspk=$decode_nj
    steps/decode.sh --num-threads $num_threads_decode --nj $nspk $expdir/mono0a/graph_nosp_tgpr $test_data $expdir/mono0a/decode_nosp_tgpr
  
fi 

# monophone alignment
if [ $stage -le 2 ] && [ $stop_stage -gt 2 ]  ; then
  steps/align_si.sh --nj $nj $train_data $lang $expdir/mono0a $expdir/mono0a_ali || exit 1;
fi
# tri1 training
if [ $stage -le 3 ] && [ $stop_stage -gt 3 ] ; then
  steps/train_deltas.sh $deltas_leaves $deltas_gausses $train_data $lang $expdir/mono0a_ali $expdir/tri1 || exit 1;

fi
# tri1 alignment
if [ $stage -le 4 ] && [ $stop_stage -gt 4 ]  ; then
  steps/align_si.sh --nj $nj $train_data $lang $expdir/tri1 $expdir/tri1_ali || exit;
fi

if [ $stage -le 4 ] && $do_decode && [ $stop_stage -gt 4 ] ; then
  utils/mkgraph.sh ${lang}_test_tgpr $expdir/tri1 $expdir/tri1/graph_nosp_tgpr || exit 1
  nspk=$(wc -l <$test_data/spk2utt)
  [ "$nspk" -gt "$decode_nj" ] && nspk=$decode_nj
  steps/decode.sh --nj $nspk --num-threads $num_threads_decode $expdir/tri1/graph_nosp_tgpr $test_data $expdir/tri1/decode_nosp_tgpr

fi
# tri2 with LDA+MLLT
if [ $stage -le 5 ] && [ $stop_stage -gt 5 ] ; then
  steps/train_lda_mllt.sh  --cmd "$train_cmd" \
      --splice-opts "--left-context=3 --right-context=3" $lda_mllt_leaves $lda_mllt_gausses \
      $train_data  $lang  $expdir/tri1_ali $expdir/tri2b || exit 1;
fi

if  [ $stage -le 5 ] && $do_decode && [ $stop_stage -gt 5 ] ; then
  utils/mkgraph.sh ${lang}_test_tgpr $expdir/tri2b $expdir/tri2b/graph_nosp_tgpr
  nspk=$(wc -l <$test_data/spk2utt)
  steps/decode.sh --nj ${nspk} --num-threads $num_threads_decode  --cmd "$decode_cmd" $expdir/tri2b/graph_nosp_tgpr \
  $test_data $expdir/tri2b/decode_nosp_tgpr || exit 1;
fi
# tri2 alignment
if [ $stage -le 6 ] && [ $stop_stage -gt 6 ]   ; then
   steps/align_si.sh  --nj $nj --cmd "$train_cmd" \
    $train_data $lang $expdir/tri2b $expdir/tri2b_ali  || exit 1;

fi
# tri3 with SAT
if [ $stage -le 7 ] && [ $stop_stage -gt 7 ]  ; then
  steps/train_sat.sh --cmd "$train_cmd" $sat_leaves $sat_gausses \
      $train_data  $lang $expdir/tri2b_ali $expdir/tri3b || exit 1;
fi
if [ $stage -le 7 ] && $do_decode && [ $stop_stage -gt 7 ]  ; then
   utils/mkgraph.sh ${lang}_test_tgpr $expdir/tri3b $expdir/tri3b/graph_nosp_tgpr
   nspk=$(wc -l <$test_data/spk2utt)
   
   steps/decode_fmllr.sh --nj ${nspk} --num-threads $num_threads_decode --cmd "$decode_cmd" \
        $expdir/tri3b/graph_nosp_tgpr $test_data \
        $expdir/tri3b/decode_nosp_tgpr || exit 1; 

fi

# tri3 alignment

if [ $stage -le 8 ] && [ $stop_stage -gt 8 ] ; then
   steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" \
       $train_data $lang $expdir/tri3b $expdir/tri3b_ali || exit 1; 
fi
# tri4 with SAT using lang instead of lang_nosp
#if [ $stage -le 9 ] && [ $stop_stage -gt 9 ]  ; then
#   steps/train_sat.sh --cmd "$train_cmd" $sat_leaves $sat_gausses $train_data  ${lang_sp} $expdir/tri3b_ali $expdir/tri4b || exit 1; 
# 
#
#fi

if [ $stage -le 9 ] && $do_decode && [ $stop_stage -gt 9 ]  ; then
#   utils/mkgraph.sh ${lang_sp}_test_tgpr $expdir/tri4b $expdir/tri4b/graph_tgpr
   nspk=$(wc -l <$test_data/spk2utt)
   steps/decode_fmllr.sh --nj ${nspk} --num-threads $num_threads_decode --cmd "$decode_cmd" \
        $expdir/tri4b/graph_tgpr $test_data \
        $expdir/tri4b/decode_tgpr || exit 1;
  
  # to train data
  nspk=$decode_nj   #$(wc -l <$train_data/spk2utt)
  steps/decode_fmllr.sh --nj ${nspk} --num-threads $num_threads_decode --cmd "$decode_cmd" \
    $expdir/tri4b/graph_tgpr $train_data_ocancer \
    $expdir/tri4b/decode_train_ocancer_tgpr || exit 1;
fi
# from tri3 we extract fMLLR features and store to dir.
#if [ $stage -le 10 ] && [ $stop_stage -gt 10 ] ; then
#   mkdir -p $train_fmllr_data
#   mkdir -p $test_fmllr_data
#   # train
#   nspk=$(wc -l <$train_data/spk2utt)
#   steps/nnet/make_fmllr_feats.sh --nj $nspk --cmd "$train_cmd" --transform-dir $expdir/tri3b_ali $train_fmllr_data $train_data   $expdir/tri3b $train_fmllr_data/log $train_fmllr_data/data || exit 1;
#   # test
#   nspk=$(wc -l <$test_data/spk2utt)
#   steps/nnet/make_fmllr_feats.sh --nj $nspk --cmd "$train_cmd" --transform-dir $expdir/tri3b/decode_nosp_tgpr $test_fmllr_data $test_data   $expdir/tri3b $test_fmllr_data/log $test_fmllr_data/data || exit 1;
#   # train for ocancer only
#    nspk=$(wc -l <$train_data/../train_correct_oov_v2_added_prefix_ocancer/spk2utt)
#    steps/nnet/make_fmllr_feats.sh --nj $nspk --cmd "$train_cmd" --transform-dir $expdir/tri3b_ali $train_fmllr_data/../train $train_data/../train_correct_oov_v2_added_prefix_ocancer   $expdir/tri3b $train_fmllr_data/../train/log $train_fmllr_data/../train/data || exit 1; 
#fi
if [ $stage -le 11 ] && [ $stop_stage -gt 11 ]  ; then
   steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" \
       $train_data $lang_sp $expdir/tri4b $expdir/tri4b_ali || exit 1;
fi

# from tri4 we extract fMLLR features and store to dir.
if [ $stage -le 12 ] && [ $stop_stage -gt 12 ] ; then
   mkdir -p $train_fmllr_data
   # train
   nspk=$(wc -l <$train_data/spk2utt)
   steps/nnet/make_fmllr_feats.sh --nj $nspk --cmd "$train_cmd" --transform-dir $expdir/tri4b_ali $train_fmllr_data $train_data   $expdir/tri4b $train_fmllr_data/log $train_fmllr_data/data || exit 1;
   # test
   mkdir -p $test_fmllr_data
   nspk=$(wc -l <$test_data/spk2utt)
   steps/nnet/make_fmllr_feats.sh --nj $nspk --cmd "$train_cmd" --transform-dir $expdir/tri4b/decode_tgpr $test_fmllr_data $test_data   $expdir/tri4b $test_fmllr_data/log $test_fmllr_data/data || exit 1;
   # train for ocancer only
    nspk=$(wc -l <$train_data/../train${ali_suffix}_added_prefix_ocancer/spk2utt)
    steps/nnet/make_fmllr_feats.sh --nj $nspk --cmd "$train_cmd" --transform-dir $expdir/tri4b_ali $train_fmllr_data/../train $train_data/../train${ali_suffix}_added_prefix_ocancer   $expdir/tri4b $train_fmllr_data/../train/log $train_fmllr_data/../train/data || exit 1; 
fi
echo "succeeded.."
#exit 1;
