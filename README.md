# USSF GRC Controls

### Heroku app link : [app link](https://csce606-ussf-d5f4faa6ca5f.herokuapp.com/)

### Code Climate : [View RubyCritic Report](https://aditya-s-gourishetty.github.io/csce606-report-ussf-report.github.io/)

HTML link for codeclimate: [View RubyCritic Report](docs/rubycritic/index.html)

### Project Tracker: [Tracker](https://github.com/orgs/tamu-edu-students/projects/69/views/2)

### Team Working Agreement : [Team Working Agreement](documentation/Fall2024/TeamWorkingAgreement.md)

### Setting up Ruby on Rails and Heroku
1. Check your Ruby version.  If no ruby, [go back to hw-ruby-intro](https://github.com/tamu-edu-students/hw-ruby-intro).
2. Check your Rails version.  If no rails, run `gem install rails`.
3. Check your Bundler version. If `bundle -v` fails, run `gem install bundler` to install it. (Normally, though, installing the `rails` gem will also install `bundler`.)
4. Verify the `heroku` [command line tool](https://devcenter.heroku.com/articles/heroku-cli) has been installed in the development environment.  If not, [follow the instructions to install it](https://devcenter.heroku.com/articles/heroku-cli#install-with-ubuntu-debian-apt-get).
5. Install `pkg-config`.

```sh
ruby -v &&\
rails -v &&\
bundle -v &&\
heroku -v &&\
sudo apt-get update && sudo apt-get install pkg-config
```
### Local Setup

- Clone this repo and navigate to the root directory of this repository
- Install dependencies using: `bundle install`
- Reach out to the team so that they can provide the master.key file with google developer secrets and place it in config folder
- Run `Rails db:migrate`
- Run `Rails db:seed` (This will take few minutes)
- Install Trivy [follow the instructions to install it](https://trivy.dev/v0.18.3/installation/)

### Instructions to run rspec and cucumber

- To run unit tests, run `rspec`
- To run BDD tests, run `cucumber`

### Start the deployment to heroku

1. heroku login
2. git init && git add . && git commit -m "initial commit"
3. heroku create app-name
4. Login to Heroku UI, navigate to the resources under your newly created app and add heroku-postres add-on
5. heroku buildpacks:set heroku/ruby --index 1 -a app-name
6. heroku buildpacks:add https://github.com/tamu-edu-students/buildpack-trivy --index 2 -a app-name
7. heroku config:set RAILS_MASTER_KEY="$(cat config/master.key)"
8. heroku run rails db:migrate
9. If we still have pending migration, `heroku run rake db:migrate:up VERSION=<version of the pending migration>`, to check status of migrations run `heroku run rake db:migrate:status`
9. heroku run rails db:seed (Will take few minutes)
10. git push heroku main
11. In the google developer console we need to add heroku URL(Reach out to Sahil Fayaz)

#### Additional info on buildpacks:
Buildpacks installs `trivy` for scanning container images in addition to depenedencies listed in Gemfile. [Documentation]()
Custom Buildpack for installing trivy : [GitHub](https://github.com/tamu-edu-students/buildpack-trivy)


## updates tp application

1. verify heroku - git remote -v
2. git add . && git commit -m "commit message" && git push heroku master

