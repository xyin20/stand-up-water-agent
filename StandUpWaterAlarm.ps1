param(
    [string]$Title = "Stand up and drink water",
    [string]$Message = "Time to stand up, stretch, and drink water.",
    [int]$AlarmSeconds = 25,
    [int]$BeepIntervalMs = 900,
    [int]$SkipIfIdleMinutes = 10
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$idleSource = @"
using System;
using System.Runtime.InteropServices;

public static class UserIdleTime
{
    [StructLayout(LayoutKind.Sequential)]
    private struct LASTINPUTINFO
    {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static TimeSpan GetIdleTime()
    {
        LASTINPUTINFO info = new LASTINPUTINFO();
        info.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));

        if (!GetLastInputInfo(ref info))
        {
            return TimeSpan.Zero;
        }

        uint elapsedMilliseconds = ((uint)Environment.TickCount) - info.dwTime;
        return TimeSpan.FromMilliseconds(elapsedMilliseconds);
    }
}
"@

Add-Type -TypeDefinition $idleSource

if ($SkipIfIdleMinutes -gt 0) {
    $idleTime = [UserIdleTime]::GetIdleTime()
    if ($idleTime -ge (New-TimeSpan -Minutes $SkipIfIdleMinutes)) {
        exit 0
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = $Title
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Width = 420
$form.Height = 210
$form.BackColor = [System.Drawing.Color]::FromArgb(250, 252, 248)

$heading = New-Object System.Windows.Forms.Label
$heading.Text = $Title
$heading.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$heading.AutoSize = $false
$heading.TextAlign = "MiddleCenter"
$heading.Left = 20
$heading.Top = 18
$heading.Width = 365
$heading.Height = 42
$form.Controls.Add($heading)

$body = New-Object System.Windows.Forms.Label
$body.Text = $Message
$body.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$body.AutoSize = $false
$body.TextAlign = "MiddleCenter"
$body.Left = 28
$body.Top = 68
$body.Width = 350
$body.Height = 46
$form.Controls.Add($body)

$button = New-Object System.Windows.Forms.Button
$button.Text = "Done"
$button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$button.Width = 120
$button.Height = 36
$button.Left = [int](($form.ClientSize.Width - $button.Width) / 2)
$button.Top = 126
$button.Anchor = "Bottom"
$button.Add_Click({ $form.Close() })
$form.Controls.Add($button)
$form.AcceptButton = $button

$deadline = (Get-Date).AddSeconds($AlarmSeconds)
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = [Math]::Max(250, $BeepIntervalMs)
$timer.Add_Tick({
    if ((Get-Date) -le $deadline) {
        [System.Media.SystemSounds]::Exclamation.Play()
    }
    else {
        $timer.Stop()
    }
})

$form.Add_Shown({
    $form.Activate()
    [System.Media.SystemSounds]::Exclamation.Play()
    $timer.Start()

    try {
        Add-Type -AssemblyName System.Speech
        $speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $speaker.Volume = 100
        $speaker.Rate = 0
        [void]$speaker.SpeakAsync("Stand up and drink water.")
    }
    catch {
        # Speech is optional; the popup and alarm sound still work without it.
    }
})

[void]$form.ShowDialog()
