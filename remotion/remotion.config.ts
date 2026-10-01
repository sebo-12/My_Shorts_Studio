import { Config } from "@remotion/cli/config";

// Cloud sessions block Remotion's browser download, so the SessionStart hook
// exports the preinstalled Chrome Headless Shell here. Unset, Remotion
// downloads its own.
Config.setBrowserExecutable(process.env.REMOTION_BROWSER_EXECUTABLE ?? null);
Config.setVideoImageFormat("jpeg");
