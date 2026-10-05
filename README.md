# My_Shorts_Studio

Vertical short videos (1080x1920), built with HyperFrames or Remotion.

## Cloud session setup

`.claude/hooks/session-start.sh` runs at the start of every Claude Code cloud session. It:

- installs the HyperFrames plugin pinned to v0.8.106
- exports `HYPERFRAMES_BROWSER_PATH` and `REMOTION_BROWSER_EXECUTABLE`, pointing both at the Chrome Headless Shell that ships with the container
- adds the session proxy's CA certificate to Chrome's certificate store, so renders can load scripts from CDNs
- runs `npm ci` in `remotion/`

## Footage workflow

Footage never goes on `main`. Each video uses a throwaway branch that you delete when the video is done. This keeps the repo small across dozens of videos.

1. Keep your original shots outside the repo, for example in `~/Videos/Shorts Footage`. The repo only holds copies. Switching branches removes another branch's files from Finder, so the repo copy should never be your only copy.
2. Copy the shots into a folder at the repo root named `<Project>_<YYYY-MM-DD>`, for example `CRTFC_Prompt_2026-10-04`. Don't use slashes in the name.
3. Push the folder to its own branch:

   ```sh
   git checkout -b footage/crtfc-2026-10-04
   git add CRTFC_Prompt_2026-10-04
   git commit -m "Add CRTFC shots"
   git push -u origin footage/crtfc-2026-10-04
   git checkout main
   ```

   GitHub rejects files over 100 MB. Compress large clips to 1080p first, for example with HandBrake.
4. Give Claude the branch name. Claude builds the video in that folder and pushes the final render to its session branch.
5. Download the render. Then delete the footage branch and Claude's session branch:

   ```sh
   git push origin --delete footage/crtfc-2026-10-04 <claude-session-branch>
   git branch -D footage/crtfc-2026-10-04
   ```

Never open a pull request for a footage branch or for a branch with footage or renders on it. GitHub keeps pull request files forever, even after the branch is deleted. Don't use Git LFS for footage either. GitHub counts deleted LFS files against your storage until you delete the whole repo.

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
