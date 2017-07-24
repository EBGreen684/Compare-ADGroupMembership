
function Compare-ADGroupMembership{
     <#
    .SYNOPSIS
    Takes a reference group name and compares the members of that group to the members of another group or groups.
    It returns a unique list of user IDs (SamAccountName) for any users that are in the reference group and any of the other 
    groups.
    .DESCRIPTION
    The function expects group names not AD group objects. It returns SamAccountNames in no specific order.
    Author - Rob Dowell
    Revision History
    2017-07-24 - RMD - Initial Version

    TODO:
    - Right now it is not super efficient since it continues to check groups even after it finds a match for a given user. 
      In general usage this probably wouldn't be a problem but it should be addressed at some point.
    - If it is deemed to be worth the effort I can change it to return actual AD objects.
    .EXAMPLE
    Compare-ADGroupMembership -referenceGroupName 'Group1' -differenceGroupName 'Group2'
    This would compare these two groups and return the SamAccountName of any users that are in both groups.
    .EXAMPLE
    Compare-ADGroupMembership -referenceGroupName 'Group1' -differenceGroupName @('Group2', 'Group3')
    This would compare the mebers of Group1 to the members of Group 2 and Group 3. It would return the SamAccountNames of any
    users that are in Group1 AND also in Group 2 OR Group3.
    .PARAMETER ReferenceGroupName
    The name of the reference group that lists all the members to look for in the other groups.
    .PARAMETER DifferenceGroupName
    The name(s) of the other group(s) to check for users that are in the reference group.
    #>
    param(
        $referenceGroupName,
        $differenceGroupName
    )

    $diffGroups = @{}
    foreach($name in $differenceGroupName){
        $diffGroups.$name = @(Get-ADGroupMember $name | Select -expand SamAccountName)
    }
    $res = @()
    foreach($user in (Get-AdgroupMember $referenceGroupName)){
        foreach($name in $differenceGroupName){
            if($diffGroups.$name.Contains($user.SamAccountName)){
                $res += $user.SamAccountName
            }
        }
    }
    $res = $res | Select -Unique
    return $res
}
