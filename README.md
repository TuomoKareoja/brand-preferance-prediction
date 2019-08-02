# Predicting Missing Brand Preferences

Using predictive model to input missing information about consumer brand preference

## Getting Started

The makefile contains commands to create and start a dockerized RStudio Server environment.
Just ```make run``` to start the RStudio Server and ```make stop``` when your done.

### Prerequisites

Docker

Make (not required, but recommended)

### Using the project

To download the necessary images and start the container:

```
make run
```

Once image has been downloaded the RStudio Server will automatically start
in your default browser. The default username is ```rstudio``` and default password is ```password```. If for some reason this the right tab won't pop out just open http://localhost:8787/. The local files are mounted to the docker container so all changes to the files are mirrored.

When you stop working, you can of course leave the container running, but
if you want to save some space and battery (and ports!) use:

```
make stop
```

This will stop the container and remove it. Remember that once you do this
all unsaved changes are permanently lost.

If you cannot run Makefiles (Windows!) you can check the makefile and
run the docker command there manually.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
