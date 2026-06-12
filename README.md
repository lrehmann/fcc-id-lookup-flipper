# FCC ID Lookup for Flipper Zero

Offline FCC ID search for Flipper Zero.

The app lets you enter a full FCC ID or prefix, browse matching FCC IDs, and view:

- FCC ID
- Grantee/applicant
- Frequency range or ranges
- Data attribution

Data is sourced from <https://fccid.io>.

## Files

- `application.fam` - uFBT external app manifest
- `fcc_id_lookup.c` - Flipper app source
- `fcc_qr_code.h` - startup QR bitmap
- `fcc_id_lookup_icon.png` - 10x10 1-bit app icon
- `fcc_freq_v2.bin` - compact offline FCC ID database
- `deploy_to_flipper.sh` - build, upload database, install, and launch

## Deploy

Connect the Flipper over USB, then run:

```sh
./deploy_to_flipper.sh
```

To force a specific serial port:

```sh
./deploy_to_flipper.sh /dev/cu.usbmodemflip_Yuwabl1
```

The script installs a local `.venv`, downloads the uFBT SDK into `.ufbt`, builds the `.fap`, uploads `fcc_freq_v2.bin` to:

```text
/ext/apps_data/fcc_id_lookup/fcc_freq_v2.bin
```

and launches the app from:

```text
/ext/apps/Tools/fcc_id_lookup.fap
```

If the same-sized database is already on the Flipper, the upload is skipped.

## Database

`fcc_freq_v2.bin` is a compact direct-access database. It is intentionally stored on the SD card instead of inside the `.fap`.

Current database:

```text
Size: 8,930,222 bytes
SHA-256: 71ac86c6f0064c7c6dd0f934e4f9f38cf93c89316ce38bcabbb8aedb3186a6e3
```
