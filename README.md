# My_Shorts_Studio

Vertical short videos (1080x1920), built with HyperFrames or Remotion.

## Cloud session setup

`.claude/hooks/session-start.sh` runs at the start of every Claude Code cloud session. It:

- installs the HyperFrames plugin pinned to v0.8.106
- exports `HYPERFRAMES_BROWSER_PATH` and `REMOTION_BROWSER_EXECUTABLE`, pointing both at the Chrome Headless Shell that ships with the container
- adds the session proxy's CA certificate to Chrome's certificate store, so renders can load scripts from CDNs
- runs `npm ci` in `remotion/`

## HyperFrames

Run the CLI with `npx -y hyperframes@0.8.106`. Scaffold a vertical project with:

```sh
npx -y hyperframes@0.8.106 init my-short --non-interactive --resolution portrait
```

Templates and registry blocks load scripts such as GSAP from public CDNs. For renders to reach them in a cloud session, two things must hold:

- The cloud environment uses **Custom** network access with the default package manager list plus these allowed domains: `cdn.jsdelivr.net`, `cdnjs.cloudflare.com`, `unpkg.com`, `static.heygen.ai`.
- Chrome trusts the session proxy's CA certificate. The session hook adds it to Chrome's certificate store.

Map videos are not supported yet. Their map tiles come from `a.basemaps.cartocdn.com` and `server.arcgisonline.com`, which are not allowed. To enable map videos, add both domains to the environment's allowed domains and update `CLAUDE.md`.

HyperFrames may log `Failed to download CDN script ... HTTP 403` before a render. The render still works, because the browser loads the script itself.

## Remotion

```sh
cd remotion
npm run dev        # Remotion Studio
npm run render     # out/short.mp4
npm run typecheck
```

The `Short` composition in `remotion/src/Root.tsx` is 1080x1920 at 30 fps.
