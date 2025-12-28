https://github.com/fastapi/full-stack-fastapi-template/tree/master/backend
https://github.com/nvm-sh/nvm/blob/master/Dockerfile
https://github.com/mjun0812/python-project-template/tree/main

https://github.com/microsoft/vscode-dev-containers/issues/304
https://docs.docker.com/reference/compose-file/build/#target
https://docs.docker.com/reference/compose-file/build/#additional_contexts

https://github.com/astral-sh/uv-docker-example/

https://stackoverflow.com/a/79348510
Save this answer.

[](https://stackoverflow.com/posts/79348510/timeline)

Show activity on this post.

With the following directory structure as an example:

```
├── nginx
|   └── Dockerfile
└── php
    ├── Dockerfile
    └── compose.yaml
```

Define an extra [build context](https://docs.docker.com/build/concepts/context/) with [`build.additional_contexts`](https://docs.docker.com/reference/compose-file/build/#additional_contexts) mapping that state the image `nginx` should be fetch from `../nginx` with an default [`build.dockerfile = Dockerfile`](https://stackoverflow.com/questions/57528077/docker-compose-with-name-other-than-dockerfile) instead of [the official image `docker-image://nginx`](https://hub.docker.com/_/nginx) with the same name.

- `php/compose.yaml`:
    

- ```yaml
    services:
      php:
        build:
          context: .
          additional_contexts:
            nginx: ../nginx
    ```
    

Now the re-defined image `nginx` can be used by Dockerfile instructions like [`FROM`, `COPY --from=<>`, etc.](https://old.reddit.com/r/docker/comments/1c5c7ze/how_do_you_supercharge_your_docker_compose_setup/kztx8jg/)

- `php/Dockerfile`:
    
    ```
    FROM nginx
    
    ...
    ```
    

* * *

This can also be achieved without using Docker Compose, just the plain [`docker buildx build --build-context nginx=../nginx .`](https://github.com/docker/buildx/blob/master/docs/reference/buildx_build.md#-additional-build-contexts---build-context) under `/php`.

* * *

In case of reduce the possiblity of name collision with existing images uploaded to docker hub or your private registry, we may prepend the image name with [`$COMPOSE_PROJECT_NAME`](https://docs.docker.com/compose/how-tos/environment-variables/envvars/#compose_project_name) like:

- `php/compose.yaml`:

- ```yaml
    services:
      php:
        build:
          context: .
          additional_contexts:
            ${COMPOSE_PROJECT_NAME}-nginx: ../nginx
          args:
            COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME
    ```
- `php/Dockerfile`:
    ```
    ARG COMPOSE_PROJECT_NAME
    FROM ${COMPOSE_PROJECT_NAME}-nginx
    ...
    ```
