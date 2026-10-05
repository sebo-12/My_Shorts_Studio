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

## Footage workflow

Video footage never goes on `main`. Each video gets a throwaway footage branch that is deleted when the video is done, so the repo does not grow.

- The user pushes each video's shots to its own branch, named `footage/<project-slug>`, for example `footage/crtfc-2026-10-04`. The shots sit in a folder named `<Project>_<YYYY-MM-DD>` at the repo root, for example `CRTFC_Prompt_2026-10-04`.
- At the start of a video, ask for the footage branch name if the user hasn't given it. Fetch that branch and merge it into the session branch.
- Put everything for that video inside its folder: compositions, scripts, assets, and the rendered MP4. Don't scatter project files across the repo.
- Commit only the final render. Every pushed file stays in the branch's history until the branch is deleted.
- Never open a pull request for a footage branch or for any branch that contains footage or renders. GitHub keeps pull request files forever, even after the branch is deleted.
- Code or doc changes meant for `main` go on a branch with no footage.
- When the video is done, give the user the exact commands to delete the footage branch and the session branch, on GitHub and locally. README.md lists them.
- Never rewrite history or force-push to remove footage. Deleting the branch is the cleanup.

## Video style

- Open with the video's own topic. Every element in the first seconds must relate to what the video teaches, for example showing the problem the video solves. No generic attention grabbers such as "STOP" or "WAIT" headlines, alarms, or flashing text unrelated to the topic. The hook should feel confident, not like begging for attention.
- On talking-head footage, zoom in and out on the user's face where it helps: punch in on key words, push in slowly during explanations, and change the framing at cuts to hide jump cuts.
- Graphics never cover the user's face or body. When a talking-head video needs on-screen graphics, use a split layout: graphics and captions in a cream panel at the top, the user in a rounded window below. Keep the user's head and shoulders fully inside the window at every zoom level. Full-frame footage with no graphics is fine for the opening line and the "Follow for more" ending.
- The user ends videos by saying "Follow for more" and pointing up. Never cut that ending. Add a Follow button animation where the finger points.
