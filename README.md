# Sonar Scan GitHub Action

Using this GitHub Action, scan your code with SonarQube scanner to detects bugs, vulnerabilities and code smells, stopping the CI/CD process if the code doesn't pass the Quality Gate.

## Requirements

* Have SonarQube on server. [Install now](https://docs.sonarqube.org/latest/setup/install-server/) and find the setup instructions.

## Usage

In your workflow YAML file (located in `.github/workflows` directory) configure this action as shown below:

```yaml
on: push
name: <a name>
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: SonarQube Scan
      uses: Blue-Express/sonar-scan-action@master
      with:
        sonarqube_url: ${{ secrets.SONAR_HOST }}
        sonarqube_token: ${{ secrets.SONAR_TOKEN }}
        projectKey: my-project-key
```
Analysis base directory/project name/version can be changed with the optional inputs:

```yaml
uses: Blue-Express/sonar-scan-action@master
with:
  projectBaseDir: "/path/to/my-project"
  projectName: "my-project-name"
  projectVersion: "v1.0.1"
```

## Secrets

- `SONAR_HOST` - **_(Required)_** this is the SonarQube server URL.
- `SONAR_TOKEN` - **_(Required)_** the login or authentication token of a SonarQube user with Execute Analysis permission on the project. 
