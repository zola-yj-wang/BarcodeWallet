# BarcodeWallet

BarcodeWallet is a Garmin Connect IQ watch app that displays EAN-13 barcodes on your watch, making it easy to show membership cards, loyalty cards, or other barcode-based IDs.

## Features

- Display a single EAN-13 barcode on the watch screen
- Store multiple cards and switch between them with up/down navigation
- Show the card name, barcode value, and current card index
- Provide a glance view with the app name
- Fall back to a simplified placeholder pattern when the barcode is not a valid 13-digit EAN-13 code

## Supported Devices

The following target devices are currently listed in `manifest.xml`:

- Forerunner 55
- Forerunner 165 / 165 Music
- Forerunner 245 / 245 Music
- Forerunner 255 / 255 Music / 255S / 255S Music
- Forerunner 265 / 265S
- Forerunner 645 / 645 Music
- Forerunner 745
- Forerunner 935
- Forerunner 945 / 945 LTE
- Forerunner 955
- Forerunner 965

## Usage

After installing the app, open the app settings in Garmin Connect IQ and enter your card data in the following format:

```text
Name|Barcode;Name|Barcode;Name|Barcode
```

Example:

```text
Costco|4712345678901;Carrefour|5901234123457
```

Rules:

- Separate cards with `;`
- Separate the card name and barcode with `|`
- Barcodes should be 13 digits and have a valid EAN-13 check digit
- Leading and trailing whitespace is trimmed automatically

Watch controls:

- `Up / Down`: switch between cards
- `Launch app`: display the currently selected barcode

## Project Structure

```text
.
├── manifest.xml
├── monkey.jungle
├── resources
│   ├── drawables
│   ├── settings
│   └── strings
└── source
    ├── BarcodeWalletApp.mc
    ├── BarcodeWalletDelegate.mc
    ├── BarcodeWalletGlanceView.mc
    ├── BarcodeWalletView.mc
    └── CardRepository.mc
```

## Development

This is a standard Connect IQ Monkey C project.

Requirements:

- Garmin Connect IQ SDK
- Visual Studio Code
- Monkey C extension for VS Code

Typical workflow:

1. Open the project in VS Code.
2. Install and configure the Connect IQ SDK.
3. Use the Monkey C extension to build, run, and test in the simulator.
4. Manage supported devices and app metadata through `manifest.xml`.

## Implementation Notes

- Barcode rendering logic lives in `source/BarcodeWalletView.mc`
- Card settings parsing lives in `source/CardRepository.mc`
- Settings are loaded from `Application.Properties` under `cards_config`
- The UI is drawn directly in code and does not use layout XML resources

## Limitations

- Only EAN-13 is supported
- Card data is stored as a single app settings string, which is not ideal for large datasets
- There is no built-in barcode scanning or camera input
- Invalid barcodes are not blocked at save time; the app shows a placeholder pattern instead
