#!/bin/bash
root_dir_affix=_male_fem_transc_update
this_fold_id=1
direct_decode_set=test # or can be train
stop_stage=10
decode_stage=0
nj_decode=3
do_decode=true
choose_seed=777
cmd=run.pl
lr_retrain=0.017
num_threads_decode=3
train90_file_name=train_utt_added_prefix_ocancer_tr90 # because we use alternative alignment, and that alignment contain prefix 'ocancer' to differentiate with 'wsj'
cv10_file_name=train_utt_added_prefix_ocancer_cv10
stage=9 # retrain wsj_dnn all layers, using alternative alignments
exp_path=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP
. ./cmd.sh
. ./path.sh
. utils/parse_options.sh
#bash utils/parse_options.sh

data_path=$exp_path/TUD${root_dir_affix}/data_fbank_pitch_for_kaldi_partition_5fold
#feat_path=$data_path/data
ali=$exp_path/TUD${root_dir_affix}/exp_for_kaldi/GMM_HMM_training_lda_2500_15000_sat_6300_60000_all/tri3b_ali
ali_suffix=_GMM_HMM_2500_6300_tri3b_ali
if [ $stage -le 1  ]  && [ $stop_stage -gt 1 ] ;then
    for fold_id in 1 2 3 4 5 ; do
	#steps/make_mfcc.sh --nj 3 $data_path $feat_path $feat_path/log || exit 1;
        if [ ! -d $data_path/$fold_id/train ];then
          mkdir -p $data_path/$fold_id 
    	  utils/copy_data_dir.sh $data_path/../data_for_kaldi_partition_5fold/$fold_id/train $data_path/$fold_id/train || exit 1;
        fi
        feat_path=$data_path/$fold_id/train/data
	steps/make_fbank_pitch.sh --nj 3 $data_path/$fold_id/train $feat_path/log $feat_path || exit 1;
	steps/compute_cmvn_stats.sh $data_path/$fold_id/train $feat_path/log $feat_path || exit 1;
    done
fi
expdir=$data_path/../exp_for_kaldi
graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/exp/tri4b/graph_tgpr
#graphdir=$exp_path/TUD_male_fem_transc_update/exp_for_kaldi/GMM_HMM_training_lda_2500_15000_sat_6300_60000_all/tri3b/graph_nosp_tgpr
decoder_folder=exp/dnn4_pretrain-dbn-fbank_add_deltas_dnn
srcdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/
langdir=$srcdir/data/lang/
#if [ $stage -le 2 ];then
##	graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/exp/tri4b/graph_tgpr
##	decoder_folder=exp/dnn4_pretrain-dbn-fbank_add_deltas_dnn
##	srcdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/
#	#steps/nnet/decode.sh --nj 3 --acwt 0.10 --srcdir $srcdir/$decoder_folder --skip-scoring true $graphdir $data_path  $expdir/decode || exit 1;
#	#steps/nnet/decode.sh --nj 3 --use-gpu no --acwt 0.10 --srcdir $srcdir/$decoder_folder --num-threads 8 --skip-scoring true $graphdir $data_path  $expdir/decode_multi_threads || exit 1;
#echo ""
#fi
#
#if [ $stage -le 3 ];then
#	acwt=0.2
#	steps/nnet/decode.sh --nj 3 --use-gpu no --acwt $acwt --srcdir $srcdir/$decoder_folder --num-threads 12 --skip-scoring true $graphdir $data_path      $expdir/decode_multi_threads_${acwt} || exit 1;
#
#fi
#if [ $stage -le 5 ];then
#        #acwt=0.1
#    #for acwt in 0.1 0.3 0.4;do
#    for acwt in 0.08 0.06 0.04 0.02  ; do
#        steps/nnet/decode.sh --nj 3 --use-gpu no --acwt $acwt --srcdir $srcdir/$decoder_folder --num-threads 10 --skip-scoring false $graphdir $data_path      $expdir/decode_multi_threads_${acwt}_w_scoring || exit 1;
#    done
#fi
#if [ $stage -le 6 ];then
#    data_path=$exp_path/TUD_male_fem_transc_update/data_fbank_pitch_for_kaldi_mark_spk
#        #acwt=0.1
#    for acwt in 0.1 0.15 0.2 0.25;do
#        steps/nnet/decode.sh --nj 3 --use-gpu no --acwt $acwt --srcdir $srcdir/$decoder_folder --num-threads 10 --skip-scoring false $graphdir $data_path      $expdir/decode_mark_spk_multi_threads_${acwt}_w_scoring || exit 1;
#    done
#fi
#
if [ $stage -le 7 ] && [ $stop_stage -gt 7 ] ;then

  for fold_id in $this_fold_id; do
    data_path=$exp_path/TUD${root_dir_affix}/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/$direct_decode_set
        #acwt=0.1
    decoder_folder=exp/dnn4_sbn-fbank_add_deltas
    #for acwt in  0.1 0.09 0.08 0.07 ;do
    for acwt in   0.07 ;do
        steps/nnet/decode.sh --stage $decode_stage --nj $nj_decode --use-gpu no --acwt $acwt --srcdir $srcdir/$decoder_folder --num-threads $num_threads_decode --skip-scoring false $graphdir $data_path      $expdir/decode_partition_${direct_decode_set}_dnn4_sbn_${acwt}_w_scoring/$fold_id/ || exit 1;
    done
  done
