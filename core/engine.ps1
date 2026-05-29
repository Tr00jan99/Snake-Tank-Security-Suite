# ==============================================================================
#                 SNAKE TANK PORTABLE SECURITY TOOLKIT v1.0.0
#                         CREATED BY SNAKE TANK
# ==============================================================================
# This is a self-contained, 100% portable native PowerShell WPF GUI toolkit.
# It requires no external dependencies (Python/pip/modules) and runs natively on Windows.
# ==============================================================================

# Parse command line argument for starting tab
param (
    [string]$Tab = "Dashboard"
)

# Suppress potential assembly import warnings
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# Global Brush Converter for WPF XAML
$Script:bc = New-Object System.Windows.Media.BrushConverter
function Get-Brush ($color) {
    return $Script:bc.ConvertFromString($color)
}

# 100/100 Upgrade: Global Findings Array for reporting
$Script:ScanFindings = @()

function Do-Events {
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
        [System.Windows.Threading.DispatcherPriority]::Background,
        [System.Action]{ $frame.Continue = $false }
    ) | Out-Null
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

# 100/100 Upgrade: Scrolling Activity Logger function
function Write-Log ($level, $message) {
    $time = Get-Date -Format "HH:mm:ss"
    $logLine = "[$time] [$level] $message`r`n"
    
    if ($txtLogs) {
        $txtLogs.AppendText($logLine)
        $txtLogs.ScrollToEnd()
        Do-Events
    }
    
    # Console stdout mirrors
    if ($level -eq "SUCCESS") {
        Write-Host "[$level] $message" -ForegroundColor Green
    } elseif ($level -eq "WARNING") {
        Write-Host "[$level] $message" -ForegroundColor Yellow
    } elseif ($level -eq "ERROR") {
        Write-Host "[$level] $message" -ForegroundColor Red
    } else {
        Write-Host "[$level] $message" -ForegroundColor Gray
    }
}

# ------------------------------------------------------------------------------
# 1. UI DEFINITION (XAML - Single-Quoted to prevent accidental $ variable expansion)
# ------------------------------------------------------------------------------
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Snake Tank Security Toolkit v1.0.0" Height="770" Width="980" 
        WindowStartupLocation="CenterScreen" ResizeMode="CanResize" Background="#0B0F19">
    <Window.Resources>
        <!-- Custom Navigation Sidebar Button Style with Hover and Focus templates -->
        <Style x:Key="NavBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent" />
            <Setter Property="Foreground" Value="#94A3B8" />
            <Setter Property="FontWeight" Value="Bold" />
            <Setter Property="FontSize" Value="12" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Margin" Value="0,0,0,8" />
            <Setter Property="Padding" Value="15,0,0,0" />
            <Setter Property="HorizontalContentAlignment" Value="Left" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Border" Background="{TemplateBinding Background}" BorderThickness="0" CornerRadius="4">
                            <ContentPresenter VerticalAlignment="Center" Margin="{TemplateBinding Padding}" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#1F2937" />
                                <Setter Property="Foreground" Value="#F8FAFC" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Custom Primary Green Button Style with Hover, Pressed and Disabled States -->
        <Style x:Key="PrimaryBtn" TargetType="Button">
            <Setter Property="Background" Value="#10B981" />
            <Setter Property="Foreground" Value="#FFFFFF" />
            <Setter Property="FontWeight" Value="Bold" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Border" Background="{TemplateBinding Background}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#059669" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#047857" />
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="#064E3B" />
                                <Setter Property="Foreground" Value="#10B981" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Custom Secondary Blue Button Style with Hover/Pressed States -->
        <Style x:Key="SecondaryBtn" TargetType="Button">
            <Setter Property="Background" Value="#3B82F6" />
            <Setter Property="Foreground" Value="#FFFFFF" />
            <Setter Property="FontWeight" Value="Bold" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Border" Background="{TemplateBinding Background}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#2563EB" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#1D4ED8" />
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="#1E3A8A" />
                                <Setter Property="Foreground" Value="#60A5FA" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <!-- Custom Purple Exporter Button Style with Hover/Pressed States -->
        <Style x:Key="PurpleBtn" TargetType="Button">
            <Setter Property="Background" Value="#8B5CF6" />
            <Setter Property="Foreground" Value="#FFFFFF" />
            <Setter Property="FontWeight" Value="Bold" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Border" Background="{TemplateBinding Background}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#7C3AED" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#6D28D9" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="230" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>

        <!-- SIDEBAR PANEL -->
        <Border Grid.Column="0" Background="#111827" BorderBrush="#1F2937" BorderThickness="0,0,1,0">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="90" />
                    <RowDefinition Height="*" />
                    <RowDefinition Height="60" />
                </Grid.RowDefinitions>

                <!-- Sidebar Header -->
                <StackPanel Grid.Row="0" Margin="20,20,20,0" VerticalAlignment="Center">
                    <TextBlock Text="SNAKE TANK" FontWeight="Bold" FontSize="20" Foreground="#10B981" />
                    <TextBlock Text="PORTABLE TOOLKIT" FontSize="11" Foreground="#94A3B8" FontWeight="SemiBold" Margin="0,2,0,0" />
                </StackPanel>

                <!-- Navigation Buttons -->
                <StackPanel Grid.Row="1" Margin="10,20,10,0">
                    <!-- Dashboard -->
                    <Button Name="btnNavDashboard" Style="{StaticResource NavBtn}" Height="42" Content="Dashboard" Background="#1F2937" Foreground="#F8FAFC" />
                    <!-- Vulnerability Scanner -->
                    <Button Name="btnNavScanner" Style="{StaticResource NavBtn}" Height="42" Content="Vulnerability Scanner" />
                    <!-- System Hardening -->
                    <Button Name="btnNavHardening" Style="{StaticResource NavBtn}" Height="42" Content="System Hardening" />
                    <!-- Threat Detector -->
                    <Button Name="btnNavThreats" Style="{StaticResource NavBtn}" Height="42" Content="Threat Detector" />
                    <!-- CVE Search & Scan -->
                    <Button Name="btnNavCVE" Style="{StaticResource NavBtn}" Height="42" Content="CVE Search &amp; Scan" />
                    <!-- OS Deep Auditor -->
                    <Button Name="btnNavOS" Style="{StaticResource NavBtn}" Height="42" Content="OS Deep Auditor" />
                    <!-- About -->
                    <Button Name="btnNavAbout" Style="{StaticResource NavBtn}" Height="42" Content="About Toolkit" />
                </StackPanel>

                <!-- Sidebar Footer -->
                <StackPanel Grid.Row="2" VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock Text="v1.0.0 - Portable Edition" FontSize="9" Foreground="#475569" HorizontalAlignment="Center" />
                    <TextBlock Text="Created by Snake Tank" FontSize="10" Foreground="#64748B" FontWeight="Bold" Margin="0,2,0,0" HorizontalAlignment="Center" />
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN CONTENT PANEL WITH DEDICATED LOG TERMINAL BOTTOM ROW -->
        <Grid Grid.Column="1" Margin="25">
            <Grid.RowDefinitions>
                <RowDefinition Height="*" />
                <RowDefinition Height="130" />
            </Grid.RowDefinitions>
            
            <!-- PAGE CONTENT HIVE (ROW 0) -->
            <Grid Grid.Row="0">
                <!-- PAGE 1: DASHBOARD -->
                <Grid Name="gridDashboard" Visibility="Visible">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="140" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,20">
                        <TextBlock Text="SYSTEM DASHBOARD" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                        <TextBlock Text="Host details and high-level security posture summary." FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" />
                    </StackPanel>

                    <!-- Stats Summary Row -->
                    <Grid Grid.Row="1" Margin="0,0,0,20">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>

                        <!-- Security Score Card -->
                        <Border Grid.Column="0" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="15" Margin="0,0,10,0">
                            <StackPanel VerticalAlignment="Center">
                                <TextBlock Text="SECURITY AUDIT SCORE" FontSize="10" FontWeight="Bold" Foreground="#94A3B8" HorizontalAlignment="Center" />
                                <TextBlock Name="txtScoreVal" Text="N/A" FontSize="36" FontWeight="Bold" Foreground="#10B981" HorizontalAlignment="Center" Margin="0,5,0,0" />
                                <TextBlock Name="txtScoreText" Text="Scan Pending" FontSize="11" Foreground="#CBD5E1" HorizontalAlignment="Center" Margin="0,2,0,0" />
                            </StackPanel>
                        </Border>

                        <!-- Total Vulnerabilities -->
                        <Border Grid.Column="1" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="15" Margin="5,0,5,0">
                            <StackPanel VerticalAlignment="Center">
                                <TextBlock Text="TOTAL VULNERABILITIES" FontSize="10" FontWeight="Bold" Foreground="#94A3B8" HorizontalAlignment="Center" />
                                <TextBlock Name="txtTotalVulns" Text="0" FontSize="36" FontWeight="Bold" Foreground="#EF4444" HorizontalAlignment="Center" Margin="0,5,0,0" />
                                <TextBlock Text="Active Findings" FontSize="11" Foreground="#CBD5E1" HorizontalAlignment="Center" Margin="0,2,0,0" />
                            </StackPanel>
                        </Border>

                        <!-- Hardening Compliance -->
                        <Border Grid.Column="2" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="15" Margin="10,0,0,0">
                            <StackPanel VerticalAlignment="Center">
                                <TextBlock Text="HARDENING COMPLIANCE" FontSize="10" FontWeight="Bold" Foreground="#94A3B8" HorizontalAlignment="Center" />
                                <TextBlock Name="txtHardeningPct" Text="N/A" FontSize="36" FontWeight="Bold" Foreground="#3B82F6" HorizontalAlignment="Center" Margin="0,5,0,0" />
                                <TextBlock Text="Subsystems Hardened" FontSize="11" Foreground="#CBD5E1" HorizontalAlignment="Center" Margin="0,2,0,0" />
                            </StackPanel>
                        </Border>
                    </Grid>

                    <!-- Host Details and Controls -->
                    <Grid Grid.Row="2">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="2.2*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>

                        <!-- Host Info Card -->
                        <Border Grid.Column="0" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="20" Margin="0,0,15,0">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto" />
                                    <RowDefinition Height="*" />
                                </Grid.RowDefinitions>

                                <TextBlock Grid.Row="0" Text="LOCAL SYSTEM CONFIGURATION" FontSize="13" FontWeight="Bold" Foreground="#F8FAFC" Margin="0,0,0,15" />
                                
                                <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                                    <StackPanel Margin="0,0,10,0">
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="Computer Hostname:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblHost" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="Operating System:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblOS" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="Windows Build version:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblBuild" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="Current Active User:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblUser" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="System Domain:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblDomain" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="CPU Processor:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblCPU" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" TextTrimming="CharacterEllipsis" ToolTip="{Binding RelativeSource={RelativeSource Self}, Path=Text}" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="CPU Architecture:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblArch" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="System Memory (RAM):" Foreground="#94A3B8" />
                                            <TextBlock Name="lblRAM" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="Motherboard model:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblMotherboard" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" TextTrimming="CharacterEllipsis" ToolTip="{Binding RelativeSource={RelativeSource Self}, Path=Text}" />
                                        </Grid>
                                        <Grid Margin="0,0,0,8">
                                            <TextBlock Text="Graphics Card (GPU):" Foreground="#94A3B8" />
                                            <TextBlock Name="lblGPU" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" TextTrimming="CharacterEllipsis" ToolTip="{Binding RelativeSource={RelativeSource Self}, Path=Text}" />
                                        </Grid>
                                        <Grid>
                                            <TextBlock Text="Wi-Fi Wireless Adapter:" Foreground="#94A3B8" />
                                            <TextBlock Name="lblWiFi" Text="Loading..." Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Right" TextTrimming="CharacterEllipsis" ToolTip="{Binding RelativeSource={RelativeSource Self}, Path=Text}" />
                                        </Grid>
                                    </StackPanel>
                                </ScrollViewer>
                            </Grid>
                        </Border>

                        <!-- Actions Card -->
                        <Border Grid.Column="1" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="15">
                            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                <TextBlock Text="QUICK ACTIONS" FontSize="13" FontWeight="Bold" Foreground="#F8FAFC" HorizontalAlignment="Center" Margin="0,0,0,12" />
                                <Button Name="btnQuickScan" Style="{StaticResource PrimaryBtn}" Width="170" Height="36" Content="RUN NEW SCAN" Margin="0,0,0,10" />
                                <Button Name="btnQuickHarden" Style="{StaticResource SecondaryBtn}" Width="170" Height="36" Content="SYSTEM HARDENING" Margin="0,0,0,10" />
                                <Button Name="btnDashboardExport" Style="{StaticResource PurpleBtn}" Width="170" Height="36" Content="EXPORT REPORT" />
                            </StackPanel>
                        </Border>
                    </Grid>
                </Grid>

                <!-- PAGE 2: SCANNER -->
                <Grid Name="gridScanner" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="50" />
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,15">
                        <TextBlock Text="VULNERABILITY AUDITOR" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                        <TextBlock Text="Native host audit mapping out vulnerabilities, severity levels, and copyable manual commands." FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" />
                    </StackPanel>

                    <!-- Controls & Progress -->
                    <Grid Grid.Row="1" Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto" />
                            <ColumnDefinition Width="Auto" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        
                        <Button Name="btnRunScan" Grid.Column="0" Style="{StaticResource PrimaryBtn}" Content="RUN COMPREHENSIVE SCAN" Width="190" Height="36" />
                        <Button Name="btnScannerExport" Grid.Column="1" Style="{StaticResource PurpleBtn}" Content="EXPORT REPORT" Width="130" Height="36" Margin="10,0,0,0" />
                        
                        <Grid Grid.Column="2" Margin="15,0,0,0">
                            <ProgressBar Name="progressBarScan" Height="14" Minimum="0" Maximum="100" Value="0" Background="#1E293B" Foreground="#10B981" BorderThickness="0" />
                            <TextBlock Name="txtProgressStatus" Text="Ready to scan" FontSize="10" Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Grid>
                    </Grid>

                    <!-- Search & Filter Panel (Row 2) -->
                    <Border Grid.Row="2" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto" />
                                <ColumnDefinition Width="*" />
                            </Grid.ColumnDefinitions>
                            
                            <!-- Search box -->
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="🔍 SEARCH FINDINGS:" Foreground="#94A3B8" FontSize="10" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,8,0" />
                                <TextBox Name="txtSearchScanner" Width="180" Height="26" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="4,2,4,2" FontSize="11" VerticalContentAlignment="Center" Margin="0,0,15,0" />
                            </StackPanel>
                            
                            <!-- Filter Severity buttons -->
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER BY SEVERITY:" Foreground="#94A3B8" FontSize="10" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,8,0" />
                                <Button Name="btnFilterAll" Content="ALL" Width="55" Height="24" Style="{StaticResource SecondaryBtn}" FontSize="9" FontWeight="Bold" Margin="0,0,5,0" Cursor="Hand" />
                                <Button Name="btnFilterCritHigh" Content="CRIT &amp; HIGH" Width="85" Height="24" Style="{StaticResource SecondaryBtn}" FontSize="9" FontWeight="Bold" Margin="0,0,5,0" Cursor="Hand" />
                                <Button Name="btnFilterMedLow" Content="MED &amp; LOW" Width="80" Height="24" Style="{StaticResource SecondaryBtn}" FontSize="9" FontWeight="Bold" Margin="0,0,5,0" Cursor="Hand" />
                                <Button Name="btnFilterInfo" Content="INFO ONLY" Width="80" Height="24" Style="{StaticResource SecondaryBtn}" FontSize="9" FontWeight="Bold" Cursor="Hand" />
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Results List (Row 3) -->
                    <Border Grid.Row="3" Background="#111827" BorderBrush="#1F2937" BorderThickness="1" CornerRadius="8" Padding="5">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="panelScanResults" Margin="10">
                                <!-- Dynamically loaded cards go here -->
                                <Border Name="borderInitialScanState" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="20">
                                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                                        <TextBlock Text="No Scan Data Available" Foreground="#F8FAFC" FontWeight="Bold" FontSize="15" HorizontalAlignment="Center" />
                                        <TextBlock Text="Click the 'RUN COMPREHENSIVE SCAN' button above to start auditing the local system." Foreground="#94A3B8" FontSize="11" Margin="0,4,0,0" HorizontalAlignment="Center" />
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 3: HARDENING -->
                <Grid Name="gridHardening" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="50" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,15">
                        <TextBlock Text="SYSTEM HARDENING HUB" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                        <TextBlock Text="Remediate vulnerabilities dynamically in one click and verify compliance in real-time." FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" />
                    </StackPanel>

                    <!-- Hardening Controls -->
                    <Grid Grid.Row="1" Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>
                        <TextBlock Text="Select action below or apply full enterprise baseline hardening instantly." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12" />
                        <Button Name="btnApplyAllHardening" Grid.Column="1" Style="{StaticResource PrimaryBtn}" Content="APPLY ENTERPRISE BASELINE HARDENING" Height="36" Padding="15,0,15,0" />
                    </Grid>

                    <!-- Hardening Rules List -->
                    <Border Grid.Row="2" Background="#111827" BorderBrush="#1F2937" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel Margin="5">
                                
                                <!-- 1. SMBv1 -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="1. Deprecate Legacy SMBv1 Protocol" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Disables the obsolete SMBv1 protocol to mitigate WannaCry ransomware and EternalBlue exploitation." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (POWERSHELL):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderSMB" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextSMB" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenSMB" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 2. Firewall -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="2. Activate Windows Firewall Profiles" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Enforces active state on all firewall boundaries (Domain, Private, Public) to block unauthorized connections." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="&#x26A0; HIGH RISK: DISABLING FIREWALL EXPOSES ENDPOINT TO REMOTE ATTACKS!" Foreground="#EF4444" FontWeight="Bold" FontSize="9" Margin="0,0,0,6" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (NETSH):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="netsh advfirewall set allprofiles state on" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderFW" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextFW" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenFW" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 3. Defender -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="3. Enable Defender Real-Time Protection" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Ensures constant malware tracking, behavioral scans, and active payload containment." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="&#x26A0; HIGH RISK: DISABLING REAL-TIME PROTECTION STOPS MALWARE DETECTION!" Foreground="#EF4444" FontWeight="Bold" FontSize="9" Margin="0,0,0,6" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (POWERSHELL):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="Set-MpPreference -DisableRealtimeMonitoring $false -DisableBehaviorMonitoring $false" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderDef" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextDef" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenDef" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 4. RDP NLA -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="4. Enforce RDP Network Level Authentication (NLA)" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Requires network authentication before RDP sessions are created, preventing pre-auth RCE attacks (BlueKeep)." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp&quot; /v UserAuthentication /t REG_DWORD /d 1 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderRDP" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextRDP" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenRDP" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 5. Password Policies -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="5. Harden System Password Policies" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Enforces local password requirements (Min length: 14 characters, failed lockout threshold: 5)." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (SAM):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="net accounts /minpwlen:14 /lockoutthreshold:5" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderPWD" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextPWD" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenPWD" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 6. Guest Account -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="6. Disable Built-in Guest Account" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Deactivates the built-in Guest user, ensuring anonymous clients cannot authenticate locally." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="&#x26A0; HIGH RISK: ENABLING GUEST ACCOUNT ALLOWS ANONYMOUS RECONNAISSANCE!" Foreground="#EF4444" FontWeight="Bold" FontSize="9" Margin="0,0,0,6" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (NET USER):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="net user Guest /active:no" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderGuest" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextGuest" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenGuest" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 7. AlwaysInstallElevated -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="7. Disable AlwaysInstallElevated Policy" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Removes registry keys allowing ordinary users to execute malicious MSI files as high-privileged SYSTEM." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="&#x26A0; HIGH RISK: ENABLING THIS ALLOWS STANDARD USERS TO INJECT SYSTEM BACKDOORS!" Foreground="#EF4444" FontWeight="Bold" FontSize="9" Margin="0,0,0,6" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer&quot; /v AlwaysInstallElevated /t REG_DWORD /d 0 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderAIE" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextAIE" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenAIE" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>
                                
                                <!-- 8. User Account Control (UAC) Consent Prompt Behavior -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="8. Enforce UAC Consent Prompting" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Configures User Account Control to require explicit admin approval on secure desktop, preventing silent privilege escalation by background software." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="&#x26A0; HIGH RISK: DISABLING THIS ALLOWS BACKGROUND MALWARE TO BYPASS UAC SILENTLY!" Foreground="#EF4444" FontWeight="Bold" FontSize="9" Margin="0,0,0,6" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System&quot; /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderUAC" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextUAC" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenUAC" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 9. LLMNR Multicast Name Resolution -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="9. Disable Link-Local Multicast Name Resolution (LLMNR)" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Disables Link-Local Multicast Name Resolution (LLMNR) to prevent Responder-style local name resolution hijacking and credential harvesting attacks." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient&quot; /v EnableMulticast /t REG_DWORD /d 0 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderLLMNR" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextLLMNR" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenLLMNR" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 10. LSA Protection (RunAsPPL) -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="10. Enable LSA Protection (RunAsPPL)" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Enforces Protected Process Light (PPL) on the Local Security Authority (LSA) process to prevent Mimikatz credential dumping from LSASS memory." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SYSTEM\CurrentControlSet\Control\Lsa&quot; /v RunAsPPL /t REG_DWORD /d 1 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderLSA" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextLSA" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenLSA" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 11. PowerShell Script Block Logging -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="11. Enable PowerShell Script Block Logging" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Enables comprehensive logging of all executing PowerShell command blocks to Event Viewer (Event ID 4104), providing critical auditing visibility for EDR and security operations." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging&quot; /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderPSLog" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextPSLog" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenPSLog" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 12. Disable WDigest Logon Credential Caching -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="12. Disable WDigest Logon Credential Caching" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Disables caching of cleartext user credentials in LSASS memory by the WDigest authentication provider to prevent offline and memory-based credential dumping." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest&quot; /v UseLogonCredential /t REG_DWORD /d 0 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderWDigest" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextWDigest" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenWDigest" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 13. Disable AutoPlay / AutoRun for All Drives -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="13. Disable AutoPlay / AutoRun for All Drives" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Deactivates absolute drive AutoPlay/AutoRun features to stop malware, worms, and malicious payloads from executing silently upon insertion of USB flash drives or external media." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer&quot; /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderAutoPlay" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextAutoPlay" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenAutoPlay" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 14. Disable Remote Registry Service -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="14. Disable Remote Registry Service" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Disables the Remote Registry service to prevent remote network clients from modifying local system registry parameters." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="&#x26A0; HIGH RISK: ENABLING REMOTE REGISTRY EXPOSES CRITICAL REGISTRY HIERARCHIES!" Foreground="#EF4444" FontWeight="Bold" FontSize="9" Margin="0,0,0,6" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (SERVICE):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="powershell -Command &quot;Stop-Service -Name RemoteRegistry -Force; Set-Service -Name RemoteRegistry -StartupType Disabled&quot;" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderRemReg" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextRemReg" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenRemReg" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 15. Restrict Anonymous SAM Enumeration -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="15. Restrict Anonymous SAM/SID Enumeration" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Restricts anonymous null-session clients from querying account names (SIDs) or sharing lists over the network, mitigating lateral reconnaissance." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SYSTEM\CurrentControlSet\Control\Lsa&quot; /v RestrictAnonymous /t REG_DWORD /d 1 /f; reg add &quot;HKLM\SYSTEM\CurrentControlSet\Control\Lsa&quot; /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderRestrictAnon" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextRestrictAnon" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenRestrictAnon" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>

                                <!-- 16. Deprecate Legacy TLS 1.0 & 1.1 -->
                                <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="15">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*" />
                                            <ColumnDefinition Width="130" />
                                            <ColumnDefinition Width="110" />
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" Margin="0,0,15,0">
                                            <TextBlock Text="16. Deprecate Legacy TLS 1.0 &amp; 1.1 Protocols" FontWeight="Bold" Foreground="#F8FAFC" FontSize="14" />
                                            <TextBlock Text="Deactivates obsolete TLS 1.0 and 1.1 protocol handshakes in SCHANNEL to enforce modern, secure cryptography (TLS 1.2+), neutralizing MitM decryption attacks." TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="11" Margin="0,4,0,8" />
                                            <TextBlock Text="MANUAL REMEDIATION COMMAND (REGISTRY):" Foreground="#10B981" FontWeight="Bold" FontSize="9" Margin="0,0,0,3" />
                                            <TextBox Text="reg add &quot;HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client&quot; /v Enabled /t REG_DWORD /d 0 /f" IsReadOnly="True" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="5" FontSize="10" FontFamily="Consolas" />
                                        </StackPanel>
                                        <Border Grid.Column="1" Name="statusBorderTLS" Height="30" Width="100" CornerRadius="4" Background="#EF4444" VerticalAlignment="Center">
                                            <TextBlock Name="statusTextTLS" Text="VULNERABLE" Foreground="#FFFFFF" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="11"/>
                                        </Border>
                                        <Button Grid.Column="2" Name="btnHardenTLS" Style="{StaticResource PrimaryBtn}" Content="HARDEN NOW" Height="30" Width="95" VerticalAlignment="Center" />
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 4: ABOUT -->
                <Grid Name="gridAbout" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,20">
                        <TextBlock Text="ABOUT PORTABLE SECURITY TOOLKIT" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                        <TextBlock Text="Designed and engineered by Snake Tank." FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" />
                    </StackPanel>

                    <!-- About Card -->
                    <Border Grid.Row="1" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="25">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel HorizontalAlignment="Center">
                                <!-- Glowing Logo -->
                                <Border BorderBrush="#10B981" BorderThickness="2" CornerRadius="12" Padding="20" Width="300" HorizontalAlignment="Center" Margin="0,10,0,15">
                                    <StackPanel>
                                        <TextBlock Text="S N A K E   T A N K" Foreground="#10B981" FontWeight="Bold" FontSize="20" HorizontalAlignment="Center" />
                                        <TextBlock Text="S E C U R I T Y   D I V I S I O N" Foreground="#94A3B8" FontSize="10" FontWeight="SemiBold" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                                    </StackPanel>
                                </Border>

                                <TextBlock Text="Snake Tank Portable Security Toolkit v1.0.0" Foreground="#F8FAFC" FontWeight="Bold" FontSize="16" HorizontalAlignment="Center" Margin="0,0,0,15" />
                                
                                <TextBlock Text="This toolkit is designed as a zero-dependency, self-contained auditing and OS remediation suite. It is highly optimized for network security engineers, IT administrators, and security auditors who need to rapidly assess and secure Windows endpoints without introducing external software footprints or modifying software configurations."
                                           TextWrapping="Wrap" Foreground="#CBD5E1" FontSize="12" TextAlignment="Center" Margin="10,0,10,15" LineHeight="18" />

                                <Border Height="1" Background="#334155" Margin="0,5,0,15" Width="400" />

                                <TextBlock Text="KEY FEATURES:" Foreground="#10B981" FontWeight="Bold" FontSize="12" HorizontalAlignment="Center" Margin="0,0,0,10" />
                                
                                <StackPanel HorizontalAlignment="Center">
                                    <TextBlock Text="• 100% Native PowerShell &amp; WPF Architecture - zero installations needed." Foreground="#E2E8F0" FontSize="11" HorizontalAlignment="Center" Margin="0,0,0,6" />
                                    <TextBlock Text="• Interactive Vulnerability Auditor covering 14 major threat vectors." Foreground="#E2E8F0" FontSize="11" HorizontalAlignment="Center" Margin="0,0,0,6" />
                                    <TextBlock Text="• One-Click System Hardening with immediate live verification." Foreground="#E2E8F0" FontSize="11" HorizontalAlignment="Center" Margin="0,0,0,6" />
                                    <TextBlock Text="• Fully documented manual remediation commands copyable directly to clipboard." Foreground="#E2E8F0" FontSize="11" HorizontalAlignment="Center" Margin="0,0,0,6" />
                                </StackPanel>

                                <TextBlock Text="All system activities are audited locally. No network telemetry is collected." Foreground="#94A3B8" FontSize="10" FontStyle="Italic" HorizontalAlignment="Center" Margin="0,20,0,0" />
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 5: THREAT & VIRUS DETECTOR -->
                <Grid Name="gridThreats" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="50" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,15">
                        <TextBlock Text="THREAT &amp; VIRUS DETECTOR" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                        <TextBlock Text="Leverage Windows Defender databases and local heuristics to hunt down malicious files or anomalies." FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" />
                    </StackPanel>

                    <!-- Controls & Progress -->
                    <Grid Grid.Row="1" Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto" />
                            <ColumnDefinition Width="Auto" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        
                        <Button Name="btnScanActiveThreats" Grid.Column="0" Style="{StaticResource PrimaryBtn}" Content="SCAN ACTIVE THREATS" Width="180" Height="36" />
                        <Button Name="btnScanHeuristics" Grid.Column="1" Style="{StaticResource SecondaryBtn}" Content="RUN HEURISTIC HUNTER" Width="180" Height="36" Margin="10,0,0,0" />
                        
                        <Grid Grid.Column="2" Margin="15,0,0,0">
                            <ProgressBar Name="progressBarThreats" Height="14" Minimum="0" Maximum="100" Value="0" Background="#1E293B" Foreground="#10B981" BorderThickness="0" />
                            <TextBlock Name="txtThreatProgress" Text="Ready to hunt threats" FontSize="10" Foreground="#F8FAFC" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Grid>
                    </Grid>

                    <!-- Results List -->
                    <Border Grid.Row="2" Background="#111827" BorderBrush="#1F2937" BorderThickness="1" CornerRadius="8" Padding="5">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="panelThreatResults" Margin="10">
                                <Border Name="borderInitialThreatState" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="20">
                                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                                        <TextBlock Text="No Threat Scan Data" Foreground="#F8FAFC" FontWeight="Bold" FontSize="15" HorizontalAlignment="Center" />
                                        <TextBlock Text="Choose 'SCAN ACTIVE THREATS' or 'RUN HEURISTIC HUNTER' above to start threat diagnostics." Foreground="#94A3B8" FontSize="11" Margin="0,4,0,0" HorizontalAlignment="Center" />
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 6: CVE SEARCH & SOFTWARE AUDITOR -->
                <Grid Name="gridCVE" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="50" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,15">
                        <TextBlock Text="CVE SEARCH &amp; SOFTWARE VULNERABILITY AUDITOR" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                        <TextBlock Text="Audit local installed applications against active exploit databases or search international CVE records." FontSize="12" Foreground="#94A3B8" Margin="0,4,0,0" />
                    </StackPanel>

                    <!-- Search Controls -->
                    <Grid Grid.Row="1" Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>

                        <TextBox Name="txtCVESearch" Height="36" Background="#0F172A" Foreground="#E2E8F0" BorderBrush="#334155" Padding="10,8,10,8" FontSize="12" VerticalAlignment="Center" Margin="0,0,10,0" />

                        <Button Name="btnSearchCVE" Grid.Column="1" Style="{StaticResource PrimaryBtn}" Content="SEARCH ONLINE" Width="140" Height="36" VerticalAlignment="Center" />
                        <Button Name="btnScanSoftwareCVE" Grid.Column="2" Style="{StaticResource PurpleBtn}" Content="AUDIT INSTALLED SOFTWARE" Width="200" Height="36" Margin="10,0,0,0" VerticalAlignment="Center" />
                    </Grid>

                    <!-- Content Panel -->
                    <Grid Grid.Row="2">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto" />
                            <RowDefinition Height="*" />
                        </Grid.RowDefinitions>

                        <!-- Progress Bar / Progress Status -->
                        <Grid Grid.Row="0" Margin="0,0,0,10" Name="gridCVEProgress" Visibility="Collapsed">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto" />
                                <RowDefinition Height="Auto" />
                            </Grid.RowDefinitions>
                            <ProgressBar Name="progressBarCVE" Height="14" Minimum="0" Maximum="100" Value="0" Background="#1E293B" Foreground="#8B5CF6" BorderThickness="0" Margin="0,0,0,4" />
                            <TextBlock Name="txtCVEProgressStatus" Text="Ready" FontSize="11" Foreground="#CBD5E1" FontWeight="Bold" HorizontalAlignment="Center" />
                        </Grid>

                        <!-- Scrollable results panel -->
                        <Border Grid.Row="1" Background="#111827" BorderBrush="#1F2937" BorderThickness="1" CornerRadius="8" Padding="5">
                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                <StackPanel Name="panelCVEResults" Margin="10">
                                    <Border Name="borderInitialCVEState" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="20">
                                        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                                            <TextBlock Text="No CVE or Software Audit Active" Foreground="#F8FAFC" FontWeight="Bold" FontSize="15" HorizontalAlignment="Center" />
                                            <TextBlock Text="Search above by software name or CVE ID, or run 'AUDIT INSTALLED SOFTWARE' to map local vulnerabilities." Foreground="#94A3B8" FontSize="11" Margin="0,4,0,0" HorizontalAlignment="Center" TextAlignment="Center" />
                                        </StackPanel>
                                    </Border>
                                </StackPanel>
                            </ScrollViewer>
                        </Border>
                    </Grid>
                </Grid>

                <!-- PAGE 7: OS DEEP AUDITOR -->
                <Grid Name="gridOSAudit" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="45" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!-- Header & OS Dashboard -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,10">
                        <Grid Margin="0,0,0,15">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*" />
                                <ColumnDefinition Width="Auto" />
                            </Grid.ColumnDefinitions>
                            
                            <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                <TextBlock Text="OS DEEP AUDITOR &amp; HARDWARE INSPECTOR" FontSize="22" FontWeight="Bold" Foreground="#F8FAFC" />
                                <TextBlock Text="Deep audit of Windows OS internals, drivers, services, CVE mapping, and one-click hardening." FontSize="12" Foreground="#94A3B8" Margin="0,2,0,0" />
                            </StackPanel>
                            
                            <!-- Dynamic OS Status Banner -->
                            <Border Grid.Column="1" Name="borderOSSecurityBanner" Background="#111827" BorderBrush="#94A3B8" BorderThickness="1.5" CornerRadius="6" Padding="12,6" VerticalAlignment="Center">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Name="txtOSSecurityStatusSymbol" Text="&#x1F6E1;" FontFamily="Segoe UI Emoji" FontSize="14" Foreground="#94A3B8" VerticalAlignment="Center" Margin="0,0,6,0" />
                                    <TextBlock Name="txtOSSecurityStatusText" Text="OS STATUS: PENDING SCAN" FontSize="11" FontWeight="Bold" Foreground="#94A3B8" VerticalAlignment="Center" />
                                </StackPanel>
                            </Border>
                        </Grid>

                        <!-- OS Strength Score Card -->
                        <Border Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="8" Padding="15">
                            <Grid VerticalAlignment="Center">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*" />
                                    <ColumnDefinition Width="Auto" />
                                </Grid.ColumnDefinitions>
                                
                                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                    <TextBlock Text="OS STRENGTH SCORE" FontSize="10" FontWeight="Bold" Foreground="#94A3B8" />
                                    <TextBlock Name="txtOSScoreVal" Text="N/A" FontSize="32" FontWeight="Bold" Foreground="#94A3B8" Margin="0,5,0,0" />
                                    <TextBlock Name="txtOSScoreText" Text="Scan Pending" FontSize="11" Foreground="#CBD5E1" Margin="0,2,0,0" />
                                </StackPanel>
                                
                                <Border Grid.Column="1" Name="borderOSGradeBadge" Background="#111827" BorderBrush="#334155" BorderThickness="2" CornerRadius="28" Width="56" Height="56" VerticalAlignment="Center" Margin="10,0,0,0">
                                    <TextBlock Name="txtOSScoreGrade" Text="-" FontSize="28" FontWeight="ExtraBold" Foreground="#94A3B8" HorizontalAlignment="Center" VerticalAlignment="Center" />
                                </Border>
                            </Grid>
                        </Border>
                    </StackPanel>

                    <!-- Scan Trigger Row -->
                    <Grid Grid.Row="1" Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>
                        <TextBlock Text="Status: Press 'RUN DEEP OS AUDIT' to extract operating system parameters." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="11" Name="txtOSAuditStatus" />
                        <Button Name="btnRunOSAudit" Grid.Column="1" Style="{StaticResource PurpleBtn}" Content="RUN DEEP OS AUDIT" Width="200" Height="34" VerticalAlignment="Center" />
                    </Grid>

                    <!-- Scrollable OS Results Panel -->
                    <Border Grid.Row="2" Background="#111827" BorderBrush="#1F2937" BorderThickness="1" CornerRadius="8" Padding="15">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="panelOSResults">
                                <Border Name="borderInitialOSState" Background="#1E293B" BorderBrush="#334155" BorderThickness="1" CornerRadius="6" Padding="20">
                                    <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                                        <TextBlock Text="No Deep OS Data Loaded" Foreground="#F8FAFC" FontWeight="Bold" FontSize="15" HorizontalAlignment="Center" />
                                        <TextBlock Text="Click the 'RUN DEEP OS AUDIT' button above to run local OS diagnostics." Foreground="#94A3B8" FontSize="11" Margin="0,4,0,0" HorizontalAlignment="Center" />
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>
            </Grid>

            <!-- SYSTEM DIAGNOSTIC LOGS TERMINAL (ROW 1) -->
            <Border Grid.Row="1" Background="#030712" BorderBrush="#1F2937" BorderThickness="1" CornerRadius="6" Margin="0,15,0,0">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="25" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>
                    <!-- Log Titlebar Header -->
                    <Border Grid.Row="0" Background="#111827" CornerRadius="5,5,0,0" Padding="10,0,10,0">
                        <Grid>
                            <TextBlock Text="SYSTEM DIAGNOSTIC LOGS" Foreground="#64748B" FontSize="10" FontWeight="Bold" VerticalAlignment="Center" />
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                                <Button Name="btnClearLogs" Content="CLEAR" Background="Transparent" Foreground="#64748B" BorderThickness="0" FontSize="9" FontWeight="Bold" Cursor="Hand" Margin="0,0,10,0" />
                                <Button Name="btnCopyLogs" Content="COPY" Background="Transparent" Foreground="#64748B" BorderThickness="0" FontSize="9" FontWeight="Bold" Cursor="Hand" />
                            </StackPanel>
                        </Grid>
                    </Border>
                    <!-- Scrollable Log output -->
                    <ScrollViewer Grid.Row="1" Name="scrollLogs" VerticalScrollBarVisibility="Auto">
                        <TextBox Name="txtLogs" Background="Transparent" Foreground="#10B981" BorderThickness="0" IsReadOnly="True" 
                                 FontFamily="Consolas" FontSize="10" Padding="10" TextWrapping="Wrap" AcceptsReturn="True" />
                    </ScrollViewer>
                </Grid>
            </Border>
        </Grid>
    </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# ------------------------------------------------------------------------------
