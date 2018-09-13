fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios pods
```
fastlane ios pods
```
Running Pods
### ios test
```
fastlane ios test
```
Runs all the tests
### ios pipeline_step_1
```
fastlane ios pipeline_step_1
```

### ios build_develop
```
fastlane ios build_develop
```
This lane will replace pipeline_step_1 for organization
### ios pipeline_step_2
```
fastlane ios pipeline_step_2
```

### ios build_dev
```
fastlane ios build_dev
```
bulding_development
### ios build_qa
```
fastlane ios build_qa
```
Building for QA
### ios build_automation
```
fastlane ios build_automation
```
Build Automation
### ios linter_validation
```
fastlane ios linter_validation
```
Running Lint Tool
### ios linter_autocorrect
```
fastlane ios linter_autocorrect
```
Running Lint Autocorrect
### ios code_coverage
```
fastlane ios code_coverage
```

### ios match_development
```
fastlane ios match_development
```
Running Match for development
### ios match_development_create
```
fastlane ios match_development_create
```
Running Match for development
### ios match_adhoc
```
fastlane ios match_adhoc
```
Running Match for staging
### ios match_automation
```
fastlane ios match_automation
```
Running Match for automation
### ios match_automation_create
```
fastlane ios match_automation_create
```
Running Match for automation
### ios match_adhoc_create
```
fastlane ios match_adhoc_create
```
Running Match for staging
### ios match_all
```
fastlane ios match_all
```
Running all Match
### ios match_all_create
```
fastlane ios match_all_create
```
Running all Match creating new profile
### ios bumpAndTagRelease
```
fastlane ios bumpAndTagRelease
```
Version Bumping!
### ios increment_build
```
fastlane ios increment_build
```
Incrementing Build
### ios upload_to_hockeyapp_qa
```
fastlane ios upload_to_hockeyapp_qa
```
Uploading to Hockey App for QA
### ios upload_to_hockeyapp_dev
```
fastlane ios upload_to_hockeyapp_dev
```
Uploading to Hockey App for DEV
### ios upload_to_hockeyapp_automation
```
fastlane ios upload_to_hockeyapp_automation
```
Uploading to Hockey App for Automation
### ios build_ops_develop
```
fastlane ios build_ops_develop
```
Lane used in OPS environment which build an IPA for OPS dev
### ios upload_to_hockeyapp_ops_dev
```
fastlane ios upload_to_hockeyapp_ops_dev
```
Lane used in OPS environment which deploys DEV to HockeyApp
### ios build_ops_qa
```
fastlane ios build_ops_qa
```
Lane used in OPS environment which build an IPA for OPS staging
### ios upload_to_hockeyapp_ops_qa
```
fastlane ios upload_to_hockeyapp_ops_qa
```
Lane used in OPS environment which deploys STAGING to HockeyApp
### ios build_ops_automation
```
fastlane ios build_ops_automation
```
Lane used in OPS environment which build an IPA for OPS Automation
### ios upload_to_hockeyapp_ops_automation
```
fastlane ios upload_to_hockeyapp_ops_automation
```
Lane used in OPS environment which deploys AUTOMATION to HockeyApp
### ios release
```
fastlane ios release
```
Deploy a new version to the App Store
### ios slack_prod_pending_approval
```
fastlane ios slack_prod_pending_approval
```
Lane used to inform in slack that there is a pending approval for production environment
### ios slack_ops_pending_approval
```
fastlane ios slack_ops_pending_approval
```
Lane used to inform in slack that there is a pending approval for OPS environment

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
