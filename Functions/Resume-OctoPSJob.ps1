function Resume-OctoPSJob {
     <#
    .SYNOPSIS
        Resume the current job on a OctoPrint server.
    .DESCRIPTION
        Resume the current job on a OctoPrint server.
    .EXAMPLE
        PS C:\> Resume-OctoPSJob -Id 1 -SkipCertificateCheck
        Resume the current print job on the OctoPrint server with Id 1
    .INPUTS
        Int32
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param (
        # Printer Host Id
        [Parameter(Mandatory=$false,
                   ParameterSetName = 'Index')]
        [int32[]]
        $Id = @(),

        # Skips certificate validation checks. This includes all validations such as expiration, revocation, trusted root authority, etc.
        [Parameter(Mandatory = $false)]
        [switch]
        $SkipCertificateCheck
    )

    begin {
        $commandBody = ConvertTo-Json -InputObject @{"command" = "pause"
                                                     "action" = "resume"}
    }

    process {
        if ($Id.count -gt 0) {
            $PHosts = Get-OctoPSHost -Id $Id
        }
        else {
            $PHosts = Get-OctoPSHost | Select-Object -First 1
        }
        foreach ($h in $PHosts) {
            $RestMethodParams = @{
                'Method'        = "Post"
                'ContentType'   = 'application/json'
                'Body'          = $commandBody
            }
            $RestMethodParams.Add('URI',"$($h.Uri)/api/job")
            $RestMethodParams.Add('Headers',@{'X-Api-Key' = $h.ApiKey})

            if ($SkipCertificateCheck)
            {
                $RestMethodParams.Add('SkipCertificateCheck', $SkipCertificateCheck)
            }
            Invoke-RestMethod @RestMethodParams | Out-Null
        }
    }

    end {
    }
}