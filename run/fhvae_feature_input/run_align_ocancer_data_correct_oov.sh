#!/bin/bash
fhvae_exp_root=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/FactorizedHierarchicalVAE/egs/oral_cancer/exp/oral_cancer_combi_wsj_si284/
fhvae_exp_folder_name=fhvae_lstm2L256_lat32_32_ad10_mfcc_cm_10_10_spk_e200_p40
data_suffix=_to_self # S-vector unificatin to self
data_suffix_test=_to_wsj_013
fold_affix=
this_fold_id=1
root_dir_affix=_male_fem_transc_update
do_fbank_pitch_extract=false
lr_retrain=0.008
data_dir_intermed=_2000_3500_6300
gmm_suffix=_deltas_2000_10000_lda_3500_18000_sat_6300_60000
#ali_suffix=_correct_oov
ali_suffix=
num_threads_decode=1
nj=1
stage=2
stop_stage=11
decode_stage=0 # if 1: skip lattice generation
flag_decode_train=false
. ./cmd.sh
. ./path.sh
. utils/parse_options.sh

exp_path=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/TUD${root_dir_affix}
data_path=$exp_path/data_fbank_pitch_for_kaldi_partition
train_data_suffix=$ali_suffix
#if [ $stage -le 1  ] && [ $stop_stage -gt 1 ]  ;then
#        #steps/make_mfcc.sh --nj 3 $data_path $feat_path $feat_path/log || exit 1;
#     for  partition in train; do 
#        feat_path=$data_path/$partition/data
#        steps/make_fbank_pitch.sh --nj 3 $data_path/$partition $feat_path/log $feat_path || exit 1;
#        steps/compute_cmvn_stats.sh $data_path/$partition $feat_path/log $feat_path || exit 1;
#     done
#fi

expdir=$exp_path/exp_for_kaldi_fhvae_input
gmm_expdir=$exp_path/exp_for_kaldi
srcdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/
#if [ $stage -le 2 ] && [ $stop_stage -gt 2  ] ;then
#    decoder_folder=exp/dnn4_sbn-fbank_add_deltas
#    data_path_all=$exp_path/data_fbank_pitch_for_kaldi_partition/train_test_all #any data might potentially be used as training data in 5-fold.
#    # we will do forced-align towards oral cancer training data 
#    # using $srcdir/$decoder_folder DNN acoustic model
#    # copy from local/nnet/train.sh
#    steps/nnet/align.sh --nj $nj  \
#     $data_path_all $srcdir/data/lang $srcdir/$decoder_folder ${expdir}/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix} || exit 1;
#fi

fold_id=$this_fold_id
dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_m_and_f_ocancer_${lr_retrain}${ali_suffix}/${fold_id}${fold_affix}
#if [ $stage -le 9 ] && [ $stop_stage -gt 9 ] ;then
#  # Train the DNN optimizing per-frame cross-entropy.
#  train90_file_name=train${ali_suffix}_tr90
#  cv10_file_name=train${ali_suffix}_cv10
#  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
#  data_path_tr90=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/${train90_file_name}
#  data_path_cv10=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/${cv10_file_name}
#  ali=$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
#  feature_transform=$dir_pretrain/final.feature_transform
#  
#  if [ ! -d $data_path_tr90 ]; then
#     utils/subset_data_dir_tr_cv.sh $exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/train $data_path_tr90 $data_path_cv10 
#
#  fi
#  mkdir -p $dir_retrain/log/
#  (tail --pid=$$ -F $dir_retrain/log/train_nnet.log 2>/dev/null)& # forward log
#  # Train
#  $cuda_cmd $dir_retrain/log/train_nnet.log \
#    steps/nnet/train.sh --nnet-init $dir_pretrain/final.nnet --feature-transform $feature_transform  --learn-rate $lr_retrain \
#    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_retrain || exit 1;
#
#
#fi
graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/exp/tri4b/graph_tgpr

#if [ $stage -le 10 ] && [ $stop_stage -gt 10 ] ;then
#    if $flag_decode_train ; then
#      data_path=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/train
#      set=train
#      echo "decoding $set"
#    else
#      data_path=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/test
#      set=test
#      echo "decoding $set"
#    fi
#        #acwt=0.1
#    #dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_ocancer_${lr_retrain}
#    decoder_folder=$dir_retrain
#    for acwt in 0.1 0.09 0.08 ;do
#        steps/nnet/decode.sh --nj $nj --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_${set}_dnn4_sbn_${acwt}_w_scoring || exit 1; 
#    done
#fi
#gmm_suffix=_lda_3500_18000_sat_6300_60000


