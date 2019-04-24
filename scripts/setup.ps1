function setup
{
	param([string]$version)

    $tmpDirRootPath = $version + '/tmp'

    # Copy the shared files to the target directory
    copy-item -Force -recurse shared "$tmpDirRootPath/shared"
    
    $dockerFileTemplatePath = '.\shared\Dockerfile'
    $dockerFileOutPath = "$version\Dockerfile"

    # Generate the Dockerfile from the template and place it in the target directory
    # Also, copy Tomcat version specific files to the target directory
    switch ($version)
    {
        'jre8-alpine'
        {
            $content = (Get-Content -path $dockerFileTemplatePath -Raw) `
                -replace '__PLACEHOLDER_BASEIMAGE__','mcr.microsoft.com/java/jre-headless:8u212-zulu-alpine-with-tools'
            break
        }

        'java11-alpine'
        {
            $content = (Get-Content -path $dockerFileTemplatePath -Raw) `
                -replace '__PLACEHOLDER_BASEIMAGE__','mcr.microsoft.com/java/jre-headless:11u2-zulu-alpine-with-tools'
            break
        }
    }
    $headerFooter = "########################################################`n### ***DO NOT EDIT*** This is an auto-generated file ###`n########################################################`n"
    $content = $headerFooter + $content + $headerFooter
    Set-Content -Value $content -Path $dockerFileOutPath
}

setup -version 'jre8-alpine'
setup -version 'java11-alpine'