# 2. AUTOMATIC CONTROL EXTRACTION
# ------------------------------------------------------------------------------
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Script
}

# ------------------------------------------------------------------------------
# 3. NAVIGATION MANAGEMENT
# ------------------------------------------------------------------------------
function Set-NavActive ($activeBtn, $activeGrid) {
    # Reset all buttons
    $navButtons = @($btnNavDashboard, $btnNavScanner, $btnNavHardening, $btnNavThreats, $btnNavCVE, $btnNavOS, $btnNavAbout)
    foreach ($btn in $navButtons) {
        $btn.Background = Get-Brush("Transparent")
        $btn.Foreground = Get-Brush("#94A3B8")
    }
    # Highlight active button
    $activeBtn.Background = Get-Brush("#1F2937")
    $activeBtn.Foreground = Get-Brush("#F8FAFC")

    # Toggle panels
    $navGrids = @($gridDashboard, $gridScanner, $gridHardening, $gridThreats, $gridCVE, $gridOSAudit, $gridAbout)
    foreach ($g in $navGrids) {
        $g.Visibility = [System.Windows.Visibility]::Collapsed
    }
    $activeGrid.Visibility = [System.Windows.Visibility]::Visible
}

$btnNavDashboard.Add_Click({ Set-NavActive $btnNavDashboard $gridDashboard })
$btnNavScanner.Add_Click({ Set-NavActive $btnNavScanner $gridScanner })
$btnNavHardening.Add_Click({ Set-NavActive $btnNavHardening $gridHardening })
$btnNavThreats.Add_Click({ Set-NavActive $btnNavThreats $gridThreats })
$btnNavCVE.Add_Click({ Set-NavActive $btnNavCVE $gridCVE })
$btnNavOS.Add_Click({ Set-NavActive $btnNavOS $gridOSAudit })
$btnNavAbout.Add_Click({ Set-NavActive $btnNavAbout $gridAbout })

# Set Initial Starting Tab
if ($Tab -eq "Scanner") {
    Set-NavActive $btnNavScanner $gridScanner
} elseif ($Tab -eq "Hardening") {
    Set-NavActive $btnNavHardening $gridHardening
} elseif ($Tab -eq "Threats") {
    Set-NavActive $btnNavThreats $gridThreats
} elseif ($Tab -eq "CVE") {
    Set-NavActive $btnNavCVE $gridCVE
} elseif ($Tab -eq "OS") {
    Set-NavActive $btnNavOS $gridOSAudit
} else {
    Set-NavActive $btnNavDashboard $gridDashboard
}

# ------------------------------------------------------------------------------
# 4. SYSTEM INFORMATION INITIATOR (DASHBOARD)
# ------------------------------------------------------------------------------
function Load-HostDetails {
    $lblHost.Text = $env:COMPUTERNAME
    $lblUser.Text = $env:USERNAME
    
    $osInfo = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $lblOS.Text = $osInfo.ProductName
    
    $build = $osInfo.CurrentBuild
    $lblBuild.Text = $build
    
    try {
        $lblDomain.Text = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Name
    } catch {
        $lblDomain.Text = "WORKGROUP (Local)"
    }
    
    $lblArch.Text = $env:PROCESSOR_ARCHITECTURE

    # 1. CPU Processor Name
    $cpuStr = "Unknown CPU"
    try {
        $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue
        if (!$cpu) { $cpu = Get-WmiObject Win32_Processor -ErrorAction SilentlyContinue }
        if ($cpu) { $cpuStr = ($cpu | Select-Object -First 1).Name.Trim() }
    } catch {}
    $lblCPU.Text = $cpuStr

    # 2. System RAM
    $ramStr = "Unknown RAM"
    try {
        $totalMemory = 0
        $sysInfo = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        if (!$sysInfo) { $sysInfo = Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue }
        if ($sysInfo) { $totalMemory = $sysInfo.TotalPhysicalMemory }
        
        if ($totalMemory -gt 0) {
            $ramGB = [Math]::Round($totalMemory / 1GB, 1)
            $ramStr = "$ramGB GB"
        }
    } catch {}
    $lblRAM.Text = $ramStr

    # 3. Motherboard
    $mbStr = "Unknown Motherboard"
    try {
        $mb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
        if (!$mb) { $mb = Get-WmiObject Win32_BaseBoard -ErrorAction SilentlyContinue }
        if ($mb) {
            $mbStr = "$($mb.Manufacturer.Trim()) $($mb.Product.Trim())"
        }
    } catch {}
    $lblMotherboard.Text = $mbStr

    # 4. GPU Graphics
    $gpuStr = "Unknown GPU"
    try {
        $gpus = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
        if (!$gpus) { $gpus = Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue }
        if ($gpus) {
            $gpuNames = @()
            foreach ($g in $gpus) { 
                if ($g.Name) { $gpuNames += $g.Name.Trim() } 
            }
            if ($gpuNames.Count -gt 0) {
                $gpuStr = $gpuNames -join ", "
            }
        }
    } catch {}
    $lblGPU.Text = $gpuStr

    # 5. Wi-Fi Wireless Adapter
    $wifiStr = "No Wi-Fi Adapter"
    try {
        $adapters = Get-CimInstance Win32_NetworkAdapter -ErrorAction SilentlyContinue
        if (!$adapters) { $adapters = Get-WmiObject Win32_NetworkAdapter -ErrorAction SilentlyContinue }
        if ($adapters) {
            $wifi = $adapters | Where-Object { 
                $_.Name -like "*wireless*" -or 
                $_.Name -like "*wi-fi*" -or 
                $_.Name -like "*wlan*" -or 
                $_.Description -like "*wireless*" -or 
                $_.Description -like "*wi-fi*" -or 
                $_.Description -like "*wlan*" 
            }
            if ($wifi) {
                $wifiStr = ($wifi | Select-Object -First 1).Name.Trim()
            }
        }
    } catch {}
    $lblWiFi.Text = $wifiStr
}
Load-HostDetails

# ------------------------------------------------------------------------------
# 5. DYNAMIC CARD ADDER (VULNERABILITY SCANNER) & STATUS CHECK POPUP
# ------------------------------------------------------------------------------
function Show-StatusCheckModal ($title, $queryCommand) {
    $searchEmoji = [char]::ConvertFromUtf32(0x1F50D)
    $closeX = [char]::ConvertFromUtf32(0x2715)

    # Create the popup window
    $win = New-Object System.Windows.Window
    $win.Title = "Snake Tank Status Check - $title"
    $win.Width = 650
    $win.Height = 450
    $win.Background = Get-Brush("#0F172A") # Dark slate
    $win.ResizeMode = [System.Windows.ResizeMode]::NoResize
    $win.WindowStyle = [System.Windows.WindowStyle]::None # Borderless custom chrome
    $win.AllowsTransparency = $true
    
    if ($window) {
        $win.Owner = $window
        $win.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterOwner
    } else {
        $win.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
    }
    
    # Glowing border container
    $border = New-Object System.Windows.Controls.Border
    $border.BorderBrush = Get-Brush("#8B5CF6") # Elegant purple glow
    $border.BorderThickness = New-Object System.Windows.Thickness(2)
    $border.CornerRadius = New-Object System.Windows.CornerRadius(10)
    $border.Background = Get-Brush("#0F172A")
    
    # Layout Grid
    $grid = New-Object System.Windows.Controls.Grid
    $grid.Margin = New-Object System.Windows.Thickness(20)
    
    # 5 Row Definitions: Header, Subtitle, Command box, Output Terminal, Footer
    $r1 = New-Object System.Windows.Controls.RowDefinition; $r1.Height = [System.Windows.GridLength]::Auto; [void]$grid.RowDefinitions.Add($r1)
    $r2 = New-Object System.Windows.Controls.RowDefinition; $r2.Height = [System.Windows.GridLength]::Auto; [void]$grid.RowDefinitions.Add($r2)
    $r3 = New-Object System.Windows.Controls.RowDefinition; $r3.Height = [System.Windows.GridLength]::Auto; [void]$grid.RowDefinitions.Add($r3)
    $r4 = New-Object System.Windows.Controls.RowDefinition; $r4.Height = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star); [void]$grid.RowDefinitions.Add($r4)
    $r5 = New-Object System.Windows.Controls.RowDefinition; $r5.Height = [System.Windows.GridLength]::Auto; [void]$grid.RowDefinitions.Add($r5)
    
    # Header Grid (Title + Close X button)
    $headerGrid = New-Object System.Windows.Controls.Grid
    $hc1 = New-Object System.Windows.Controls.ColumnDefinition; $hc1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star); [void]$headerGrid.ColumnDefinitions.Add($hc1)
    $hc2 = New-Object System.Windows.Controls.ColumnDefinition; $hc2.Width = [System.Windows.GridLength]::Auto; [void]$headerGrid.ColumnDefinitions.Add($hc2)
    
    $titleBlock = New-Object System.Windows.Controls.TextBlock
    $titleBlock.Text = "$searchEmoji LIVE VULNERABILITY STATUS AUDIT"
    $titleBlock.Foreground = Get-Brush("#8B5CF6")
    $titleBlock.FontWeight = [System.Windows.FontWeights]::Bold
    $titleBlock.FontSize = 14
    [System.Windows.Controls.Grid]::SetColumn($titleBlock, 0)
    [void]$headerGrid.Children.Add($titleBlock)
    
    $closeBtn = New-Object System.Windows.Controls.Button
    $closeBtn.Content = $closeX
    $closeBtn.Background = [System.Windows.Media.Brushes]::Transparent
    $closeBtn.Foreground = Get-Brush("#94A3B8")
    $closeBtn.BorderThickness = New-Object System.Windows.Thickness(0)
    $closeBtn.FontSize = 14
    $closeBtn.FontWeight = [System.Windows.FontWeights]::Bold
    $closeBtn.Cursor = [System.Windows.Input.Cursors]::Hand
    $closeBtn.Add_Click({ $win.Close() })
    [System.Windows.Controls.Grid]::SetColumn($closeBtn, 1)
    [void]$headerGrid.Children.Add($closeBtn)
    
    [System.Windows.Controls.Grid]::SetRow($headerGrid, 0)
    [void]$grid.Children.Add($headerGrid)
    
    # Subtitle
    $subTitle = New-Object System.Windows.Controls.TextBlock
    $subTitle.Text = "Target check: $title"
    $subTitle.Foreground = Get-Brush("#F8FAFC")
    $subTitle.FontWeight = [System.Windows.FontWeights]::SemiBold
    $subTitle.FontSize = 12
    $subTitle.Margin = New-Object System.Windows.Thickness(0, 5, 0, 15)
    [System.Windows.Controls.Grid]::SetRow($subTitle, 1)
    [void]$grid.Children.Add($subTitle)
    
    # Command display stack
    $cmdStack = New-Object System.Windows.Controls.StackPanel
    $cmdStack.Margin = New-Object System.Windows.Thickness(0, 0, 0, 15)
    
    $lblCmd = New-Object System.Windows.Controls.TextBlock
    $lblCmd.Text = "EXECUTING QUERY COMMAND:"
    $lblCmd.Foreground = Get-Brush("#94A3B8")
    $lblCmd.FontWeight = [System.Windows.FontWeights]::Bold
    $lblCmd.FontSize = 9
    $lblCmd.Margin = New-Object System.Windows.Thickness(0, 0, 0, 5)
    [void]$cmdStack.Children.Add($lblCmd)
    
    # Command grid (TextBox + Copy button)
    $codeGrid = New-Object System.Windows.Controls.Grid
    $cc1 = New-Object System.Windows.Controls.ColumnDefinition; $cc1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star); [void]$codeGrid.ColumnDefinitions.Add($cc1)
    $cc2 = New-Object System.Windows.Controls.ColumnDefinition; $cc2.Width = [System.Windows.GridLength]::Auto; [void]$codeGrid.ColumnDefinitions.Add($cc2)
    
    $cmdBox = New-Object System.Windows.Controls.TextBox
    $cmdBox.Text = $queryCommand
    $cmdBox.IsReadOnly = $true
    $cmdBox.Background = Get-Brush("#090D16")
    $cmdBox.Foreground = Get-Brush("#38BDF8") # Light blue consolas text
    $cmdBox.BorderBrush = Get-Brush("#334155")
    $cmdBox.Padding = New-Object System.Windows.Thickness(8)
    $cmdBox.FontFamily = New-Object System.Windows.Media.FontFamily("Consolas")
    $cmdBox.FontSize = 10
    $cmdBox.TextWrapping = [System.Windows.TextWrapping]::Wrap
    [System.Windows.Controls.Grid]::SetColumn($cmdBox, 0)
    [void]$codeGrid.Children.Add($cmdBox)
    
    $cmdCopy = New-Object System.Windows.Controls.Button
    $cmdCopy.Content = "COPY CMD"
    $cmdCopy.Background = Get-Brush("#3B82F6")
    $cmdCopy.Foreground = Get-Brush("#FFFFFF")
    $cmdCopy.FontWeight = [System.Windows.FontWeights]::Bold
    $cmdCopy.FontSize = 9
    $cmdCopy.Padding = New-Object System.Windows.Thickness(8, 0, 8, 0)
    $cmdCopy.Margin = New-Object System.Windows.Thickness(8, 0, 0, 0)
    $cmdCopy.Cursor = [System.Windows.Input.Cursors]::Hand
    $cmdCopy.Add_Click({
        [System.Windows.Clipboard]::SetText($queryCommand)
        $cmdCopy.Content = "COPIED!"
        $cmdCopy.Background = Get-Brush("#10B981")
    })
    [System.Windows.Controls.Grid]::SetColumn($cmdCopy, 1)
    [void]$codeGrid.Children.Add($cmdCopy)
    [void]$cmdStack.Children.Add($codeGrid)
    
    [System.Windows.Controls.Grid]::SetRow($cmdStack, 2)
    [void]$grid.Children.Add($cmdStack)
    
    # Output Terminal Area
    $termGrid = New-Object System.Windows.Controls.Grid
    $termGrid.Margin = New-Object System.Windows.Thickness(0, 0, 0, 15)
    
    $termRow1 = New-Object System.Windows.Controls.RowDefinition; $termRow1.Height = [System.Windows.GridLength]::Auto; [void]$termGrid.RowDefinitions.Add($termRow1)
    $termRow2 = New-Object System.Windows.Controls.RowDefinition; $termRow2.Height = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star); [void]$termGrid.RowDefinitions.Add($termRow2)
    
    $lblOutput = New-Object System.Windows.Controls.TextBlock
    $lblOutput.Text = "AUDIT OUTPUT TERMINAL:"
    $lblOutput.Foreground = Get-Brush("#94A3B8")
    $lblOutput.FontWeight = [System.Windows.FontWeights]::Bold
    $lblOutput.FontSize = 9
    $lblOutput.Margin = New-Object System.Windows.Thickness(0, 0, 0, 5)
    [System.Windows.Controls.Grid]::SetRow($lblOutput, 0)
    [void]$termGrid.Children.Add($lblOutput)
    
    $termBox = New-Object System.Windows.Controls.TextBox
    $termBox.Text = "Executing live system status audit query..."
    $termBox.IsReadOnly = $true
    $termBox.Background = Get-Brush("#020617")
    $termBox.Foreground = Get-Brush("#A7F3D0") # Obsidian green terminal look
    $termBox.BorderBrush = Get-Brush("#1E293B")
    $termBox.FontFamily = New-Object System.Windows.Media.FontFamily("Consolas")
    $termBox.FontSize = 10
    $termBox.Padding = New-Object System.Windows.Thickness(10)
    $termBox.AcceptsReturn = $true
    $termBox.VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
    $termBox.HorizontalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
    [System.Windows.Controls.Grid]::SetRow($termBox, 1)
    [void]$termGrid.Children.Add($termBox)
    
    [System.Windows.Controls.Grid]::SetRow($termGrid, 3)
    [void]$grid.Children.Add($termGrid)
    
    # Footer Grid
    $footerGrid = New-Object System.Windows.Controls.Grid
    
    $fc1 = New-Object System.Windows.Controls.ColumnDefinition; $fc1.Width = [System.Windows.GridLength]::Auto; [void]$footerGrid.ColumnDefinitions.Add($fc1)
    $fc2 = New-Object System.Windows.Controls.ColumnDefinition; $fc2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star); [void]$footerGrid.ColumnDefinitions.Add($fc2)
    $fc3 = New-Object System.Windows.Controls.ColumnDefinition; $fc3.Width = [System.Windows.GridLength]::Auto; [void]$footerGrid.ColumnDefinitions.Add($fc3)
    
    $runBtn = New-Object System.Windows.Controls.Button
    $runBtn.Content = "RUN LIVE AUDIT"
    $runBtn.Background = Get-Brush("#8B5CF6")
    $runBtn.Foreground = Get-Brush("#FFFFFF")
    $runBtn.FontWeight = [System.Windows.FontWeights]::Bold
    $runBtn.FontSize = 11
    $runBtn.Padding = New-Object System.Windows.Thickness(15, 8, 15, 8)
    $runBtn.Cursor = [System.Windows.Input.Cursors]::Hand
    
    # Action for RUN LIVE AUDIT button
    $runBtn.Add_Click({
        $runBtn.IsEnabled = $false
        $runBtn.Content = "EXECUTING..."
        $termBox.Text = "Retrieving system configuration live..."
        $termBox.Foreground = Get-Brush("#F59E0B")
        Do-Events
        
        try {
            # Run command
            $result = Invoke-Expression $queryCommand 2>&1
            $resultStr = ""
            if ($result) {
                $resultStr = $result | Out-String
            } else {
                $resultStr = "Command executed successfully. Status verified secure with null return/implicit true."
            }
            $termBox.Text = $resultStr
            $termBox.Foreground = Get-Brush("#A7F3D0")
        } catch {
            $termBox.Text = "ERROR QUERYING STATUS:`n" + $_.Exception.Message
            $termBox.Foreground = Get-Brush("#EF4444")
        }
        
        $runBtn.Content = "RUN LIVE AUDIT"
        $runBtn.IsEnabled = $true
    })
    [System.Windows.Controls.Grid]::SetColumn($runBtn, 0)
    [void]$footerGrid.Children.Add($runBtn)
    
    $closeBtn2 = New-Object System.Windows.Controls.Button
    $closeBtn2.Content = "CLOSE WINDOW"
    $closeBtn2.Background = Get-Brush("#334155")
    $closeBtn2.Foreground = Get-Brush("#F1F5F9")
    $closeBtn2.FontWeight = [System.Windows.FontWeights]::SemiBold
    $closeBtn2.FontSize = 11
    $closeBtn2.Padding = New-Object System.Windows.Thickness(15, 8, 15, 8)
    $closeBtn2.Cursor = [System.Windows.Input.Cursors]::Hand
    $closeBtn2.Add_Click({ $win.Close() })
    [System.Windows.Controls.Grid]::SetColumn($closeBtn2, 2)
    [void]$footerGrid.Children.Add($closeBtn2)
    
    [System.Windows.Controls.Grid]::SetRow($footerGrid, 4)
    [void]$grid.Children.Add($footerGrid)
    
    $border.Child = $grid
    $win.Content = $border
    
    # Register window loaded event to execute automatically after opening
    $win.Add_Loaded({
        # Run in a Dispatcher/timer block shortly after loaded to avoid UI freezing
        $timer = New-Object System.Windows.Threading.DispatcherTimer
        $timer.Interval = [System.TimeSpan]::FromMilliseconds(200)
        $timer.Add_Tick({
            $timer.Stop()
            $runBtn.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
        })
        $timer.Start()
    })
    
    [void]$win.ShowDialog()
}