#gmm_suffix=_deltas_3000_17000_lda_3500_18000_sat_6300_60000
#data_dir_intermed=_3000_3500_6300

dir_combi_train=$expdir/dnn4_recons${data_suffix}_m_and_f_ocancer_${lr_retrain}${ali_suffix}$gmm_suffix/${fold_id}
feat_path_root=$fhvae_exp_root/${fold_id}/$fhvae_exp_folder_name/eval/repl_utt/data_for_kaldi
ali=$gmm_expdir/GMM_HMM_training${gmm_suffix}_all/$fold_id${fold_affix}/tri4b_ali
if [ $stage -le 11 ] && [ $stop_stage -gt 11 ] ;then
  # Train the DNN optimizing per-frame cross-entropy.
  train90_file_name=train${ali_suffix}${data_suffix}_tr90
  cv10_file_name=train${ali_suffix}${data_suffix}_cv10
  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
  data_path_tr90=$feat_path_root/${train90_file_name}
  data_path_cv10=$feat_path_root/${cv10_file_name}
  if [ ! -d $data_path_tr90 ] || [ ! -d  $data_path_cv10 ] ; then
    # Need a pre-prepared cv_spk_list.txt
    utils/subset_data_dir_tr_cv.sh --cv-spk-list $feat_path_root/cv_spk_list.txt $feat_path_root/train${ali_suffix}${data_suffix}_complete $data_path_tr90 $data_path_cv10  || exit 1;
  fi
   

  #ali=$expdir/wsj_dnn4_sbn_train_ali
  #(to above line)ali=$expdir/GMM_HMM_training${gmm_suffix}_all/tri4b_ali
  #$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
  feature_transform=$dir_pretrain/final.feature_transform
  mkdir -p $dir_combi_train/log/
  (tail --pid=$$ -F $dir_combi_train/log/train_nnet.log 2>/dev/null)& # forward log
  # Train
  $cuda_cmd $dir_combi_train/log/train_nnet.log \
    steps/nnet/train.sh    --learn-rate $lr_retrain \
    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_combi_train || exit 1; 


fi

#graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/exp/tri4b/graph_tgpr
graphdir=$ali/../tri4b/graph_tgpr

if [ $stage -le 12 ] && [ $stop_stage -gt 12 ] ;then
    data_path=$feat_path_root/test${data_suffix_test}
        #acwt=0.1
    decoder_folder=$dir_combi_train
    nspk=$(wc -l <$data_path/spk2utt)
    [ "$nspk" -gt "$nj" ] && nspk=$nj
    for acwt in 0.1 0.09 0.08 ;do
        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_test${data_suffix_test}_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
fi

if [ $stage -le 13 ] && [ $stop_stage -gt 13 ] ;then
    data_path=$feat_path_root/train${ali_suffix}${data_suffix}_complete # deliberatly remove data_dir_intermed
    if [ !  -f ${data_path}_oc_spk/text  ] ; then
       # requires a speaker list that contains only ocancer speakers
       echo "${data_path}_oc_spk"
       utils/subset_data_dir.sh --spk-list $feat_path_root/ocancer_spk_list.txt $data_path ${data_path}_oc_spk || exit 1;
    fi
    decoder_folder=$dir_combi_train
    nspk=$(wc -l <${data_path}_oc_spk/spk2utt)
    [ "$nspk" -gt "$nj" ] && nspk=$nj
    for acwt in 0.08 0.09 0.1;do 
        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir ${data_path}_oc_spk      $decoder_folder/decode_partition_train${data_suffix}_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
    
fi



##############################below using z1 as inputs, above using train_to_self and test_to_wsj_013

