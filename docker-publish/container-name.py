import os, re

container = os.environ.get("CONTAINER", "")
if container == "":
    # GITHUB_CONTAINER is a two-part name like UoMResearchIT/actions
    container = re.sub(r".*/", "", os.environ["GITHUB_REPOSITORY"])
    print(f"determined container name to be {container}")

with open(os.environ["GITHUB_OUTPUT"], "a") as f:
    f.write(f"container={container}\n")
