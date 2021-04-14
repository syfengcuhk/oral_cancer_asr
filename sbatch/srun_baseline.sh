#!/bin/sh
#you can control the resources and scheduling with '#SBATCH' settings
# (see 'man sbatch' for more information on setting these parameters)
# The default partition is the 'general' partition
#SBATCH --partition=general
# The default Quality of Service is the 'short' QoS (maximum run time: 4 hours)
#SBATCH --qos=short
# The default run (wall-clock) time is 1 minute
#SBATCH --time=01:00:00
# The default number of parallel tasks per job is 1
#SBATCH --ntasks=1
# Request 1 CPU per active thread of your program (assume 1 unless you specifically set this)
# The default number of CPUs per task is 1 (note: CPUs are always allocated per 2)
#SBATCH --cpus-per-task=18
# The default memory per node is 1024 megabytes (1GB) (for multiple tasks, specify --mem-per-cpu instead)
#SBATCH --mem=14G
##SBATCH --gres=gpu
# Set mail type to 'END' to receive a mail when the job finishes
# Do not enable mails when submitting large numbers (>20) of jobs at once
#SBATCH --mail-type=END

# 5-fold test set
#srun bash scripts_for_kaldi/run/run_decode_test_only_without_mark_spk_with_cmvn.sh --root-dir-affix _for_journal --stage 7 --stop-stage 8 --nj-decode 2 --num-threads-decode 10 --direct-decode-set test  --this-fold-id 5

# 5-fold train set
srun bash scripts_for_kaldi/run/run_decode_test_only_without_mark_spk_with_cmvn.sh --root-dir-affix _for_journal --stage 7 --stop-stage 8 --nj-decode 3 --num-threads-decode 10 --direct-decode-set train --this-fold-id 1
