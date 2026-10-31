# My_Shorts_Studio

Vertical short videos (1080x1920), built with HyperFrames or Remotion.

## Cloud session setup

`.claude/hooks/session-start.sh` runs at the start of every Claude Code cloud session. It:

- installs the HyperFrames plugin pinned to v0.8.106
- exports `HYPERFRAMES_BROWSER_PATH` and `REMOTION_BROWSER_EXECUTABLE`, pointing both at the Chrome Headless Shell that ships with the container
- adds the session proxy's CA certificate to Chrome's certificate store, so renders can load scripts from CDNs
- runs `npm ci` in `remotion/`

## Footage workflow

Footage never goes on `main`. Each video gets its own throwaway branch, and you delete it when the video is done. This keeps the repo small across dozens of videos. The steps below use GitHub Desktop.

### Before you start

- Keep your original clips in a folder outside the repo, for example `~/Videos/Shorts Footage`. The repo only ever holds copies. Switching branches makes another branch's files disappear from Finder, so the repo copy should never be your only copy.
- Check that every clip is under 100 MB. In Finder, open the folder, switch to list view, and read the Size column. GitHub rejects bigger files. Compress them to 1080p first, for example with HandBrake.
- Pick two names, using the date you filmed:
  - Folder: `<Project>_<YYYY-MM-DD>`, for example `CRTFC_Prompt_2026-10-04`. No slashes or spaces.
  - Branch: `footage/<project>-<yyyy-mm-dd>`, for example `footage/crtfc-2026-10-04`.

### Upload your clips

1. Open GitHub Desktop. Make sure the top says Current Branch, `main`. Click Fetch origin, then Pull origin if it appears.
2. Click Current Branch, then New Branch. Type the branch name and click Create Branch. Check the name at the top. A dash at the end means a space slipped in. Fix it with Branch, Rename before you publish.
3. Click Repository, then Show in Finder. That opens the repo folder.
4. In a second Finder window, open your clips folder. Hold Option and drag it into the repo folder, so it copies instead of moves.
5. Right-click the copied folder, choose Rename, and give it the folder name.
6. Back in GitHub Desktop, check that the left side lists your clips. Uncheck anything that isn't footage.
7. In the Summary box, type `Add <project> shots` and click Commit to `footage/...`.
8. Click Publish branch and wait for it to finish.
9. Click Current Branch and switch back to `main`. If a box asks about your changes, choose to leave them on the footage branch. The clips disappear from the repo folder. That's expected, because they're safe on GitHub.
10. Tell Claude the branch name.

GitHub shows a yellow Compare & pull request banner after every footage push. Ignore it. Never open a pull request for a footage branch or for any branch with footage or renders on it. GitHub keeps pull request files forever, even after the branch is deleted.

### Get the finished video

Claude pushes the final MP4 into your project folder on its own `claude/...` branch and tells you the branch name.

1. Go to the repo on github.com.
2. Click the branch button that says `main` and pick Claude's branch.
3. Open your project folder and click the MP4.
4. Click the download button at the top right of the file view. Save the video somewhere outside the repo.

### Clean up

Only clean up after the video is saved outside the repo. Deleting the branches also deletes the video's project files, so keep them if you might re-edit.

1. In GitHub Desktop, switch to `main`. You can't delete the branch you're on.
2. Click Current Branch, right-click the footage branch, and choose Delete. Leave "Yes, delete this branch on the remote" checked, so it's deleted on GitHub too.
3. On github.com, click the branch count next to the `main` button. Click the trash can next to each `claude/...` branch for this video. If one of them has an open pull request with rule or doc changes, merge it first.
4. Back in GitHub Desktop, click Fetch origin. Only `main` should be left.

Branches starting with `origin/` in GitHub Desktop exist only on GitHub. Delete those on github.com.

### Terminal version

```sh
# Upload
git checkout main && git pull
git checkout -b footage/crtfc-2026-10-04
git add CRTFC_Prompt_2026-10-04
git commit -m "Add CRTFC shots"
git push -u origin footage/crtfc-2026-10-04
git checkout main

# Clean up, after the video is saved
git push origin --delete footage/crtfc-2026-10-04 <claude-branch>
git branch -D footage/crtfc-2026-10-04
```

Don't use Git LFS for footage. GitHub counts deleted LFS files against your storage until you delete the whole repo.

## Content skills

`.claude/skills/` holds five writing skills for ideas, hooks, scripts, captions, and YouTube Shorts strategy, copied from [vyralcontent/content-skills](https://github.com/vyralcontent/content-skills) with the vendor's product pitch removed. Claude loads them in every session. `CLAUDE.md` lists where this repo's video style overrides them.

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
