# USSF GRC Controls

### Heroku app link : [app link](https://csce606-ussf-d5f4faa6ca5f.herokuapp.com/)
### Code Climate : [View RubyCritic Report](https://aditya-s-gourishetty.github.io)
HTML link for codeclimate: [View RubyCritic Report](docs/rubycritic/index.html)
### Team Working Agreement : [Team Working Agreement](documentation/Fall2024/TeamWorkingAgreement.md)

### Instructions to run rspec and cucumber
- Do bundle install.
- Reach out to the team so that they can provide the master.key file with google developer secrets.
- Run rspec and cucumber.


Custom Buildpack for installing trivy : [GitHub](https://github.com/tamu-edu-students/buildpack-trivy) 

Buildpacks installs `trivy` for scanning container images in addition to depenedencies listed in Gemfile. [Documentation]()
### Start the deployment to heroku 

1. heroku login 
2. git init && git add . && git commit -m "initial commit"
3. heroku create <app-name>
4. heroku buildpacks:set heroku/ruby --index 1 <app-name>
5. heroku buildpacks:add https://github.com/tamu-edu-students/buildpack-trivy --index 2  -a <app-name>
6. git push heroku master

## updates tp application 

1. verify heroku - git remote -v 
2. git add . && git commit -m "commit message" && git push heroku master 