fi


if [ $stage -le 8 ] && [ $stop_stage -gt 8 ]  ;then
    decoder_folder=$srcdir/exp/dnn4_sbn-fbank_add_deltas
    data_path=$exp_path/TUD${root_dir_affix}/data_fbank_pitch_for_kaldi_partition/train
    # we will do forced-align towards oral cancer training data 
    # using $srcdir/$decoder_folder DNN acoustic model
    # copy from local/nnet/train.sh
    steps/nnet/align.sh --nj 4  \
     $data_path $srcdir/data/lang $srcdir/$decoder_folder ${expdir}/wsj_dnn4_sbn_train_ali || exit 1;


fi


dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_ocancer_${lr_retrain}${ali_suffix}
if [ $stage -le 9 ] && [ $stop_stage -gt 9 ]   ;then
  # Train the DNN optimizing per-frame cross-entropy.
  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
  data_path_tr90=$exp_path/TUD${root_dir_affix}/data_fbank_pitch_for_kaldi_partition/${train90_file_name}
  data_path_cv10=$exp_path/TUD${root_dir_affix}/data_fbank_pitch_for_kaldi_partition/${cv10_file_name}
  #ali=$expdir/wsj_dnn4_sbn_train_ali
  feature_transform=$dir_pretrain/final.feature_transform
  #dbn=$dir_pretrain/6.dbn
  mkdir -p $dir_retrain/log/
  (tail --pid=$$ -F $dir_retrain/log/train_nnet.log 2>/dev/null)& # forward log
  # Train
  $cuda_cmd $dir_retrain/log/train_nnet.log \
    steps/nnet/train.sh --nnet-init $dir_pretrain/final.nnet --feature-transform $feature_transform  --learn-rate $lr_retrain \
    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_retrain || exit 1;


fi


if [ $stage -le 10 ] && [ $stop_stage -gt 10 ]   ;then
    #data_path=$exp_path/TUD_male_fem_transc_update/data_fbank_pitch_for_kaldi_mark_spk
    data_path=$exp_path/TUD${root_dir_affix}/data_fbank_pitch_for_kaldi_partition/test
        #acwt=0.1
    decoder_folder=$dir_retrain
    for acwt in 0.1 0.09 0.08 ;do
        steps/nnet/decode.sh --nj 3 --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false $graphdir $data_path      $decoder_folder/decode_partition_test_dnn4_sbn_${acwt}_w_scoring || exit 1; 
    done
fi



echo "finished."
