#Script imports csv data
#operates on it with psql
#sends raport via email
#11.12.2021

$TIMESTAMP = Get-Date -Format "MMddyyyy"
$TIMESTAMP_ext = Get-Date -Format "MMddyyyyhhmmss"
$INDEX = "305769"
$downfileadd = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"
$password = '6177d16e5ea1e0'
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("fde052434aa9a6", $secpasswd)
$wd = "C:\Spatial-DataBases\test\"
$LogFile = "${wd}PROCESSED\skrypt1_305769.log"
$psql = 'postgresql://postgres:postgres@localhost:5432/powershell'

#Download file
Invoke-WebRequest -Uri $downfileadd -OutFile "${wd}Customers_Nov2021.zip"

#Unzip
$7ZipPath = '"C:\Program Files\7-Zip\7z.exe"'
$zipFile = '"${wd}Customers_Nov2021.zip"'
$zipFilePassword = "agh"
$command = "& $7ZipPath e -o${wd} -y -tzip -p$zipFilePassword $zipFile"
iex $command

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Unziping succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Unziping failed"
}

#Import file
$Nov2021Arr = Import-Csv -Path "${wd}Customers_Nov2021.csv"
$OldArr = Import-Csv -Path "${wd}Customers_old.csv"

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Import-csv succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Import-csv failed"
}

#Check file
$Arr = @()
$flag = $true
$dupcnt = 0
foreach ($i in $Nov2021Arr)
{
    foreach ($j in $OldArr)
    {
        if($i.first_name -eq $j.first_name -and $i.last_name -eq $j.last_name)
        {
           Add-Content '${wd}Customers_Nov2021.bad_${TIMESTAMP}.txt' $i
           $flag = $false
           $dupcnt += 1
        }
    }
    if($flag)
    {
        $Arr += $i
    }
    $flag = $true
}

#Install postgis
"CREATE EXTENSION IF NOT EXISTS postgis;" | psql $psql

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Create Extension succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Create Extension failed"
}

#Create psql table
"CREATE TABLE IF NOT EXISTS CUSTOMERS_305769 (first_name varchar(100), last_name varchar(100), email varchar(100), geom geometry(Point) );" | psql $psql

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Create Table succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Create Table failed"
}

#insert into table
foreach($customer in $Arr)
{
    $first_name = $customer.first_name
    $last_name = $customer.last_name
    $email = $customer.email
    $lat = $customer.lat
    $long = $customer.long
    "INSERT INTO CUSTOMERS_305769 VALUES ('${first_name}', '${last_name}', '${email}', ST_MakePoint(${lat}, ${long}));" | psql $psql
}

#Copyfile with prefix to subfolder
$CsvArr="COPY CUSTOMERS_305769 TO STDOUT WITH (FORMAT CSV, HEADER);" | psql $psql
$CsvArr | Out-File  -FilePath "${wd}PROCESSED\${TIMESTAMP}_CUSTOMERS_305769.csv"

#Prepare email's body
[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "${wd}PROCESSED\${TIMESTAMP}_CUSTOMERS_305769.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }

$cnt = $Arr.Count
$tabcnt = $cnt*4
$Body = "Liczba wierszy: ${LinesInFile}`nLiczba poprawnych wierszy: ${cnt}`nLiczba duplikatów: ${dupcnt}`nLiczba danych zaladowanych do tabeli: ${tabcnt}"

#Send email
Send-MailMessage -To “jon-snow@winterfell.com” -From “mother-of-dragons@houseoftargaryen.net”  -Subject “CUSTOMERS LOAD - ${TIMESTAMP}" -Body $Body -Credential $cred -UseSsl -SmtpServer “smtp.mailtrap.io” -Port 587

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Raport-send succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Raport-send failed"
}

#SQL Query
"SELECT first_name,last_name INTO BEST_CUSTOMERS_305769
FROM customers_305769 c
WHERE st_distancesphere(c.geom, ST_GeomFromText('POINT(41.39988501005976 -75.67329768604034)'))<50000;" | psql $psql

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Select succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Select failed"
}

#Export psql data into csv
$CsvArr="COPY BEST_CUSTOMERS_305769 TO STDOUT WITH (FORMAT CSV, HEADER);" | psql $psql

$CsvArr | Out-File  -FilePath "${wd}BEST_CUSTOMERS_305769.csv"

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Export-csv succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Export-csv failed"
}

#Zip file
Compress-Archive -Path '${wd}BEST_CUSTOMERS_305769.csv' -CompressionLevel Fastest -DestinationPath "${wd}BEST_CUSTOMERS_305769.zip"

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext Zip succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext Zip failed"
}

#Prepare email's body
[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "${wd}BEST_CUSTOMERS_305769.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }
 
$moddate = (Get-Item "${wd}BEST_CUSTOMERS_305769.csv").LastWriteTime

$Body = "Data ostatniej modyfikacji: ${moddate}`nLiczba wierszy: ${LinesInFile}"

#Send email with attachment
Send-MailMessage -To “jon-snow@winterfell.com” -From “mother-of-dragons@houseoftargaryen.net”  -Subject “ZIP FILE - ${TIMESTAMP}" -Body $Body -Credential $cred -UseSsl -SmtpServer “smtp.mailtrap.io” -Port 587 -Attachments '${wd}BEST_CUSTOMERS_305769.zip'

if($?)
{
   Add-Content $LogFile -Value "$TIMESTAMP_ext File-send succeeded"
}
else
{
    Add-Content $LogFile -Value "$TIMESTAMP_ext File-send failed"
}