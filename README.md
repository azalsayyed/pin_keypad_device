# PIN Keypad (UEFN Verse)

Code by AZ ALSAYYED.

## What it does

A PIN keypad for Fortnite Creative (UEFN). A player presses a button device, a keypad appears on their screen, and they type a code.

- Right code: fires a trigger (and optionally an accolade), then closes.
- Wrong code: fires a "fail" trigger and shows how many tries are left.
- Too many wrong tries: the player is locked out for a set time and a "lockout" trigger fires.
- Digits can be hidden as dots, codes can be one-time only, and every code can fire its own trigger.

Note: this was written without access to UEFN, so it has not been compiled or play-tested yet. Build it once and fix any compiler messages before relying on it.

## Devices you need

| Device | Count | Purpose |
|---|---|---|
| `pin_keypad_device` (this script) | 1 | The keypad logic |
| Button device | 1 or more | Opens the keypad when a player interacts |
| Trigger device | 3 | Default success, fail, lockout |
| Accolades device | optional | XP/reward on a correct code |

## Add it to your project

1. Open your project in UEFN.
2. Open **Verse Explorer** (Verse menu > Verse Explorer).
3. Right-click your project folder > **Add new Verse file**, name it `pin_keypad_device`, and paste in the contents of `pin_keypad_device.verse`. (Or copy the file into the project's Verse folder.)
4. Choose **Verse > Build Verse Code** (Ctrl+Shift+B) and wait for "Build succeeded".
5. In the Content Browser, find `pin_keypad_device`, drag it into the level, and fill in its Details panel.

## Edit the code list

Select the device in the level and open **Codes** in Details. Each entry has:

- **PIN**: the digits, as text (`0420` keeps its leading zero).
- **OnSuccess**: a trigger just for this code. If empty, `DefaultSuccess` is used.
- **Reward**: optional accolades device.
- **OnlyOnce**: if on, the code stops working after one use.

Other settings: `MaxDigits`, `MaxAttempts`, `LockoutSeconds`, `HideDigits`, `Title`, and the two colors.

## Usage example

Goal: a door that opens with `4821`.

1. Place the keypad device, one button device, and three trigger devices.
2. On the keypad: add the button to **OpenButtons**, and assign the triggers to **DefaultSuccess**, **OnFail**, **OnLockout**.
3. Add one entry to **Codes** with PIN `4821`.
4. Wire `DefaultSuccess` to open your door (for example, the trigger's `On Triggered` event to a door or barrier device's `Open`/`Disable`).
5. Launch a session, press the button, type `4821`, press OK. The door opens. Three wrong codes lock the keypad for 15 seconds.

## Known limits

- Lockout and attempts are tracked per player while the island runs, and reset when it restarts.
- Keypad state is kept in memory for each player who has opened it, and is not cleaned up when they leave.
