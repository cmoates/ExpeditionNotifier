# ExpeditionNotifier

UE4SS producer mod: hooks expedition-complete UI and publishes events via **[PalMaildir](https://github.com/cmoates/PalMaildir)**.

Requires **PalMaildir** loaded first in `mods.txt`.

## Install

```txt
PalMaildir : 1
ExpeditionNotifier : 1
```

Copy both mod folders into `ue4ss/Mods/`.

**Alt+F8** toggles publishing (default ON).

## Config (`Scripts/config.lua`)

| Option | Default | Description |
|--------|---------|-------------|
| `enabled` | `true` | Load-time default; Alt+F8 toggles at runtime. |
| `dedupe_seconds` | `8` | Suppress duplicate expedition text. |
| `debug` | `false` | Extra UE4SS.log lines. |

## Notifications

Run `PalMaildir/tools/palmail-watcher.py` on your PC while playing (see PalMaildir README).
