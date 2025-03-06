# Variables
$VMName = "Ubuntu 22.04 LTS"
$COMPort = "COM3"
$PipeBaseName = "Ubuntu-$COMPort"
$PipeName = "\\.\pipe\$PipeBaseName"

# Check if the VM exists
if (Get-VM -Name $VMName) {

    # Remove existing COM port if present
    if(Get-VMComPort -VMName $VMName -Number 1){
        Set-VMComPort -VMName $VMName -Number 1 -Path $null
    }

    # Check if the pipe already exists
    if ([System.IO.Directory]::GetFiles("\\.\pipe\") -contains $PipeName) {
        Write-Warning "Named pipe '$PipeName' already exists. Attempting to remove."
        try {
            Remove-Item $PipeName -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to remove existing pipe: $($_.Exception.Message)"
            return
        }
    }

    # Create the named pipe
    try {
        [void][System.IO.Pipes.NamedPipeServerStream]::new($PipeName.Substring(2), [System.IO.Pipes.PipeDirection]::InOut)
    }
    catch {
        Write-Error "Failed to create named pipe: $($_.Exception.Message)"
        return
    }

    # Add the serial port to the VM
    try {
        Set-VMComPort -VMName $VMName -Number 1 -Path $PipeName
        Write-Host "Serial port added to VM '$VMName' using pipe '$PipeName'."
    }
    catch {
        Write-Error "Failed to add serial port to VM: $($_.Exception.Message)"
        Remove-Item $PipeName
        return
    }

    # Create background job to keep the pipe open
    $job = Start-Job -ScriptBlock {
        param($pipeName)
        try{
            $pipe = [System.IO.Pipes.NamedPipeServerStream]::new($pipeName.Substring(2), [System.IO.Pipes.PipeDirection]::InOut)
            $pipe.WaitForConnection()
            Write-Host "Pipe '$pipeName' connected."
            while ($pipe.IsConnected) {
                Start-Sleep -Seconds 1
            }
            Write-Host "Pipe '$pipeName' disconnected."
        }
        catch{
            Write-Error "Pipe job failed: $($_.Exception.Message)"
        }
        finally{
            if ($pipe -and $pipe.IsConnected){
                $pipe.Close()
            }
        }
    } -ArgumentList $PipeName

    Write-Host "Background job started to keep pipe open (Job ID: $($job.Id))."

} else {
    Write-Error "VM '$VMName' not found."
}