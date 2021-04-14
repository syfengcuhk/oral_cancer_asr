#!/bin/bash
#you can control the resources and scheduling with '#SBATCH' settings
# (see 'man sbatch' for more information on setting these parameters)
# The default partition is the 'general' partition
#SBATCH --partition=general
# The default Quality of Service is the 'short' QoS (maximum run time: 4 hours)
#SBATCH --qos=short
# The default run (wall-clock) time is 1 minute
#SBATCH --time=03:50:00
# The default number of parallel tasks per job is 1
#SBATCH --ntasks=1
# Request 1 CPU per active thread of your program (assume 1 unless you specifically set this)
# The default number of CPUs per task is 1 (note: CPUs are always allocated per 2)
#SBATCH --cpus-per-task=32
# The default memory per node is 1024 megabytes (1GB) (for multiple tasks, specify --mem-per-cpu instead)
#SBATCH --mem=18G
##SBATCH --gres=gpu
# Set mail type to 'END' to receive a mail when the job finishes
# Do not enable mails when submitting large numbers (>20) of jobs at once
#SBATCH --mail-type=END

#srun bash scripts_for_kaldi/run/fhvae_feature_input/run_align_ocancer_data_correct_oov.sh --root-dir-affix _for_journal  --stage 16 --stop-stage 17  --lr-retrain 0.008 --nj 4 --num-threads-decode 8 --decode-stage 0  --data-dir-intermed _2500_3500_6300 --gmm-suffix _deltas_2500_15000_lda_3500_18000_sat_6300_60000  --this-fold-id 1  --fold-affix _from_male_fem_transc_update # decode-stage = 1 if skip lattice generation, stage=11 means dnn training, stage=12 means decoding

srun bash scripts_for_kaldi/run/fhvae_feature_input/run_align_ocancer_data_correct_oov.sh --root-dir-affix _for_journal  --stage 15 --stop-stage 17  --lr-retrain 0.008 --nj 4 --num-threads-decode 8 --decode-stage 0  --data-dir-intermed _2500_3500_6300 --gmm-suffix _deltas_2500_15000_lda_3500_18000_sat_6300_60000  --this-fold-id 5  --fold-affix "" # decode-stage = 1 if skip lattice generation, stage=11 means dnn training, stage=12 means decoding

