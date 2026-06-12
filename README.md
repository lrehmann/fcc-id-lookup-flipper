# FCC ID Lookup for Flipper Zero

Offline FCC ID applicant and frequency lookup for Flipper Zero.

Enter a full FCC ID or any non-empty prefix, browse matching FCC IDs, and open a detail page with the applicant and supported frequency ranges. The FCCID.io-derived database is available offline and read directly from the app asset database.

Data source: [FCCID.io](https://fccid.io). Example record source: https://fcc.id/2A2V6-FZ.

## Large Database Notice

FCC ID Lookup includes a large offline database asset, currently about 8.9 MB. Catalog installation and first launch can take noticeably longer than small apps because Flipper must transfer and unpack the database asset before the app can use it.

On first app use after install or update, opening the database may also take extra time. If a search is submitted before the database is ready, the app shows a status screen and continues once loading completes.

## Features

- Full FCC ID lookup with exact-match precedence.
- Prefix search for any non-empty normalized prefix.
- Paginated result lists for broad prefixes.
- Applicant display on the detail page.
- Supported frequency values formatted as Hz, kHz, MHz, GHz, or THz.
- Direct-read offline database asset for catalog builds.

## Install Modes

The catalog-compatible build uses Flipper `fap_file_assets`, so `files/fcc_freq_v2.bin` is provided with the app and unpacked by Flipper on first launch or after asset updates. This is the supported self-contained data distribution path for catalog apps. The large database can delay installation and first launch because Flipper transfers and unpacks app assets before the app entry point runs, but the app no longer creates a second raw cache after launch.

For local development and faster first-splash testing, run:

```sh
./deploy_to_flipper.sh --fast-start
```

Fast-start mode builds a tiny FAP and uploads `files/fcc_freq_v2.bin` separately to `/ext/apps_data/fcc_id_lookup/fcc_freq_v2.bin`. The app can draw the splash screen immediately and search the sidecar directly. To install the exact catalog-style bundled-asset build locally, run:

```sh
./deploy_to_flipper.sh --catalog
```

## Screenshots

![Intro QR screen](screenshots/intro-qr.png)

Intro QR screen: launch page with QR code, project URL, and one-key prompt to start searching.

![Empty search screen](screenshots/search-empty.png)

Empty search screen: FCC ID or prefix text input using the Flipper keyboard.

![Prefix search screen](screenshots/search-prefix.png)

Prefix search screen: normalized prefix search.

![Detail summary screen](screenshots/detail-summary.png)

Detail summary screen: result with FCC ID, applicant, and data-source URL.

![Frequency detail screen](screenshots/detail-frequencies.png)

Frequency detail screen: supported frequency list using compact unit formatting.

## Install

Install from the Flipper Apps Catalog, or connect one Flipper over USB and run:

```sh
./deploy_to_flipper.sh
```

The deploy script creates a local `.venv`, downloads the uFBT SDK into `.ufbt`, builds the FAP, and installs the app at `/ext/apps/Tools/fcc_id_lookup.fap`. Launch FCC ID Lookup from Apps > Tools on the Flipper.

The script uses uFBT and storage auto-detection. To force a specific serial port, run:

```sh
./deploy_to_flipper.sh /dev/cu.usbmodemflip_XXXX1
```

## Database

Catalog builds package `files/fcc_freq_v2.bin` through `fap_file_assets`, and Flipper unpacks it to the FCC ID Lookup app assets folder. Fast-start local deploys upload the same file as an app-data sidecar. In both modes, the app reads the database directly without creating `fcc_freq_v2_cache.bin`.

Current database:

- Raw size: 8,930,222 bytes
- Raw SHA-256: 71ac86c6f0064c7c6dd0f934e4f9f38cf93c89316ce38bcabbb8aedb3186a6e3
