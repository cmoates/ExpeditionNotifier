# ExpeditionNotifier

UE4SS producer mod: hooks expedition-complete UI and publishes events via **[PalEventDrop](https://github.com/cmoates/PalEventDrop)**.

Requires **PalEventDrop** loaded first in `mods.txt`.

## Install

```txt
PalEventDrop : 1
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

Run `PalEventDrop/tools/event-watcher.py` on your PC while playing (see PalEventDrop README).
