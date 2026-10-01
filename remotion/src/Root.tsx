import { Composition } from "remotion";
import { Short } from "./Short";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="Short"
      component={Short}
      durationInFrames={150}
      fps={30}
      width={1080}
      height={1920}
      defaultProps={{ title: "My Shorts Studio" }}
    />
  );
};
