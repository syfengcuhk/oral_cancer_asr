#!/bin/bash
#you can control the resources and scheduling with '#SBATCH' settings
# (see 'man sbatch' for more information on setting these parameters)
# The default partition is the 'general' partition
#SBATCH --partition=general
# The default Quality of Service is the 'short' QoS (maximum run time: 4 hours)
#SBATCH --qos=short
# The default run (wall-clock) time is 1 minute
#SBATCH --time=01:10:00
# The default number of parallel tasks per job is 1
#SBATCH --ntasks=1
# Request 1 CPU per active thread of your program (assume 1 unless you specifically set this)
# The default number of CPUs per task is 1 (note: CPUs are always allocated per 2)
#SBATCH --cpus-per-task=30
# The default memory per node is 1024 megabytes (1GB) (for multiple tasks, specify --mem-per-cpu instead)
#SBATCH --mem=24G
##SBATCH --gres=gpu
# Set mail type to 'END' to receive a mail when the job finishes
# Do not enable mails when submitting large numbers (>20) of jobs at once
#SBATCH --mail-type=END

srun bash scripts_for_kaldi/run/run_align_ocancer_data_correct_oov.sh --root-dir-affix _for_journal  --stage 10 --stop-stage 11 --lr-retrain 0.008 --nj 4 --num-threads-decode 10 --decode-stage 0 --flag-decode-train true --this-fold-id 1 --fold-affix _from_male_fem_transc_update  #1 # decode-stage = 1 if skip lattice generation
 