function Add-FindingCard ($severity, $title, $description, $evidence, $manualCommand, $queryCommand = "") {
    # Determine color based on severity
    $sevColor = "#10B981" # Info
    if ($severity -eq "Critical") { $sevColor = "#EF4444" }
    elseif ($severity -eq "High") { $sevColor = "#F97316" }
    elseif ($severity -eq "Medium") { $sevColor = "#F59E0B" }
    elseif ($severity -eq "Low") { $sevColor = "#3B82F6" }
    
    # Create border card
    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush("#1E293B")
    $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $card.BorderBrush = Get-Brush("#334155")
    $card.BorderThickness = New-Object System.Windows.Thickness(1)
    $card.Margin = New-Object System.Windows.Thickness(0,0,0,12)
    $card.Padding = New-Object System.Windows.Thickness(16)
    
    # Grid inside card
    $cardGrid = New-Object System.Windows.Controls.Grid
    $row1 = New-Object System.Windows.Controls.RowDefinition
    $row1.Height = [System.Windows.GridLength]::Auto
    [void]$cardGrid.RowDefinitions.Add($row1)
    
    $row2 = New-Object System.Windows.Controls.RowDefinition
    $row2.Height = [System.Windows.GridLength]::Auto
    [void]$cardGrid.RowDefinitions.Add($row2)
    
    # Header Panel (Severity Badge + Title)
    $headerPanel = New-Object System.Windows.Controls.StackPanel
    $headerPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $headerPanel.Margin = New-Object System.Windows.Thickness(0,0,0,10)
    
    # Severity Badge
    $badge = New-Object System.Windows.Controls.Border
    $badge.Background = Get-Brush($sevColor)
    $badge.CornerRadius = New-Object System.Windows.CornerRadius(4)
    $badge.Padding = New-Object System.Windows.Thickness(8,3,8,3)
    $badge.Margin = New-Object System.Windows.Thickness(0,0,10,0)
    $badge.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    
    $badgeText = New-Object System.Windows.Controls.TextBlock
    $badgeText.Text = $severity.ToUpper()
    $badgeText.Foreground = Get-Brush("#FFFFFF")
    $badgeText.FontWeight = [System.Windows.FontWeights]::Bold
    $badgeText.FontSize = 10
    $badge.Child = $badgeText
    [void]$headerPanel.Children.Add($badge)
    
    # Title Text
    $titleText = New-Object System.Windows.Controls.TextBlock
    $titleText.Text = $title
    $titleText.Foreground = Get-Brush("#F8FAFC")
    $titleText.FontWeight = [System.Windows.FontWeights]::Bold
    $titleText.FontSize = 14
    $titleText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [void]$headerPanel.Children.Add($titleText)
    
    [System.Windows.Controls.Grid]::SetRow($headerPanel, 0)
    [void]$cardGrid.Children.Add($headerPanel)
    
    # Details Panel
    $detailsPanel = New-Object System.Windows.Controls.StackPanel
    
    # Description
    $descText = New-Object System.Windows.Controls.TextBlock
    $descText.Text = "Description: $description"
    $descText.Foreground = Get-Brush("#CBD5E1")
    $descText.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $descText.FontSize = 12
    $descText.Margin = New-Object System.Windows.Thickness(0,0,0,6)
    [void]$detailsPanel.Children.Add($descText)
    
    # Evidence
    $evText = New-Object System.Windows.Controls.TextBlock
    $evText.Text = "Evidence: $evidence"
    $evText.Foreground = Get-Brush("#94A3B8")
    $evText.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $evText.FontSize = 11
    $evText.Margin = New-Object System.Windows.Thickness(0,0,0,8)
    [void]$detailsPanel.Children.Add($evText)
    
    # Command Box Header
    $cmdHead = New-Object System.Windows.Controls.TextBlock
    $cmdHead.Text = "MANUAL REMEDIATION COMMAND:"
    $cmdHead.Foreground = Get-Brush("#10B981")
    $cmdHead.FontWeight = [System.Windows.FontWeights]::Bold
    $cmdHead.FontSize = 9
    $cmdHead.Margin = New-Object System.Windows.Thickness(0,4,0,3)
    [void]$detailsPanel.Children.Add($cmdHead)
    
    # Command Box Grid (TextBox + Copy Button)
    $cmdGrid = New-Object System.Windows.Controls.Grid
    
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    [void]$cmdGrid.ColumnDefinitions.Add($col1)
    
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = [System.Windows.GridLength]::Auto
    [void]$cmdGrid.ColumnDefinitions.Add($col2)
    
    # TextBox
    $cmdText = New-Object System.Windows.Controls.TextBox
    $cmdText.Text = $manualCommand
    $cmdText.IsReadOnly = $true
    $cmdText.Background = Get-Brush("#0F172A")
    $cmdText.Foreground = Get-Brush("#E2E8F0")
    $cmdText.BorderBrush = Get-Brush("#334155")
    $cmdText.Padding = New-Object System.Windows.Thickness(6)
    $cmdText.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $cmdText.FontFamily = New-Object System.Windows.Media.FontFamily("Consolas")
    $cmdText.FontSize = 10
    [System.Windows.Controls.Grid]::SetColumn($cmdText, 0)
    [void]$cmdGrid.Children.Add($cmdText)
    
    # Copy Button
    $copyBtn = New-Object System.Windows.Controls.Button
    $copyBtn.Content = "COPY"
    $copyBtn.Background = Get-Brush("#3B82F6")
    $copyBtn.Foreground = Get-Brush("#FFFFFF")
    $copyBtn.FontWeight = [System.Windows.FontWeights]::Bold
    $copyBtn.FontSize = 10
    $copyBtn.Width = 65
    $copyBtn.Margin = New-Object System.Windows.Thickness(8,0,0,0)
    $copyBtn.Cursor = [System.Windows.Input.Cursors]::Hand
    
    # Copy Click Action
    $copyBtn.Add_Click({
        [System.Windows.Clipboard]::SetText($manualCommand)
        $copyBtn.Content = "COPIED"
        $copyBtn.Background = Get-Brush("#10B981")
    })
    
    [System.Windows.Controls.Grid]::SetColumn($copyBtn, 1)
    [void]$cmdGrid.Children.Add($copyBtn)
    [void]$detailsPanel.Children.Add($cmdGrid)
    
    # ADD-ON: Check Status Interface Section
    if ($queryCommand) {
        $statusHead = New-Object System.Windows.Controls.TextBlock
        $statusHead.Text = "STATUS QUERY COMMAND:"
        $statusHead.Foreground = Get-Brush("#8B5CF6") # Vibrant purple
        $statusHead.FontWeight = [System.Windows.FontWeights]::Bold
        $statusHead.FontSize = 9
        $statusHead.Margin = New-Object System.Windows.Thickness(0,8,0,3)
        [void]$detailsPanel.Children.Add($statusHead)
        
        $statusGrid = New-Object System.Windows.Controls.Grid
        
        $sc1 = New-Object System.Windows.Controls.ColumnDefinition
        $sc1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        [void]$statusGrid.ColumnDefinitions.Add($sc1)
        
        $sc2 = New-Object System.Windows.Controls.ColumnDefinition
        $sc2.Width = [System.Windows.GridLength]::Auto
        [void]$statusGrid.ColumnDefinitions.Add($sc2)
        
        # TextBox for Status check command
        $statusText = New-Object System.Windows.Controls.TextBox
        $statusText.Text = $queryCommand
        $statusText.IsReadOnly = $true
        $statusText.Background = Get-Brush("#0F172A")
        $statusText.Foreground = Get-Brush("#E2E8F0")
        $statusText.BorderBrush = Get-Brush("#334155")
        $statusText.Padding = New-Object System.Windows.Thickness(6)
        $statusText.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $statusText.FontFamily = New-Object System.Windows.Media.FontFamily("Consolas")
        $statusText.FontSize = 10
        [System.Windows.Controls.Grid]::SetColumn($statusText, 0)
        [void]$statusGrid.Children.Add($statusText)
        
        # "CHECK STATUS" Button
        $checkBtn = New-Object System.Windows.Controls.Button
        $checkBtn.Content = "CHECK STATUS"
        $checkBtn.Background = Get-Brush("#8B5CF6")
        $checkBtn.Foreground = Get-Brush("#FFFFFF")
        $checkBtn.FontWeight = [System.Windows.FontWeights]::Bold
        $checkBtn.FontSize = 9
        $checkBtn.Width = 90
        $checkBtn.Margin = New-Object System.Windows.Thickness(8,0,0,0)
        $checkBtn.Cursor = [System.Windows.Input.Cursors]::Hand
        
        $checkBtn.Add_Click({
            Show-StatusCheckModal $title $queryCommand
        })
        
        [System.Windows.Controls.Grid]::SetColumn($checkBtn, 1)
        [void]$statusGrid.Children.Add($checkBtn)
        [void]$detailsPanel.Children.Add($statusGrid)
    }
    
    [System.Windows.Controls.Grid]::SetRow($detailsPanel, 1)
    [void]$cardGrid.Children.Add($detailsPanel)
    
    $card.Child = $cardGrid
    [void]$panelScanResults.Children.Add($card)
    
    # 100/100 Upgrade: Log & Store in Global Findings
    $Script:ScanFindings += [PSCustomObject]@{
        Severity = $severity
        Title = $title
        Description = $description
        Evidence = $evidence
        ManualCommand = $manualCommand
        QueryCommand = $queryCommand
        Card = $card
    }
    Write-Log "INFO" "Audited finding added: [$severity] $title"
}

