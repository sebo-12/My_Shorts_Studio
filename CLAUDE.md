# My_Shorts_Studio

Vertical short videos (1080x1920), built with HyperFrames or Remotion. See README.md for setup and commands.

## Network access in cloud sessions

The cloud environment uses Custom network access: the default package manager list plus exactly these domains:

- cdn.jsdelivr.net
- cdnjs.cloudflare.com
- unpkg.com
- static.heygen.ai

Every other domain is blocked. Map videos do not work yet: their tiles come from `a.basemaps.cartocdn.com` and `server.arcgisonline.com`, which are blocked. Before building a map video, tell the user and ask them to add both domains in the environment's network settings. Then update this file and README.md to match.

If a render fails to load an asset from any other domain, report the blocked domain to the user. Don't work around it silently.
