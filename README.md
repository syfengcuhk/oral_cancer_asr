
Oral Cancer Speech Recognition
Code to reproduce ASR experiments using baseline, DNN AM retraining, baseline+OC, fMLLR and FHVAE systems.

In scripts_for_kaldi/run/
Baseline:
  run_decode_test_only_without_mark_spk_with_cmvn.sh --stage 7 --stop-stage 8

DNN AM retraining: 
  run_align_ocancer_data_correct_oov.sh 
    Retraining: --stage 9 --stop-stage 10
    Decoding: --stage 10 --stop-stage 11

Baseline+OC:
 run_align_ocancer_data_correct_oov.sh 
    Training: --stage 17 --stop-stage 18
    Decoding: --stage 18 --stop-stage 20

FMLLR: 
  run_align_ocancer_data_correct_oov.sh 
    Training: --stage 11 --stop-stage 12
    Decoding: --stage 12 --stop-stage 14

FHVAE: 
  run_align_ocancer_data_correct_oov.sh
    Training: --stage 14 --stop-stage 15
    Decoding: --stage 15 --stop-stage 17
  
