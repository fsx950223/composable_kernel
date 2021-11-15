#!/bin/bash

## GPU visibility
 export HIP_VISIBLE_DEVICES=0

 make -j ckProfiler

 DRIVER="./profiler/ckProfiler"

OP=$1
DATATYPE=$2
LAYOUT=$3
VERIFY=$4
INIT=$5
LOG=$6
REPEAT=$7

########  op  datatype  layout  verify  init  log  repeat  M___ N___ K___  StrideA StrideB StrideC
#$DRIVER $OP $DATATYPE $LAYOUT $VERIFY $INIT $LOG $REPEAT   256  256  256      256     256     256
#$DRIVER $OP $DATATYPE $LAYOUT $VERIFY $INIT $LOG $REPEAT   960 1024 1024     1024    1024    1024
#$DRIVER $OP $DATATYPE $LAYOUT $VERIFY $INIT $LOG $REPEAT  1024 1024 1024     1024    1024    1024
#$DRIVER $OP $DATATYPE $LAYOUT $VERIFY $INIT $LOG $REPEAT  1920 2048 2048     2048    2048    2048
 $DRIVER $OP $DATATYPE $LAYOUT $VERIFY $INIT $LOG $REPEAT  3840 4096 4096     4096    4096    4096
#$DRIVER $OP $DATATYPE $LAYOUT $VERIFY $INIT $LOG $REPEAT  7680 8192 8192     8192    8192    8192
