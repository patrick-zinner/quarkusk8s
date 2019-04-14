### Needed tools

* Docker
* Minikube (+ Ingress)
* Maven
* Make

### How to run it

After cloning this repository, navigate into the root directory and execute `make setup`.

This will:
* create a namespace 
* build a docker image and tag it
* install the Strimzi operator, deploy a Kafka instance and create a Kafka topic.
This is done purely to demonstrate how to deploy "infrastructre"
* deploy the Java application on minikube

Check if it is up and running my executing `kubectl get pods -n q8s`

After making some changes to your Java application, you can simply use `make build deploy` to rebuild 
and redeploy your app.

### How does it work?
While finding a way to develop with minikube locally, I've ran into the problem that
rebuilding and tagging a docker image with `latest` does work in combination with
`kubectl apply`. Kubernetes won't do anything if you apply the same configuration file without any changes.

I also didn't want to push the image to a Docker registry everytime I make code changes and make my local
installation to pull the image everytime. What if I'm working somewhere where the internet connection is bad?

If you have a look at the `pom.xml` file, you will see that this POC uses the dockerfile-maven
plugin for building and tagging our image. You'll also see that there is a maven property called `imageTag`.
This property is used to define how our images should be tagged.

Now check the `Makefile`. The `build` recipe does three things:

* It configures the shell to use Minikube's Docker host. By doing so, Minikube does not need to pull the image.
* Pruning unused Docker images. **Attention:** This is just for testing. Obviously you don't want to delete all your images
just becaused they are not running in a container right now.
* Building the app and a Docker image by using Maven and the dockerfile-maven plugin. Mind the argument that is passed: 
`-DimageTag=${IMAGE_TAG}`. This will override the property defined in the `pom.xml`. In this POC, this is a timestamp. 
This means, after the build succeeds, the image will be tagged with something similar to `2019-04-14---10:03:01`.

Have a look at your images by using `docker images`.

Now check the `quarkusk8s.yaml`. This is where the deployment configuration for our app is defined. Two things are important:
```yaml
image: zinnsoldat/quarkusk8s:${IMAGE_TAG}
```
Instead of using a fixed tag, we're using a placeholder for the tag name.

```yaml
imagePullPolicy: IfNotPresent
```
By setting the `imagePullPolicy` to `IfNotPresent`, Kubernetes will use local images (if they are present) instead of
pulling images from a remote registry.

Obviously, `kubectl` does not care about our placeholders. Thats why the `deploy` recipe in the `Makefile` uses `envsubst`
to replace the placeholder and copies it to the /tmp/ directory. Then the temporaraly created configuration file is applied.