dir_combi_train=$expdir/dnn4_z1_m_and_f_ocancer_${lr_retrain}${ali_suffix}$gmm_suffix/${fold_id}
feat_path_root=$fhvae_exp_root/${fold_id}/$fhvae_exp_folder_name/eval/z1_meanvar/data_for_kaldi
ali=$gmm_expdir/GMM_HMM_training${gmm_suffix}_all/$fold_id${fold_affix}/tri4b_ali
if [ $stage -le 14 ] && [ $stop_stage -gt 14 ] ;then
  # Train the DNN optimizing per-frame cross-entropy.
  train90_file_name=train${ali_suffix}_combi_wsj_si284_tr90
  cv10_file_name=train${ali_suffix}_combi_wsj_si284_cv10
  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
  data_path_tr90=$feat_path_root/${train90_file_name}
  data_path_cv10=$feat_path_root/${cv10_file_name}
  if [ ! -d $data_path_tr90 ] || [ ! -d  $data_path_cv10 ] ; then
    # Need a pre-prepared cv_spk_list.txt
    utils/subset_data_dir_tr_cv.sh --cv-spk-list $feat_path_root/cv_spk_list.txt $feat_path_root/train${ali_suffix}_combi_wsj_si284_complete $data_path_tr90 $data_path_cv10  || exit 1;
  fi
   

  #ali=$expdir/wsj_dnn4_sbn_train_ali
  #(to above line)ali=$expdir/GMM_HMM_training${gmm_suffix}_all/tri4b_ali
  #$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
  feature_transform=$dir_pretrain/final.feature_transform
  mkdir -p $dir_combi_train/log/
  (tail --pid=$$ -F $dir_combi_train/log/train_nnet.log 2>/dev/null)& # forward log
  # Train
  $cuda_cmd $dir_combi_train/log/train_nnet.log \
    steps/nnet/train.sh  --cmvn-opts "--norm-means=false --norm-vars=false"  --learn-rate $lr_retrain \
    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_combi_train || exit 1; 


fi

#graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/exp/tri4b/graph_tgpr
graphdir=$ali/../tri4b/graph_tgpr

if [ $stage -le 15 ] && [ $stop_stage -gt 15 ] ;then
    data_path=$feat_path_root/test
        #acwt=0.1
    decoder_folder=$dir_combi_train
    nspk=$(wc -l <$data_path/spk2utt)
    [ "$nspk" -gt "$nj" ] && nspk=$nj
    for acwt in 0.1 0.09 0.08 ;do
        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_test_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
fi

if [ $stage -le 16 ] && [ $stop_stage -gt 16 ] ;then
    data_path=$feat_path_root/train${ali_suffix}_combi_wsj_si284_complete # deliberatly remove data_dir_intermed
    if [ !  -f ${data_path}_oc_spk/text  ] ; then
       # requires a speaker list that contains only ocancer speakers
#       echo "${data_path}_oc_spk"
       utils/subset_data_dir.sh --spk-list $feat_path_root/ocancer_spk_list.txt $data_path ${data_path}_oc_spk || exit 1;
    fi
    decoder_folder=$dir_combi_train
    nspk=$(wc -l <${data_path}_oc_spk/spk2utt)
    [ "$nspk" -gt "$nj" ] && nspk=$nj
    for acwt in 0.08 0.09 0.1;do 
        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir ${data_path}_oc_spk      $decoder_folder/decode_partition_train_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
    
