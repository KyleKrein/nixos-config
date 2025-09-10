/*
  distancethreshold: Minimum cutoff for a gestures to take effect
  degreesleniency: Offset degrees within which gesture is recognized (max=45)
  timeoutms: Maximum duration for a gesture to take place in miliseconds
  orientation: Number of 90 degree turns to shift gestures by
  verbose: 1=enabled, 0=disabled; helpful for debugging
  device: Path to the /dev/ filesystem device events should be read from
  gestures: Array of gestures; binds num of fingers / gesturetypes to commands
            Supported gestures: SwipeLR, SwipeRL, SwipeDU, SwipeUD,
                                SwipeDLUR, SwipeURDL, SwipeDRUL, SwipeULDR
*/

unsigned int distancethreshold = 125;
unsigned int distancethreshold_pressed = 60;
unsigned int degreesleniency = 15;
unsigned int timeoutms = 800;
unsigned int orientation = 0;
unsigned int verbose = 1;
double edgesizeleft = 50.0;
double edgesizetop = 50.0;
double edgesizeright = 50.0;
double edgesizebottom = 50.0;
double edgessizecaling = 2.0;
char *device = "/dev/touchscreen";

// Gestures can also be specified interactively from the command line using -g
Gesture gestures[] = {
    {1, SwipeRL, EdgeRight, DistanceAny, ActModeReleased,
     "niri msg action focus-column-right"},
    {1, SwipeLR, EdgeLeft, DistanceAny, ActModeReleased,
     "niri msg action focus-column-left"},
    {1, SwipeDU, CornerBottomRight, DistanceMedium, ActModeReleased,
     "niri msg action focus-workspace-down"},
    {1, SwipeUD, CornerTopRight, DistanceMedium, ActModeReleased,
     "niri msg action focus-workspace-up"},
    {1, SwipeDU, CornerBottomLeft, DistanceShort, ActModeReleased,
     "niri msg action switch-preset-column-width"},
    //{1, SwipeUD, EdgeTop, DistanceAny, ActModeReleased, "nwggrid -o 0.98"},
    //"pkill -SIGRTMIN -f wvkbd"},
    //{2, SwipeUD, EdgeAny, DistanceAny, ActModeReleased,
    //"sway-interactive-screenshot -s focused-output"},
    //{3, SwipeLR, EdgeAny, DistanceAny, ActModeReleased,
    //"swaymsg layout tabbed"},
    //{3, SwipeRL, EdgeAny, DistanceAny, ActModeReleased,
    //"swaymsg layout toggle split"},
    {2, SwipeUD, EdgeLeft, DistanceShort, ActModePressed,
     "niri msg action fullscreen-window"},
    {2, SwipeUD, EdgeRight, DistanceMedium, ActModeReleased,
     "niri msg action close-window"},
    {2, SwipeDU, EdgeBottom, DistanceAny, ActModeReleased,
     "pkill -34 -f wvkbd"},
    {3, SwipeUD, EdgeTop, DistanceLong, ActModeReleased,
     "pkill quickshell"},
    //{2, SwipeUD, EdgeBottom, DistanceAny, ActModeReleased,
    //"pkill -9 -f wvkbd-mobintl"},
    {3, SwipeDU, EdgeAny, DistanceAny, ActModeReleased,
     "niri msg action toggle-overview"},
};
