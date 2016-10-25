function Test-VisualStudioTeamServicesBuildHostedAgent {
    $output=$false
    if($env:AGENT_ID)
    {
        $output=$env:AGENT_NAME -eq "Hosted Agent"
    }
    $output
}

Test-VisualStudioTeamServicesBuildHostedAgent