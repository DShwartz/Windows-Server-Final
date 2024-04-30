#Requires -RunAsAdministrator

# Import the Active Directory module
Import-Module ActiveDirectory

# Set Path variable for commands
$path = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName

# Make OUs
echo "Creating OUs..."
New-ADOrganizationalUnit -Name "WhiteWater OU" -Path $Path

# Set new path variable for commands
$path = "ou=WhiteWater OU,$path"
New-ADOrganizationalUnit -Name "Groups" -Path $Path
New-ADOrganizationalUnit -Name "Users" -Path $Path

# Set variables for groups and users later on
$GroupPath = "ou=Groups,$path"
$UserPath = "ou=Users,$path"


# Create groups
echo "Creating groups..."
$ADGroups = Import-Csv -Path ".\groups.csv"

foreach ($group in $ADGroups) {
    $groupTable = @{
        Name = $group.Name
        Path = $GroupPath
        Scope = Global
        Category = Security
        Description = $group.Description
    }

    New-ADGroup @groupTable
}



# Create users
echo "Creating users..."

# import CSV
$ADUsers = Import-Csv -Path ".\users.csv" -Delimiter ","



echo "Done!"

# Delete everything if the user wants
$delete = read-host "Should I delete the OUs? [Y/n]"
if ($delete -eq 'n') {
    exit
} else { 
    Get-ADObject -Filter * -SearchBase $path | ForEach-Object -Process {
        Set-AdObject -ProtectedFromAccidentalDeletion $false -Identity $_
    }
    Remove-ADOrganizationalUnit -Identity $path -Recursive
    echo "Deletion finished!"
}