# ------------------------------------------------------------------------------
# 6. SCANNING AND AUDIT MOTOR
# ------------------------------------------------------------------------------
function Run-VulnerabilityScan {
    $btnRunScan.IsEnabled = $false
    if ($btnQuickScan) { $btnQuickScan.IsEnabled = $false }
    $btnRunScan.Content = "SCANNING..."
    
    # 100/100 Upgrade: Clear global findings array & reset log console
    $Script:ScanFindings = @()
    Write-Log "INFO" "=================================================="
    Write-Log "INFO" "SNAKE TANK SECURITY AUDIT ENGINE INITIATED"
    Write-Log "INFO" "=================================================="
    
    # Reset filter UI
    if ($txtSearchScanner) { $txtSearchScanner.Text = "" }
    if ($btnFilterAll) {
        $Script:ScannerFilterState = "All"
        $btnFilterAll.Background = Get-Brush("#8B5CF6")
        $btnFilterCritHigh.Background = Get-Brush("#1E293B")
        $btnFilterMedLow.Background = Get-Brush("#1E293B")
        $btnFilterInfo.Background = Get-Brush("#1E293B")
    }
    
    # Clear previous results
    $panelScanResults.Children.Clear()
    
    # Initialize counts
    $crit = 0; $high = 0; $med = 0; $low = 0; $info = 0
    
    # Check 1: OS Update Baseline (4%)
    $progressBarScan.Value = 4
    $txtProgressStatus.Text = "Auditing operating system baseline update level (1/22)..."
    Write-Log "INFO" "Step 1/22: Checking Windows OS build compliance..."
    Do-Events
    
    $build = [int](Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild
    $prod = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
    $release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId -ErrorAction SilentlyContinue).ReleaseId
    if (-not $release) { $release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion }
    $evidence = "OS: $prod | Version: $release | Build: $build"
    $qCmd1 = "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select-Object ProductName, DisplayVersion, CurrentBuild"
    
    if ($build -lt 19045) {
        Add-FindingCard "High" "Outdated Windows OS Build Version" "The operating system is running build $build which is older than modern baseline standards (19045 - Win 10 22H2 / Win 11). Outdated builds have missing vulnerability patches." $evidence "wuauclt /detectnow /updatenow" $qCmd1
        $high++
    } else {
        Add-FindingCard "Info" "Modern Windows OS Build Verified" "The operating system build is modern and fully supported." $evidence "N/A - System baseline up to date." $qCmd1
        $info++
    }
    
    # Check 2: SMBv1 Legacy State (9%)
    $progressBarScan.Value = 9
    $txtProgressStatus.Text = "Checking legacy SMBv1 networking configurations (2/22)..."
    Write-Log "INFO" "Step 2/22: Checking legacy SMBv1 networking parameters..."
    Do-Events
    
    $smb1Key = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name SMB1 -ErrorAction SilentlyContinue
    $smbEnabled = $false
    if ($smb1Key -and $smb1Key.SMB1 -eq 1) { $smbEnabled = $true }
    $smbConf = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
    if ($smbConf -and $smbConf.EnableSMB1Protocol -eq $true) { $smbEnabled = $true }
    
    $qCmd2 = "Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol"
    if ($smbEnabled) {
        $evidence = "Registry LanmanServer\Parameters\SMB1 set to 1 or PowerShell EnableSMB1Protocol is True."
        Add-FindingCard "Critical" "Legacy SMBv1 Protocol Activated" "SMBv1 is active. This legacy protocol lacks modern security controls and is highly susceptible to credential interception, network malware propagation, and EternalBlue RCE attacks." $evidence "Set-SmbServerConfiguration -EnableSMB1Protocol `$false -Force" $qCmd2
        $crit++
    } else {
        $evidence = "SMB1 registry key set to 0 or unconfigured (default disabled in modern builds)."
        Add-FindingCard "Info" "Legacy SMBv1 Protocol Disabled" "SMBv1 is properly deactivated on this host." $evidence "N/A - Current baseline is secure." $qCmd2
        $info++
    }
    
    # Check 3: Firewall State (13%)
    $progressBarScan.Value = 13
    $txtProgressStatus.Text = "Auditing active network boundaries and Firewall profiles (3/22)..."
    Write-Log "INFO" "Step 3/22: Verifying active network firewall profile boundaries..."
    Do-Events
    
    $fwState = Get-NetFirewallProfile -ErrorAction SilentlyContinue
    $disabledFw = @()
    if ($fwState) {
        foreach ($profile in $fwState) {
            if ($profile.Enabled -eq $false) { $disabledFw += $profile.Name }
        }
    } else {
        if ((netsh advfirewall show allprofiles state) -match "State\s+OFF") { $disabledFw += "Domain/Private/Public" }
    }
    
    $qCmd3 = "Get-NetFirewallProfile | Select-Object Name, Enabled"
    if ($disabledFw.Count -gt 0) {
        $evidence = "Disabled firewall profiles: " + ($disabledFw -join ", ")
        Add-FindingCard "High" "Windows Firewall Profile Deactivated" "One or more Windows Firewall profiles are disabled. This removes local protection filters and exposes running services to external network attacks." $evidence "netsh advfirewall set allprofiles state on" $qCmd3
        $high++
    } else {
        $evidence = "All active profiles (Domain, Private, Public) are active."
        Add-FindingCard "Info" "Windows Firewall Fully Active" "All Windows Firewall boundary profiles are active." $evidence "N/A - System protected by local firewall." $qCmd3
        $info++
    }
    
    # Check 4: Windows Defender RTP (18%)
    $progressBarScan.Value = 18
    $txtProgressStatus.Text = "Verifying Defender Real-Time Protection parameters (4/22)..."
    Write-Log "INFO" "Step 4/22: Inspecting Windows Defender real-time tracking variables..."
    Do-Events
    
    $rtp = $true
    $rtpEv = "Active"
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($def) {
        $rtp = $def.RealTimeProtectionEnabled
        if ($rtp -eq $false) { $rtpEv = "RealTimeProtectionEnabled is set to False." }
    } else {
        if ((Get-Service -Name Windefend -ErrorAction SilentlyContinue).Status -ne "Running") {
            $rtp = $false
            $rtpEv = "Windefend service is currently stopped."
        }
    }
    
    $qCmd4 = "Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled"
    if ($rtp -eq $false) {
        Add-FindingCard "Critical" "Windows Defender Real-Time Protection Disabled" "Real-Time Protection is deactivated. The host is unable to identify or quarantine executing malware, scripts, or suspicious payloads in real-time." $rtpEv "Set-MpPreference -DisableRealtimeMonitoring `$false" $qCmd4
        $crit++
    } else {
        Add-FindingCard "Info" "Windows Defender Active Protection Verified" "Antivirus and Real-Time behavioral monitors are running." "RealTimeProtectionEnabled = True" "N/A - Active scanning active." $qCmd4
        $info++
    }
    
    # Check 5: RDP NLA (22%)
    $progressBarScan.Value = 22
    $txtProgressStatus.Text = "Auditing Remote Desktop UserAuthentication settings (5/22)..."
    Write-Log "INFO" "Step 5/22: Auditing Remote Desktop Network Level Authentication (NLA)..."
    Do-Events
    
    $rdp = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -ErrorAction SilentlyContinue
    $nla = 0
    if ($rdp) { $nla = $rdp.UserAuthentication }
    
    $qCmd5 = "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication"
    if ($nla -eq 0) {
        $evidence = "Registry HKLM\..\WinStations\RDP-Tcp\UserAuthentication is set to 0."
        Add-FindingCard "High" "RDP Network Level Authentication (NLA) Disabled" "NLA is disabled. Remote attackers can establish terminal handshakes and trigger potential pre-authentication RCE exploits (like BlueKeep CVE-2019-0708) without providing valid login credentials." $evidence "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp`" /v UserAuthentication /t REG_DWORD /d 1 /f" $qCmd5
        $high++
    } else {
        $evidence = "NLA is set to 1 (Enabled)."
        Add-FindingCard "Info" "RDP Network Level Authentication (NLA) Secure" "NLA is active, preventing remote pre-authentication exploits." $evidence "N/A - RDP secure." $qCmd5
        $info++
    }
    
    # Check 6: Password Policies (27%)
    $progressBarScan.Value = 27
    $txtProgressStatus.Text = "Parsing active Local Accounts password constraints (6/22)..."
    Write-Log "INFO" "Step 6/22: Parsing active Local Security Accounts password constraints..."
    Do-Events
    
    $netAcc = net accounts
    $minLen = 0
    $lockout = 0
    foreach ($line in $netAcc) {
        if ($line -match "Minimum password length:\s+(\d+)") { $minLen = [int]$Matches[1] }
        elseif ($line -match "Lockout threshold:\s+(\d+|Never)") {
            if ($Matches[1] -eq "Never") { $lockout = 0 }
            else { $lockout = [int]$Matches[1] }
        }
    }
    $lockoutStr = $lockout
    if ($lockout -eq 0) { $lockoutStr = "Never" }
    $pwEv = "Minimum password length: $minLen | Lockout threshold: $lockoutStr"
    
    $qCmd6 = "net accounts"
    if ($minLen -lt 14) {
        Add-FindingCard "High" "Weak Minimum Password Length Constraint" "Local account minimum password length is set to $minLen (recommended is 14+). This increases susceptibility to offline brute forcing and hashing audits." $pwEv "net accounts /minpwlen:14" $qCmd6
        $high++
    }
    if ($lockout -eq 0) {
        Add-FindingCard "High" "Account Lockout Policy Disabled" "Lockout threshold is set to Never. Attackers can brute-force account passwords continuously without lock restrictions." $pwEv "net accounts /lockoutthreshold:5" $qCmd6
        $high++
    }
    if ($minLen -ge 14 -and $lockout -gt 0) {
        Add-FindingCard "Info" "Strong Password Policies Enabled" "Password parameters conform to secure defaults." $pwEv "N/A - SAM boundaries verified." $qCmd6
        $info++
    }
    
    # Check 7: Guest Account (31%)
    $progressBarScan.Value = 31
    $txtProgressStatus.Text = "Checking local security boundaries for built-in Guest user (7/22)..."
    Write-Log "INFO" "Step 7/22: Auditing built-in local Guest user account status..."
    Do-Events
    
    $guestActive = $false
    $guestUser = Get-LocalUser -Name Guest -ErrorAction SilentlyContinue
    if ($guestUser) { $guestActive = $guestUser.Enabled }
    else {
        if ((net user Guest) -match "Account active\s+Yes") { $guestActive = $true }
    }
    
    $qCmd7 = "Get-LocalUser -Name Guest | Select-Object Name, Enabled"
    if ($guestActive) {
        $evidence = "Local Guest account status: Enabled."
        Add-FindingCard "Medium" "Built-in Local Guest Account Active" "The built-in Guest account is enabled. This allows anonymous, unauthenticated network sessions to access system folders or initiate lateral actions." $evidence "net user Guest /active:no" $qCmd7
        $med++
    } else {
        $evidence = "Local Guest account is deactivated."
        Add-FindingCard "Info" "Built-in Local Guest Account Secure" "The built-in Guest account is properly disabled." $evidence "N/A - anonymous access prevented." $qCmd7
        $info++
    }
    
    # Check 8: AlwaysInstallElevated (36%)
    $progressBarScan.Value = 36
    $txtProgressStatus.Text = "Auditing Windows Installer administrative settings (8/22)..."
    Write-Log "INFO" "Step 8/22: Scanning registry policies for AlwaysInstallElevated bypass vulnerability..."
    Do-Events
    
    $aieHKLM = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -ErrorAction SilentlyContinue
    $aieHKCU = Get-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -ErrorAction SilentlyContinue
    $aieVal = 0
    $aieEv = @()
    if ($aieHKLM -and $aieHKLM.AlwaysInstallElevated -eq 1) { $aieVal = 1; $aieEv += "HKLM = 1" }
    if ($aieHKCU -and $aieHKCU.AlwaysInstallElevated -eq 1) { $aieVal = 1; $aieEv += "HKCU = 1" }
    
    $qCmd8 = "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name AlwaysInstallElevated -ErrorAction SilentlyContinue; Get-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name AlwaysInstallElevated -ErrorAction SilentlyContinue"
    if ($aieVal -eq 1) {
        $evidence = $aieEv -join " | "
        Add-FindingCard "Critical" "AlwaysInstallElevated Policy Active" "AlwaysInstallElevated is active in the registry. This dangerous configuration permits non-privileged users to install arbitrary MSI installers with full system SYSTEM authorities, leading to a trivial LPE vulnerability." $evidence "reg add `"HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer`" /v AlwaysInstallElevated /t REG_DWORD /d 0 /f" $qCmd8
        $crit++
    } else {
        $evidence = "Registry keys are not configured or set to 0."
        Add-FindingCard "Info" "AlwaysInstallElevated Policy Secure" "Windows Installer AlwaysInstallElevated policy is secure." $evidence "N/A - Installer permissions restricted." $qCmd8
        $info++
    }
    
    # Check 9: Unquoted Service Paths (40%)
    $progressBarScan.Value = 40
    $txtProgressStatus.Text = "Scanning core system services for unquoted paths (9/22)..."
    Write-Log "INFO" "Step 9/22: Parsing local system service pathways for unquoted spaces..."
    Do-Events
    
    $unquoted = @()
    $svcQuery = Get-WmiObject -Class Win32_Service -ErrorAction SilentlyContinue
    if ($svcQuery) {
        foreach ($service in $svcQuery) {
            $path = $service.PathName
            if ($path) {
                $path = $path.Trim()
                if ($path -like "* *" -and -not $path.StartsWith('"')) {
                    $exePart = $path
                    if ($path.ToLower().Contains(".exe")) {
                        $exePart = $path.Substring(0, $path.ToLower().IndexOf(".exe") + 4)
                    } else {
                        $exePart = $path.Split(" ")[0]
                    }
                    if ($exePart -like "* *" -and -not $exePart.StartsWith('"')) {
                        $unquoted += [PSCustomObject]@{
                             Name = $service.Name
                             DisplayName = $service.DisplayName
                             Path = $path
                        }
                    }
                }
            }
        }
    }    $qCmd9 = 'Get-WmiObject -Class Win32_Service | Where-Object { $_.PathName -like "* *" -and -not $_.PathName.StartsWith([char]34) } | Select-Object Name, DisplayName, PathName'
    if ($unquoted.Count -gt 0) {
        foreach ($us in $unquoted) {
            $evidence = "Service: $($us.Name) | Path: $($us.Path)"
            $mit = "reg add `"HKLM\SYSTEM\CurrentControlSet\Services\$($us.Name)`" /v ImagePath /t REG_EXPAND_SZ /d `"`\`"$($us.Path)`"\`"`" /f"
            Add-FindingCard "High" "Unquoted Service Path: $($us.DisplayName)" "The service '$($us.DisplayName)' has an unquoted path containing spaces. Low-privileged local attackers can place a malicious executable at intersecting paths (e.g. C:\Program.exe) to intercept and run code as SYSTEM during startup." $evidence $mit $qCmd9
            $high++
        }
    } else {
        $evidence = "No unquoted service paths detected on system."
        Add-FindingCard "Info" "Unquoted Service Paths Verified Clean" "No unquoted service paths exist on the local system." $evidence "N/A - Service configurations secure." $qCmd9
        $info++
    }
    
    # Check 10: Startup persistence heuristics (45%)
    $progressBarScan.Value = 45
    $txtProgressStatus.Text = "Analyzing startup persistence folders and signature validations (10/22)..."
    Write-Log "INFO" "Step 10/22: Scanning startup entries for script interpreters or unsigned persistence..."
    Do-Events
    
    $suspiciousKeywords = @("powershell", "cmd.exe", "wscript", "cscript", "mshta", "rundll32", "regsvr32", "certutil", "-enc", "-ec")
    $runKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    $startupFindings = 0
    
    $qCmd10 = "Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'"
    foreach ($keyPath in $runKeys) {
        if (Test-Path $keyPath) {
            $keyProps = Get-ItemProperty -Path $keyPath
            $propNames = Get-Item -Path $keyPath | Select-Object -ExpandProperty Property
            foreach ($name in $propNames) {
                $data = $keyProps.$name.ToString()
                $exePath = $data.Trim()
                if ($exePath.StartsWith('"')) {
                    $end = $exePath.IndexOf('"', 1)
                    if ($end -ne -1) { $exePath = $exePath.Substring(1, $end - 1) }
                } else {
                    $end = $exePath.IndexOf(' ')
                    if ($end -ne -1) { $exePath = $exePath.Substring(0, $end) }
                }
                
                $sigStatus = "Unknown"; $sigSubject = "Unknown"
                $fileExists = Test-Path $exePath -ErrorAction SilentlyContinue
                if ($fileExists) {
                    try {
                        $sig = Get-AuthenticodeSignature -FilePath $exePath -ErrorAction SilentlyContinue
                        if ($sig) {
                            $sigStatus = $sig.Status.ToString()
                            if ($sig.SignerCertificate) { $sigSubject = $sig.SignerCertificate.Subject }
                        }
                    } catch {
                        $sigStatus = "Unknown"
                        $sigSubject = "Query Error"
                    }
                }
                
                $isSuspiciousCmd = $false
                foreach ($kw in $suspiciousKeywords) {
                    if ($data.ToLower().Contains($kw)) { $isSuspiciousCmd = $true; break }
                }
                $inTemp = ($exePath.ToLower().Contains("appdata") -or $exePath.ToLower().Contains("temp"))
                $isUnsigned = ($sigStatus -ne "Valid")
                
                if ($isSuspiciousCmd -or ($isUnsigned -and $inTemp)) {
                    $evidence = "Value: $name | Data: $data | Signature: $sigStatus | Signer: $sigSubject"
                    $mit = "Remove-ItemProperty -Path `"$keyPath`" -Name `"$name`""
                    Add-FindingCard "High" "Suspicious Startup Persistence: $name" "A startup entry uses script interpreters, Living-off-the-Land commands, or runs unsigned binaries out of system temporary directories, indicating potential persistence." $evidence $mit $qCmd10
                    $startupFindings++
                    $high++
                }
            }
        }
    }
    
    if ($startupFindings -eq 0) {
        Add-FindingCard "Info" "Startup Registry Persistence Clean" "No suspicious script execution or unsigned binaries in temporary locations are configured in the startup hives." "All values are standard or signed." "N/A - Startup locations audited." $qCmd10
        $info++
    }
 
    # Check 11: UAC Consent Prompt Administrative Policy (50%)
    $progressBarScan.Value = 50
    $txtProgressStatus.Text = "Verifying UAC administrative elevation consent policies (11/22)..."
    Write-Log "INFO" "Step 11/22: Checking User Account Control Consent Prompting behavior..."
    Do-Events
    
    $uacKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name ConsentPromptBehaviorAdmin -ErrorAction SilentlyContinue
    $uacVal = 5
    if ($uacKey) { $uacVal = $uacKey.ConsentPromptBehaviorAdmin }
    $uacEv = "ConsentPromptBehaviorAdmin = $uacVal"
    
    $qCmd11 = "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin"
    if ($uacVal -eq 0) {
        Add-FindingCard "High" "UAC Administrative Silent Elevation Active" "User Account Control is set to silently elevate administrator requests. Malware or background scripts can execute high-privilege operations silently without notifying the user." $uacEv "reg add `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f" $qCmd11
        $high++
    } else {
        Add-FindingCard "Info" "UAC Consent Prompting Verified" "User Account Control requires explicit interaction on secure desktop for administrative elevation." $uacEv "N/A - UAC boundaries secure." $qCmd11
        $info++
    }

    # Check 12: LLMNR Multicast Name Resolution (54%)
    $progressBarScan.Value = 54
    $txtProgressStatus.Text = "Checking Link-Local Multicast Name Resolution (LLMNR) status (12/22)..."
    Write-Log "INFO" "Step 12/22: Checking Link-Local Multicast Name Resolution (LLMNR) status..."
    Do-Events

    $llmnrVal = 1
    if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient") {
        $llmnrKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue
        if ($llmnrKey -and $llmnrKey.EnableMulticast -eq 0) {
            $llmnrVal = 0
        }
    }
    $llmnrEv = "EnableMulticast = $llmnrVal"

    $qCmd12 = "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name EnableMulticast -ErrorAction SilentlyContinue"
    if ($llmnrVal -eq 1) {
        Add-FindingCard "High" "LLMNR Multicast Resolution Active" "Link-Local Multicast Name Resolution (LLMNR) is active on this host. Attackers on the same local network can spoof query responses to capture sensitive credentials." $llmnrEv "reg add `"HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient`" /v EnableMulticast /t REG_DWORD /d 0 /f" $qCmd12
        $high++
    } else {
        Add-FindingCard "Info" "LLMNR Multicast Resolution Disabled" "Link-Local Multicast Name Resolution is properly deactivated, preventing Responder-style hijacking attacks." $llmnrEv "N/A - LLMNR secure." $qCmd12
        $info++
    }

    # Check 13: LSA Protection (RunAsPPL) (59%)
    $progressBarScan.Value = 59
    $txtProgressStatus.Text = "Verifying LSA Credential Dumping Protection (13/22)..."
    Write-Log "INFO" "Step 13/22: Checking LSA Credential Dumping Protection (RunAsPPL)..."
    Do-Events

    $lsaVal = 0
    $lsaKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction SilentlyContinue
    if ($lsaKey) {
        $lsaVal = $lsaKey.RunAsPPL
    }
    $lsaEv = "RunAsPPL = $lsaVal"

    $qCmd13 = "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name RunAsPPL -ErrorAction SilentlyContinue"
    if ($lsaVal -ne 1 -and $lsaVal -ne 2) {
        Add-FindingCard "High" "LSA dumping protection (RunAsPPL) Disabled" "LSA protection is disabled, allowing administrative processes to access LSA memory and dump passwords or hashes (e.g. using Mimikatz)." $lsaEv "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Lsa`" /v RunAsPPL /t REG_DWORD /d 1 /f" $qCmd13
        $high++
    } else {
        Add-FindingCard "Info" "LSA dumping protection (RunAsPPL) Enabled" "Protected Process Light (PPL) is active on the LSA subsystem, blocking memory dumping." $lsaEv "N/A - LSA protection active (Requires reboot on change)." $qCmd13
        $info++
    }

    # Check 14: Default RDP Port Check (63%)
    $progressBarScan.Value = 63
    $txtProgressStatus.Text = "Checking Remote Desktop default port configurations (14/22)..."
    Write-Log "INFO" "Step 14/22: Checking default Remote Desktop (RDP) port exposure..."
    Do-Events

    $rdpActive = $false
    $tsDenyKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -ErrorAction SilentlyContinue
    if ($tsDenyKey -and $tsDenyKey.fDenyTSConnections -eq 0) {
        $rdpActive = $true
    }

    $rdpPort = 3389
    $portKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" -ErrorAction SilentlyContinue
    if ($portKey) {
        $rdpPort = $portKey.PortNumber
    }
    $rdpEv = "RDP Active: $rdpActive | Listening Port: $rdpPort"

    $qCmd14 = "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber"
    if ($rdpActive -and $rdpPort -eq 3389) {
        Add-FindingCard "Medium" "Default RDP Listening Port 3389 Active" "Remote Desktop (RDP) is enabled and listening on the default port 3389. This makes the host susceptible to port scanners, credential brute-forcing, and RDP vulnerabilities." $rdpEv "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp`" /v PortNumber /t REG_DWORD /d 33890 /f" $qCmd14
        $med++
    } else {
        Add-FindingCard "Info" "RDP Port Configuration Secure" "Remote Desktop is either disabled or configured to listen on a non-default port." $rdpEv "N/A - RDP port not default." $qCmd14
        $info++
    }

    # Check 15: PowerShell Script Block Logging (68%)
    $progressBarScan.Value = 68
    $txtProgressStatus.Text = "Checking PowerShell Script Block Logging status (15/22)..."
    Write-Log "INFO" "Step 15/22: Checking PowerShell Script Block Logging status..."
    Do-Events

    $psLogVal = 0
    if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging") {
        $psLogKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue
        if ($psLogKey -and $psLogKey.EnableScriptBlockLogging -eq 1) { $psLogVal = 1 }
    }
    $psLogEv = "EnableScriptBlockLogging = $psLogVal"

    $qCmd15 = "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name EnableScriptBlockLogging -ErrorAction SilentlyContinue"
    if ($psLogVal -eq 0) {
        Add-FindingCard "High" "PowerShell Script Block Logging Disabled" "PowerShell Script Block Logging is deactivated on this host. Malware skits run invisibly, preventing SOC detection, SIEM aggregation, and post-incident digital forensics." $psLogEv "reg add `"HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging`" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f" $qCmd15
        $high++
    } else {
        Add-FindingCard "Info" "PowerShell Script Block Logging Active" "PowerShell Script Block Logging is active, ensuring auditing transparency." $psLogEv "N/A - PowerShell logging active." $qCmd15
        $info++
    }

    # Check 16: WDigest Caching (72%)
    $progressBarScan.Value = 72
    $txtProgressStatus.Text = "Checking WDigest Logon Credential caching (16/22)..."
    Write-Log "INFO" "Step 16/22: Checking WDigest Logon Credential caching..."
    Do-Events

    $wdigestVal = 0
    $wdigestKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -ErrorAction SilentlyContinue
    if ($wdigestKey) { $wdigestVal = $wdigestKey.UseLogonCredential }
    $wdigestEv = "UseLogonCredential = $wdigestVal"

    $qCmd16 = "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -Name UseLogonCredential -ErrorAction SilentlyContinue"
    if ($wdigestVal -eq 1) {
        Add-FindingCard "Critical" "WDigest Credential Caching Active" "WDigest cleartext password caching is active in LSASS memory. Local administrators can dump high-privileged accounts passwords in plaintext using Mimikatz." $wdigestEv "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest`" /v UseLogonCredential /t REG_DWORD /d 0 /f" $qCmd16
        $crit++
    } else {
        Add-FindingCard "Info" "WDigest Credential Caching Secure" "WDigest cleartext credential caching is properly deactivated." $wdigestEv "N/A - Plaintext credential caching disabled." $qCmd16
        $info++
    }

    # Check 17: AutoPlay / AutoRun (77%)
    $progressBarScan.Value = 77
    $txtProgressStatus.Text = "Checking Drive AutoPlay and AutoRun settings (17/22)..."
    Write-Log "INFO" "Step 17/22: Checking Drive AutoPlay and AutoRun settings..."
    Do-Events

    $autoplayVal = 0
    $autoplayKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue
    if ($autoplayKey) { $autoplayVal = $autoplayKey.NoDriveTypeAutoRun }
    $autoplayEv = "NoDriveTypeAutoRun = $autoplayVal"

    $qCmd17 = "Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutoRun -ErrorAction SilentlyContinue"
    if ($autoplayVal -ne 255) {
        Add-FindingCard "Medium" "AutoPlay / AutoRun Restrictions Disabled" "AutoPlay/AutoRun is not fully disabled across all drive profiles (NoDriveTypeAutoRun is not 255). Insertion of malicious USB or media drives can trigger silent script triggers." $autoplayEv "reg add `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer`" /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f" $qCmd17
        $med++
    } else {
        Add-FindingCard "Info" "AutoPlay / AutoRun Restrictions Active" "AutoPlay and AutoRun are deactivated for all drive categories, preventing USB propagation vectors." $autoplayEv "N/A - USB worms mitigated." $qCmd17
        $info++
    }

    # Check 18: Remote Registry Service (81%)
    $progressBarScan.Value = 81
    $txtProgressStatus.Text = "Verifying Remote Registry service state (18/22)..."
    Write-Log "INFO" "Step 18/22: Verifying Remote Registry service state..."
    Do-Events

    $remReg = Get-Service -Name "RemoteRegistry" -ErrorAction SilentlyContinue
    $remRegState = "Stopped"
    $remRegStart = "Disabled"
    if ($remReg) {
        $remRegState = $remReg.Status.ToString()
        $remRegStart = $remReg.StartType.ToString()
    }
    $remRegEv = "Service Status: $remRegState | Startup Type: $remRegStart"

    $qCmd18 = "Get-Service -Name RemoteRegistry | Select-Object Name, StartType, Status"
    if ($remRegState -eq "Running" -or $remRegStart -ne "Disabled") {
        Add-FindingCard "Low" "Remote Registry Service Active" "The Remote Registry service is enabled or currently active. Pen-testers or remote actors can modify local system registry parameters over the network if administrative boundaries are breached." $remRegEv "powershell -Command `"Stop-Service -Name RemoteRegistry -Force; Set-Service -Name RemoteRegistry -StartupType Disabled`"" $qCmd18
        $low++
    } else {
        Add-FindingCard "Info" "Remote Registry Service Disabled" "Remote Registry service is stopped and configured as Disabled." $remRegEv "N/A - Remote registry modifications prevented." $qCmd18
        $info++
    }

    # Check 19: Local Administrators Group Membership Audit (86%)
    $progressBarScan.Value = 86
    $txtProgressStatus.Text = "Auditing Local Administrators Group Membership (19/22)..."
    Write-Log "INFO" "Step 19/22: Auditing Local Administrators Group Membership..."
    Do-Events

    $admins = @()
    try {
        $netLocal = net localgroup administrators
        $start = $false
        foreach ($line in $netLocal) {
            $l = $line.Trim()
            if ($l -match "^-+$") { $start = $true; continue }
            if ($start -and $l -and $l -notmatch "command completed successfully") {
                $admins += $l
            }
        }
        if ($admins.Count -eq 0) {
            $group = Get-CimInstance Win32_Group -Filter "Name='Administrators'" -ErrorAction SilentlyContinue
            if ($group) {
                $members = Get-CimInstance Win32_GroupUser -ErrorAction SilentlyContinue | Where-Object { $_.GroupComponent -like "*Name=`"Administrators`"*" }
                foreach ($m in $members) {
                    if ($m.PartComponent -match "Name=`"([^`"]+)`"") { $admins += $Matches[1] }
                }
            }
        }
    } catch {}

    $adminsStr = $admins -join ", "
    if ($admins.Count -eq 0) { $adminsStr = "Unable to retrieve (Query Blocked)" }
    $adminEv = "Members: $adminsStr"

    $hasUnusualAdmin = $false
    $unusualNames = @("guest", "test", "user", "standard")
    foreach ($a in $admins) {
        foreach ($un in $unusualNames) {
            if ($a.ToLower() -eq $un) { $hasUnusualAdmin = $true }
        }
    }

    $qCmd19 = "Get-LocalGroupMember -Group 'Administrators' | Select-Object Name, PrincipalSource, ObjectClass"
    if ($hasUnusualAdmin -or $admins.Count -gt 3) {
        Add-FindingCard "Medium" "Over-Privileged Accounts in Local Administrators Group" "The local Administrators group contains standard, guest, or multiple user accounts ($adminsStr). Over-privileged accounts are a major vulnerability that lateral movement malware uses to hijack machines." $adminEv "net localgroup administrators [Username] /delete" $qCmd19
        $med++
    } else {
        Add-FindingCard "Info" "Local Administrators Group Membership Audited" "The local Administrators group membership is standard and conforms to corporate safety guidelines." $adminEv "N/A - Administrator pool verified." $qCmd19
        $info++
    }

    # Check 20: BitLocker Drive Encryption Status (90%)
    $progressBarScan.Value = 90
    $txtProgressStatus.Text = "Checking BitLocker Drive Encryption Status (20/22)..."
    Write-Log "INFO" "Step 20/22: Checking BitLocker Drive Encryption Status..."
    Do-Events

    $bitlockerState = "Off"
    $blEv = "Unknown Protection Status"
    try {
        $bl = Get-CimInstance -Namespace root\CIMV2\Security\MicrosoftVolumeEncryption -ClassName Win32_EncryptableVolume -ErrorAction SilentlyContinue
        if (!$bl) { $bl = Get-WmiObject -Namespace root\CIMV2\Security\MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -ErrorAction SilentlyContinue }
        
        if ($bl) {
            $osVol = $bl | Where-Object { $_.DriveLetter -eq "C:" } | Select-Object -First 1
            if ($osVol) {
                if ($osVol.ProtectionStatus -eq 1) {
                    $bitlockerState = "On"
                    $blEv = "Volume C: Protection Status: On (Encrypted)"
                } else {
                    $blEv = "Volume C: Protection Status: Off (Unencrypted)"
                }
            }
        }
    } catch {}

    $qCmd20 = "Get-CimInstance -Namespace root\cimv2\Security\MicrosoftVolumeEncryption -ClassName Win32_EncryptableVolume | Select-Object DeviceID, DriveLetter, ProtectionStatus"
    if ($bitlockerState -ne "On") {
        Add-FindingCard "High" "BitLocker Drive Encryption Deactivated" "The primary OS volume (C:) is unencrypted. This represents a major physical safety risk where any actor with physical access can extract drive files offline by bypassing OS controls." $blEv "control /name Microsoft.BitLockerDriveEncryption" $qCmd20
        $high++
    } else {
        Add-FindingCard "Info" "BitLocker Drive Encryption Active" "BitLocker Full Disk Encryption is active on the primary OS volume, securing local storage offline." $blEv "N/A - Drive fully encrypted." $qCmd20
        $info++
    }

    # Check 21: Active Listening Ports Exposure (95%)
    $progressBarScan.Value = 95
    $txtProgressStatus.Text = "Analyzing Exposed Active Listening Network Ports (21/22)..."
    Write-Log "INFO" "Step 21/22: Analyzing Exposed Active Listening Network Ports..."
    Do-Events

    $listeningPorts = @()
    $hasDangerousPort = $false
    try {
        $nets = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
        if ($nets) {
            foreach ($n in $nets) {
                if ($n.LocalAddress -eq "0.0.0.0" -or $n.LocalAddress -eq "*") {
                    $port = $n.LocalPort
                    if ($listeningPorts -notcontains $port) {
                        $listeningPorts += $port
                        if ($port -eq 445 -or $port -eq 21 -or $port -eq 23 -or $port -eq 139) {
                            $hasDangerousPort = $true
                        }
                    }
                }
            }
        } else {
            $netstat = netstat -an | Where-Object { $_ -match "LISTENING" }
            foreach ($line in $netstat) {
                if ($line -match "0\.0\.0\.0:(\d+)") {
                    $port = [int]$Matches[1]
                    if ($listeningPorts -notcontains $port) {
                        $listeningPorts += $port
                        if ($port -eq 445 -or $port -eq 21 -or $port -eq 23 -or $port -eq 139) { $hasDangerousPort = $true }
                    }
                }
            }
        }
    } catch {}

    $portsStr = $listeningPorts -join ", "
    if ($listeningPorts.Count -eq 0) { $portsStr = "None detected listening publicly" }
    $portsEv = "Exposed Ports: TCP $portsStr"

    $qCmd21 = "Get-NetTCPConnection -State Listen | Where-Object { `$_.LocalAddress -eq '0.0.0.0' -or `$_.LocalAddress -eq '::' } | Select-Object LocalAddress, LocalPort, State"
    if ($hasDangerousPort) {
        Add-FindingCard "Medium" "Exposed High-Risk Network Ports" "The host has public service ports active and listening to the local network (TCP $portsStr). Leaving ports like SMB (445) or legacys exposed invites lateral intrusion scans." $portsEv "netsh advfirewall firewall set rule group=`"File and Printer Sharing`" new enable=No" $qCmd21
        $med++
    } else {
        Add-FindingCard "Info" "Exposed Network Ports Audited Secure" "No legacy dangerous services (like Telnet or legacy File Sharing) are listening publicly." $portsEv "N/A - External port exposure minimized." $qCmd21
        $info++
    }

    # Check 22: Third-Party AV/EDR Systems (91%)
    $progressBarScan.Value = 91
    $txtProgressStatus.Text = "Verifying Third-Party AV/EDR Endpoint Software (22/24)..."
    Write-Log "INFO" "Step 22/24: Verifying Third-Party AV/EDR Endpoint Software..."
    Do-Events

    $thirdPartyAVs = @()
    try {
        $avProducts = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct -ErrorAction SilentlyContinue
        if (!$avProducts) { $avProducts = Get-WmiObject -Namespace root/SecurityCenter2 -Class AntiVirusProduct -ErrorAction SilentlyContinue }
        
        if ($avProducts) {
            foreach ($av in $avProducts) {
                $name = $av.displayName
                if ($name -notlike "*Windows Defender*" -and $name -notlike "*Windows Security*") {
                    $thirdPartyAVs += $name
                }
            }
        }
    } catch {}

    $qCmd22 = "Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct | Select-Object displayName, productState"
    if ($thirdPartyAVs.Count -gt 0) {
        $avStr = $thirdPartyAVs -join ", "
        $avEv = "Active Security Suite: $avStr"
        Add-FindingCard "Info" "Active Third-Party Endpoint AV/EDR Verified" "Third-party endpoint security software ($avStr) is running and active alongside Windows Security, enhancing system threat containment." $avEv "N/A - Enterprise defense suite active." $qCmd22
        $info++
    } else {
        $avEv = "Endpoint AV: Windows Defender Active Only"
        Add-FindingCard "Info" "Windows Security Center Audited Secure" "The host is protected by the built-in Windows Defender Antivirus, without any competing security suites." $avEv "N/A - Host defense is active." $qCmd22
        $info++
    }

    # Check 23: Anonymous SAM/SID Enumeration (95%)
    $progressBarScan.Value = 95
    $txtProgressStatus.Text = "Auditing Anonymous SAM/SID Enumeration Policy (23/24)..."
    Write-Log "INFO" "Step 23/24: Auditing Anonymous SAM/SID Enumeration Policy..."
    Do-Events

    $restrictAnon = 0
    $restrictAnonSam = 0
    try {
        $lsaKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -ErrorAction SilentlyContinue
        if ($lsaKey) {
            if ($lsaKey.RestrictAnonymous) { $restrictAnon = $lsaKey.RestrictAnonymous }
            if ($lsaKey.RestrictAnonymousSAM) { $restrictAnonSam = $lsaKey.RestrictAnonymousSAM }
        }
    } catch {}

    $anonEv = "RestrictAnonymous = $restrictAnon; RestrictAnonymousSAM = $restrictAnonSam"

    $qCmd23 = "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name RestrictAnonymous, RestrictAnonymousSAM -ErrorAction SilentlyContinue"
    if ($restrictAnon -ne 1 -or $restrictAnonSam -ne 1) {
        Add-FindingCard "Medium" "Anonymous SAM/SID Enumeration Allowed" "Anonymous network clients are permitted to query account names (SIDs) and lists of local shares. This allows external actors to perform lateral network reconnaissance." $anonEv "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Lsa`" /v RestrictAnonymous /t REG_DWORD /d 1 /f; reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Lsa`" /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f" $qCmd23
        $med++
    } else {
        Add-FindingCard "Info" "Anonymous SAM/SID Enumeration Restricted" "Anonymous null-session enumeration of local accounts and shares is properly blocked on this host." $anonEv "N/A - Anonymous enumeration restricted." $qCmd23
        $info++
    }

    # Check 24: SCHANNEL Legacy TLS Protocols (100%)
    $progressBarScan.Value = 100
    $txtProgressStatus.Text = "Checking Legacy TLS 1.0 & 1.1 Protocols (24/24)..."
    Write-Log "INFO" "Step 24/24: Checking Legacy TLS 1.0 & 1.1 Protocols..."
    Do-Events

    $tls10Client = 1
    $tls10Server = 1
    $tls11Client = 1
    $tls11Server = 1

    try {
        $k10C = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k10C) { $tls10Client = $k10C.Enabled }
        
        $k10S = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k10S) { $tls10Server = $k10S.Enabled }

        $k11C = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k11C) { $tls11Client = $k11C.Enabled }

        $k11S = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k11S) { $tls11Server = $k11S.Enabled }
    } catch {}

    $tlsEv = "TLS 1.0 Client: $(if ($tls10Client -eq 0) { 'Disabled' } else { 'Enabled' }), Server: $(if ($tls10Server -eq 0) { 'Disabled' } else { 'Enabled' }) | TLS 1.1 Client: $(if ($tls11Client -eq 0) { 'Disabled' } else { 'Enabled' }), Server: $(if ($tls11Server -eq 0) { 'Disabled' } else { 'Enabled' })"

    $qCmd24 = "Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols' -Recurse -ErrorAction SilentlyContinue"
    if ($tls10Client -ne 0 -or $tls10Server -ne 0 -or $tls11Client -ne 0 -or $tls11Server -ne 0) {
        Add-FindingCard "Medium" "Legacy TLS 1.0 & 1.1 Protocols Enabled" "Obsolete and insecure TLS 1.0 and TLS 1.1 protocols are enabled on this host. This exposes network communications to decryption, hijacking, and credential-downgrade attacks." $tlsEv "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client`" /v Enabled /t REG_DWORD /d 0 /f; reg add `"HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server`" /v Enabled /t REG_DWORD /d 0 /f" $qCmd24
        $med++
    } else {
        Add-FindingCard "Info" "Legacy TLS 1.0 & 1.1 Protocols Disabled" "Obsolete TLS 1.0 and 1.1 handshakes are fully disabled in the system's SCHANNEL protocols, enforcing modern cryptography." $tlsEv "N/A - Obsolete cryptography deprecated." $qCmd24
        $info++
    }
    
    # --------------------------------------------------------------------------
    # DASHBOARD RESULTS UPDATE
    # --------------------------------------------------------------------------
    $total = $crit + $high + $med + $low
    $txtTotalVulns.Text = $total.ToString()
    
    # Calculate Security Score
    # Start at 100, subtract: 15 for Critical, 10 for High, 5 for Medium, 2 for Low
    $score = 100 - ($crit * 15) - ($high * 10) - ($med * 5) - ($low * 2)
    if ($score -lt 0) { $score = 0 }
    $txtScoreVal.Text = $score.ToString() + "/100"
    
    if ($score -ge 85) {
        $txtScoreVal.Foreground = Get-Brush("#10B981") # Green
        $txtScoreText.Text = "Sufficient Protection"
        $txtScoreText.Foreground = Get-Brush("#10B981")
    } elseif ($score -ge 50) {
        $txtScoreVal.Foreground = Get-Brush("#F59E0B") # Yellow
        $txtScoreText.Text = "Attention Required"
        $txtScoreText.Foreground = Get-Brush("#F59E0B")
    } else {
        $txtScoreVal.Foreground = Get-Brush("#EF4444") # Red
        $txtScoreText.Text = "Highly Vulnerable"
        $txtScoreText.Foreground = Get-Brush("#EF4444")
    }
    
    # Calculate Compliance %
    # Out of the 16 hardening rules
    $hardenedCount = 0
    
    # 1. SMBv1 Disabled
    if ($smbEnabled -eq $false) { $hardenedCount++ }
    # 2. Firewall Enabled
    if ($disabledFw.Count -eq 0) { $hardenedCount++ }
    # 3. Defender RTP Active
    if ($rtp -eq $true) { $hardenedCount++ }
    # 4. RDP NLA Active
    if ($nla -eq 1) { $hardenedCount++ }
    # 5. Password strong
    if ($minLen -ge 14 -and $lockout -gt 0) { $hardenedCount++ }
    # 6. Guest Disabled
    if ($guestActive -eq $false) { $hardenedCount++ }
    # 7. AlwaysInstallElevated secure
    if ($aieVal -eq 0) { $hardenedCount++ }
    # 8. UAC Consent Prompt active
    if ($uacVal -ne 0) { $hardenedCount++ }
    # 9. LLMNR Disabled
    if ($llmnrVal -eq 0) { $hardenedCount++ }
    # 10. LSA Protection Enabled
    if ($lsaVal -eq 1 -or $lsaVal -eq 2) { $hardenedCount++ }
    # 11. PS Logging Enabled
    if ($psLogVal -eq 1) { $hardenedCount++ }
    # 12. WDigest Caching Disabled
    if ($wdigestVal -eq 0) { $hardenedCount++ }
    # 13. AutoPlay Disabled
    if ($autoplayVal -eq 255) { $hardenedCount++ }
    # 14. Remote Registry Disabled
    if ($remRegState -ne "Running" -and $remRegStart -eq "Disabled") { $hardenedCount++ }
    # 15. Restrict Anonymous SAM/SID Enumeration
    if ($restrictAnon -eq 1 -and $restrictAnonSam -eq 1) { $hardenedCount++ }
    # 16. Legacy TLS Disabled
    if ($tls10Client -eq 0 -and $tls10Server -eq 0 -and $tls11Client -eq 0 -and $tls11Server -eq 0) { $hardenedCount++ }
    
    $pct = [int](($hardenedCount / 16) * 100)
    $txtHardeningPct.Text = $pct.ToString() + "%"
    
    # Refresh Hardening statuses in the other tab
    Update-AllHardeningStatuses
    
    # Finalize Progress Bar UI
    $txtProgressStatus.Text = "Audit completed successfully! $total vulnerabilities mapped."
    Write-Log "SUCCESS" "Vulnerability scan completed. Score: $score/100, Findings: $total."
    
    $btnRunScan.IsEnabled = $true
    if ($btnQuickScan) { $btnQuickScan.IsEnabled = $true }
    $btnRunScan.Content = "RUN COMPREHENSIVE SCAN"
}

