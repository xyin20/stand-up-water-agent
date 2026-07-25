# Stand Up Water Agent

This folder contains a small Windows reminder agent. It uses Task Scheduler to run a PowerShell alarm every 50 minutes while you are logged in.

If you are away from the computer, the reminder stays quiet. By default, the alarm skips itself when there has been no keyboard or mouse activity for 10 minutes.

## Install

From this folder, run:

```powershell
.\Install-StandUpWaterAgent.ps1
```

Or double-click:

```text
Install-StandUpWaterAgent.cmd
```

To install and trigger the first reminder immediately:

```powershell
.\Install-StandUpWaterAgent.ps1 -StartNow
```

## Test the alarm manually

```powershell
.\StandUpWaterAlarm.ps1
```

To test the popup even after being idle, disable idle skipping for that one run:

```powershell
.\StandUpWaterAlarm.ps1 -SkipIfIdleMinutes 0
```

## Change the interval

For example, to remind every 20 minutes:

```powershell
.\Install-StandUpWaterAgent.ps1 -IntervalMinutes 20
```

## Uninstall

```powershell
.\Uninstall-StandUpWaterAgent.ps1
```

Or double-click:

```text
Uninstall-StandUpWaterAgent.cmd
```
