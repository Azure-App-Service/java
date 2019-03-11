function setup
{
	param([string]$version)

    # Remove tmp directory
	$dirpath = $version + '/tmp/shared'
	If (Test-Path $dirpath)
	{
		remove-item -recurse -force $dirpath
	}

    # Copy the shared files to the target directory
    copy-item -recurse shared $dirpath
    
    $dockerFileTemplatePath = '.\shared\Dockerfile'
    $dockerFileOutPath = "$version\Dockerfile"

    # Generate the Dockerfile from the template and place it in the target directory
    # Also, copy Tomcat version specific files to the target directory
    switch ($version)
    {
        'jre8-alpine'
        {
            $content = (Get-Content -path $dockerFileTemplatePath -Raw) `
                -replace '__PLACEHOLDER_BASEIMAGE__','mcr.microsoft.com/java/jre-headless:8u202-zulu-alpine'
            break
        }

        'java11-alpine'
        {
            $content = (Get-Content -path $dockerFileTemplatePath -Raw) `
                -replace '__PLACEHOLDER_BASEIMAGE__','mcr.microsoft.com/java/jre-headless:11u2-zulu-alpine'
            break
        }
    }
    $headerFooter = "########################################################`n### ***DO NOT EDIT*** This is an auto-generated file ###`n########################################################`n"
    $content = $headerFooter + $content + $headerFooter
    Set-Content -Value $content -Path $dockerFileOutPath
}

setup -version 'jre8-alpine'
setup -version 'java11-alpine'
