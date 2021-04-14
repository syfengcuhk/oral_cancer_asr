#!/bin/sh
#you can control the resources and scheduling with '#SBATCH' settings
# (see 'man sbatch' for more information on setting these parameters)
# The default partition is the 'general' partition
#SBATCH --partition=general
# The default Quality of Service is the 'short' QoS (maximum run time: 4 hours)
#SBATCH --qos=short
# The default run (wall-clock) time is 1 minute
#SBATCH --time=02:00:00
# The default number of parallel tasks per job is 1
#SBATCH --ntasks=1
# Request 1 CPU per active thread of your program (assume 1 unless you specifically set this)
# The default number of CPUs per task is 1 (note: CPUs are always allocated per 2)
#SBATCH --cpus-per-task=18
# The default memory per node is 1024 megabytes (1GB) (for multiple tasks, specify --mem-per-cpu instead)
#SBATCH --mem=12G
##SBATCH --gres=gpu
# Set mail type to 'END' to receive a mail when the job finishes
# Do not enable mails when submitting large numbers (>20) of jobs at once
#SBATCH --mail-type=END
which_fmllr=tri4b
#srun bash  scripts_for_kaldi/run/run_train_gmm_hmm_ocancer_correct_oov.sh --deltas-leaves 2500 --deltas-gausses 15000 --lda-mllt-leaves 3500 --lda-mllt-gausses 18000 --sat-leaves 6300 --sat-gausses 60000   --stage 12  --stop-stage 13 --num-threads-decode 9  --do-decode true --nj 30 --decode-nj 3 --expdir-suffix _all --fold-affix _from_male_fem_transc_update --fold-id 1
#stage=5 starts from tri2b training, and tri2b and tri2b later will be influenced by #leaves and #gausses; stage=10 means extract fMLLR features; stage=11 means start from extract fmllr-tri4b
#srun bash  scripts_for_kaldi/run/run_train_gmm_hmm_ocancer_correct_oov.sh --deltas-leaves 3000 --deltas-gausses 17000 --lda-mllt-leaves 3500 --lda-mllt-gausses 18000 --sat-leaves 6300 --sat-gausses 60000  --train-data data_for_kaldi_partition/train_combi_wsj_si284 --train-fmllr-data  data_fmllr_${which_fmllr}_3000_3500_6300_for_kaldi_partition/train_combi_wsj_si284  --test-fmllr-data data_fmllr_${which_fmllr}_3000_3500_6300_for_kaldi_partition/test   --stage 9  --stop-stage 10 --num-threads-decode 9  --do-decode true --nj 30 --decode-nj 3 --expdir-suffix _all    #stage=5 starts from tri2b training, and tri2b and tri2b later will be influenced by #leaves and #gausses; stage=10 means extract fMLLR features; stage=11 means start from extract fmllr-tri4b
#srun bash  scripts_for_kaldi/run/run_train_gmm_hmm_ocancer_correct_oov.sh --lda-mllt-leaves 3500 --lda-mllt-gausses 18000 --sat-leaves 6300 --sat-gausses 60000  --train-data data_for_kaldi_partition/train_combi_wsj_si284 --train-fmllr-data  data_fmllr_${which_fmllr}_2000_3500_6300_for_kaldi_partition/train_combi_wsj_si284  --test-fmllr-data data_fmllr_${which_fmllr}_2000_3500_6300_for_kaldi_partition/test   --stage 9  --stop-stage 10 --num-threads-decode 9  --do-decode true --nj 30 --decode-nj 3 --expdir-suffix _all    #stage=5 starts from tri2b training, and tri2b and tri2b later will be influenced by #leaves and #gausses; stage=10 means extract fMLLR features; stage=11 means start from extract fmllr-tri4b
#srun bash  scripts_for_kaldi/run/run_train_gmm_hmm_ocancer_correct_oov.sh --deltas-leaves 3000 --deltas-gausses 17000 --lda-mllt-leaves 3500 --lda-mllt-gausses 18000 --sat-leaves 6300 --sat-gausses 60000  --train-data data_for_kaldi_partition/train_correct_oov_v2_combi_wsj_si284 --train-fmllr-data  data_fmllr_${which_fmllr}_for_kaldi_partition/train_correct_oov_v2_combi_wsj_si284  --test-fmllr-data data_fmllr_${which_fmllr}_for_kaldi_partition/test   --stage 12  --stop-stage 13 --num-threads-decode 9  --do-decode true --nj 30 --decode-nj 3 --expdir-suffix _all    #stage=5 starts from tri2b training, and tri2b and tri2b later will be influenced by #leaves and #gausses; stage=11 means extract fMLLR features; stage=12 means start from extract fmllr-tri4b


######### # come up with an idea when writing Oral cancer journal paper: what if we use only oral cancer training data to train a "baseline" system, rather than use WSJ training data to train the "baseline" reported in the paper?
srun bash scripts_for_kaldi/run/run_train_no_merge_wsj_gmm_hmm_ocancer_correct_oov.sh --deltas-leaves 2500 --deltas-gausses 15000 --lda-mllt-leaves 3500 --lda-mllt-gausses 18000 --sat-leaves 6300 --sat-gausses 60000 --stage 9  --stop-stage 10 --num-threads-decode 6  --do-decode true --nj 10 --decode-nj 3 --expdir-suffix "" --fold-affix "" --fold-id 5
