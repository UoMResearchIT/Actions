import os, re

container = os.environ.get("CONTAINER", "").lower()
if container == "":
    # GITHUB_CONTAINER is a two-part name like UoMResearchIT/actions
    container = re.sub(r".*/", "", os.environ["GITHUB_REPOSITORY"]).lower()
    print(f"determined container name to be \033[0;32m{container}\033[0m")
namespace = os.environ["NAMESPACE"].lower()
version = os.environ["VERSION"]

with open(os.environ["GITHUB_OUTPUT"], "a") as f:
    f.write(f"container={container}\n")
    f.write(f"namespace={namespace}\n")
    f.write(f"handle=ghcr.io/{namespace}/{container}:{version}\n")