fi
### below is performing dnn training with mfcc input features, opposed to fmllr features, and others keep unchanged
#
#dir_combi_train=$expdir/dnn4_mfcc_tri4b_m_and_f_ocancer_${lr_retrain}${ali_suffix}$gmm_suffix/$fold_id${fold_affix}
#ali=$expdir/GMM_HMM_training${gmm_suffix}_all/${fold_id}${fold_affix}/tri4b_ali
#if [ $stage -le 14 ] && [ $stop_stage -gt 14 ] ;then
#  # Train the DNN optimizing per-frame cross-entropy.
#  data_suffix=_combi_wsj_si284
#  train90_file_name=train${ali_suffix}${data_suffix}_tr90
#  cv10_file_name=train${ali_suffix}${data_suffix}_cv10
#  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
#  data_path_tr90=$exp_path/data_for_kaldi_partition/${train90_file_name}
#  data_path_cv10=$exp_path/data_for_kaldi_partition/${cv10_file_name}
#  if [ ! -d $train90_file_name ] || [ ! -d  $cv10_file_name ] ; then
#    utils/subset_data_dir_tr_cv.sh --cv-spk-list /tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/TUD_fem_transc_update/data_fmllr_tri4b_for_kaldi_partition/cv_spk.list $exp_path/data_for_kaldi_partition/train${ali_suffix}${data_suffix} $data_path_tr90 $data_path_cv10  || exit 1;
#  fi
#
#
#  #ali=$expdir/wsj_dnn4_sbn_train_ali
#  #(to above line)ali=$expdir/GMM_HMM_training${gmm_suffix}_all/tri4b_ali
#  #$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
#  feature_transform=$dir_pretrain/final.feature_transform
#  mkdir -p $dir_combi_train/log/
#  (tail --pid=$$ -F $dir_combi_train/log/train_nnet.log 2>/dev/null)& # forward log
#  # Train
#  $cuda_cmd $dir_combi_train/log/train_nnet.log \
#    steps/nnet/train.sh --cmvn-opts "--norm-means=true --norm-vars=false"   --learn-rate $lr_retrain \
#    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_combi_train || exit 1;
#
#
#fi
#graphdir=$ali/../tri4b/graph_tgpr
#
#if [ $stage -le 15 ] && [ $stop_stage -gt 15 ] ;then
#    data_path=$exp_path/data_for_kaldi_partition/test
#        #acwt=0.1
#    decoder_folder=$dir_combi_train
#    nspk=$(wc -l <$data_path/spk2utt)
#    [ "$nspk" -gt "$nj" ] && nspk=$nj
#    for acwt in 0.1 0.09 0.08 ;do
#        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_test_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
#fi
#
#if [ $stage -le 16 ] && [ $stop_stage -gt 16 ] ;then
#    data_path=$exp_path/data_for_kaldi_partition/train # deliberatly remove data_dir_intermed
#    decoder_folder=$dir_combi_train
#    nspk=$(wc -l <$data_path/spk2utt)
#    [ "$nspk" -gt "$nj" ] && nspk=$nj
#    for acwt in 0.08 0.09 0.1;do
#        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_train_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
#
#fi
#
### below is performing dnn training with fbank_pitch input features, opposed to fmllr features, and others keep unchanged
#
#dir_combi_train=$expdir/dnn4_fbank_pitch_tri4b_m_and_f_ocancer_${lr_retrain}${ali_suffix}$gmm_suffix/${fold_id}${fold_affix}
#ali=$expdir/GMM_HMM_training${gmm_suffix}_all/$fold_id${fold_affix}/tri4b_ali
#if [ $stage -le 17 ] && [ $stop_stage -gt 17 ] ;then
#  data_suffix=_combi_wsj_si284
##  if $do_fbank_pitch_extract ; then 
##	steps/make_fbank_pitch.sh --nj 30 $exp_path/data_fbank_pitch_for_kaldi_partition/train${ali_suffix}${data_suffix}
##	steps/compute_cmvn_stats.sh $exp_path/data_fbank_pitch_for_kaldi_partition/train${ali_suffix}${data_suffix}
##  fi
#  # Train the DNN optimizing per-frame cross-entropy.
#  train90_file_name=train${ali_suffix}${data_suffix}_tr90
#  cv10_file_name=train${ali_suffix}${data_suffix}_cv10
#  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
#  data_path_tr90=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/${train90_file_name}
#  data_path_cv10=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/${cv10_file_name}
##  if [ ! -d $train90_file_name ] || [ ! -d  $cv10_file_name ] ; then
##    utils/subset_data_dir_tr_cv.sh --cv-spk-list /tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/TUD_fem_transc_update/data_fmllr_tri4b_for_kaldi_partition/cv_spk.list $exp_path/data_fbank_pitch_for_kaldi_partition/train${ali_suffix}${data_suffix} $data_path_tr90 $data_path_cv10  || exit 1;
##  fi
#
#
#  #ali=$expdir/wsj_dnn4_sbn_train_ali
#  #(to above line)ali=$expdir/GMM_HMM_training${gmm_suffix}_all/tri4b_ali
#  #$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
#  feature_transform=$dir_pretrain/final.feature_transform
#  mkdir -p $dir_combi_train/log/
#  (tail --pid=$$ -F $dir_combi_train/log/train_nnet.log 2>/dev/null)& # forward log
#  # Train
#  $cuda_cmd $dir_combi_train/log/train_nnet.log \
#    steps/nnet/train.sh --cmvn-opts "--norm-means=true --norm-vars=false"   --learn-rate $lr_retrain \
#    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_combi_train || exit 1;
#
#
#fi
#
#graphdir=$ali/../tri4b/graph_tgpr
#
#if [ $stage -le 18 ] && [ $stop_stage -gt 18 ] ;then
#    data_path=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/test
#        #acwt=0.1
#    decoder_folder=$dir_combi_train
#    nspk=$(wc -l <$data_path/spk2utt)
#    [ "$nspk" -gt "$nj" ] && nspk=$nj
#    for acwt in 0.1 0.09 0.08 ;do
#        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_test_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
#fi
#
#if [ $stage -le 19 ] && [ $stop_stage -gt 19 ] ;then
#    data_path=$exp_path/data_fbank_pitch_for_kaldi_partition_5fold/$fold_id/train # deliberatly remove data_dir_intermed
#    decoder_folder=$dir_combi_train
#    nspk=$(wc -l <$data_path/spk2utt)
#    [ "$nspk" -gt "$nj" ] && nspk=$nj
#    for acwt in 0.08 0.09 0.1;do
#        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_train_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
#
#fi

echo "succeeded..."
