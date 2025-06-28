MODPATH=${0%/*}

# log
LOGFILE=$MODPATH/debug.log
exec 2>$LOGFILE
set -x

# wait
until [ "`getprop sys.boot_completed`" == 1 ]; do
  sleep 10
done

# function
stop_log() {
SIZE=`du $LOGFILE | sed "s|$LOGFILE||g"`
if [ "$LOG" != stopped ] && [ "$SIZE" -gt 100 ]; then
  exec 2>/dev/null
  set +x
  LOG=stopped
fi
}
keep_memory() {
stop_log
for PKG in $PKGS; do
  PIDS=`/system/bin/ps -A | awk -v pkg="$PKG" '$0 ~ pkg {print $2}'`
  for PID in $PIDS; do
    if [ "`cat /proc/$PID/oom_adj`" -gt -17 ]; then
      echo -17 > /proc/$PID/oom_adj
    fi
    if [ "`cat /proc/$PID/oom_score_adj`" -gt -1000 ]; then
      echo -1000 > /proc/$PID/oom_score_adj
    fi
  done
done
sleep 5
keep_memory
}

PKGS="com.android.chrome"
keep_memory




