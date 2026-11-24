# Publish Image to Github Container Repository

Launches a Docker image as a container, and handles cleaning up the container at the end.

Example usage:

```yml
  - uses: UoMResearchIT/actions/docker-run-image@main
    with:
      image-id: ${{ steps.make-image.outputs.image-id }}
      port: 8080
```

> [!NOTE]
> Assumes you are using a Linux container.

## Inputs

### Required

* `image-id`

  The ID of the Docker image to start. **Required.**
  
  Often comes from the step that builds the image.

### Optional

* `port`

  A port to map on the inside of the container to the outside (where the rest of the workflow can see it). **Optional.**

* `run-args`

  Extra arguments to pass to `docker run`. **Optional.**

## Outputs

* `container-id`

  The random ID of the running container. Definitely will be free of spaces.

## Permissions

No special permissions required.
