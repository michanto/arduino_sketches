# Variables
$VMName = "Ubuntu 22.04 LTS"  # VM name with spaces
$COMPort = "COM3"       # Replace with the COM port you want to use
$PipeBaseName = "Ubuntu-$COMPort" # Base name for the pipe
$PipeName = "\\.\pipe\$PipeBaseName" # Full pipe name

# Check if the VM exists
if (Get-VM -Name $VMName) {

    # Check if a serial port already exists, and remove it if it does.
    if(Get-VMComPort -VMName $VMName -Number 1){
        Set-VMComPort -VMName $VMName -Number 1 -Path $null
    }

    # Create the named pipe
    try {
        # Create the named pipe
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
        # clean up the named pipe if adding the port fails.
        Remove-Item $PipeName
        return
    }

    # Create a background job to keep the pipe open
    $job = Start-Job -ScriptBlock {
        param($pipeName)
        try{
            $pipe = [System.IO.Pipes.NamedPipeServerStream]::new($pipeName.Substring(2), [System.IO.Pipes.PipeDirection]::InOut)
            $pipe.WaitForConnection()
            Write-Host "Pipe '$pipeName' connected."
            # The pipe will stay open until the VM disconnects or this job is stopped.
            while ($pipe.IsConnected) {
                Start-Sleep -Seconds 1 #Prevent high CPU usage
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