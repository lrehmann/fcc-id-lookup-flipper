# FCC ID Lookup for Flipper Zero

Offline FCC ID applicant and frequency lookup for Flipper Zero.

Enter a full FCC ID or any non-empty prefix, browse matching FCC IDs, and open a detail page with the applicant and supported frequency ranges. The FCCID.io-derived database is bundled as a compressed app asset and expanded into an app-data cache on first use.

Data source: [FCCID.io](https://fccid.io). Example record source: https://fcc.id/2A2V6-FZ.

## Features

- Full FCC ID lookup with exact-match precedence.
- Prefix search for any non-empty normalized prefix.
- Paginated result lists for broad prefixes.
- Applicant display on the detail page.
- Supported frequency values formatted as Hz, kHz, MHz, GHz, or THz.
- Bundled compressed offline database using Flipper app assets.

## Screenshots

- [Intro QR screen](screenshots/intro-qr.png): centered launch page with QR code, project URL, and a one-key prompt to start searching.
- [Empty search screen](screenshots/search-empty.png): FCC ID or prefix text input with the on-device keyboard ready for entry.
- [Prefix search screen](screenshots/search-prefix.png): example prefix entry before submitting a lookup.
- [Detail summary screen](screenshots/detail-summary.png): detail page showing full FCC ID, applicant, grant date, and data source.
- [Frequencies screen](screenshots/detail-frequencies.png): supported frequency list using compact unit formatting.

## Install

Install from the Flipper Apps Catalog, or connect one Flipper over USB and run ./deploy_to_flipper.sh.

The deploy script creates a local .venv, downloads the uFBT SDK into .ufbt, builds the FAP, and installs the app at /ext/apps/Tools/fcc_id_lookup.fap. Launch the app from Apps > Tools > FCC ID Lookup on the Flipper.

The script uses uFBT and storage auto-detection, so it works with whichever connected Flipper is visible to the tools. To force a specific serial port, run ./deploy_to_flipper.sh /dev/cu.usbmodemflip_XXXX1.

On launch, the app starts preparing the database cache in the background. If a search is submitted before the cache is ready, the app shows a preparation status page with progress when available.

## Database

files/fcc_freq_v2.fcz is packaged with the app through fap_file_assets and unpacked by Flipper to the FCC ID Lookup app assets folder. The app expands it into an uncompressed app-data cache named fcc_freq_v2_cache.bin for normal lookup speed.

Current database:

- Raw size: 8,930,222 bytes
- Raw SHA-256: 71ac86c6f0064c7c6dd0f934e4f9f38cf93c89316ce38bcabbb8aedb3186a6e3
- Packed asset size: 5,026,856 bytes
- Packed asset SHA-256: 7224446aa6c3158a75702e50baa5c48df18925c76db486b1a016ccb9de7d3c49
