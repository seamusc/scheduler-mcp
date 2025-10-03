# MCP Scheduler - Claude Integration Guide

This document provides guidance for Claude on how to interact with and use the MCP Scheduler.

## Overview

MCP Scheduler is a task automation server that schedules and executes various types of tasks. All times are in **UTC**.

## Available Task Types

### 1. Shell Command Tasks
Execute system commands on a schedule.

**Example:**
```
Add a shell command task named "Daily Backup" that runs at midnight UTC with the command "pg_dump mydb > backup.sql"
```

### 2. API Call Tasks
Make HTTP requests to external services on a schedule.

**Example:**
```
Add an API task to fetch weather data every 6 hours from https://api.weather.gov/stations/KJFK/observations/latest
```

### 3. AI Tasks
Execute prompts using Claude Code in headless mode. The AI response is stored in execution history.

**Requirements:**
- Claude Code CLI must be installed and accessible via the command line
- Default command: `claude` (configurable via `--claude-command` or `MCP_SCHEDULER_CLAUDE_COMMAND`)
- Claude Code must be properly authenticated
- Claude Code runs locally in headless mode with access to Read, Glob, Grep, Bash, Edit, and Write tools

**Example:**
```
Add an AI task to generate a daily summary every morning at 9am UTC with the prompt "Summarize today's tasks"
```

### 4. Reminder Tasks
Display desktop notifications with sound on a schedule.

**Platform Support:**
- Windows: Uses HTA (HTML Application) with MessageBeep
- macOS: Uses osascript with default system sound
- Linux: Uses notify-send/zenity with paplay

**Example:**
```
Add a reminder task for team meetings every Tuesday and Thursday at 9:30am UTC
```

## Cron Format Reference

All schedules use **cron format** with times in **UTC**.

Format: `minute hour day month day-of-week`

**Common Examples:**
- `0 0 * * *` - Daily at midnight UTC
- `0 9 * * *` - Daily at 9am UTC
- `0 */2 * * *` - Every 2 hours
- `30 14 * * 1-5` - 2:30pm UTC, Monday-Friday
- `0 9 * * 1` - Every Monday at 9am UTC
- `0 0 1 * *` - First day of each month at midnight UTC

## Available Tools

### Task Creation
- `add_command_task(name, schedule, command, description?, enabled?, do_only_once?)`
- `add_api_task(name, schedule, api_url, api_method?, api_headers?, api_body?, description?, enabled?, do_only_once?)`
- `add_ai_task(name, schedule, prompt, description?, enabled?, do_only_once?)`
- `add_reminder_task(name, schedule, message, title?, description?, enabled?, do_only_once?)`

### Task Management
- `list_tasks()` - Get all scheduled tasks
- `get_task(task_id)` - Get details and execution history
- `update_task(task_id, ...)` - Update task parameters
- `remove_task(task_id)` - Delete a task
- `enable_task(task_id)` - Enable a disabled task
- `disable_task(task_id)` - Disable a task without deleting it
- `run_task_now(task_id)` - Execute immediately (ignores schedule)

### Monitoring
- `get_task_executions(task_id, limit?)` - Get execution history
- `get_server_info()` - Get server status and configuration

## Important Parameters

### `do_only_once` (default: `true`)
- `true`: Task runs once at the scheduled time, then automatically disables
- `false`: Task runs repeatedly on schedule

### `enabled` (default: `true`)
- `true`: Task is active and will run on schedule
- `false`: Task is disabled and won't run

## Best Practices for Claude

1. **Always clarify timezone**: Remind users that all times are in UTC. If they specify local time, convert it to UTC.

2. **Default to one-time tasks**: Use `do_only_once=true` unless the user explicitly wants recurring tasks.

3. **Validate cron expressions**: Ensure the schedule format is valid before creating tasks.

4. **Check AI task requirements**: Before adding AI tasks, verify the user has Claude Code CLI installed and accessible.

5. **Platform-specific reminders**: Warn users that reminder tasks may have limited functionality on headless servers or systems without notification support.

6. **Execution history**: Use `get_task_executions()` to check if tasks ran successfully and view their output.

## Example Interactions

### User: "Remind me to check emails every morning at 9am"
**Claude should:**
1. Clarify timezone: "Just to confirm, you want this at 9am in your local time zone (e.g., EST), correct? The scheduler uses UTC, so I'll convert that to [time] UTC."
2. Create the task: `add_reminder_task(name="Check Emails", schedule="0 14 * * *", message="Time to check your emails!", do_only_once=false)`

### User: "Run a backup script tonight at midnight"
**Claude should:**
1. Clarify: "Which midnight - tonight in your local timezone? I'll schedule it for [time] UTC."
2. Ask for the script path/command
3. Create: `add_command_task(name="Backup Script", schedule="0 5 * * *", command="/path/to/backup.sh", do_only_once=true)`

### User: "Generate a weekly report with AI every Monday"
**Claude should:**
1. Check if Claude Code CLI is configured (via `get_server_info()`)
2. Ask what time on Monday and what the report should contain
3. Create: `add_ai_task(name="Weekly Report", schedule="0 9 * * 1", prompt="Generate a weekly report summarizing...", do_only_once=false)`

## Troubleshooting

### Task not running
- Check if task is enabled: `get_task(task_id)`
- Verify cron schedule is correct
- Check execution history for errors: `get_task_executions(task_id)`

### AI task failing
- Verify Claude Code CLI is installed and accessible (check `which claude` or `where claude`)
- Ensure Claude Code is properly authenticated
- Check execution history for error messages
- Verify the claude command path is correct (default: claude)

### Reminder not showing
- Platform may not support desktop notifications
- Check execution history for error messages
- On Linux, ensure notify-send or zenity is installed

## Server Configuration

Users can configure the scheduler via:
- Command line: `python main.py --port 8080 --transport sse --claude-command claude`
- Environment variables: `MCP_SCHEDULER_PORT=8080`
- Config file: `--config config.json`

Key configuration options:
- `--port`: Server port (default: 8080)
- `--transport`: `stdio` or `sse` (default: stdio)
- `--claude-command`: Command to invoke Claude Code CLI (default: claude)
- `--execution-timeout`: Task timeout in seconds (default: 300)
- `--db-path`: SQLite database location (default: scheduler.db)
