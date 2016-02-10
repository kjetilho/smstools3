#!/bin/bash
# ---------------------------------------------------------------------------------------
# This example is for three modems, named GSM1, GSM2 and GSM3 using queues Q1, Q2 and Q3.
# In the global part of smsd.conf, enable message counters:
# stats = /var/spool/sms/stats
# Use zero value for interval if statistics files are not used:
# stats_interval = 0
#
# Enable checkhandler (this script):
# checkhandler = /usr/local/bin/load_balancing.sh
#
# Define queues and providers:
# [queues]
# Q1 = /var/spool/sms/Q1
# Q2 = /var/spool/sms/Q2
# Q3 = /var/spool/sms/Q3
# 
# [providers]
# Q1 = 0,1,2,3,4,5,6,7,8,9,s
# Q2 = 0,1,2,3,4,5,6,7,8,9,s
# Q3 = 0,1,2,3,4,5,6,7,8,9,s
#
# Add queue definition for each modem:
# [GSM1]
# queues = Q1
# etc...
# ---------------------------------------------------------------------------------------

STATSDIR=/var/spool/sms/stats

read_counter()
{
  RESULT=0
  FILE=$STATSDIR/$1.counter

  if [[ -e $FILE ]]
  then
    COUNTER=`formail -zx $1: < $FILE`
    if [ "$COUNTER" != "" ]; then
      RESULT=$COUNTER
    fi
  fi
  return $RESULT
}

# If there is Queue (or Provider) defined, load balancing is ignored:
QUEUE=`formail -zx Queue: < $1`
if [ "$QUEUE" = "" ]; then
  QUEUE=`formail -zx Provider: < $1`
  if [ "$QUEUE" = "" ]; then
    # Read current counters:
    read_counter GSM1
    COUNTER1=$?
    read_counter GSM2
    COUNTER2=$?
    read_counter GSM3
    COUNTER3=$?

    QUEUE=Q1
    COUNTER=$COUNTER1
    if [ $COUNTER2 -lt $COUNTER ]; then
      QUEUE=Q2
      COUNTER=$COUNTER2
    fi
    if [ $COUNTER3 -lt $COUNTER ]; then
      QUEUE=Q3
      COUNTER=$COUNTER3
    fi

    TMPFILE=`mktemp /tmp/smsd_XXXXXX`
    cp $1 $TMPFILE
    formail -f -I "Queue: $QUEUE" < $TMPFILE > $1
    unlink $TMPFILE
  fi
fi
exit 0
