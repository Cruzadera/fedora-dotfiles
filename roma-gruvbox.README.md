# roma-gruvbox

`roma-gruvbox.omp.json` is a two-line Oh My Posh v29 theme that blends Catppuccin-style layout discipline with a Gruvbox Material palette.

## Design goals

- Calm, low-noise prompt with clear visual hierarchy.
- Rounded separators using Nerd Font glyphs instead of sharp triangles.
- Strong readability on dark Fedora/KDE terminals.
- Fast rendering by leaning on built-in Oh My Posh segments.

## Palette

These are the configurable colors used throughout the theme.

- `#282828` background base: the terminal surface and the darkest prompt surfaces.
- `#EBDBB2` foreground base: primary readable text.
- `#D8A657` primary yellow: prompt symbol, Python, and accent highlights.
- `#A9B665` pastel green: Git branch, Git clean state, Node, added lines.
- `#7DAEA3` pastel cyan: Go, Kubernetes, and other cool-tooling accents.
- `#89B4FA` soft blue: .NET, Terraform, and the OS accent.
- `#E78A4E` orange: Java and Rust accents.
- `#EA6962` soft red: failures, deletions, and conflicts.
- `#928374` grey: auxiliary metadata like timing, time, and upstream counts.
- `#3C3836` dark grey: neutral panel backgrounds.
- `#32302F` deeper neutral: language/version pills.

## Segment guide

### First line

- `os`
  - Detects the current operating system automatically.
  - Fedora uses the Nerd Font Fedora glyph `` through Oh My Posh's OS icon mapping.
- `path`
  - Shows the current working directory with the `󰉋` icon.
  - Uses truncation so only the trailing path remains visible when the path gets long.
- `git`
  - Shows only inside Git repositories.
  - The theme splits Git information into multiple compact subsegments for clarity:
    - branch name
    - added files
    - modified files
    - deleted files
    - conflicts
    - ahead/behind counts
    - stash count
- Language/version segments
  - `java`
    - Java / Maven toolchain pill.
    - Appears in Java-style project roots such as `pom.xml` and `build.gradle(.kts)` workspaces.
  - `node`
  - `python`
  - `rust`
  - `dotnet`
  - `php`
  - `ruby`
  - `terraform`
  - `kubectl`
  - These segments stay quiet unless the relevant tooling or project markers are present.
  - `java`, `node`, `python`, `rust`, `dotnet`, `php`, `ruby`, and `terraform` are the file-aware pills.
  - `kubectl` is context/toolchain-aware for environments where Oh My Posh can resolve that data cleanly.
- `executiontime`
  - Appears only after commands longer than 3 seconds.
  - Uses the `󰔛` icon and a grey panel.

### Prompt end

- `text`
  - Renders the prompt symbol `❯` in Gruvbox yellow.
  - This stays on the same line as the rest of the prompt so typed commands do not drop to a second line.

## Notes on the implementation

- The JSON stays valid and directly usable, so there are no inline comments inside the config file.
- Rounded separators are created with `` and `` so the prompt feels closer to Catppuccin's soft framing.
- The theme avoids custom shell commands so it stays fast in Bash and VSCodium terminals.

## Future improvements

1. Add a dedicated right prompt for hostname, VPN state, or battery level if you want more context without cluttering the main line.
2. Split Java and Maven into separate visual treatments if you want Maven to stand out more strongly in large polyglot repositories.
3. Add a dedicated manifest scanner for Kubernetes if you want file-only triggering instead of context-aware triggering.
4. Add per-segment background templates for dirty Git states if you want even more visual polish.
5. Tune path truncation depth per project size so very deep mono-repos stay compact.
6. Add transient prompt styling if you want a cleaner after-command experience in interactive shells.
