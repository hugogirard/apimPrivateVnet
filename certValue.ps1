param(
    [string]$certPath,
    [string]$certPassword
)

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$flag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable

$cert.Import($certPath, $certPassword, $flag)

$bin = $cert.RawData
$base64Value = [System.Convert]::ToBase64String($bin)

Write-Host $base64Value