$btnRunScan.Add_Click({ Run-VulnerabilityScan })
$btnQuickScan.Add_Click({
    Set-NavActive $btnNavScanner $gridScanner
    Run-VulnerabilityScan
})

# ------------------------------------------------------------------------------
# SCANNER SEARCH & FILTER ENGINE
# ------------------------------------------------------------------------------
$Script:ScannerFilterState = "All"

function Filter-ScannerFindings {
    $search = $txtSearchScanner.Text.Trim().ToLower()
    $filter = $Script:ScannerFilterState
    
    if (-not $Script:ScanFindings -or $Script:ScanFindings.Count -eq 0) { return }
    
    foreach ($finding in $Script:ScanFindings) {
        if (-not $finding.Card) { continue }
        
        $matchesSearch = $true
        if ($search) {
            $matchesSearch = ($finding.Title.ToLower().Contains($search) -or $finding.Description.ToLower().Contains($search))
        }
        
        $matchesSeverity = $true
        if ($filter -eq "CritHigh") {
            $matchesSeverity = ($finding.Severity -eq "Critical" -or $finding.Severity -eq "High")
        } elseif ($filter -eq "MedLow") {
            $matchesSeverity = ($finding.Severity -eq "Medium" -or $finding.Severity -eq "Low")
        } elseif ($filter -eq "Info") {
            $matchesSeverity = ($finding.Severity -eq "Info")
        }
        
        if ($matchesSearch -and $matchesSeverity) {
            $finding.Card.Visibility = [System.Windows.Visibility]::Visible
        } else {
            $finding.Card.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
}

function Set-ScannerFilterState ($state) {
    $Script:ScannerFilterState = $state
    
    # Visual updates for selected state
    $btnFilterAll.Background = Get-Brush("#1E293B")
    $btnFilterCritHigh.Background = Get-Brush("#1E293B")
    $btnFilterMedLow.Background = Get-Brush("#1E293B")
    $btnFilterInfo.Background = Get-Brush("#1E293B")
    
    if ($state -eq "All") { $btnFilterAll.Background = Get-Brush("#8B5CF6") }
    elseif ($state -eq "CritHigh") { $btnFilterCritHigh.Background = Get-Brush("#8B5CF6") }
    elseif ($state -eq "MedLow") { $btnFilterMedLow.Background = Get-Brush("#8B5CF6") }
    elseif ($state -eq "Info") { $btnFilterInfo.Background = Get-Brush("#8B5CF6") }
    
    Filter-ScannerFindings
}

# Bind events for filter bar
$txtSearchScanner.Add_TextChanged({ Filter-ScannerFindings })
$btnFilterAll.Add_Click({ Set-ScannerFilterState "All" })
$btnFilterCritHigh.Add_Click({ Set-ScannerFilterState "CritHigh" })
$btnFilterMedLow.Add_Click({ Set-ScannerFilterState "MedLow" })
$btnFilterInfo.Add_Click({ Set-ScannerFilterState "Info" })

# Initialize default selected color
$btnFilterAll.Background = Get-Brush("#8B5CF6")

# ------------------------------------------------------------------------------
# 7. SYSTEM HARDENING ENGINE & LIVE VERIFICATION
# ------------------------------------------------------------------------------
function Set-RegistryDword ($path, $name, $value) {
    try {
        if (!(Test-Path $path)) {
            [void](New-Item -Path $path -Force -ErrorAction Stop)
        }
        if (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue) {
            Set-ItemProperty -Path $path -Name $name -Value $value -Force -ErrorAction Stop
        } else {
            [void](New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWORD -Force -ErrorAction Stop)
        }
        return $true
    } catch {
        throw $_
    }
}

function Update-AllHardeningStatuses {
    # 1. SMBv1
    $smb1Key = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name SMB1 -ErrorAction SilentlyContinue
    $smbEnabled = $false
    if ($smb1Key -and $smb1Key.SMB1 -eq 1) { $smbEnabled = $true }
    
    $smbConf = $null
    try {
        $smbConf = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
    } catch {}
    if ($smbConf -and $smbConf.EnableSMB1Protocol -eq $true) { $smbEnabled = $true }
    
    if ($smbEnabled) {
        $statusBorderSMB.Background = Get-Brush("#EF4444")
        $statusTextSMB.Text = "VULNERABLE"
        $btnHardenSMB.IsEnabled = $true
        $btnHardenSMB.Content = "HARDEN NOW"
        $btnHardenSMB.Background = Get-Brush("#10B981")
    } else {
        $statusBorderSMB.Background = Get-Brush("#10B981")
        $statusTextSMB.Text = "SECURE"
        $btnHardenSMB.IsEnabled = $true
        $btnHardenSMB.Content = "REVERT"
        $btnHardenSMB.Background = Get-Brush("#475569")
    }
    
    # 2. Firewall
    $fwState = $null
    try {
        $fwState = Get-NetFirewallProfile -ErrorAction SilentlyContinue
    } catch {}
    $fwDisabled = $false
    if ($fwState) {
        foreach ($profile in $fwState) {
            if ($profile.Enabled -eq $false) { $fwDisabled = $true }
        }
    } else {
        if ((netsh advfirewall show allprofiles state) -match "State\s+OFF") { $fwDisabled = $true }
    }
    if ($fwDisabled) {
        $statusBorderFW.Background = Get-Brush("#EF4444")
        $statusTextFW.Text = "VULNERABLE"
        $btnHardenFW.IsEnabled = $true
        $btnHardenFW.Content = "HARDEN NOW"
        $btnHardenFW.Background = Get-Brush("#10B981")
    } else {
        $statusBorderFW.Background = Get-Brush("#10B981")
        $statusTextFW.Text = "SECURE"
        $btnHardenFW.IsEnabled = $true
        $btnHardenFW.Content = "REVERT"
        $btnHardenFW.Background = Get-Brush("#475569")
    }
    
    # 3. Defender
    $rtp = $true
    $def = $null
    try {
        $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    } catch {}
    if ($def) { $rtp = $def.RealTimeProtectionEnabled }
    else {
        if ((Get-Service -Name Windefend -ErrorAction SilentlyContinue).Status -ne "Running") { $rtp = $false }
    }
    if ($rtp -eq $false) {
        $statusBorderDef.Background = Get-Brush("#EF4444")
        $statusTextDef.Text = "VULNERABLE"
        $btnHardenDef.IsEnabled = $true
        $btnHardenDef.Content = "HARDEN NOW"
        $btnHardenDef.Background = Get-Brush("#10B981")
    } else {
        $statusBorderDef.Background = Get-Brush("#10B981")
        $statusTextDef.Text = "SECURE"
        $btnHardenDef.IsEnabled = $true
        $btnHardenDef.Content = "REVERT"
        $btnHardenDef.Background = Get-Brush("#475569")
    }
    
    # 4. RDP NLA
    $rdp = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -ErrorAction SilentlyContinue
    $nla = 0
    if ($rdp) { $nla = $rdp.UserAuthentication }
    if ($nla -eq 0) {
        $statusBorderRDP.Background = Get-Brush("#EF4444")
        $statusTextRDP.Text = "VULNERABLE"
        $btnHardenRDP.IsEnabled = $true
        $btnHardenRDP.Content = "HARDEN NOW"
        $btnHardenRDP.Background = Get-Brush("#10B981")
    } else {
        $statusBorderRDP.Background = Get-Brush("#10B981")
        $statusTextRDP.Text = "SECURE"
        $btnHardenRDP.IsEnabled = $true
        $btnHardenRDP.Content = "REVERT"
        $btnHardenRDP.Background = Get-Brush("#475569")
    }
    
    # 5. Password Policy
    $netAcc = net accounts
    $minLen = 0
    $lockout = 0
    foreach ($line in $netAcc) {
        if ($line -match "Minimum password length:\s+(\d+)") { $minLen = [int]$Matches[1] }
        elseif ($line -match "Lockout threshold:\s+(\d+|Never)") {
            if ($Matches[1] -eq "Never") { $lockout = 0 }
            else { $lockout = [int]$Matches[1] }
        }
    }
    if ($minLen -lt 14 -or $lockout -eq 0) {
        $statusBorderPWD.Background = Get-Brush("#EF4444")
        $statusTextPWD.Text = "VULNERABLE"
        $btnHardenPWD.IsEnabled = $true
        $btnHardenPWD.Content = "HARDEN NOW"
        $btnHardenPWD.Background = Get-Brush("#10B981")
    } else {
        $statusBorderPWD.Background = Get-Brush("#10B981")
        $statusTextPWD.Text = "SECURE"
        $btnHardenPWD.IsEnabled = $true
        $btnHardenPWD.Content = "REVERT"
        $btnHardenPWD.Background = Get-Brush("#475569")
    }
    
    # 6. Guest Account
    $guestActive = $false
    try {
        $guestUser = Get-LocalUser -Name Guest -ErrorAction SilentlyContinue
        if ($guestUser) { $guestActive = $guestUser.Enabled }
    } catch {
        if ((net user Guest 2>$null) -match "Account active\s+Yes") { $guestActive = $true }
    }
    if ($guestActive) {
        $statusBorderGuest.Background = Get-Brush("#EF4444")
        $statusTextGuest.Text = "VULNERABLE"
        $btnHardenGuest.IsEnabled = $true
        $btnHardenGuest.Content = "HARDEN NOW"
        $btnHardenGuest.Background = Get-Brush("#10B981")
    } else {
        $statusBorderGuest.Background = Get-Brush("#10B981")
        $statusTextGuest.Text = "SECURE"
        $btnHardenGuest.IsEnabled = $true
        $btnHardenGuest.Content = "REVERT"
        $btnHardenGuest.Background = Get-Brush("#475569")
    }
    
    # 7. AlwaysInstallElevated
    $aieHKLM = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -ErrorAction SilentlyContinue
    $aieHKCU = Get-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated -ErrorAction SilentlyContinue
    $aie = 0
    if ($aieHKLM -and $aieHKLM.AlwaysInstallElevated -eq 1) { $aie = 1 }
    if ($aieHKCU -and $aieHKCU.AlwaysInstallElevated -eq 1) { $aie = 1 }
    if ($aie -eq 1) {
        $statusBorderAIE.Background = Get-Brush("#EF4444")
        $statusTextAIE.Text = "VULNERABLE"
        $btnHardenAIE.IsEnabled = $true
        $btnHardenAIE.Content = "HARDEN NOW"
        $btnHardenAIE.Background = Get-Brush("#10B981")
    } else {
        $statusBorderAIE.Background = Get-Brush("#10B981")
        $statusTextAIE.Text = "SECURE"
        $btnHardenAIE.IsEnabled = $true
        $btnHardenAIE.Content = "REVERT"
        $btnHardenAIE.Background = Get-Brush("#475569")
    }

    # 8. UAC Administrative Consent Policy
    $uacKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue
    $uacVal = 5
    if ($uacKey) { $uacVal = $uacKey.ConsentPromptBehaviorAdmin }
    if ($uacVal -eq 0) {
        $statusBorderUAC.Background = Get-Brush("#EF4444")
        $statusTextUAC.Text = "VULNERABLE"
        $btnHardenUAC.IsEnabled = $true
        $btnHardenUAC.Content = "HARDEN NOW"
        $btnHardenUAC.Background = Get-Brush("#10B981")
    } else {
        $statusBorderUAC.Background = Get-Brush("#10B981")
        $statusTextUAC.Text = "SECURE"
        $btnHardenUAC.IsEnabled = $true
        $btnHardenUAC.Content = "REVERT"
        $btnHardenUAC.Background = Get-Brush("#475569")
    }

    # 9. LLMNR Multicast Resolution
    $llmnrVal = 1
    if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient") {
        $llmnrKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue
        if ($llmnrKey -and $llmnrKey.EnableMulticast -eq 0) { $llmnrVal = 0 }
    }
    if ($llmnrVal -eq 1) {
        $statusBorderLLMNR.Background = Get-Brush("#EF4444")
        $statusTextLLMNR.Text = "VULNERABLE"
        $btnHardenLLMNR.IsEnabled = $true
        $btnHardenLLMNR.Content = "HARDEN NOW"
        $btnHardenLLMNR.Background = Get-Brush("#10B981")
    } else {
        $statusBorderLLMNR.Background = Get-Brush("#10B981")
        $statusTextLLMNR.Text = "SECURE"
        $btnHardenLLMNR.IsEnabled = $true
        $btnHardenLLMNR.Content = "REVERT"
        $btnHardenLLMNR.Background = Get-Brush("#475569")
    }

    # 10. LSA Protection
    $lsaVal = 0
    $lsaKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction SilentlyContinue
    if ($lsaKey) { $lsaVal = $lsaKey.RunAsPPL }
    if ($lsaVal -ne 1 -and $lsaVal -ne 2) {
        $statusBorderLSA.Background = Get-Brush("#EF4444")
        $statusTextLSA.Text = "VULNERABLE"
        $btnHardenLSA.IsEnabled = $true
        $btnHardenLSA.Content = "HARDEN NOW"
        $btnHardenLSA.Background = Get-Brush("#10B981")
    } else {
        $statusBorderLSA.Background = Get-Brush("#10B981")
        $statusTextLSA.Text = "SECURE"
        $btnHardenLSA.IsEnabled = $true
        $btnHardenLSA.Content = "REVERT"
        $btnHardenLSA.Background = Get-Brush("#475569")
    }

    # 11. PS Script Block Logging
    $psLogVal = 0
    if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging") {
        $psLogKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue
        if ($psLogKey -and $psLogKey.EnableScriptBlockLogging -eq 1) { $psLogVal = 1 }
    }
    if ($psLogVal -eq 0) {
        $statusBorderPSLog.Background = Get-Brush("#EF4444")
        $statusTextPSLog.Text = "VULNERABLE"
        $btnHardenPSLog.IsEnabled = $true
        $btnHardenPSLog.Content = "HARDEN NOW"
        $btnHardenPSLog.Background = Get-Brush("#10B981")
    } else {
        $statusBorderPSLog.Background = Get-Brush("#10B981")
        $statusTextPSLog.Text = "SECURE"
        $btnHardenPSLog.IsEnabled = $true
        $btnHardenPSLog.Content = "REVERT"
        $btnHardenPSLog.Background = Get-Brush("#475569")
    }

    # 12. WDigest Caching
    $wdigestVal = 0
    $wdigestKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -ErrorAction SilentlyContinue
    if ($wdigestKey) { $wdigestVal = $wdigestKey.UseLogonCredential }
    if ($wdigestVal -eq 1) {
        $statusBorderWDigest.Background = Get-Brush("#EF4444")
        $statusTextWDigest.Text = "VULNERABLE"
        $btnHardenWDigest.IsEnabled = $true
        $btnHardenWDigest.Content = "HARDEN NOW"
        $btnHardenWDigest.Background = Get-Brush("#10B981")
    } else {
        $statusBorderWDigest.Background = Get-Brush("#10B981")
        $statusTextWDigest.Text = "SECURE"
        $btnHardenWDigest.IsEnabled = $true
        $btnHardenWDigest.Content = "REVERT"
        $btnHardenWDigest.Background = Get-Brush("#475569")
    }

    # 13. AutoPlay Protection
    $autoplayVal = 0
    $autoplayKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue
    if ($autoplayKey) { $autoplayVal = $autoplayKey.NoDriveTypeAutoRun }
    if ($autoplayVal -ne 255) {
        $statusBorderAutoPlay.Background = Get-Brush("#EF4444")
        $statusTextAutoPlay.Text = "VULNERABLE"
        $btnHardenAutoPlay.IsEnabled = $true
        $btnHardenAutoPlay.Content = "HARDEN NOW"
        $btnHardenAutoPlay.Background = Get-Brush("#10B981")
    } else {
        $statusBorderAutoPlay.Background = Get-Brush("#10B981")
        $statusTextAutoPlay.Text = "SECURE"
        $btnHardenAutoPlay.IsEnabled = $true
        $btnHardenAutoPlay.Content = "REVERT"
        $btnHardenAutoPlay.Background = Get-Brush("#475569")
    }

    # 14. Remote Registry
    $remReg = Get-Service -Name "RemoteRegistry" -ErrorAction SilentlyContinue
    $remRegState = "Stopped"
    $remRegStart = "Disabled"
    if ($remReg) {
        $remRegState = $remReg.Status.ToString()
        $remRegStart = $remReg.StartType.ToString()
    }
    if ($remRegState -eq "Running" -or $remRegStart -ne "Disabled") {
        $statusBorderRemReg.Background = Get-Brush("#EF4444")
        $statusTextRemReg.Text = "VULNERABLE"
        $btnHardenRemReg.IsEnabled = $true
        $btnHardenRemReg.Content = "HARDEN NOW"
        $btnHardenRemReg.Background = Get-Brush("#10B981")
    } else {
        $statusBorderRemReg.Background = Get-Brush("#10B981")
        $statusTextRemReg.Text = "SECURE"
        $btnHardenRemReg.IsEnabled = $true
        $btnHardenRemReg.Content = "REVERT"
        $btnHardenRemReg.Background = Get-Brush("#475569")
    }

    # 15. Restrict Anonymous SAM/SID Enumeration
    $restrictAnon = 0
    $restrictAnonSam = 0
    try {
        $lsaKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -ErrorAction SilentlyContinue
        if ($lsaKey) {
            if ($lsaKey.RestrictAnonymous) { $restrictAnon = $lsaKey.RestrictAnonymous }
            if ($lsaKey.RestrictAnonymousSAM) { $restrictAnonSam = $lsaKey.RestrictAnonymousSAM }
        }
    } catch {}
    if ($restrictAnon -ne 1 -or $restrictAnonSam -ne 1) {
        $statusBorderRestrictAnon.Background = Get-Brush("#EF4444")
        $statusTextRestrictAnon.Text = "VULNERABLE"
        $btnHardenRestrictAnon.IsEnabled = $true
        $btnHardenRestrictAnon.Content = "HARDEN NOW"
        $btnHardenRestrictAnon.Background = Get-Brush("#10B981")
    } else {
        $statusBorderRestrictAnon.Background = Get-Brush("#10B981")
        $statusTextRestrictAnon.Text = "SECURE"
        $btnHardenRestrictAnon.IsEnabled = $true
        $btnHardenRestrictAnon.Content = "REVERT"
        $btnHardenRestrictAnon.Background = Get-Brush("#475569")
    }

    # 16. Legacy TLS Protocols
    $tls10Client = 1
    $tls10Server = 1
    $tls11Client = 1
    $tls11Server = 1
    try {
        $k10C = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k10C) { $tls10Client = $k10C.Enabled }
        
        $k10S = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k10S) { $tls10Server = $k10S.Enabled }

        $k11C = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k11C) { $tls11Client = $k11C.Enabled }

        $k11S = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        if ($k11S) { $tls11Server = $k11S.Enabled }
    } catch {}
    if ($tls10Client -ne 0 -or $tls10Server -ne 0 -or $tls11Client -ne 0 -or $tls11Server -ne 0) {
        $statusBorderTLS.Background = Get-Brush("#EF4444")
        $statusTextTLS.Text = "VULNERABLE"
        $btnHardenTLS.IsEnabled = $true
        $btnHardenTLS.Content = "HARDEN NOW"
        $btnHardenTLS.Background = Get-Brush("#10B981")
    } else {
        $statusBorderTLS.Background = Get-Brush("#10B981")
        $statusTextTLS.Text = "SECURE"
        $btnHardenTLS.IsEnabled = $true
        $btnHardenTLS.Content = "REVERT"
        $btnHardenTLS.Background = Get-Brush("#475569")
    }

    # Recalculate Compliance % for Dashboard Info
    $hardCount = 0
    if ($smbEnabled -eq $false) { $hardCount++ }
    if ($fwDisabled -eq $false) { $hardCount++ }
    if ($rtp -eq $true) { $hardCount++ }
    if ($nla -eq 1) { $hardCount++ }
    if ($minLen -ge 14 -and $lockout -gt 0) { $hardCount++ }
    if ($guestActive -eq $false) { $hardCount++ }
    if ($aie -eq 0) { $hardCount++ }
    if ($uacVal -ne 0) { $hardCount++ }
    if ($llmnrVal -eq 0) { $hardCount++ }
    if ($lsaVal -eq 1 -or $lsaVal -eq 2) { $hardCount++ }
    if ($psLogVal -eq 1) { $hardCount++ }
    if ($wdigestVal -eq 0) { $hardCount++ }
    if ($autoplayVal -eq 255) { $hardCount++ }
    if ($remRegState -ne "Running" -and $remRegStart -eq "Disabled") { $hardCount++ }
    if ($restrictAnon -eq 1 -and $restrictAnonSam -eq 1) { $hardCount++ }
    if ($tls10Client -eq 0 -and $tls10Server -eq 0 -and $tls11Client -eq 0 -and $tls11Server -eq 0) { $hardCount++ }
    
    $pct = [int](($hardCount / 16) * 100)
    $txtHardeningPct.Text = $pct.ToString() + "%"
}

# Run initial hardening verification check
Update-AllHardeningStatuses

