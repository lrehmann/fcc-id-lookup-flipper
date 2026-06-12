# FCC ID Lookup for Flipper Zero

Offline FCC ID applicant and frequency lookup for Flipper Zero.

Enter a full FCC ID or any non-empty prefix, browse matching FCC IDs, and open a detail page with the applicant and supported frequency ranges. The app reads a compact FCCID.io-derived database from the Flipper SD card.

Data source: [FCCID.io](https://fccid.io). Detail pages show the record source as https://fcc.id/{FCC_ID}.

## Features

- Full FCC ID lookup with exact-match precedence.
- Prefix search for any non-empty normalized prefix.
- Paginated result lists for broad prefixes.
- Applicant display on the detail page.
- Supported frequency values formatted as Hz, kHz, MHz, GHz, or THz.
- Missing-database screen that shows the required SD-card path.

## Screenshots

- [Intro QR screen](screenshots/intro-qr.png): centered launch page with QR code, project URL, and a one-key prompt to start searching.
- [Empty search screen](screenshots/search-empty.png): FCC ID or prefix text input with the on-device keyboard ready for entry.
- [Prefix search screen](screenshots/search-prefix.png): example prefix entry before submitting a lookup.
- [Detail summary screen](screenshots/detail-summary.png): detail page showing full FCC ID, applicant, grant date, and data source.
- [Frequencies screen](screenshots/detail-frequencies.png): supported frequency list using compact unit formatting.

## Install

Run ./deploy_to_flipper.sh.

The deploy script creates a local .venv, downloads the uFBT SDK into .ufbt, builds the FAP, uploads fcc_freq_v2.bin to /ext/apps_data/fcc_id_lookup/fcc_freq_v2.bin, installs the app at /ext/apps/Tools/fcc_id_lookup.fap, and launches it.

The script uses uFBT and storage auto-detection, so it works with whichever connected Flipper is visible to the tools. To force a specific serial port, run ./deploy_to_flipper.sh /dev/cu.usbmodemflip_XXXX1.

If a same-sized database is already present on the Flipper, the script skips the slow database upload.

## Faster Database Install

The first install can be slow because USB serial storage upload to the Flipper is not fast. The fastest path is to copy the database directly to the Flipper SD card first.

1. Power off or disconnect the Flipper.
2. Remove the microSD card and mount it on your computer.
3. On the SD card, create apps_data/fcc_id_lookup.
4. Copy fcc_freq_v2.bin to apps_data/fcc_id_lookup/fcc_freq_v2.bin.
5. Reinsert the SD card, connect the Flipper over USB, and run ./deploy_to_flipper.sh.

## Database

fcc_freq_v2.bin is stored on the SD card instead of inside the FAP.

Current database:

- Size: 8,930,222 bytes
- SHA-256: 71ac86c6f0064c7c6dd0f934e4f9f38cf93c89316ce38bcabbb8aedb3186a6e3

For catalog installs, the app binary can be installed from the catalog, but the offline database still needs to be copied to /ext/apps_data/fcc_id_lookup/fcc_freq_v2.bin.
