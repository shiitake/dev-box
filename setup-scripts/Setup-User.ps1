param($username)

$password = "TempPass123!"

# Create new user
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
  	Write-Host "User: $username already exists"
} else {
	net user $username $password /add
	net user $username /logonpasswordchg:yes
	Write-Host "User: $username created.  Temporary password is $password"
}

# verify user is local admin
if ((Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue).Name -contains "$ENV:COMPUTERNAME\$username") {
	Write-Host "User: $username is already local admin"
} else {
	# Add new user to the Administrators group
	net localgroup Administrators $username /add
}