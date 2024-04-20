#!/usr/bin/bash
#
# Some basic monitoring functionality; Tested on Amazon Linux 2023.
#

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the current date and time
CURRENT_DATETIME=$(date +"%Y-%m-%d %H:%M:%S")

# Append the contents of log.log to archive_log.log
cat "$DIR/log.log" >> "$DIR/archive_log.log"

# Clear the contents of log.log
> "$DIR/log.log"

TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AWS_REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')

# Collect metrics
CPU_UTILIZATION=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')
IO_WAIT=$(iostat | awk 'NR==4 {print $4}')
TCP_CONNECTIONS=$(netstat -an | wc -l)
HTTP_CONNECTIONS=$(netstat -an | grep 80 | wc -l)
SSH_CONNECTIONS=$(netstat -an | grep 22 | wc -l)
VIRTUAL_STORAGE=$(df / | tail -1 | awk '{print $5}')
DISK_USAGE=$(df / | tail -1 | awk '{print $3}')
RUNNING_PROCESSES=$(ps aux | wc -l)

# Calculated metrics
# Check if the instance is overloaded based on the IO wait and memory usage
if (( $(echo "$IO_WAIT > 70" | bc -l) )) && (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
  INSTANCE_OVERLOADED=1
else
  INSTANCE_OVERLOADED=0
fi

# Check if the instance is overloaded based on CPU utilization and HTTP connections
if (( $(echo "$CPU_UTILIZATION > 50" | bc -l) )) && (( $HTTP_CONN > 100 )); then
  SCALE_INSTANCE=1
else
  SCALE_INSTANCE=0
fi

# Check the number of HTTP connections is high
if (( $(echo "$HTTP_CONNECTIONS > 100" | bc -l) )); then
  HIGH_HTTP_CONNECTIONS=1
else
  HIGH_HTTP_CONNECTIONS=0
fi

# Check Check the nuymber of SSH connections
if (( $(echo "$SSH_CONNECTIONS >= 2" | bc -l) )); then
  HIGH_SSH_CONNECTIONS=1
else
  HIGH_SSH_CONNECTIONS=0
fi

# Append the date, time, and instance ID to the log file
echo "########################START########################" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: Instance_ID           : $INSTANCE_ID" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: AWS_REGION            : $AWS_REGION" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: MEMORY_USAGE          : $MEMORY_USAGE" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: TCP_CONNECTIONS       : $TCP_CONNECTIONS" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: HTTP_CONNECTIONS      : $HTTP_CONNECTIONS" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: SSH_CONNECTIONS       : $SSH_CONNECTIONS" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: IO_WAIT               : $IO_WAIT" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: VIRTUAL_STORAGE       : $VIRTUAL_STORAGE" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: DISK_USAGE            : $DISK_USAGE" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: RUNNING_PROCESSES     : $RUNNING_PROCESSES" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: INSTANCE_OVERLOADED   : $INSTANCE_OVERLOADED" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: HIGH_HTTP_CONNECTIONS : $HIGH_HTTP_CONNECTIONS" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: HIGH_SSH_CONNECTIONS  : $HIGH_SSH_CONNECTIONS" >> "$DIR/log.log"
echo "$CURRENT_DATETIME :: SCALE_INSTANCE       : $SCALE_INSTANCE" >> "$DIR/log.log"
echo "########################END#########################" >> "$DIR/log.log"

# Send metrics to CloudWatch
aws cloudwatch put-metric-data --metric-name MemoryUsage --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $MEMORY_USAGE
aws cloudwatch put-metric-data --metric-name TCPConnections --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $TCP_CONNECTIONS
aws cloudwatch put-metric-data --metric-name HTTPConnections --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $HTTP_CONNECTIONS
aws cloudwatch put-metric-data --metric-name SSHConnections --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $SSH_CONNECTIONS
aws cloudwatch put-metric-data --metric-name IOWait --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $IO_WAIT
aws cloudwatch put-metric-data --metric-name VirtualStorage --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $VIRTUAL_STORAGE
aws cloudwatch put-metric-data --metric-name DiskUsage --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $DISK_USAGE
aws cloudwatch put-metric-data --metric-name RunningProcesses --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $RUNNING_PROCESSES
aws cloudwatch put-metric-data --metric-name InstanceOverloaded --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $INSTANCE_OVERLOADED
aws cloudwatch put-metric-data --metric-name HighHTTPConnections --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $HIGH_HTTP_CONNECTIONS
aws cloudwatch put-metric-data --metric-name HighSSHConnections --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $HIGH_SSH_CONNECTIONS
aws cloudwatch put-metric-data --metric-name ScaleInstance --dimensions Instance=$INSTANCE_ID --namespace "Custom" --value $SCALE_INSTANCE
