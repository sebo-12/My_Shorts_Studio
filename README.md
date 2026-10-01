# My_Shorts_Studio

Vertical short videos (1080x1920), built with HyperFrames or Remotion.

## Cloud session setup

`.claude/hooks/session-start.sh` runs at the start of every Claude Code cloud session. It:

- installs the HyperFrames plugin pinned to v0.8.106
- exports `HYPERFRAMES_BROWSER_PATH` and `REMOTION_BROWSER_EXECUTABLE`, pointing both at the Chrome Headless Shell that ships with the container
- runs `npm ci` in `remotion/`

## HyperFrames

Run the CLI with `npx -y hyperframes@0.8.106`. Scaffold a vertical project with:

```sh
npx -y hyperframes@0.8.106 init my-short --non-interactive --resolution portrait
```

The cloud environment's network policy blocks public CDNs such as cdn.jsdelivr.net, and the starter `index.html` loads GSAP from there, so renders fail. Install GSAP from npm and load it with a local path instead:

```sh
cd my-short && npm i gsap@3.14.2
# in index.html
<script src="node_modules/gsap/dist/gsap.min.js"></script>
```

## Remotion

```sh
cd remotion
npm run dev        # Remotion Studio
npm run render     # out/short.mp4
npm run typecheck
```

The `Short` composition in `remotion/src/Root.tsx` is 1080x1920 at 30 fps.
