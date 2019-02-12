# Getting Started

* git clone [this repo]
* bundle install
* cp config/secrets.yml.template config/secrets.yml
* Edit secrets.yml and fill in values
* rake db:migrate
* rake jetty:unzip
* rake configure\_jetty
* rake jetty:start
* rails s

# Importing Records

Import all \*.xml files within a directory:

```bash
rake import:ead['path/to/your/ead/files']
rake import:sirsi['path/to/your/sirsi/files']
```

Import specific EAD files:

```bash
rake import:ead['spec/fixtures/sample_ead_files/U_DDH.xml, spec/fixtures/sample_ead_files/U_DAR.xml']
```

Note that there is not a space between the rake task name and the square bracket that begins the arguments list, and that there are qutoes around the argument list.


## PDF files
Collection records have an associated pdf file that contains the collection catalogue.  This is implemented by letting the web server server the files (e.g. webrick in development) and Apache http when deployed.  To add some sample pdfs to the public folder of the application: 

```bash
rake copy:pdf
```

## Deploying with Capistrano

First, set up an ssh config entry with details about the server name used in the relevant config/deploy/[my-env].rb file.
Next, connect to the server via ssh to test the config.
Then you can deploy code and update the server with the command 
```
bundle exec cap [my-env] deploy
```

## Getting Started using docker

Ensure you have docker and docker-compose. See [notes on installing docker](https://github.com/research-technologies/hull_synchronizer/wiki/Notes-on-installing-docker)

To build and run the system in your local environment,

Clone the repository
```
git clone https://github.com/research-technologies/hull-history-centre-bl7.git
```

Issue the docker-compose `up` command:
```bash
$ docker-compose up --build
```
You should see the Synchronizer app at localhost:3000
