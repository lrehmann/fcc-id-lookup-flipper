# FCC ID Lookup

Offline FCC ID applicant and frequency lookup for Flipper Zero.

Enter a full FCC ID or any non-empty prefix, browse matching FCC IDs, and open a detail page with the applicant and supported frequency ranges. The FCCID.io-derived database is available offline and read directly from the app asset database.

Data source: https://fccid.io. Example record source: https://fcc.id/2A2V6-FZ.

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

## Database

Catalog builds package files/fcc_freq_v2.bin through Flipper app assets. Flipper unpacks it to the FCC ID Lookup app assets folder. The app reads the database directly without creating a second raw cache file.

Current database:

- Raw size: 8,930,222 bytes
- Raw SHA-256: 71ac86c6f0064c7c6dd0f934e4f9f38cf93c89316ce38bcabbb8aedb3186a6e3
