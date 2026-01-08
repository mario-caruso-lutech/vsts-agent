#!/bin/bash
# Cleanup script for Azure DevOps self-hosted agent (_work directory)
# Works with systemd-managed agent service

# Adjust these values to your environment
AGENT_SERVICE="vsts-agent.service"              # systemd service name for your agent
AGENT_DIR="/home/azdevops-agent/myagent"        # agent installation directory
WORK_DIR="$AGENT_DIR/_work"
N=7   # number of recent build folders to keep

echo "=== Azure DevOps Agent Cleanup Started ==="

# 1. Stop the agent service
echo "Stopping agent service: $AGENT_SERVICE ..."
sudo /bin/systemctl stop "$AGENT_SERVICE"

# 2. Clean old build folders (numeric directories)
echo "Cleaning old build folders, keeping last $N..."
cd "$WORK_DIR" || exit 1
ls -dt [0-9]* 2>/dev/null | tail -n +$((N+1)) | xargs -r rm -rf

# 3. Clean temp directory
if [ -d "$WORK_DIR/_temp" ]; then
  echo "Cleaning temp directory..."
  rm -rf "$WORK_DIR/_temp"/*
fi

# 4. Clean logs older than 7 days
echo "Cleaning old logs..."
find "$WORK_DIR" -type f -name "*.log" -mtime +7 -delete

# 5. Optional: clean tool cache (commented out by default)
# echo "Cleaning tool cache..."
# rm -rf "$WORK_DIR/_tool"/*

echo "Cleanup complete."

# 6. Restart the agent service
echo "Restarting agent service: $AGENT_SERVICE ..."
sudo /bin/systemctl start "$AGENT_SERVICE"

echo "=== Azure DevOps Agent Cleanup Finished ==="