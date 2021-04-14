#!/bin/bash
lr_retrain=0.008
#ali_suffix=_correct_oov
ali_suffix=_correct_oov_v2
train_data_suffix=$ali_suffix
num_threads_decode=1
nj=1
stage=2
stop_stage=11
decode_stage=0 # if 1: skip lattice generation
exp_path=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/TUD_fem_transc_update
data_path=$exp_path/data_fbank_pitch_for_kaldi_partition
. ./cmd.sh
. ./path.sh
. utils/parse_options.sh

if [ $stage -le 1  ];then
        #steps/make_mfcc.sh --nj 3 $data_path $feat_path $feat_path/log || exit 1;
     #for  partition in train_female test; do 
     for  partition in train; do 
        feat_path=$data_path/$partition/data
        steps/make_fbank_pitch.sh --nj 3 $data_path/$partition $feat_path/log $feat_path || exit 1;
        steps/compute_cmvn_stats.sh $data_path/$partition $feat_path/log $feat_path || exit 1;
     done
fi

expdir=$exp_path/exp_for_kaldi
srcdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/
if [ $stage -le 2 ];then
    decoder_folder=exp/dnn4_sbn-fbank_add_deltas
    #data_path=$exp_path/data_fbank_pitch_for_kaldi_partition/train_female
    data_path=$exp_path/data_fbank_pitch_for_kaldi_partition/train${train_data_suffix}
    # we will do forced-align towards oral cancer training data 
    # using $srcdir/$decoder_folder DNN acoustic model
    # copy from local/nnet/train.sh
    steps/nnet/align.sh --nj $nj  \
     $data_path $srcdir/data/lang $srcdir/$decoder_folder ${expdir}/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix} || exit 1;
fi

#dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_ocancer_${lr_retrain}${ali_suffix}
dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_m_and_f_ocancer_${lr_retrain}${ali_suffix}
if [ $stage -le 9 ] && [ $stop_stage -gt 9 ] ;then
  # Train the DNN optimizing per-frame cross-entropy.
  #train90_file_name=train_female_tr90
  #cv10_file_name=train_female_cv10
  train90_file_name=train${ali_suffix}_tr90
  cv10_file_name=train${ali_suffix}_cv10
  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
  data_path_tr90=$exp_path/data_fbank_pitch_for_kaldi_partition/${train90_file_name}
  data_path_cv10=$exp_path/data_fbank_pitch_for_kaldi_partition/${cv10_file_name}
  #ali=$expdir/wsj_dnn4_sbn_train_ali
  ali=$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
  feature_transform=$dir_pretrain/final.feature_transform
  #dbn=$dir_pretrain/6.dbn
  mkdir -p $dir_retrain/log/
  (tail --pid=$$ -F $dir_retrain/log/train_nnet.log 2>/dev/null)& # forward log
  # Train
  $cuda_cmd $dir_retrain/log/train_nnet.log \
    steps/nnet/train.sh --nnet-init $dir_pretrain/final.nnet --feature-transform $feature_transform  --learn-rate $lr_retrain \
    $data_path_tr90 $data_path_cv10 $srcdir/data/lang $ali $ali $dir_retrain || exit 1;


fi
graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/wsj_s5/exp/tri4b/graph_tgpr

if [ $stage -le 10 ] && [ $stop_stage -gt 10 ] ;then
    data_path=$exp_path/data_fbank_pitch_for_kaldi_partition/test
        #acwt=0.1
    #dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_ocancer_${lr_retrain}
    decoder_folder=$dir_retrain
    for acwt in 0.1 0.09 0.08 ;do
        steps/nnet/decode.sh --nj $nj --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_test_dnn4_sbn_${acwt}_w_scoring || exit 1; 
    done
fi
#gmm_suffix=_lda_3500_18000_sat_6300_60000
gmm_suffix=_deltas_2500_15000_lda_3500_18000_sat_6300_60000
data_dir_intermed=_2500_3500_6300


#gmm_suffix=_deltas_3000_17000_lda_3500_18000_sat_6300_60000
#data_dir_intermed=_3000_3500_6300


dir_combi_train=$expdir/dnn4_fmllr_tri4b_m_and_f_ocancer_${lr_retrain}${ali_suffix}$gmm_suffix
ali=$expdir/GMM_HMM_training${gmm_suffix}_all/tri4b_ali
if [ $stage -le 11 ] && [ $stop_stage -gt 11 ] ;then
  # Train the DNN optimizing per-frame cross-entropy.
  #train90_file_name=train_female_tr90
  #cv10_file_name=train_female_cv10
  data_suffix=_combi_wsj_si284
  train90_file_name=train${ali_suffix}${data_suffix}_tr90
  cv10_file_name=train${ali_suffix}${data_suffix}_cv10
  dir_pretrain=$srcdir/exp/dnn4_sbn-fbank_add_deltas
  data_path_tr90=$exp_path/data_fmllr_tri4b${data_dir_intermed}_for_kaldi_partition/${train90_file_name}
  data_path_cv10=$exp_path/data_fmllr_tri4b${data_dir_intermed}_for_kaldi_partition/${cv10_file_name}
  #ali=$expdir/wsj_dnn4_sbn_train_ali
  #(to above line)ali=$expdir/GMM_HMM_training${gmm_suffix}_all/tri4b_ali
  #$expdir/wsj_dnn4_sbn_train_m_and_f_ali${ali_suffix}
  feature_transform=$dir_pretrain/final.feature_transform
  #dbn=$dir_pretrain/6.dbn
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
    data_path=$exp_path/data_fmllr_tri4b${data_dir_intermed}_for_kaldi_partition/test
        #acwt=0.1
    #dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_ocancer_${lr_retrain}
    decoder_folder=$dir_combi_train
    nspk=$(wc -l <$data_path/spk2utt)
    [ "$nspk" -gt "$nj" ] && nspk=$nj
    for acwt in 0.1 0.09 0.08 ;do
        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_test_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
fi

if [ $stage -le 13 ] && [ $stop_stage -gt 13 ] ;then
    data_path=$exp_path/data_fmllr_tri4b_for_kaldi_partition/train # deliberatly remove data_dir_intermed
        #acwt=0.1
    #dir_retrain=$expdir/dnn4_sbn-fbank_add_deltas_retrain_ocancer_${lr_retrain}
    #decoder_folder=$dir_combi_train
    graphdir=/tudelft.net/staff-bulk/ewi/insy/SpeechLab/siyuanfeng/software/kaldi/egs/relocated_from_DSP/TUD_fem_transc_update/exp_for_kaldi/GMM_HMM_training_lda_3500_18000_sat_6300_60000_all/tri4b_ali/../tri4b/graph_tgpr
    decoder_folder=exp_for_kaldi/dnn4_fmllr_tri4b_m_and_f_ocancer_0.008_correct_oov_v2_lda_3500_18000_sat_6300_60000 # hard-code to this dir because it achieved the best test WER
    nspk=$(wc -l <$data_path/spk2utt)
    [ "$nspk" -gt "$nj" ] && nspk=$nj
    #for acwt in 0.08 0.09 0.1;do 
    #for acwt in 0.092 0.102;do 
    for acwt in 0.09; do 
        steps/nnet/decode.sh --nj $nspk --use-gpu no --acwt $acwt --srcdir $decoder_folder --num-threads $num_threads_decode --skip-scoring false --stage $decode_stage $graphdir $data_path      $decoder_folder/decode_partition_train_dnn4_sbn_${acwt}_w_scoring || exit 1;         done
    
fi


echo "succeeded..."
