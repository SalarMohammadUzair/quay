## registering as an AppBar
- RegisterAppBar calls the Windows Shell API (`SHAppBarMessage`) to reserve
  screen space so other windows don't overlap the bar
- edge parameter tells Windows which side of the screen to dock against:

| Value | Constant     | Edge   |
|-------|--------------|--------|
| 0     | ABE_LEFT     | Left   |
| 1     | ABE_TOP      | Top    |
| 2     | ABE_RIGHT    | Right  |
| 3     | ABE_BOTTOM   | Bottom |

# does it finally work? is wakatime working?
why not detecto? vcf
