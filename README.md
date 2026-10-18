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

1. Configure Discord webhook (PalEventDrop README).
2. Start **one** watcher: `python tools/event-watcher.py` or `tools/run-watcher.ps1`.
3. Play Palworld with both mods enabled; finish an expedition.

**Alt+F8** toggles publishing. Check `ue4ss/UE4SS.log` for `[ExpeditionNotifier]` and `[PalEventDrop]`.

Preview Discord formatting without the game:

```powershell
cd path\to\PalEventDrop
.\tools\write-test-expedition.ps1
```