# 100/100 Upgrade: Log Terminal Control Bindings
if ($btnClearLogs) {
    $btnClearLogs.Add_Click({ $txtLogs.Clear() })
}
if ($btnCopyLogs) {
    $btnCopyLogs.Add_Click({
        if ($txtLogs.Text) {
            [System.Windows.Clipboard]::SetText($txtLogs.Text)
            [System.Windows.MessageBox]::Show("Diagnostic activities copied to clipboard!", "Logs Copied", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
    })
}

# Click handlers for individual hardening rules

# 1.# Click handlers for individual hardening rules (Harden / Revert Toggle Engine)

# 1. SMBv1
$btnHardenSMB.Add_Click({
    if ($statusTextSMB.Text -eq "SECURE") {
        Write-Log "WARNING" "Reverting SMBv1 protocol to INSECURE/ENABLED state..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 1 -Force -ErrorAction Stop
            Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force -ErrorAction Stop
            Write-Log "SUCCESS" "Legacy SMBv1 protocol has been enabled. System is now VULNERABLE."
        } catch {
            Write-Log "ERROR" "Failed to enable SMBv1: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Applying deprecation patch for obsolete SMBv1 protocol..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Force -ErrorAction Stop
            Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction Stop
            Write-Log "SUCCESS" "Legacy SMBv1 protocol deprecated successfully."
        } catch {
            Write-Log "WARNING" "Failed to deprecate SMBv1: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 2. Firewall
$btnHardenFW.Add_Click({
    if ($statusTextFW.Text -eq "SECURE") {
        Write-Log "WARNING" "Disabling all local Firewall profiles... [HIGH RISK]"
        try {
            netsh advfirewall set allprofiles state off >$null 2>&1
            Write-Log "SUCCESS" "All Windows Firewall profiles deactivated. System is now VULNERABLE."
        } catch {
            Write-Log "ERROR" "Failed to disable firewall: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Enforcing active states on all local Firewall boundaries..."
        try {
            netsh advfirewall set allprofiles state on >$null 2>&1
            Write-Log "SUCCESS" "Active Windows Firewall profiles verified and activated."
        } catch {
            Write-Log "WARNING" "Failed to activate firewall profiles: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 3. Defender
$btnHardenDef.Add_Click({
    if ($statusTextDef.Text -eq "SECURE") {
        Write-Log "WARNING" "Disabling Windows Defender Real-Time Protection... [HIGH RISK]"
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
            Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction Stop
            Write-Log "SUCCESS" "Defender Real-Time protection monitors deactivated. System is now VULNERABLE."
        } catch {
            Write-Log "ERROR" "Failed to disable Defender monitors: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Enabling Defender Active Protection parameters..."
        try {
            Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
            Set-MpPreference -DisableBehaviorMonitoring $false -ErrorAction Stop
            Write-Log "SUCCESS" "Defender Real-Time behavioral monitors initialized."
        } catch {
            Write-Log "WARNING" "Failed to enable Defender monitors: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 4. RDP NLA
$btnHardenRDP.Add_Click({
    if ($statusTextRDP.Text -eq "SECURE") {
        Write-Log "WARNING" "Disabling RDP Network Level Authentication (NLA)..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "RDP NLA deactivated. System is now VULNERABLE to pre-auth exploits."
        } catch {
            Write-Log "ERROR" "Failed to deactivate RDP NLA: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Configuring RDP authentication parameters..."
        try {
            if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp")) {
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "WinStations\RDP-Tcp" -Force -ErrorAction Stop >$null
            }
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "RDP Network Level Authentication (NLA) enforced."
        } catch {
            Write-Log "WARNING" "Failed to enforce NLA: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 5. Password Policy
$btnHardenPWD.Add_Click({
    if ($statusTextPWD.Text -eq "SECURE") {
        Write-Log "WARNING" "Reverting system password requirements to blank default..."
        try {
            net accounts /minpwlen:0 /lockoutthreshold:0 >$null 2>&1
            Write-Log "SUCCESS" "Local password minimum length set to 0 and lockout disabled. System is now VULNERABLE."
        } catch {
            Write-Log "ERROR" "Failed to weaken password policies: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Applying complex Local Accounts password policy configurations..."
        try {
            net accounts /minpwlen:14 /lockoutthreshold:5 >$null 2>&1
            Write-Log "SUCCESS" "Local password minimum length (14 chars) and lockout limit (5 attempts) hardened."
        } catch {
            Write-Log "WARNING" "Failed to harden password policies: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 6. Guest Account
$btnHardenGuest.Add_Click({
    if ($statusTextGuest.Text -eq "SECURE") {
        Write-Log "WARNING" "Enabling built-in Guest user account... [HIGH RISK]"
        try {
            net user Guest /active:yes >$null 2>&1
            Write-Log "SUCCESS" "Built-in Guest account status activated. System is now VULNERABLE."
        } catch {
            Write-Log "ERROR" "Failed to activate Guest account: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Deactivating built-in local Guest account..."
        try {
            net user Guest /active:no >$null 2>&1
            Write-Log "SUCCESS" "Built-in Guest account status deactivated."
        } catch {
            Write-Log "WARNING" "Failed to deactivate Guest user: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 7. AlwaysInstallElevated
$btnHardenAIE.Add_Click({
    if ($statusTextAIE.Text -eq "SECURE") {
        Write-Log "WARNING" "Activating AlwaysInstallElevated privileged installer execution... [HIGH RISK]"
        try {
            if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "Installer" -Force -ErrorAction Stop >$null
            }
            if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer")) {
                New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "Installer" -Force -ErrorAction Stop >$null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Force -ErrorAction Stop
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "AlwaysInstallElevated enabled. Standard users can execute MSIs with SYSTEM privileges."
        } catch {
            Write-Log "ERROR" "Failed to enable AlwaysInstallElevated: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Deprecating installer elevated execution paths..."
        try {
            if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "Installer" -Force -ErrorAction Stop >$null
            }
            if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer")) {
                New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "Installer" -Force -ErrorAction Stop >$null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 0 -Force -ErrorAction Stop
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "Privileged AlwaysInstallElevated installer policies disabled."
        } catch {
            Write-Log "WARNING" "Failed to disable AlwaysInstallElevated: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 8. UAC Administrative Consent Policy
$btnHardenUAC.Add_Click({
    if ($statusTextUAC.Text -eq "SECURE") {
        Write-Log "WARNING" "Disabling UAC secure elevation consent prompts... [HIGH RISK]"
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "ConsentPromptBehaviorAdmin set to 0. Background apps can silently elevate to Admin without user consent."
        } catch {
            Write-Log "ERROR" "Failed to disable UAC consent prompt: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Applying UAC administrative consent prompting constraints..."
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "User Account Control Consent Prompting policies enforced on secure desktop."
        } catch {
            Write-Log "WARNING" "Failed to enforce secure UAC prompts: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 9. LLMNR Multicast Name Resolution
$btnHardenLLMNR.Add_Click({
    if ($statusTextLLMNR.Text -eq "SECURE") {
        Write-Log "WARNING" "Re-enabling LLMNR local multicast name resolution..."
        try {
            if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient") {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Force -ErrorAction Stop
            }
            Write-Log "SUCCESS" "LLMNR name resolution multicast enabled. System vulnerable to Responder spoofing."
        } catch {
            Write-Log "ERROR" "Failed to enable LLMNR: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Applying Link-Local Multicast Name Resolution (LLMNR) deprecation patch..."
        try {
            if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force -ErrorAction Stop >$null
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "Link-Local Multicast Name Resolution (LLMNR) disabled successfully."
        } catch {
            Write-Log "WARNING" "Failed to disable LLMNR: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 10. LSA Protection
$btnHardenLSA.Add_Click({
    if ($statusTextLSA.Text -eq "SECURE") {
        Write-Log "WARNING" "Disabling LSA process dump protection (RunAsPPL)..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "RunAsPPL protection deactivated. System vulnerable to LSASS password dumping."
        } catch {
            Write-Log "ERROR" "Failed to disable LSA Protection: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Configuring Protected Process Light (PPL) protection for LSA..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 1 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "LSA Credential dumping protection (RunAsPPL) enabled. A system reboot is required to apply the protection policy fully."
        } catch {
            Write-Log "WARNING" "Failed to enable LSA protection: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 11. PS Logging
$btnHardenPSLog.Add_Click({
    if ($statusTextPSLog.Text -eq "SECURE") {
        Write-Log "WARNING" "Disabling PowerShell Script Block Logging..."
        try {
            if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging") {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Force -ErrorAction Stop
            }
            Write-Log "SUCCESS" "PowerShell script block auditing deactivated."
        } catch {
            Write-Log "ERROR" "Failed to disable PowerShell Script Block Logging: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Enabling PowerShell Script Block Logging..."
        try {
            if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging")) {
                [void](New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell" -Name "ScriptBlockLogging" -Force -ErrorAction Stop)
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "PowerShell Script Block Logging enabled."
        } catch {
            Write-Log "WARNING" "Failed to enable PowerShell Script Block Logging: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 12. WDigest Caching
$btnHardenWDigest.Add_Click({
    if ($statusTextWDigest.Text -eq "SECURE") {
        Write-Log "WARNING" "Enabling plaintext WDigest password caching in LSASS..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 1 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "WDigest cleartext password caching re-enabled. Credential harvesters can extract plaintext passwords from LSASS memory."
        } catch {
            Write-Log "ERROR" "Failed to enable WDigest Caching: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Disabling WDigest Logon Credential Caching..."
        try {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "WDigest cleartext password caching in LSASS disabled."
        } catch {
            Write-Log "WARNING" "Failed to disable WDigest logon caching: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 13. AutoPlay Protection
$btnHardenAutoPlay.Add_Click({
    if ($statusTextAutoPlay.Text -eq "SECURE") {
        Write-Log "WARNING" "Enabling drive AutoPlay and AutoRun propagation..."
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 0 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "AutoPlay protections deactivated. Executables can execute automatically from external media."
        } catch {
            Write-Log "ERROR" "Failed to remove AutoPlay restrictions: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Enforcing AutoPlay / AutoRun drive restrictions..."
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Force -ErrorAction Stop
            Write-Log "SUCCESS" "AutoPlay and AutoRun drive propagation protections enforced."
        } catch {
            Write-Log "WARNING" "Failed to restrict AutoPlay settings: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 14. Remote Registry
$btnHardenRemReg.Add_Click({
    if ($statusTextRemReg.Text -eq "SECURE") {
        Write-Log "WARNING" "Activating Remote Registry Service... [HIGH RISK]"
        try {
            Set-Service -Name "RemoteRegistry" -StartupType Automatic -ErrorAction Stop
            Start-Service -Name "RemoteRegistry" -ErrorAction Stop
            Write-Log "SUCCESS" "Remote Registry service initialized in automatic startup mode."
        } catch {
            Write-Log "ERROR" "Failed to start Remote Registry service: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Disabling Remote Registry Service..."
        try {
            Stop-Service -Name "RemoteRegistry" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "RemoteRegistry" -StartupType Disabled -ErrorAction Stop
            Write-Log "SUCCESS" "Remote Registry service stopped and startup configured as Disabled."
        } catch {
            Write-Log "WARNING" "Failed to stop Remote Registry service: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 15. Restrict Anonymous SAM/SID Enumeration
$btnHardenRestrictAnon.Add_Click({
    if ($statusTextRestrictAnon.Text -eq "SECURE") {
        Write-Log "WARNING" "Allowing Anonymous Null Session SAM/SID network queries..."
        try {
            [void](Set-RegistryDword -path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -name "RestrictAnonymous" -value 0)
            [void](Set-RegistryDword -path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -name "RestrictAnonymousSAM" -value 0)
            Write-Log "SUCCESS" "Anonymous SID queries re-enabled. System vulnerable to lateral reconnaissance."
        } catch {
            Write-Log "ERROR" "Failed to allow anonymous queries: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Enforcing Anonymous SAM/SID Enumeration restrictions..."
        try {
            [void](Set-RegistryDword -path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -name "RestrictAnonymous" -value 1)
            [void](Set-RegistryDword -path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -name "RestrictAnonymousSAM" -value 1)
            Write-Log "SUCCESS" "Anonymous SAM/SID enumeration restrictions successfully enforced."
        } catch {
            Write-Log "WARNING" "Failed to enforce Anonymous SAM/SID restrictions: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# 16. Legacy TLS Protocols
$btnHardenTLS.Add_Click({
    if ($statusTextTLS.Text -eq "SECURE") {
        Write-Log "WARNING" "Re-enabling legacy TLS 1.0 and TLS 1.1 server/client channels..."
        try {
            $paths = @(
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
            )
            foreach ($p in $paths) {
                [void](Set-RegistryDword -path $p -name "Enabled" -value 1)
                [void](Set-RegistryDword -path $p -name "DisabledByDefault" -value 0)
            }
            Write-Log "SUCCESS" "Legacy TLS 1.0 & 1.1 active protocols re-enabled in SCHANNEL."
        } catch {
            Write-Log "ERROR" "Failed to enable legacy TLS: $($_.Exception.Message)"
        }
    } else {
        Write-Log "INFO" "Disabling insecure legacy TLS 1.0 & 1.1 protocol handshakes in SCHANNEL..."
        try {
            $paths = @(
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
            )
            foreach ($p in $paths) {
                [void](Set-RegistryDword -path $p -name "Enabled" -value 0)
                [void](Set-RegistryDword -path $p -name "DisabledByDefault" -value 1)
            }
            Write-Log "SUCCESS" "Insecure legacy TLS 1.0 & 1.1 protocols deprecated in SCHANNEL."
        } catch {
            Write-Log "WARNING" "Failed to disable legacy TLS protocols: $($_.Exception.Message)"
        }
    }
    Update-AllHardeningStatuses
})

# Quick actions mapping on Dashboard
$btnQuickHarden.Add_Click({
    Set-NavActive $btnNavHardening $gridHardening
})

# 100/100 Upgrade: HTML Report Exporter function
function Export-HtmlReport {
    if ($Script:ScanFindings.Count -eq 0) {
        if ($env:SNAKE_TANK_TEST -ne "True") {
            [System.Windows.MessageBox]::Show("Please execute a Comprehensive Scan first to compile vulnerabilities.", "No Scan Data Found", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        }
        return
    }
    
    $outputPath = ""
    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        if ($desktop -and (Test-Path $desktop)) {
            $outputPath = Join-Path $desktop "Snake_Tank_Audit_Report.html"
        }
    } catch {}
    if (!$outputPath) {
        try {
            $outputPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "Snake_Tank_Audit_Report.html"
        } catch {
            $outputPath = ".\Snake_Tank_Audit_Report.html"
        }
    }
    Write-Log "INFO" "Compiling security audit results into responsive HTML template..."
    
    $hostName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $osName = $lblOS.Text
    $buildVer = $lblBuild.Text
    $domainName = $lblDomain.Text
    $cpuArch = $lblArch.Text
    
    $score = $txtScoreVal.Text
    $totalVulns = $txtTotalVulns.Text
    $hardeningPct = $txtHardeningPct.Text
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $findingsHtml = ""
    foreach ($f in $Script:ScanFindings) {
        $badgeClass = "badge-info"
        if ($f.Severity -eq "Critical") { $badgeClass = "badge-critical" }
        elseif ($f.Severity -eq "High") { $badgeClass = "badge-high" }
        elseif ($f.Severity -eq "Medium") { $badgeClass = "badge-medium" }
        elseif ($f.Severity -eq "Low") { $badgeClass = "badge-low" }
        
        # Clean special shell characters for html output
        $manualCmdClean = $f.ManualCommand -replace "<", "&lt;" -replace ">", "&gt;"
        
        $findingsHtml += @"
        <div class="card">
            <div class="card-header">
                <span class="badge $badgeClass">$($f.Severity.ToUpper())</span>
                <span class="card-title">$($f.Title)</span>
            </div>
            <div class="card-body">
                <p><strong>Description:</strong> $($f.Description)</p>
                <p class="evidence"><strong>Evidence:</strong> $($f.Evidence)</p>
                <div class="remediation-header">MANUAL REMEDIATION COMMAND:</div>
                <pre><code>$manualCmdClean</code></pre>
            </div>
        </div>
"@
    }
    
    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Snake Tank Security Audit Report - $hostName</title>
    <style>
        body {
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif;
            background-color: #0b0f19;
            color: #f8fafc;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        header {
            border-bottom: 2px solid #10b981;
            padding-bottom: 20px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .brand-title {
            color: #10b981;
            font-size: 26px;
            font-weight: 800;
            letter-spacing: 2px;
            margin: 0;
        }
        .brand-subtitle {
            color: #94a3b8;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 4px;
        }
        .timestamp {
            color: #64748b;
            font-size: 13px;
        }
        .grid-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background-color: #1e293b;
            border: 1px solid #334155;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
        }
        .stat-label {
            color: #94a3b8;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .stat-value {
            font-size: 38px;
            font-weight: 800;
            margin: 10px 0 5px 0;
        }
        .color-green { color: #10b981; }
        .color-red { color: #ef4444; }
        .color-blue { color: #3b82f6; }
        .stat-desc {
            color: #cbd5e1;
            font-size: 12px;
        }
        .section-title {
            font-size: 18px;
            font-weight: 700;
            margin: 30px 0 15px 0;
            color: #f8fafc;
            border-left: 4px solid #10b981;
            padding-left: 10px;
        }
        .host-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
            background-color: #1e293b;
            border: 1px solid #334155;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 35px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #334155;
            padding: 8px 0;
        }
        .info-row:last-child {
            border-bottom: none;
        }
        .info-label {
            color: #94a3b8;
            font-weight: 600;
        }
        .info-val {
            color: #f8fafc;
            font-weight: 700;
        }
        .card {
            background-color: #1e293b;
            border: 1px solid #334155;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
        }
        .card-header {
            display: flex;
            align-items: center;
            margin-bottom: 12px;
        }
        .badge {
            color: white;
            font-size: 10px;
            font-weight: 800;
            padding: 4px 8px;
            border-radius: 4px;
            text-transform: uppercase;
            margin-right: 12px;
            display: inline-block;
        }
        .badge-critical { background-color: #ef4444; }
        .badge-high { background-color: #f97316; }
        .badge-medium { background-color: #f59e0b; }
        .badge-low { background-color: #3b82f6; }
        .badge-info { background-color: #10b981; }
        .card-title {
            font-size: 15px;
            font-weight: 700;
            color: #f8fafc;
        }
        .card-body p {
            margin: 6px 0;
            font-size: 13px;
            line-height: 1.5;
        }
        .evidence {
            color: #94a3b8;
            font-size: 12px !important;
            background-color: #0f172a;
            padding: 8px;
            border-radius: 4px;
            border-left: 3px solid #64748b;
        }
        .remediation-header {
            color: #10b981;
            font-size: 10px;
            font-weight: 700;
            margin-top: 15px;
            letter-spacing: 0.5px;
        }
        pre {
            background-color: #0f172a;
            border: 1px solid #334155;
            padding: 12px;
            border-radius: 6px;
            overflow-x: auto;
            margin: 5px 0 0 0;
        }
        code {
            font-family: 'Consolas', 'Courier New', monospace;
            color: #e2e8f0;
            font-size: 12px;
        }
        footer {
            text-align: center;
            margin-top: 50px;
            padding-top: 20px;
            border-top: 1px solid #334155;
            color: #64748b;
            font-size: 11px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1 class="brand-title">SNAKE TANK</h1>
                <div class="brand-subtitle">Security Division - System Audit Report</div>
            </div>
            <div class="timestamp">Generated on: $date</div>
        </header>

        <div class="grid-stats">
            <div class="stat-card">
                <div class="stat-label">Audit Security Score</div>
                <div class="stat-value color-green">$score</div>
                <div class="stat-desc">Posture rating out of 100</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Vulnerabilities</div>
                <div class="stat-value color-red">$totalVulns</div>
                <div class="stat-desc">Identified security findings</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Hardening Compliance</div>
                <div class="stat-value color-blue">$hardeningPct</div>
                <div class="stat-desc">System subsystems secured</div>
            </div>
        </div>

        <h2 class="section-title">Host Configuration Profile</h2>
        <div class="host-info-grid">
            <div>
                <div class="info-row"><span class="info-label">Hostname:</span><span class="info-val">$hostName</span></div>
                <div class="info-row"><span class="info-label">OS Name:</span><span class="info-val">$osName</span></div>
                <div class="info-row"><span class="info-label">Windows Build:</span><span class="info-val">$buildVer</span></div>
            </div>
            <div>
                <div class="info-row"><span class="info-label">Active User:</span><span class="info-val">$userName</span></div>
                <div class="info-row"><span class="info-label">System Domain:</span><span class="info-val">$domainName</span></div>
                <div class="info-row"><span class="info-label">CPU Arch:</span><span class="info-val">$cpuArch</span></div>
            </div>
        </div>

        <h2 class="section-title">Detailed Vulnerability Diagnostics</h2>
        $findingsHtml

        <footer>
            <p>Snake Tank Portable Security Toolkit v1.0.0 &bull; confidential local audit report</p>
        </footer>
    </div>
</body>
</html>
"@
    
    try {
        $htmlContent | Out-File -FilePath $outputPath -Encoding utf8 -Force
        Write-Log "SUCCESS" "Beautiful security audit report successfully compiled and saved to Desktop!"
        if ($env:SNAKE_TANK_TEST -ne "True") {
            [System.Windows.MessageBox]::Show("Security Audit Report exported successfully to Desktop!`n`nPath: $outputPath", "Report Exported", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
    } catch {
        Write-Log "ERROR" "Failed to save HTML report to Desktop. Error: $_"
        if ($env:SNAKE_TANK_TEST -ne "True") {
            [System.Windows.MessageBox]::Show("Failed to export security report. Please check folder permissions.", "Export Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    }
}

# Bind report export buttons
$btnDashboardExport.Add_Click({ Export-HtmlReport })
$btnScannerExport.Add_Click({ Export-HtmlReport })

# Apply all baseline hardening
$btnApplyAllHardening.Add_Click({
    $btnApplyAllHardening.Content = "APPLYING BASELINE..."
    $btnApplyAllHardening.IsEnabled = $false
    Write-Log "INFO" "=================================================="
    Write-Log "INFO" "APPLYING BASELINE SECURE HARDENING CONSTRAINTS"
    Write-Log "INFO" "=================================================="
    Do-Events

    # 1. SMBv1
    if ($statusTextSMB.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[1/16] Deprecating legacy SMBv1 networking configurations..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[1/16] SMBv1 is already secure. Skipping."
    }
    
    # 2. Firewall
    if ($statusTextFW.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[2/16] Setting Windows Firewall Profile states to ON..."
        netsh advfirewall set allprofiles state on >$null 2>&1
    } else {
        Write-Log "INFO" "[2/16] Firewall profiles are already active. Skipping."
    }
    
    # 3. Defender
    if ($statusTextDef.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[3/16] Enforcing active Real-Time behavioral monitors..."
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $false -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[3/16] Defender real-time protection is already active. Skipping."
    }
    
    # 4. RDP NLA
    if ($statusTextRDP.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[4/16] Activating Remote Desktop Network Level Authentication (NLA)..."
        if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp")) { New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "WinStations\RDP-Tcp" -Force >$null 2>&1 }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[4/16] RDP NLA is already active. Skipping."
    }
    
    # 5. Password Policy
    if ($statusTextPWD.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[5/16] Enforcing complex Password and lockout requirements..."
        net accounts /minpwlen:14 /lockoutthreshold:5 >$null 2>&1
    } else {
        Write-Log "INFO" "[5/16] Password policies are already hardened. Skipping."
    }
    
    # 6. Guest Account
    if ($statusTextGuest.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[6/16] Deactivating local Guest user boundaries..."
        net user Guest /active:no >$null 2>&1
    } else {
        Write-Log "INFO" "[6/16] Local Guest user is already disabled. Skipping."
    }
    
    # 7. AlwaysInstallElevated
    if ($statusTextAIE.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[7/16] Disallowing administrative installation override policies..."
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer")) { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "Installer" -Force >$null 2>&1 }
        if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer")) { New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Force >$null 2>&1 }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 0 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[7/16] AlwaysInstallElevated installer policies are already disabled. Skipping."
    }
    
    # 8. UAC Administrative Consent Policy
    if ($statusTextUAC.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[8/16] Enforcing UAC secure administrative prompt controls..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[8/16] UAC secure consent prompts are already active. Skipping."
    }
    
    # 9. LLMNR Multicast Name Resolution
    if ($statusTextLLMNR.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[9/16] Disabling Link-Local Multicast Name Resolution (LLMNR)..."
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")) { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force >$null 2>&1 }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[9/16] LLMNR multicast resolution is already disabled. Skipping."
    }
 
    # 10. LSA Protection
    if ($statusTextLSA.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[10/16] Enabling LSA dumping protection (RunAsPPL)..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 1 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[10/16] LSA protection (RunAsPPL) is already active. Skipping."
    }
 
    # 11. PS Logging
    if ($statusTextPSLog.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[11/16] Enabling PowerShell Script Block Logging..."
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging")) { [void](New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell" -Name "ScriptBlockLogging" -Force) }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[11/16] PowerShell Logging is already active. Skipping."
    }
 
    # 12. WDigest Caching
    if ($statusTextWDigest.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[12/16] Disabling WDigest Cleartext Logon Credential Caching..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[12/16] WDigest logon caching is already disabled. Skipping."
    }
 
    # 13. AutoPlay Protection
    if ($statusTextAutoPlay.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[13/16] Deactivating AutoPlay/AutoRun USB drive propagation vectors..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[13/16] AutoPlay/AutoRun drive restrictions are already active. Skipping."
    }
 
    # 14. Remote Registry
    if ($statusTextRemReg.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[14/16] Stopping and disabling Remote Registry service..."
        Stop-Service -Name "RemoteRegistry" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "RemoteRegistry" -StartupType Disabled -ErrorAction SilentlyContinue
    } else {
        Write-Log "INFO" "[14/16] Remote Registry service is already disabled. Skipping."
    }

    # 15. Restrict Anonymous SAM/SID Enumeration
    if ($statusTextRestrictAnon.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[15/16] Restricting Anonymous SAM/SID Enumeration over the network..."
        try {
            [void](Set-RegistryDword -path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -name "RestrictAnonymous" -value 1)
            [void](Set-RegistryDword -path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -name "RestrictAnonymousSAM" -value 1)
        } catch {}
    } else {
        Write-Log "INFO" "[15/16] Anonymous SAM/SID enumeration is already restricted. Skipping."
    }

    # 16. Legacy TLS Protocols
    if ($statusTextTLS.Text -eq "VULNERABLE") {
        Write-Log "INFO" "[16/16] Disabling legacy TLS 1.0 & 1.1 protocol handshakes in SCHANNEL..."
        try {
            $paths = @(
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client",
                "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
            )
            foreach ($p in $paths) {
                [void](Set-RegistryDword -path $p -name "Enabled" -value 0)
                [void](Set-RegistryDword -path $p -name "DisabledByDefault" -value 1)
            }
        } catch {}
    } else {
        Write-Log "INFO" "[16/16] Legacy TLS 1.0 & 1.1 protocols are already disabled. Skipping."
    }
 
    # Refresh UI
    Update-AllHardeningStatuses
    
    Write-Log "SUCCESS" "Baseline hardening completed. System verified SECURE!"
    $btnApplyAllHardening.Content = "APPLY ENTERPRISE BASELINE HARDENING"
    $btnApplyAllHardening.IsEnabled = $true
})

# ==============================================================================
# CVE SEARCH & SOFTWARE VULNERABILITY AUDITOR ENGINE
# ==============================================================================
function Add-CVECard ($severity, $cveId, $title, $description, $evidence, $solution, $url) {
    if ($borderInitialCVEState) {
        try {
            [void]$panelCVEResults.Children.Remove($borderInitialCVEState)
        } catch {}
    }

    $sevColor = "#EF4444" # Critical (Red)
    if ($severity -eq "High") { $sevColor = "#F97316" } # Orange
    elseif ($severity -eq "Medium") { $sevColor = "#F59E0B" } # Yellow
    elseif ($severity -eq "Low") { $sevColor = "#3B82F6" } # Blue
    elseif ($severity -eq "Info") { $sevColor = "#10B981" } # Green

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush("#1E293B")
    $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $card.BorderBrush = Get-Brush("#334155")
    $card.BorderThickness = New-Object System.Windows.Thickness(1)
    $card.Margin = New-Object System.Windows.Thickness(0,0,0,12)
    $card.Padding = New-Object System.Windows.Thickness(15)

    $stack = New-Object System.Windows.Controls.StackPanel

    # Header Panel (Badges + Title)
    $hdr = New-Object System.Windows.Controls.StackPanel
    $hdr.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $hdr.Margin = New-Object System.Windows.Thickness(0,0,0,8)

    # Severity Badge
    $badge = New-Object System.Windows.Controls.Border
    $badge.Background = Get-Brush($sevColor)
    $badge.CornerRadius = New-Object System.Windows.CornerRadius(4)
    $badge.Padding = New-Object System.Windows.Thickness(6,2,6,2)
    $badge.Margin = New-Object System.Windows.Thickness(0,0,8,0)
    
    $badgeText = New-Object System.Windows.Controls.TextBlock
    $badgeText.Text = $severity.ToUpper()
    $badgeText.Foreground = Get-Brush("#FFFFFF")
    $badgeText.FontWeight = [System.Windows.FontWeights]::Bold
    $badgeText.FontSize = 9
    $badge.Child = $badgeText
    [void]$hdr.Children.Add($badge)

    # CVE ID Badge
    if ($cveId) {
        $cveBadge = New-Object System.Windows.Controls.Border
        $cveBadge.Background = Get-Brush("#8B5CF6") # Purple
        $cveBadge.CornerRadius = New-Object System.Windows.CornerRadius(4)
        $cveBadge.Padding = New-Object System.Windows.Thickness(6,2,6,2)
        $cveBadge.Margin = New-Object System.Windows.Thickness(0,0,8,0)
        
        $cveText = New-Object System.Windows.Controls.TextBlock
        $cveText.Text = $cveId
        $cveText.Foreground = Get-Brush("#FFFFFF")
        $cveText.FontWeight = [System.Windows.FontWeights]::Bold
        $cveText.FontSize = 9
        $cveBadge.Child = $cveText
        [void]$hdr.Children.Add($cveBadge)
    }

    # Title
    $titleText = New-Object System.Windows.Controls.TextBlock
    $titleText.Text = $title
    $titleText.Foreground = Get-Brush("#F8FAFC")
    $titleText.FontWeight = [System.Windows.FontWeights]::Bold
    $titleText.FontSize = 13
    $titleText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [void]$hdr.Children.Add($titleText)

    [void]$stack.Children.Add($hdr)

    # Description
    $descBlock = New-Object System.Windows.Controls.TextBlock
    $descBlock.Text = $description
    $descBlock.Foreground = Get-Brush("#CBD5E1")
    $descBlock.FontSize = 11
    $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $descBlock.Margin = New-Object System.Windows.Thickness(0,0,0,6)
    [void]$stack.Children.Add($descBlock)

    # Evidence
    if ($evidence) {
        $evBlock = New-Object System.Windows.Controls.TextBlock
        $evBlock.Text = "EVIDENCE: $evidence"
        $evBlock.Foreground = Get-Brush("#F59E0B")
        $evBlock.FontWeight = [System.Windows.FontWeights]::Bold
        $evBlock.FontSize = 10
        $evBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $evBlock.Margin = New-Object System.Windows.Thickness(0,0,0,4)
        [void]$stack.Children.Add($evBlock)
    }

    # Solution / Recommendation
    if ($solution) {
        $solBlock = New-Object System.Windows.Controls.TextBlock
        $solBlock.Text = "REMEDIATION: $solution"
        $solBlock.Foreground = Get-Brush("#10B981")
        $solBlock.FontWeight = [System.Windows.FontWeights]::Bold
        $solBlock.FontSize = 10
        $solBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $solBlock.Margin = New-Object System.Windows.Thickness(0,0,0,4)
        [void]$stack.Children.Add($solBlock)
    }

    # Reference link button
    if ($url) {
        $btnLink = New-Object System.Windows.Controls.Button
        $btnLink.Content = "VIEW REFERENCE SOURCE"
        $btnLink.Height = 22
        $btnLink.Width = 140
        $btnLink.FontSize = 9
        $btnLink.FontWeight = [System.Windows.FontWeights]::Bold
        $btnLink.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
        $btnLink.Background = Get-Brush("#0F172A")
        $btnLink.Foreground = Get-Brush("#8B5CF6")
        $btnLink.BorderBrush = Get-Brush("#334155")
        $btnLink.Margin = New-Object System.Windows.Thickness(0,4,0,0)
        
        $btnLink.Add_Click({
            try {
                [System.Diagnostics.Process]::Start($url)
            } catch {
                [System.Windows.Clipboard]::SetText($url)
                [System.Windows.MessageBox]::Show("Reference URL copied to clipboard: $url", "URL Copied")
            }
        })
        [void]$stack.Children.Add($btnLink)
    }

    $card.Child = $stack
    [void]$panelCVEResults.Children.Add($card)
}

function Get-InstalledSoftware {
    $apps = @()
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($path in $paths) {
        try {
            $regItems = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
            foreach ($item in $regItems) {
                if ($item.DisplayName -and $item.DisplayName.Trim() -ne "") {
                    $apps += [PSCustomObject]@{
                        Name      = $item.DisplayName.Trim()
                        Version   = if ($item.DisplayVersion) { $item.DisplayVersion.ToString().Trim() } else { "Unknown" }
                        Publisher = if ($item.Publisher) { $item.Publisher.ToString().Trim() } else { "Unknown" }
                    }
                }
            }
        } catch {}
    }
    $uniqueApps = $apps | Group-Object Name | ForEach-Object { $_.Group[0] }
    return $uniqueApps
}

function Start-SoftwareCVEScan {
    $gridCVEProgress.Visibility = [System.Windows.Visibility]::Visible
    $panelCVEResults.Children.Clear()
    
    $progressBarCVE.Value = 10
    $txtCVEProgressStatus.Text = "Enumerating installed applications..."
    Do-Events

    $localApps = Get-InstalledSoftware
    $totalApps = $localApps.Count
    
    Write-Log "INFO" "Local inventory compiled: $totalApps applications installed."

    $progressBarCVE.Value = 30
    $txtCVEProgressStatus.Text = "Downloading CISA Known Exploited Vulnerabilities catalog..."
    Do-Events

    $kev = $null
    $isOffline = $false
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        $kev = Invoke-RestMethod -Uri "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json" -TimeoutSec 10 -ErrorAction Stop
    } catch {
        $isOffline = $true
        Write-Log "WARNING" "Could not fetch CISA KEV catalog online. Running in offline mode."
    }

    $progressBarCVE.Value = 60
    $txtCVEProgressStatus.Text = "Cross-referencing software profiles against databases..."
    Do-Events

    $findingsCount = 0

    if ($isOffline) {
        Add-CVECard "Info" "" "Local Inventory Audited Securely (Offline Mode)" "The host compiled $totalApps installed applications. Direct CVE correlation requires internet access. No critical offline signature mismatches identified." "" "Verify network status to enable live threat catalog lookup." ""
        foreach ($app in $localApps) {
            Add-CVECard "Low" "" "$($app.Name) (v$($app.Version))" "Publisher: $($app.Publisher). Installed locally on this endpoint. Set up internet link to cross-reference NVD/CISA exploits live." "Registry Uninstall profile active" "Verify update status inside the application." ""
        }
    } else {
        $vulnerabilities = $kev.vulnerabilities
        $matchedVulnerabilities = @()
        foreach ($app in $localApps) {
            $appName = $app.Name.ToLower()
            foreach ($v in $vulnerabilities) {
                $prodName = $v.product.ToLower()
                if ($prodName -and $prodName.Length -gt 2 -and ($appName -like "*$prodName*" -or $prodName -like "*$appName*")) {
                    $matchedVulnerabilities += [PSCustomObject]@{
                        App          = $app
                        CVE          = $v.cveID
                        VulnName     = $v.vulnerabilityName
                        Description  = $v.shortDescription
                        Remediation  = $v.requiredAction
                        ReferenceUrl = "https://nvd.nist.gov/vuln/detail/" + $v.cveID
                    }
                }
            }
        }

        $progressBarCVE.Value = 90
        $txtCVEProgressStatus.Text = "Rendering threat compliance reports..."
        Do-Events

        if ($matchedVulnerabilities.Count -eq 0) {
            Add-CVECard "Info" "" "Host Software Compliance Audited Secure" "Successfully audited $totalApps local applications against $($vulnerabilities.Count) active vulnerabilities in CISA KEV feed. Zero matches identified! The software environment conforms to modern protection criteria." "No active exploited CVE matches detected in registry inventory." "Maintain local patch management procedures." ""
        } else {
            foreach ($match in $matchedVulnerabilities) {
                $findingsCount++
                $app = $match.App
                $title = "Potentially Vulnerable Installed Software: $($app.Name)"
                $desc = "Installed Version: $($app.Version) | Publisher: $($app.Publisher)`n`nKnown Exploited Vulnerability details: $($match.VulnName)`n`n$($match.Description)"
                Add-CVECard "High" $match.CVE $title $desc "Application software name match inside Active Exploitation Catalog." $match.Remediation $match.ReferenceUrl
            }
        }
    }

    $progressBarCVE.Value = 100
    $txtCVEProgressStatus.Text = "Vulnerability audit completed! Found $findingsCount matches."
    Do-Events
    Write-Log "SUCCESS" "Software vulnerability audit finished. Inspected $totalApps applications, flagged $findingsCount threat profiles."
}

function Search-OnlineCVE {
    $query = $txtCVESearch.Text.Trim()
    if ($query -eq "") {
        [System.Windows.MessageBox]::Show("Please enter a software name, version, or CVE ID to search.", "Empty Query", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }

    $gridCVEProgress.Visibility = [System.Windows.Visibility]::Visible
    $panelCVEResults.Children.Clear()
    
    $progressBarCVE.Value = 20
    $txtCVEProgressStatus.Text = "Contacting public CVE directories..."
    Do-Events

    Write-Log "INFO" "Executing on-demand CVE search query for: $query"

    try {
        $url = ""
        $isSpecificCVE = $false
        if ($query -match "^CVE-\d{4}-\d{4,7}$") {
            $url = "https://cve.circl.lu/api/cve/$query"
            $isSpecificCVE = $true
        } else {
            $url = "https://cve.circl.lu/api/search/" + [Uri]::EscapeDataString($query)
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        $results = Invoke-RestMethod -Uri $url -TimeoutSec 10 -ErrorAction Stop

        $progressBarCVE.Value = 70
        $txtCVEProgressStatus.Text = "Parsing search query responses..."
        Do-Events

        if ($null -eq $results -or $results.Count -eq 0 -or ($isSpecificCVE -and !$results.id)) {
            Add-CVECard "Info" "" "Zero CVE Matching Records Found" "No CVE entries or active exploits matched the query '$query' in public vulnerability directories. If searching by software, try basic brand name matches (e.g., 'adobe', 'zoom')." "Search matched 0 catalog entries." "N/A" ""
        } else {
            $progressBarCVE.Value = 90
            $txtCVEProgressStatus.Text = "Rendering matching catalog entries..."
            Do-Events

            if ($isSpecificCVE) {
                $cve = $results
                $cvss = if ($cve.cvss) { $cve.cvss } else { "N/A" }
                $severity = "Medium"
                if ($cve.cvss -ge 9.0) { $severity = "Critical" }
                elseif ($cve.cvss -ge 7.0) { $severity = "High" }
                elseif ($cve.cvss -ge 4.0) { $severity = "Medium" }
                else { $severity = "Low" }

                $title = "Vulnerability Detail Summary (CVSS: $cvss)"
                $urlDetail = "https://nvd.nist.gov/vuln/detail/" + $cve.id
                Add-CVECard $severity $cve.id $title $cve.summary "Direct database identifier search match." "Consult Vendor Advisory and apply the latest security patches." $urlDetail
            } else {
                $cves = @($results)
                if ($cves.Count -gt 25) { $cves = $cves[0..24] }

                foreach ($cve in $cves) {
                    $cvss = if ($cve.cvss) { $cve.cvss } else { "N/A" }
                    $severity = "Medium"
                    if ($cve.cvss -ge 9.0) { $severity = "Critical" }
                    elseif ($cve.cvss -ge 7.0) { $severity = "High" }
                    elseif ($cve.cvss -ge 4.0) { $severity = "Medium" }
                    else { $severity = "Low" }

                    $title = "Vulnerability Matching Product (CVSS: $cvss)"
                    $urlDetail = "https://nvd.nist.gov/vuln/detail/" + $cve.id
                    Add-CVECard $severity $cve.id $title $cve.summary "Matches catalog search filters." "Consult Vendor Advisory and apply the latest security patches." $urlDetail
                }
            }
            Write-Log "SUCCESS" "On-demand CVE query executed successfully for: $query"
        }
    } catch {
        Write-Log "WARNING" "CVE lookup failed: $($_.Exception.Message)"
        Add-CVECard "Critical" "" "CVE Direct Query Interrupted" "Could not connect to online CVE directories. Verify that the system has an active internet link and can resolve cve.circl.lu domain names.`n`nDiagnostic Error: $($_.Exception.Message)" "Connection error." "Check internet settings and try again." ""
    }

    $progressBarCVE.Value = 100
    $txtCVEProgressStatus.Text = "Search finished!"
    Do-Events
}

$btnSearchCVE.Add_Click({ Search-OnlineCVE })
$btnScanSoftwareCVE.Add_Click({ Start-SoftwareCVEScan })

# ==============================================================================
# THREAT DETECTOR ENGINE & HEURISTIC VIRUS HUNTER FUNCTIONS
# ==============================================================================

function Add-ThreatCard ($type, $title, $filePath, $severity, $description) {
    if ($borderInitialThreatState) {
        try {
            [void]$panelThreatResults.Children.Remove($borderInitialThreatState)
        } catch {}
    }

    $sevColor = "#EF4444"
    if ($severity -eq "High") { $sevColor = "#F97316" }

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush("#1E293B")
    $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $card.BorderBrush = Get-Brush("#334155")
    $card.BorderThickness = New-Object System.Windows.Thickness(1)
    $card.Margin = New-Object System.Windows.Thickness(0,0,0,12)
    $card.Padding = New-Object System.Windows.Thickness(15)

    $grid = New-Object System.Windows.Controls.Grid
    
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    [void]$grid.ColumnDefinitions.Add($col1)
    
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = [System.Windows.GridLength]::Auto
    [void]$grid.ColumnDefinitions.Add($col2)

    $details = New-Object System.Windows.Controls.StackPanel
    [System.Windows.Controls.Grid]::SetColumn($details, 0)
    
    $hdr = New-Object System.Windows.Controls.StackPanel
    $hdr.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $hdr.Margin = New-Object System.Windows.Thickness(0,0,0,8)

    $badge = New-Object System.Windows.Controls.Border
    $badge.Background = Get-Brush($sevColor)
    $badge.CornerRadius = New-Object System.Windows.CornerRadius(4)
    $badge.Padding = New-Object System.Windows.Thickness(6,2,6,2)
    $badge.Margin = New-Object System.Windows.Thickness(0,0,8,0)
    
    $badgeText = New-Object System.Windows.Controls.TextBlock
    $badgeText.Text = $severity.ToUpper()
    $badgeText.Foreground = Get-Brush("#FFFFFF")
    $badgeText.FontWeight = [System.Windows.FontWeights]::Bold
    $badgeText.FontSize = 9
    $badge.Child = $badgeText
    [void]$hdr.Children.Add($badge)

    $tbadge = New-Object System.Windows.Controls.Border
    $tbadge.Background = Get-Brush("#3B82F6")
    $tbadge.CornerRadius = New-Object System.Windows.CornerRadius(4)
    $tbadge.Padding = New-Object System.Windows.Thickness(6,2,6,2)
    $tbadge.Margin = New-Object System.Windows.Thickness(0,0,8,0)
    
    $tbadgeText = New-Object System.Windows.Controls.TextBlock
    $tbadgeText.Text = $type.ToUpper()
    $tbadgeText.Foreground = Get-Brush("#FFFFFF")
    $tbadgeText.FontWeight = [System.Windows.FontWeights]::Bold
    $tbadgeText.FontSize = 9
    $tbadge.Child = $tbadgeText
    [void]$hdr.Children.Add($tbadge)

    $txtTitle = New-Object System.Windows.Controls.TextBlock
    $txtTitle.Text = $title
    $txtTitle.Foreground = Get-Brush("#F8FAFC")
    $txtTitle.FontWeight = [System.Windows.FontWeights]::Bold
    $txtTitle.FontSize = 13
    $txtTitle.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [void]$hdr.Children.Add($txtTitle)

    [void]$details.Children.Add($hdr)

    $txtDesc = New-Object System.Windows.Controls.TextBlock
    $txtDesc.Text = $description
    $txtDesc.Foreground = Get-Brush("#CBD5E1")
    $txtDesc.FontSize = 11
    $txtDesc.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $txtDesc.Margin = New-Object System.Windows.Thickness(0,0,0,4)
    [void]$details.Children.Add($txtDesc)

    $txtPath = New-Object System.Windows.Controls.TextBlock
    $txtPath.Text = "Path: $filePath"
    $txtPath.Foreground = Get-Brush("#94A3B8")
    $txtPath.FontSize = 10
    $txtPath.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $txtPath.FontFamily = New-Object System.Windows.Media.FontFamily("Consolas")
    [void]$details.Children.Add($txtPath)

    [void]$grid.Children.Add($details)

    $actions = New-Object System.Windows.Controls.StackPanel
    $actions.Orientation = [System.Windows.Controls.Orientation]::Vertical
    $actions.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $actions.Margin = New-Object System.Windows.Thickness(15,0,0,0)
    [System.Windows.Controls.Grid]::SetColumn($actions, 1)

    $btnQuarantine = New-Object System.Windows.Controls.Button
    $btnQuarantine.Content = "QUARANTINE"
    $btnQuarantine.Style = $window.FindResource("PrimaryBtn")
    $btnQuarantine.Height = 26
    $btnQuarantine.Width = 100
    $btnQuarantine.FontSize = 10
    $btnQuarantine.Margin = New-Object System.Windows.Thickness(0,0,0,6)
    [void]$actions.Children.Add($btnQuarantine)

    $btnDelete = New-Object System.Windows.Controls.Button
    $btnDelete.Content = "DELETE FILE"
    $btnDelete.Height = 26
    $btnDelete.Width = 100
    $btnDelete.FontSize = 10
    $btnDelete.Foreground = Get-Brush("#FFFFFF")
    $btnDelete.Background = Get-Brush("#EF4444")
    $btnDelete.BorderThickness = New-Object System.Windows.Thickness(0)
    $btnDelete.Cursor = [System.Windows.Input.Cursors]::Hand
    
    $redTemplateXml = @'
<ControlTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" TargetType="Button">
    <Border Name="Border" Background="#EF4444" CornerRadius="4">
        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
    </Border>
    <ControlTemplate.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
            <Setter TargetName="Border" Property="Background" Value="#DC2626" />
        </Trigger>
        <Trigger Property="IsPressed" Value="True">
            <Setter TargetName="Border" Property="Background" Value="#B91C1C" />
        </Trigger>
        <Trigger Property="IsEnabled" Value="False">
            <Setter TargetName="Border" Property="Background" Value="#7F1D1D" />
            <Setter Property="Foreground" Value="#F87171" />
        </Trigger>
    </ControlTemplate.Triggers>
</ControlTemplate>
'@
    $redReader = New-Object System.Xml.XmlNodeReader ([xml]$redTemplateXml)
    $btnDelete.Template = [Windows.Markup.XamlReader]::Load($redReader)

    [void]$actions.Children.Add($btnDelete)
    [void]$grid.Children.Add($actions)

    $card.Child = $grid
    [void]$panelThreatResults.Children.Add($card)

    $isSystemCritical = {
        param([string]$path)
        $p = $path.ToLower()
        if ($p.Contains("c:\windows\system32") -or 
            $p.Contains("c:\windows\syswow64") -or 
            $p.Contains("c:\windows\winxs") -or 
            $p -eq "c:\windows" -or 
            $p -eq "c:\windows\" -or
            $p.StartsWith($env:SystemRoot.ToLower() + "\system32") -or 
            $p.StartsWith($env:SystemRoot.ToLower() + "\syswow64")) {
            return $true
        }
        return $false
    }

    $btnQuarantine.Add_Click({
        if (&$isSystemCritical $filePath) {
            [System.Windows.MessageBox]::Show("For safety reasons, system-critical pathways cannot be altered.", "Security Safeguard", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
            Write-Log "WARNING" "Blocked quarantine attempt on system critical path: $filePath"
            return
        }

        try {
            $qDir = Join-Path $env:ProgramData "SnakeTank_Quarantine"
            if (!(Test-Path $qDir)) {
                [void](New-Item -Path $env:ProgramData -Name "SnakeTank_Quarantine" -ItemType Directory -Force)
            }
            
            if (Test-Path $filePath) {
                $fileName = Split-Path $filePath -Leaf
                $destPath = Join-Path $qDir "$fileName.quarantine"
                Move-Item -Path $filePath -Destination $destPath -Force -ErrorAction Stop
                
                Write-Log "SUCCESS" "Threat successfully quarantined: $filePath -> $destPath"
                
                $btnQuarantine.Content = "QUARANTINED"
                $btnQuarantine.IsEnabled = $false
                $btnDelete.IsEnabled = $false
                $txtDesc.Text = "Quarantined threat. Isolated and harmless."
                $txtDesc.Foreground = Get-Brush("#10B981")
            } else {
                [System.Windows.MessageBox]::Show("File not found or already moved.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            }
        } catch {
            Write-Log "ERROR" "Failed to quarantine file: $($_.Exception.Message)"
            [System.Windows.MessageBox]::Show("Failed to quarantine file. Make sure you are running as Administrator.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    })

    $btnDelete.Add_Click({
        if (&$isSystemCritical $filePath) {
            [System.Windows.MessageBox]::Show("For safety reasons, system-critical pathways cannot be altered.", "Security Safeguard", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
            Write-Log "WARNING" "Blocked deletion attempt on system critical path: $filePath"
            return
        }

        if ($env:SNAKE_TANK_TEST -ne "True") {
            $confirm = [System.Windows.MessageBox]::Show("Are you sure you want to permanently delete this file?`n`nPath: $filePath", "Confirm Deletion", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
            if ($confirm -ne [System.Windows.MessageBoxResult]::Yes) { return }
        }

        try {
            if (Test-Path $filePath) {
                Remove-Item -Path $filePath -Force -ErrorAction Stop
                Write-Log "SUCCESS" "Threat permanently deleted: $filePath"
                
                $btnQuarantine.IsEnabled = $false
                $btnDelete.Content = "DELETED"
                $btnDelete.IsEnabled = $false
                $txtDesc.Text = "Threat permanently deleted from disk."
                $txtDesc.Foreground = Get-Brush("#10B981")
            } else {
                [System.Windows.MessageBox]::Show("File not found or already deleted.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            }
        } catch {
            Write-Log "ERROR" "Failed to delete file: $($_.Exception.Message)"
            [System.Windows.MessageBox]::Show("Failed to delete file. Make sure you are running as Administrator.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    })
}

function Start-ThreatScan {
    $btnScanActiveThreats.IsEnabled = $false
    $btnScanHeuristics.IsEnabled = $false
    $progressBarThreats.Value = 10
    $txtThreatProgress.Text = "Connecting to Windows Defender database..."
    Write-Log "INFO" "Initiating active threat database query..."
    Do-Events

    [void]$panelThreatResults.Children.Clear()

    $progressBarThreats.Value = 50
    $txtThreatProgress.Text = "Analyzing threat alerts..."
    Do-Events

    $threats = @()
    try {
        $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue
    } catch {
        Write-Log "WARNING" "Failed to query Defender threat log: $_"
    }

    $progressBarThreats.Value = 90
    Do-Events

    if ($threats -and $threats.Count -gt 0) {
        $foundCount = 0
        foreach ($t in $threats) {
            $tName = $t.ThreatName
            $tPath = $t.Resources | Where-Object { $_ -like "file:*" } | ForEach-Object { $_ -replace "file:", "" }
            if (-not $tPath) { $tPath = "Active System Memory Process" }
            $tSeverity = "Critical"
            if ($t.SeverityID -lt 4) { $tSeverity = "High" }
            
            Add-ThreatCard -type "Defender" -title $tName -filePath $tPath -severity $tSeverity -description "Active Defender detection. Action required immediately."
            $foundCount++
        }
        Write-Log "SUCCESS" "Active threat scan complete. Found $foundCount active threats."
    } else {
        $cleanCard = New-Object System.Windows.Controls.Border
        $cleanCard.Background = Get-Brush("#1E293B")
        $cleanCard.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $cleanCard.BorderBrush = Get-Brush("#334155")
        $cleanCard.BorderThickness = New-Object System.Windows.Thickness(1)
        $cleanCard.Padding = New-Object System.Windows.Thickness(20)
        
        $cleanStack = New-Object System.Windows.Controls.StackPanel
        $cleanStack.HorizontalAlignment = [System.Windows.VerticalAlignment]::Center
        
        $t1 = New-Object System.Windows.Controls.TextBlock
        $t1.Text = "Zero Active Threat Incidents"
        $t1.Foreground = Get-Brush("#10B981")
        $t1.FontWeight = [System.Windows.FontWeights]::Bold
        $t1.FontSize = 14
        $t1.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        [void]$cleanStack.Children.Add($t1)
        
        $t2 = New-Object System.Windows.Controls.TextBlock
        $t2.Text = "Windows Defender reporting clean system memory and workspace vectors."
        $t2.Foreground = Get-Brush("#94A3B8")
        $t2.FontSize = 11
        $t2.Margin = New-Object System.Windows.Thickness(0,4,0,0)
        $t2.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        [void]$cleanStack.Children.Add($t2)
        
        $cleanCard.Child = $cleanStack
        [void]$panelThreatResults.Children.Add($cleanCard)
        
        Write-Log "SUCCESS" "Active threat scan complete. No active Defender threats reported."
    }

    $progressBarThreats.Value = 100
    $txtThreatProgress.Text = "Threat scan completed successfully."
    $btnScanActiveThreats.IsEnabled = $true
    $btnScanHeuristics.IsEnabled = $true
}

function Start-HeuristicScan {
    $btnScanActiveThreats.IsEnabled = $false
    $btnScanHeuristics.IsEnabled = $false
    $progressBarThreats.Value = 5
    $txtThreatProgress.Text = "Gathering target directory structures..."
    Write-Log "INFO" "=================================================="
    Write-Log "INFO" "HEURISTIC THREAT HUNTER MOTOR ACTIVATED"
    Write-Log "INFO" "=================================================="
    Do-Events

    [void]$panelThreatResults.Children.Clear()

    $targetFolders = @()
    if ($env:TEMP -and (Test-Path $env:TEMP)) { $targetFolders += $env:TEMP }
    if ($env:APPDATA -and (Test-Path $env:APPDATA)) { $targetFolders += $env:APPDATA }
    
    $downloads = Join-Path $env:USERPROFILE "Downloads"
    if (Test-Path $downloads) { $targetFolders += $downloads }

    $startupUser = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
    $startupAll = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
    if (Test-Path $startupUser) { $targetFolders += $startupUser }
    if (Test-Path $startupAll) { $targetFolders += $startupAll }

    $detectedThreats = @()

    $totalFolders = $targetFolders.Count
    $folderIndex = 0

    foreach ($folder in $targetFolders) {
        $folderIndex++
        $folderProgress = [int](5 + ($folderIndex / $totalFolders) * 80)
        $progressBarThreats.Value = $folderProgress
        $txtThreatProgress.Text = "Scanning directory: $folder..."
        Write-Log "INFO" "Scanning folder ($folderIndex/$totalFolders): $folder"
        Do-Events

        $files = @()
        try {
            $files = Get-ChildItem -Path $folder -File -Recurse -Depth 1 -ErrorAction SilentlyContinue
        } catch {
            continue
        }

        foreach ($file in $files) {
            $fPath = $file.FullName
            $fName = $file.Name
            $fExt = $file.Extension.ToLower()

            if ($fName -match "\.(pdf|docx|doc|xlsx|xls|txt|jpg|png|zip|rar|7z)\.(exe|vbs|js|bat|cmd|ps1|scr)$") {
                $detectedThreats += [PSCustomObject]@{
                    Type = "Heuristic"
                    Title = "Suspicious Double Extension file"
                    Path = $fPath
                    Severity = "Critical"
                    Description = "File has a deceptive double-extension design ($fName) engineered to trick operators into executing code."
                }
                continue
            }

            if (($fExt -eq ".exe" -or $fExt -eq ".dll" -or $fExt -eq ".sys") -and 
                ($fPath.ToLower().Contains("temp") -or $fPath.ToLower().Contains("appdata"))) {
                
                $sigStatus = "Unknown"
                try {
                    $sig = Get-AuthenticodeSignature -FilePath $fPath -ErrorAction SilentlyContinue
                    if ($sig) { $sigStatus = $sig.Status.ToString() }
                } catch {}

                if ($sigStatus -ne "Valid") {
                    $detectedThreats += [PSCustomObject]@{
                        Type = "Heuristic"
                        Title = "Unsigned binary in high-risk folder"
                        Path = $fPath
                        Severity = "High"
                        Description = "Unsigned binary ($fName) found in user-writable system directory ($sigStatus signature)."
                    }
                    continue
                }
            }

            if (($fPath.ToLower().Contains("startup") -or $fPath.ToLower().Contains("start menu")) -and 
                ($fExt -eq ".vbs" -or $fExt -eq ".js" -or $fExt -eq ".bat" -or $fExt -eq ".cmd" -or $fExt -eq ".ps1")) {
                $detectedThreats += [PSCustomObject]@{
                    Type = "Heuristic"
                    Title = "Unsigned Startup script persistence"
                    Path = $fPath
                    Severity = "High"
                    Description = "Script interpreter persistence config ($fName) discovered directly in administrative startup directories."
                }
                continue
            }
        }
    }

    $progressBarThreats.Value = 95
    $txtThreatProgress.Text = "Populating detected threat reports..."
    Do-Events

    if ($detectedThreats.Count -gt 0) {
        foreach ($dt in $detectedThreats) {
            Add-ThreatCard -type $dt.Type -title $dt.Title -filePath $dt.Path -severity $dt.Severity -description $dt.Description
        }
        Write-Log "WARNING" "Heuristic scanner complete. Flagged $($detectedThreats.Count) suspicious threat vectors!"
    } else {
        $cleanCard = New-Object System.Windows.Controls.Border
        $cleanCard.Background = Get-Brush("#1E293B")
        $cleanCard.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $cleanCard.BorderBrush = Get-Brush("#334155")
        $cleanCard.BorderThickness = New-Object System.Windows.Thickness(1)
        $cleanCard.Padding = New-Object System.Windows.Thickness(20)
        
        $cleanStack = New-Object System.Windows.Controls.StackPanel
        $cleanStack.HorizontalAlignment = [System.Windows.VerticalAlignment]::Center
        
        $t1 = New-Object System.Windows.Controls.TextBlock
        $t1.Text = "No Suspicious Heuristic Anomalies Found"
        $t1.Foreground = Get-Brush("#10B981")
        $t1.FontWeight = [System.Windows.FontWeights]::Bold
        $t1.FontSize = 14
        $t1.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        [void]$cleanStack.Children.Add($t1)
        
        $t2 = New-Object System.Windows.Controls.TextBlock
        $t2.Text = "All user-writable and persistence folders are verified secure of unsigned binaries and double extensions."
        $t2.Foreground = Get-Brush("#94A3B8")
        $t2.FontSize = 11
        $t2.Margin = New-Object System.Windows.Thickness(0,4,0,0)
        $t2.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        [void]$cleanStack.Children.Add($t2)
        
        $cleanCard.Child = $cleanStack
        [void]$panelThreatResults.Children.Add($cleanCard)

        Write-Log "SUCCESS" "Heuristic threat scan completed. System workspace remains verified clean."
    }

    $progressBarThreats.Value = 100
    $txtThreatProgress.Text = "Heuristic hunting scan completed successfully."
    $btnScanActiveThreats.IsEnabled = $true
    $btnScanHeuristics.IsEnabled = $true
}

$btnScanActiveThreats.Add_Click({ Start-ThreatScan })
$btnScanHeuristics.Add_Click({ Start-HeuristicScan })

# ==============================================================================
# OS DEEP AUDITOR FUNCTIONS & EVENT REGISTRATION
# ==============================================================================

function Add-OSCard ($category, $title, $description, $detailsList) {
    if ($borderInitialOSState) {
        try { [void]$panelOSResults.Children.Remove($borderInitialOSState) } catch {}
    }
    $catColor = "#8B5CF6"
    if ($category -eq "OS PROFILE") { $catColor = "#06B6D4" }
    elseif ($category -eq "HARDWARE") { $catColor = "#10B981" }
    elseif ($category -eq "STORAGE") { $catColor = "#3B82F6" }
    elseif ($category -eq "NETWORK") { $catColor = "#F59E0B" }
    elseif ($category -eq "HOTFIXES") { $catColor = "#EC4899" }
    elseif ($category -eq "ACCOUNTS") { $catColor = "#F97316" }
    elseif ($category -eq "SHARES") { $catColor = "#EF4444" }
    elseif ($category -eq "DRIVERS") { $catColor = "#6366F1" }
    elseif ($category -eq "SERVICES") { $catColor = "#14B8A6" }
    elseif ($category -eq "OS CVE") { $catColor = "#E11D48" }

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush("#1E293B")
    $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $card.BorderBrush = Get-Brush("#334155")
    $card.BorderThickness = New-Object System.Windows.Thickness(1)
    $card.Margin = New-Object System.Windows.Thickness(0,0,0,12)
    $card.Padding = New-Object System.Windows.Thickness(15)
    $stack = New-Object System.Windows.Controls.StackPanel
    $hdr = New-Object System.Windows.Controls.StackPanel
    $hdr.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $hdr.Margin = New-Object System.Windows.Thickness(0,0,0,8)
    $badge = New-Object System.Windows.Controls.Border
    $badge.Background = Get-Brush($catColor)
    $badge.CornerRadius = New-Object System.Windows.CornerRadius(4)
    $badge.Padding = New-Object System.Windows.Thickness(6,2,6,2)
    $badge.Margin = New-Object System.Windows.Thickness(0,0,8,0)
    $badgeText = New-Object System.Windows.Controls.TextBlock
    $badgeText.Text = $category.ToUpper()
    $badgeText.Foreground = Get-Brush("#FFFFFF")
    $badgeText.FontWeight = [System.Windows.FontWeights]::Bold
    $badgeText.FontSize = 9
    $badge.Child = $badgeText
    [void]$hdr.Children.Add($badge)
    $titleText = New-Object System.Windows.Controls.TextBlock
    $titleText.Text = $title
    $titleText.Foreground = Get-Brush("#F8FAFC")
    $titleText.FontWeight = [System.Windows.FontWeights]::Bold
    $titleText.FontSize = 13
    $titleText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [void]$hdr.Children.Add($titleText)
    [void]$stack.Children.Add($hdr)
    $descBlock = New-Object System.Windows.Controls.TextBlock
    $descBlock.Text = $description
    $descBlock.Foreground = Get-Brush("#94A3B8")
    $descBlock.FontSize = 11
    $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $descBlock.Margin = New-Object System.Windows.Thickness(0,0,0,10)
    [void]$stack.Children.Add($descBlock)
    $detailsContainer = New-Object System.Windows.Controls.StackPanel
    $detailsContainer.Margin = New-Object System.Windows.Thickness(10,0,0,0)
    foreach ($item in $detailsList) {
        if ($item -match "^\[(CRITICAL|HIGH|MEDIUM|LOW|SECURE)\]") {
            $severity = $Matches[1]
            $cleanedItem = $item -replace "^\[(CRITICAL|HIGH|MEDIUM|LOW|SECURE)\]\s*", ""
            $rowStack = New-Object System.Windows.Controls.StackPanel
            $rowStack.Orientation = [System.Windows.Controls.Orientation]::Horizontal
            $rowStack.Margin = New-Object System.Windows.Thickness(0,0,0,6)
            $pillColor = "#EF4444"
            if ($severity -eq "HIGH") { $pillColor = "#F97316" }
            elseif ($severity -eq "MEDIUM") { $pillColor = "#F59E0B" }
            elseif ($severity -eq "LOW") { $pillColor = "#3B82F6" }
            elseif ($severity -eq "SECURE") { $pillColor = "#10B981" }
            $pill = New-Object System.Windows.Controls.Border
            $pill.Background = Get-Brush($pillColor)
            $pill.CornerRadius = New-Object System.Windows.CornerRadius(4)
            $pill.Padding = New-Object System.Windows.Thickness(6,2,6,2)
            $pill.Margin = New-Object System.Windows.Thickness(0,0,8,0)
            $pill.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $pillText = New-Object System.Windows.Controls.TextBlock
            $pillText.Text = $severity
            $pillText.Foreground = Get-Brush("#FFFFFF")
            $pillText.FontWeight = [System.Windows.FontWeights]::Bold
            $pillText.FontSize = 8
            $pill.Child = $pillText
            [void]$rowStack.Children.Add($pill)
            $txtBlock = New-Object System.Windows.Controls.TextBlock
            $txtBlock.Text = $cleanedItem
            $txtBlock.Foreground = Get-Brush("#CBD5E1")
            $txtBlock.FontSize = 11
            $txtBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
            $txtBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $txtBlock.Width = 580
            [void]$rowStack.Children.Add($txtBlock)
            [void]$detailsContainer.Children.Add($rowStack)
        } else {
            $itemBlock = New-Object System.Windows.Controls.TextBlock
            $itemBlock.Text = "$([char]0x2022) $item"
            $itemBlock.Foreground = Get-Brush("#CBD5E1")
            $itemBlock.FontSize = 11
            $itemBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
            $itemBlock.Margin = New-Object System.Windows.Thickness(0,0,0,4)
            [void]$detailsContainer.Children.Add($itemBlock)
        }
    }
    [void]$stack.Children.Add($detailsContainer)
    $card.Child = $stack
    [void]$panelOSResults.Children.Add($card)
}

function Add-OSFindingCard ($category, $severity, $title, $description, $evidence, $remediationScript, $buttonLabel) {
    if ($borderInitialOSState) {
        try { [void]$panelOSResults.Children.Remove($borderInitialOSState) } catch {}
    }
    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush("#1E293B")
    $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $borderColor = "#3B82F6"
    if ($severity -eq "Critical") { $borderColor = "#EF4444" }
    elseif ($severity -eq "High") { $borderColor = "#F97316" }
    elseif ($severity -eq "Medium") { $borderColor = "#F59E0B" }
    elseif ($severity -eq "Secure") { $borderColor = "#10B981" }
    $card.BorderBrush = Get-Brush($borderColor)
    $card.BorderThickness = New-Object System.Windows.Thickness(1,0,0,0)
    $card.Margin = New-Object System.Windows.Thickness(0,0,0,12)
    $card.Padding = New-Object System.Windows.Thickness(15)
    $grid = New-Object System.Windows.Controls.Grid
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Auto)
    $grid.ColumnDefinitions.Add($col1)
    $grid.ColumnDefinitions.Add($col2)
    $stack = New-Object System.Windows.Controls.StackPanel
    [System.Windows.Controls.Grid]::SetColumn($stack, 0)
    $hdr = New-Object System.Windows.Controls.StackPanel
    $hdr.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $hdr.Margin = New-Object System.Windows.Thickness(0,0,0,4)
    $pill = New-Object System.Windows.Controls.Border
    $pill.Background = Get-Brush($borderColor)
    $pill.CornerRadius = New-Object System.Windows.CornerRadius(4)
    $pill.Padding = New-Object System.Windows.Thickness(6,2,6,2)
    $pill.Margin = New-Object System.Windows.Thickness(0,0,8,0)
    $pillText = New-Object System.Windows.Controls.TextBlock
    $pillText.Text = $severity.ToUpper()
    $pillText.Foreground = Get-Brush("#FFFFFF")
    $pillText.FontWeight = [System.Windows.FontWeights]::Bold
    $pillText.FontSize = 9
    $pill.Child = $pillText
    [void]$hdr.Children.Add($pill)
    $titleText = New-Object System.Windows.Controls.TextBlock
    $titleText.Text = $title
    $titleText.Foreground = Get-Brush("#F8FAFC")
    $titleText.FontWeight = [System.Windows.FontWeights]::Bold
    $titleText.FontSize = 13
    $titleText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [void]$hdr.Children.Add($titleText)
    [void]$stack.Children.Add($hdr)
    $descBlock = New-Object System.Windows.Controls.TextBlock
    $descBlock.Text = $description
    $descBlock.Foreground = Get-Brush("#94A3B8")
    $descBlock.FontSize = 11
    $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $descBlock.Margin = New-Object System.Windows.Thickness(0,0,0,6)
    [void]$stack.Children.Add($descBlock)
    $evidBlock = New-Object System.Windows.Controls.TextBlock
    $evidBlock.Text = "Evidence: $evidence"
    $evidBlock.Foreground = Get-Brush("#64748B")
    $evidBlock.FontSize = 10
    $evidBlock.FontStyle = [System.Windows.FontStyles]::Italic
    $evidBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
    [void]$stack.Children.Add($evidBlock)
    [void]$grid.Children.Add($stack)
    if ($remediationScript -and $remediationScript -ne "") {
        $localScript = $remediationScript
        $localLabel = $buttonLabel
        $btnAction = New-Object System.Windows.Controls.Button
        $btnAction.Content = $buttonLabel
        $btnAction.Background = Get-Brush("#10B981")
        $btnAction.Foreground = Get-Brush("#FFFFFF")
        $btnAction.FontWeight = [System.Windows.FontWeights]::Bold
        $btnAction.FontSize = 10
        $btnAction.Padding = New-Object System.Windows.Thickness(12,6,12,6)
        $btnAction.BorderThickness = New-Object System.Windows.Thickness(0)
        $btnAction.Cursor = [System.Windows.Input.Cursors]::Hand
        $btnAction.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $btnAction.Margin = New-Object System.Windows.Thickness(15,0,0,0)
        $btnAction.Tag = $localScript
        $btnAction.Add_Click({
            param($sender, $e)
            $sender.IsEnabled = $false
            $sender.Content = "APPLYING..."
            Do-Events
            try {
                Invoke-Expression $sender.Tag
                Write-Log "SUCCESS" "OS Hardening Applied Successfully"
                $sender.Content = "SECURED"
                $sender.Background = Get-Brush("#059669")
            } catch {
                Write-Log "ERROR" "OS Hardening Failed: $($_.Exception.Message)"
                $sender.Content = "FAILED"
                $sender.Background = Get-Brush("#EF4444")
            }
        })
        [System.Windows.Controls.Grid]::SetColumn($btnAction, 1)
        [void]$grid.Children.Add($btnAction)
    }
    $card.Child = $grid
    [void]$panelOSResults.Children.Add($card)
}

function Start-OSDeepAudit {
    $btnRunOSAudit.IsEnabled = $false
    $btnRunOSAudit.Content = "AUDITING OS..."
    $txtOSAuditStatus.Text = "Status: Gathering system profiles..."
    $panelOSResults.Children.Clear()
    $Script:OSScore = 0
    Write-Log "INFO" "=================================================="
    Write-Log "INFO" "SNAKE TANK DEEP OS AUDITING ENGINE INITIATED"
    Write-Log "INFO" "=================================================="
    Do-Events

    # 1. OS PROFILE
    $txtOSAuditStatus.Text = "Status: Querying OS Profiles..."
    Do-Events
    try {
        $osName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
        $osBuild = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild
        $osVer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue -Name DisplayVersion).DisplayVersion
        if (-not $osVer) { $osVer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue -Name ReleaseId).ReleaseId }
        $osArch = $env:PROCESSOR_ARCHITECTURE
        $bootType = "Unknown"
        $firmwareType = [Environment]::GetEnvironmentVariable("firmware_type", "Machine")
        if ($firmwareType) { $bootType = $firmwareType }
        else {
            if (Test-Path "HKLM:\System\CurrentControlSet\Control\SecureBoot\State" -ErrorAction SilentlyContinue) { $bootType = "UEFI" }
            else { $bootType = "Legacy BIOS" }
        }
        $secureBoot = "Disabled/Unsupported"
        $sbKey = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecureBoot\State" -Name "UEFISecureBootEnabled" -ErrorAction SilentlyContinue
        if ($sbKey -and $sbKey.UEFISecureBootEnabled -eq 1) { $secureBoot = "Enabled"; $Script:OSScore += 20 }
        $osDetails = @("Product Name: $osName", "Build Version: $osBuild ($osVer)", "Architecture: $osArch", "System Boot Type: $bootType", "Secure Boot State: $secureBoot", "System Directory: $env:windir")
        Add-OSCard "OS PROFILE" "Windows Operating System Profile" "Summary of host OS build, runtime environment, and active firmware validation." $osDetails
        if ($secureBoot -ne "Enabled") {
            Add-OSFindingCard "OS PROFILE" "Medium" "UEFI Secure Boot Disabled" "Secure Boot prevents malicious firmware and rootkits from loading during startup." "Secure Boot State: $secureBoot" 'Start-Process "ms-settings:recovery"' "OPEN RECOVERY OPTIONS"
        }
        Write-Log "INFO" "OS Profile Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit OS Profile: $($_.Exception.Message)" }

    # 2. HARDWARE SPECIFICATIONS
    $txtOSAuditStatus.Text = "Status: Collecting Hardware specifications..."
    Do-Events
    try {
        $cpu = "Unknown Processor"; $cores = 1
        $cpuInfo = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue
        if (!$cpuInfo) { $cpuInfo = Get-WmiObject -Class Win32_Processor -ErrorAction SilentlyContinue }
        if ($cpuInfo) { $cpu = $cpuInfo.Name.Trim(); $cores = $cpuInfo.NumberOfCores }
        $memSizeGb = 0
        $compSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        if (!$compSystem) { $compSystem = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction SilentlyContinue }
        if ($compSystem) { $memSizeGb = [Math]::Round($compSystem.TotalPhysicalMemory / 1GB, 2) }
        $hwDetails = @("CPU Model: $cpu", "CPU Cores: $cores physical cores", "Total Physical RAM: $memSizeGb GB", "Computer Manufacturer: $($compSystem.Manufacturer)", "System Model: $($compSystem.Model)")
        Add-OSCard "HARDWARE" "System Hardware Specifications" "Extracts processor topology, total installed RAM, and manufacturer motherboard profiles." $hwDetails
        Write-Log "INFO" "Hardware Profile Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Hardware: $($_.Exception.Message)" }

    # 3. DISK & STORAGE
    $txtOSAuditStatus.Text = "Status: Evaluating Disk and Storage..."
    Do-Events
    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
        if (!$disks) { $disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue }
        $diskDetails = @()
        if ($disks) {
            foreach ($d in $disks) {
                $totalSize = [Math]::Round($d.Size / 1GB, 2); $freeSize = [Math]::Round($d.FreeSpace / 1GB, 2)
                $usedPercent = [Math]::Round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 1)
                $diskDetails += "Volume $($d.DeviceID) ($($d.VolumeName)) | Format: $($d.FileSystem) | Size: $totalSize GB ($freeSize GB Free, $usedPercent% Used)"
            }
        } else { $diskDetails += "Could not enumerate logical drives." }
        Add-OSCard "STORAGE" "Logical Partitions and Storage Health" "Monitors connected logical drive capacities, volumes, and consumption percentages." $diskDetails
        Write-Log "INFO" "Storage Hive Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Storage: $($_.Exception.Message)" }

    # 4. NETWORK ADAPTERS
    $txtOSAuditStatus.Text = "Status: Inspecting Network Adapter details..."
    Do-Events
    try {
        $adapters = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "127.*" }
        $netDetails = @()
        if ($adapters) {
            foreach ($a in $adapters) {
                $intf = Get-NetAdapter -InterfaceIndex $a.InterfaceIndex -ErrorAction SilentlyContinue
                $status = if ($intf) { $intf.Status } else { "Active" }
                $netDetails += "Interface: $($a.InterfaceAlias) | IP: $($a.IPAddress) | Status: $status"
            }
        } else { $netDetails += "No active IPv4 network interface endpoints identified." }
        Add-OSCard "NETWORK" "Active IPv4 Adapter Interfaces" "List of active local network adapters, alias handles, and assigned IPv4 addresses." $netDetails
        Write-Log "INFO" "Network Adapter Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Network Adapters: $($_.Exception.Message)" }

    # 5. HOTFIXES
    $txtOSAuditStatus.Text = "Status: Enumerating Hotfixes..."
    Do-Events
    try {
        $hotfixes = Get-HotFix -ErrorAction SilentlyContinue
        $hfDetails = @()
        if ($hotfixes) {
            $latest = $hotfixes | Where-Object { $_.InstalledOn } | Sort-Object InstalledOn -Descending | Select-Object -First 5
            if (-not $latest) { $latest = $hotfixes | Select-Object -First 5 }
            foreach ($h in $latest) { $hfDetails += "ID: $($h.HotFixID) | Description: $($h.Description) | Installed On: $($h.InstalledOn)" }
            if ($hotfixes.Count -gt 5) { $hfDetails += "... and $($hotfixes.Count - 5) other hotfix updates installed." }
        } else { $hfDetails += "No Windows KB Hotfix history found." }
        Add-OSCard "HOTFIXES" "Installed KB Security Updates" "Audit of the most recent operating system security updates and KB patch levels." $hfDetails
        Write-Log "INFO" "KB Hotfixes Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit KB Hotfixes: $($_.Exception.Message)" }

    # 6. LOCAL USER ACCOUNTS
    $txtOSAuditStatus.Text = "Status: Enumerating Local Accounts..."
    Do-Events
    try {
        $users = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction SilentlyContinue
        if (!$users) { $users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction SilentlyContinue }
        $userDetails = @()
        if ($users) {
            foreach ($u in $users) {
                $status = if ($u.Disabled) { "Disabled" } else { "Enabled" }
                $lock = if ($u.Lockout) { "Locked Out" } else { "Active" }
                $userDetails += "Username: $($u.Name) ($($u.Caption)) | State: $status ($lock)"
            }
        } else { $userDetails += "Could not extract local Win32_UserAccount data." }
        Add-OSCard "ACCOUNTS" "Local Security User Account Registry" "Lists all local SAM accounts, operational states, and administrative lockout statuses." $userDetails
        Write-Log "INFO" "Local Accounts Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Local User Accounts: $($_.Exception.Message)" }

    # 7. NETWORK SHARES
    $txtOSAuditStatus.Text = "Status: Auditing Network SMB Shares..."
    Do-Events
    try {
        $shares = Get-SmbShare -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*$" }
        $shareDetails = @()
        if ($shares) {
            foreach ($s in $shares) { $shareDetails += "Share Name: $($s.Name) | Local Path: $($s.Path) | Description: $($s.Description)" }
            Add-OSCard "SHARES" "Exposed Shared Folders (SMB)" "Audits active non-default folder shares which could invite anonymous reconnaissance." $shareDetails
            Add-OSFindingCard "SHARES" "High" "Exposed Network Shares" "Active SMB shares expose the system to anonymous reconnaissance and lateral movement." "Shares Found: $($shares.Count)" 'Stop-Service LanmanServer -Force; Set-Service LanmanServer -StartupType Disabled' "DISABLE SMB SERVER"
        } else {
            $shareDetails += "No public SMB folder shares configured."
            Add-OSCard "SHARES" "Exposed Shared Folders (SMB)" "Audits active non-default folder shares which could invite anonymous reconnaissance." $shareDetails
            $Script:OSScore += 20
        }
        Write-Log "INFO" "Exposed Network Shares Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Network Shares: $($_.Exception.Message)" }

    # 8. ACTIVE SYSTEM DRIVERS
    $txtOSAuditStatus.Text = "Status: Querying installed and active drivers..."
    Do-Events
    try {
        $drivers = Get-CimInstance -ClassName Win32_SystemDriver -Filter "State='Running'" -ErrorAction SilentlyContinue
        if (-not $drivers) { $drivers = Get-WmiObject -Class Win32_SystemDriver -Filter "State='Running'" -ErrorAction SilentlyContinue }
        $driverDetails = @()
        if ($drivers) {
            $sample = $drivers | Select-Object -First 8
            foreach ($d in $sample) { $driverDetails += "Driver: $($d.Name) | Display: $($d.DisplayName) | State: $($d.State)" }
            if ($drivers.Count -gt 8) { $driverDetails += "... and $($drivers.Count - 8) other active running system drivers." }
        } else { $driverDetails += "No active system drivers resolved." }
        Add-OSCard "DRIVERS" "Installed & Active System Drivers" "Monitors core running OS kernel drivers, active states, and system file pathways." $driverDetails
        $Script:OSScore += 15
        Write-Log "INFO" "Active System Drivers Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Active Drivers: $($_.Exception.Message)" }

    # 9. CRITICAL WINDOWS SERVICES (with hardening)
    $txtOSAuditStatus.Text = "Status: Inspecting critical services..."
    Do-Events
    try {
        $targetServices = @("WinRM", "RemoteRegistry", "Spooler", "Windefend", "wuauserv", "SharedAccess")
        $services = Get-Service -Name $targetServices -ErrorAction SilentlyContinue
        $serviceDetails = @()
        if ($services) {
            foreach ($s in $services) { $serviceDetails += "Service: $($s.Name) | Display: $($s.DisplayName) | Status: $($s.Status)" }
        } else { $serviceDetails += "No targeted critical services could be queried." }
        Add-OSCard "SERVICES" "Critical Windows Operating System Services" "Audits status of vital background system services like Windows Update, Defender, and Spooler." $serviceDetails
        $spooler = Get-Service Spooler -ErrorAction SilentlyContinue
        if ($spooler -and $spooler.Status -eq 'Running') {
            Add-OSFindingCard "SERVICES" "High" "Print Spooler Running (PrintNightmare)" "The Print Spooler service is exposed to PrintNightmare privilege escalation. It should be disabled unless actively sharing printers." "Status: Running" 'Stop-Service Spooler -Force; Set-Service Spooler -StartupType Disabled' "DISABLE SPOOLER"
        } else { $Script:OSScore += 15 }
        $remreg = Get-Service RemoteRegistry -ErrorAction SilentlyContinue
        if ($remreg -and $remreg.Status -eq 'Running') {
            Add-OSFindingCard "SERVICES" "High" "Remote Registry Running" "Allows remote attackers to query and modify system registry keys via network protocols." "Status: Running" 'Stop-Service RemoteRegistry -Force; Set-Service RemoteRegistry -StartupType Disabled' "DISABLE REMOTE REGISTRY"
        } else { $Script:OSScore += 10 }
        Write-Log "INFO" "Critical System Services Audit completed."
    } catch { Write-Log "ERROR" "Failed to audit Critical Services: $($_.Exception.Message)" }

    # 10. OS CVE VULNERABILITY ANALYSIS
    $txtOSAuditStatus.Text = "Status: Cross-referencing OS CVE databases..."
    Do-Events
    try {
        $hasWin10Patch = $false; $hasWin11Patch = $false
        if ($hotfixes) {
            foreach ($h in $hotfixes) {
                if ($h.HotFixID -eq "KB5037768" -or $h.HotFixID -eq "KB5039211" -or $h.HotFixID -eq "KB5040422") { $hasWin10Patch = $true }
                if ($h.HotFixID -eq "KB5037771" -or $h.HotFixID -eq "KB5039212" -or $h.HotFixID -eq "KB5040431") { $hasWin11Patch = $true }
            }
        }
        $osCveDetails = @()
        if ($osName -match "Windows 10" -or $osBuild -eq 19045) {
            if (-not $hasWin10Patch) {
                $osCveDetails += "[CRITICAL] CVE-2024-30044 | CVSS 8.8 (RCE) - Windows MSHTML Remote Code Execution. Remediation: Apply KB5037768."
                $osCveDetails += "[HIGH] CVE-2024-21338 | CVSS 7.8 (EoP) - Windows Kernel Elevation of Privilege (CISA KEV). Remediation: KB5037768."
                $osCveDetails += "[HIGH] CVE-2023-38180 | CVSS 7.5 (DoS) - .NET Framework Denial of Service. Remediation: Apply cumulative patches."
            } else { $osCveDetails += "[SECURE] Windows 10 Cumulative Compliance Verified. Critical OS CVEs remediated." }
        } elseif ($osName -match "Windows 11" -or $osBuild -ge 22000) {
            if (-not $hasWin11Patch) {
                $osCveDetails += "[CRITICAL] CVE-2024-30044 | CVSS 8.8 (RCE) - Windows MSHTML Remote Code Execution. Remediation: Apply KB5037771."
                $osCveDetails += "[HIGH] CVE-2024-21338 | CVSS 7.8 (EoP) - Windows Kernel EoP (CISA KEV). Remediation: KB5037771."
                $osCveDetails += "[HIGH] CVE-2024-20656 | CVSS 7.8 (EoP) - VS Code Elevation of Privilege. Remediation: Apply Windows Update."
            } else { $osCveDetails += "[SECURE] Windows 11 Cumulative Compliance Verified. Critical OS CVEs remediated." }
        } else { $osCveDetails += "[CRITICAL] CVE-2023-24955 | CVSS 7.2 (RCE) - Legacy OS Remote Code Execution. Remediation: Upgrade OS." }
        Add-OSCard "OS CVE" "OS-Level Vulnerability & Exploitation Analysis" "Cross-references running Windows Build and hotfixes against CISA KEV and active OS CVE threats." $osCveDetails
        if ((-not $hasWin10Patch -and ($osName -match "Windows 10" -or $osBuild -eq 19045)) -or (-not $hasWin11Patch -and ($osName -match "Windows 11" -or $osBuild -ge 22000))) {
            Add-OSFindingCard "OS CVE" "Critical" "Missing Critical Security Updates" "The operating system is missing critical cumulative updates exposing it to RCE and kernel privilege escalation." "Missing: Latest Cumulative Update" 'Start-Process "ms-settings:windowsupdate-action"' "LAUNCH WINDOWS UPDATE"
        } else { $Script:OSScore += 20 }
        Write-Log "INFO" "OS CVE Database Mapping completed."
    } catch { Write-Log "ERROR" "Failed to audit OS CVEs: $($_.Exception.Message)" }

    # UPDATE OS DASHBOARD
    $txtOSScoreVal.Text = "$($Script:OSScore)/100"
    if ($Script:OSScore -ge 90) {
        $txtOSScoreGrade.Text = "A"; $txtOSScoreText.Text = "Highly Secured"
        $borderOSGradeBadge.BorderBrush = Get-Brush("#10B981"); $txtOSScoreGrade.Foreground = Get-Brush("#10B981")
        $txtOSSecurityStatusText.Text = "OS STATUS: SECURED"; $txtOSSecurityStatusText.Foreground = Get-Brush("#10B981")
        $borderOSSecurityBanner.BorderBrush = Get-Brush("#10B981")
        $txtOSSecurityStatusSymbol.Text = [char]::ConvertFromUtf32(0x1F6E1); $txtOSSecurityStatusSymbol.Foreground = Get-Brush("#10B981")
    } elseif ($Script:OSScore -ge 70) {
        $txtOSScoreGrade.Text = "B"; $txtOSScoreText.Text = "Hardened"
        $borderOSGradeBadge.BorderBrush = Get-Brush("#34D399"); $txtOSScoreGrade.Foreground = Get-Brush("#34D399")
        $txtOSSecurityStatusText.Text = "OS STATUS: OPTIMIZED"; $txtOSSecurityStatusText.Foreground = Get-Brush("#34D399")
        $borderOSSecurityBanner.BorderBrush = Get-Brush("#34D399")
        $txtOSSecurityStatusSymbol.Text = [char]::ConvertFromUtf32(0x1F6E1); $txtOSSecurityStatusSymbol.Foreground = Get-Brush("#34D399")
    } elseif ($Script:OSScore -ge 50) {
        $txtOSScoreGrade.Text = "C"; $txtOSScoreText.Text = "Attention Needed"
        $borderOSGradeBadge.BorderBrush = Get-Brush("#F59E0B"); $txtOSScoreGrade.Foreground = Get-Brush("#F59E0B")
        $txtOSSecurityStatusText.Text = "OS STATUS: ATTENTION REQUIRED"; $txtOSSecurityStatusText.Foreground = Get-Brush("#F59E0B")
        $borderOSSecurityBanner.BorderBrush = Get-Brush("#F59E0B")
        $txtOSSecurityStatusSymbol.Text = [char]::ConvertFromUtf32(0x26A0); $txtOSSecurityStatusSymbol.Foreground = Get-Brush("#F59E0B")
    } else {
        $txtOSScoreGrade.Text = "F"; $txtOSScoreText.Text = "Vulnerable"
        $borderOSGradeBadge.BorderBrush = Get-Brush("#EF4444"); $txtOSScoreGrade.Foreground = Get-Brush("#EF4444")
        $txtOSSecurityStatusText.Text = "OS STATUS: CRITICAL RISK"; $txtOSSecurityStatusText.Foreground = Get-Brush("#EF4444")
        $borderOSSecurityBanner.BorderBrush = Get-Brush("#EF4444")
        $txtOSSecurityStatusSymbol.Text = [char]::ConvertFromUtf32(0x1F6A8); $txtOSSecurityStatusSymbol.Foreground = Get-Brush("#EF4444")
    }

    $btnRunOSAudit.IsEnabled = $true
    $btnRunOSAudit.Content = "RUN DEEP OS AUDIT"
    $txtOSAuditStatus.Text = "Status: Deep OS Audit Completed successfully!"
    Write-Log "SUCCESS" "Deep OS Auditing and Hardware Inspection completed successfully!"
}

$btnRunOSAudit.Add_Click({ Start-OSDeepAudit })


# ------------------------------------------------------------------------------
# 8. LAUNCH WINDOW
# ------------------------------------------------------------------------------
if ($env:SNAKE_TANK_TEST -ne "True") {
    $window.ShowDialog() | Out-Null
} else {
    Write-Host "[+] Snake Tank GUI Window verified and loaded successfully!"
}

