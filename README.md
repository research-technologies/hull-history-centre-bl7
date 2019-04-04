# Getting Started

* git clone [this repo]
* bundle install
* setup the environment variables (as noted below) 
* rake db:migrate
* solr_wrapper &
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

## Environment Variables

 * The environment variables used by docker when running the containers and by the rails application should be in file named .env
 * For docker, copy the file .env.template to .env and change / add the necessary information
 * For running the application without docker, setup the ENVIRONMENT VARIABLES as you would normally do so (eg. .rbenv-vars)

The following are required by the appliation if digital object metadata is being imported from Hyrax and Digital Archival Objects are being served from the application:

```
HYRAX_APP= # URL for the hyrax instance
HYRAX_APP_USER= # hyrax admin user email
HYRAX_APP_PASS= # hyrax admin user password
HYRAX_SOLR_URL= # full solr url for the solr instance being used for hyrax
```

### Secrets

Generate a new secret with:

```
rails secret
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
You should see the rails app at localhost:3000 (if you set EXTERNAL_PORT to a different port, it will be running on that port)

## Universal Viewer Configuration

The file 'public/uv_config.json' is used to determine how the universal viewer is displayed.

For example, the following config disables the download button, but leaves the share button enabled:

```
{
  "modules":
  {
    "footerPanel":
    {
      "options":
      {
        "shareEnabled": true,
        "downloadEnabled": false
      }
    }
  }
}
```

