<h1 align="center" style="font-size:28px; line-height:1"><b>Cashew</b></h1>

<a href="https://cashewapp.web.app/">
  <div align="center">
    <img alt="Icon" src="promotional/icons/icon.png" width="150px">
  </div>
</a>

<br />

<div align="center">
  <a href="https://github.com/Marrrshl/Cashew_local-automatic-backup/releases/">
    <img alt="GitHub Badge" src="promotional/store-banners/github-badge.png" height="60px">
  </a>
</div>

<p align="center">
  Install and auto-update via <a href="https://github.com/ImranR98/Obtainium">Obtainium</a> pointed at this repo's releases.
</p>

<br />

---

> **This is a personal fork** of [jameskokoska/Cashew](https://github.com/jameskokoska/Cashew), frozen at v5.3.4+396, with a custom app ID/icon (so it can be installed alongside the official app) and a local automatic-backup feature added: the app writes a rolling backup to a folder you choose (e.g. one synced across devices with Syncthing or similar), and automatically loads the newest backup from that folder on startup. Not affiliated with the original developer, and not accepting contributions or issues — this is maintained for personal use only. All credit for the original app goes to the original developer.

---

Cashew is a full-fledged, feature-rich application designed to empower users in managing their finances effectively. Built using Flutter - with Drift's SQL package, and Firebase - this app offers a seamless and intuitive user experience across various devices. Development started in September 2021.

---

## Release

This fork is available only via [GitHub Releases](https://github.com/Marrrshl/Cashew_local-automatic-backup/releases/), installed and auto-updated using [Obtainium](https://github.com/ImranR98/Obtainium).

For the original, actively-developed app (App Store, Google Play, Web App, and upstream GitHub releases), see the [official Cashew repository](https://github.com/jameskokoska/Cashew) and [website](https://cashewapp.web.app/).

### Changelog

Changes and progress for the original app are documented in the upstream [commits](https://github.com/jameskokoska/Cashew/commits/main) and [changelog](https://github.com/jameskokoska/Cashew/blob/main/budget/lib/widgets/showChangelog.dart). This fork does not maintain its own separate changelog beyond its GitHub release notes.

## Key Features

### 💸 Budget Management

- Custom Budgets and Time Periods: Set up personalized budgets with flexible time periods, such as monthly, weekly, daily, or any custom time period that suits your financial planning needs. A custom time period is useful if you plan on setting a one-time travel budget!
- Added Budgets: Selectively add transactions to specific budgets, allowing you to focus on specific expense categories.
- Category Spending Limits per Budget: Set limits for each category within a budget, ensuring responsible spending.
- Past Budget History Viewing: Analyze your spending habits over time by accessing past budget history, enabling comparison and tracking of financial progress.
- Goals: Create spending and saving goals and put transactions towards different purchases or savings. Track your progress towards achieving your financial goals.

### 💰 Transaction Management

- Support for Different Transaction Types: Categorize transactions effectively based on types such as upcoming, subscription, repeating, debts (borrowed), and credit (lent). Each type behaves in certain ways in the interface. Pay your upcoming transactions when you're ready, or mark your lent out transactions as collected.
- Custom Categories: Create personalized categories to organize transactions according to your unique spending habits. Search through multiple icons and select the default option as expenses or income when adding transactions.
- Custom Titles: Automatically assign transactions with the same name to specific categories, saving time and ensuring consistency. These titles are stored in memory and popup when you add another transaction with a similar name.
- Search and Filters: Easily search and filter transactions based on various criteria such as date, category, amount, or custom tags, enabling quick access to information.
- Easy Editing: Long-press and swipe to select multiple budgets, edit accordingly as needed or delete multiple at once.

### 💱 Financial Flexibility

- Multiple Currencies and Accounts: Manage finances across different currencies and accounts with up-to-date conversion rates for accurate calculations and effortless currency conversions. The interface shows the original amount added and the converted amount to the selected account.
- Switch Accounts and Currencies with Ease: On the homepage, easily select a different account and currency and everything will be converted automatically in an instant.

### 🔒 Enhanced Security and Accessibility

- Biometric Lock: Secure budget data using biometric authentication, adding an extra layer of privacy.
- Google Login: Conveniently log in to the app using your Google account, ensuring a streamlined and hassle-free authentication process. **Note: not configured/functional in this fork.**

### 🎨 User Experience and Design

- Material You Design: Enjoy a visually appealing and modern interface, following the principles of Material You design for a delightful user experience.
- Custom Accent Color: Personalize the app by selecting a custom accent color that suits your style, or follow that of the system.
- Light and Dark Mode: Seamlessly switch between light and dark themes to optimize visibility and reduce eye strain.
- Customizable Home Screen: Tailor the home screen layout and widgets to display the financial information that matters most to you, providing a personalized and efficient dashboard.
- Detailed Graph Visuals: Gain valuable insights into spending patterns through detailed and interactive graphs, visualizing financial data at a glance.
- Beautiful Adaptive UI: A responsive user interface that adapts flawlessly to both web and mobile platforms, providing an immersive and consistent user experience across devices.

### ☁ Backup and Syncing

- Local Automatic Backup (this fork): Choose a folder (e.g. one synced across devices with Syncthing or similar), and the app automatically writes a rolling backup on every data change and loads the newest backup on startup — no Google account required.
- Google Drive Backup: Safeguard budget data by utilizing Google Drive's backup functionality, allowing easy restoration of data if needed. **Note: not configured/functional in this fork.**

### 💿 Smart Automation

- Notifications: Stay informed about important financial events and receive timely reminders for budget goals, transactions, and upcoming due dates.
- Import CSV Files: Seamlessly import financial data by uploading CSV files, facilitating a smooth transition from other applications or platforms.
- Import Google Sheets: Seamlessly import Google Sheets tables, quickly importing many transactions from a spreadsheet.
- App Links: Automatically create transactions with pre-filled data using app linking (documentation below)

## App Links

Only supported in the Android and Web App versions as of now. App links allow direct navigation and automation of actions using application URLs. Some examples are below:

### Examples (for Android)

Ensure Cashew is installed on the device you are launching these URLs from.

#### Example 1: Create an expense transaction for 100 with the category Shopping at the current time

> https://cashewapp.web.app/addTransaction?amount=-100&title=All%20the%20shopping&category=Shopping&notes=Went%20shopping

#### Example 2: Create an income transaction with a missing category at the current time

> https://cashewapp.web.app/addTransaction?amount=100&title=Income&notes=Got%20money

#### Example 3: Open the add transaction page with a custom date with prefilled details

> https://cashewapp.web.app/addTransactionRoute?amount=-50&title=All%20the%20shopping&notes=Went%20shopping&date=2024-03-02

#### Example 4: Create multiple transactions with one link using JSON

> https://cashewapp.web.app/addTransaction?JSON=%7B%22transactions%22%3A%5B%7B%22amount%22%3A%22-100%22%2C%20%22notes%22%3A%22This%20is%20a%20note%22%2C%20%22category%22%3A%22Shopping%22%7D%2C%7B%22amount%22%3A%22-150%22%2C%20%22notes%22%3A%22This%20is%20a%20note%202%22%7D%5D%7D

See `JSON List of Transactions` below to view how the link is formatted.

### Routes

| Routes for Android                          | Routes for Web App                             |
| ------------------------------------------- | ---------------------------------------------- |
| `https://cashewapp.web.app/[Endpoint here]` | `https://budget-track.web.app/[Endpoint here]` |

### Endpoints

| Endpoint               | Description                                                               |
| ---------------------- | ------------------------------------------------------------------------- |
| `/addTransaction`      | Add a new transaction without a UI prompt (unless a category is missing). |
| `/addTransactionRoute` | Open the add new transaction route with information filled in.            |

### Parameters

| Parameter     | Description                                                                                                                                                                                                                                                                                          | Required | Default         |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------- |
| `amount`      | The amount of the transaction. If negative, it represents an expense; if positive, it represents income.                                                                                                                                                                                             | No       | 0               |
| `title`       | The title of the transaction. If an associated title is found and the category is not set, the associated title's category will be used.                                                                                                                                                             | No       | Empty string    |
| `notes`       | The notes associated with the transaction.                                                                                                                                                                                                                                                           | No       | Empty string    |
| `date`        | The date of the transaction. Supported string formats can be found in the `getCommonDateFormats()` method [here](https://github.com/jameskokoska/Cashew/blob/5.2.3%2B328/budget/lib/struct/commonDateFormats.dart).                                                                                  | No       | Current time    |
| `category`    | The name of the category to add the transaction to. Executes a name search, takes the first entry, not case sensitive.                                                                                                                                                                               | No       | Prompt user     |
| `subcategory` | The name of the subcategory to add the transaction to. If provided, it overwrites the category if a subcategory is found under a main category. Executes a name search, takes the first entry, not case sensitive.                                                                                   | No       | None            |
| `account`     | The name of the account. Executes a name search, takes the first entry, not case sensitive.                                                                                                                                                                                                          | No       | Primary account |
| `JSON`        | A list of JSON objects of transactions. If provided, Cashew will import a list/multiple transactions at once. Each JSON object in the list can use any of the aforementioned parameters. The JSON object should be keyed with `transactions` followed by the list of objects. See the example below. | No       | None            |

<details> 
  <summary>Detailed Parameters</summary>

The following is a list of all and additional (not fully supported) parameters that can be passed in. They are ordered in terms of precedence, the parameters at the top will be parsed before the ones below. Therefore, overlapping fields will be proceeded by the first parameter.

**Class:** related parameters will have the same class.

**Standalone parameters:** only this parameter will be used, all other parameters will be ignored.

App link parsing can be found [here](https://github.com/jameskokoska/Cashew/blob/main/budget/lib/widgets/util/deepLinks.dart).

| Class | Parameter        | Description                                                                                                                                                                                                                                                                                                                              | Required | Default         | Standalone |
| ----- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------- | ---------- |
| a     | `messageToParse` | Uses a scanner template to parse the passed in message. Only `date` or `dateCreated` can be passed along with this standalone parameter. All other fields will be constructed by the scanner template. Scanner templates are not enabled in Cashew by default. To enable this feature, enable `Notification Transactions` debug feature. | None     | None            | Yes        |
| b     | `JSON`           | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | None            | Yes        |
| c     | `subcategoryPk`  | The primary key of the subcategory entry within the database.                                                                                                                                                                                                                                                                            | No       | None            |
| c     | `subcategory`    | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | None            |
| c     | `categoryPk`     | The primary key of the category entry within the database.                                                                                                                                                                                                                                                                               | No       | Prompt user     |
| c     | `category`       | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | Prompt user     |
| d     | `walletPk`       | The primary key of the wallet entry within the database.                                                                                                                                                                                                                                                                                 | No       | Primary account |
| d     | `account`        | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | Primary account |
| d     | `wallet`         | Same as `account`.                                                                                                                                                                                                                                                                                                                       | No       | Primary account |
| e     | `date`           | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | Current time    |
| e     | `dateCreated`    | Same as `date`.                                                                                                                                                                                                                                                                                                                          | No       | Current time    |
| f     | `amount`         | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | 0               |
| g     | `title`          | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | Empty string    |
| g     | `name`           | Same as `title`.                                                                                                                                                                                                                                                                                                                         | No       | Empty string    |
| h     | `notes`          | Description in the above table.                                                                                                                                                                                                                                                                                                          | No       | Empty string    |
| h     | `note`           | Same as `notes`.                                                                                                                                                                                                                                                                                                                         | No       | Empty string    |

</details>

### JSON List of Transactions

The input JSON for `addTransaction` and `addTransactionRoute` should follow the following format:

```JSON
{
  "transactions":[
    { ... },
    { ... },
    { ... }
  ]
}
```

As an example:

```JSON
{
  "transactions": [
    {
      "amount": "-100",
      "notes": "This is a note",
      "category": "Shopping"
    },
    {
      "amount": "-150",
      "notes": "This is a note 2"
    }
  ]
}
```

Don't forget to encode the JSON in the URL as JSON uses invalid URI characters. Once encoded, the output link would look something like:

> https://cashewapp.web.app/addTransaction?JSON=%7B%22transactions%22%3A%5B%7B%22amount%22%3A%22-100%22%2C%20%22notes%22%3A%22This%20is%20a%20note%22%2C%20%22category%22%3A%22Shopping%22%7D%2C%7B%22amount%22%3A%22-150%22%2C%20%22notes%22%3A%22This%20is%20a%20note%202%22%7D%5D%7D

### Testing

#### Using ADB

You can use ADB to test app links. For example

```shell
adb shell am start -a android.intent.action.VIEW -d "https://cashewapp.web.app/addTransaction?amount=-70\&title=Grocery%20Shopping\&date=2024-03-02\&category=Food\&subcategory=Groceries\&notes=Bought%20fruits%20and%20vegetables\&account=test"
```

#### Using links

You can click links and open them with Cashew. See the example section above to test.

## Bundled Packages

This repository contains, bundled in, modified versions of the discontinued packages listed below. They can be found in the folder `/budget/packages`

- https://pub.dev/packages/implicitly_animated_reorderable_list
- https://pub.dev/packages/sliding_sheet

## Developer Notes

These notes are inherited from the original project and remain accurate for working with this codebase.

### Android Release

- To build an app-bundle Android release, run `flutter build appbundle --release`

Note: required Android SDK.

### GitHub release

- Create a tag for the current version specified in `pubspec.yaml`
- `git tag <version>`
- Push the tag
- `git push origin <version>`
- Create the release and upload binaries

### Scripts

`deploy_and_build_windows.bat`

- Deploy to Firebase and build the apk and appbundle (not used in this fork; Firebase deployment is not configured here)

`open_release_builds.bat`

- Opens the location of the built apk and appbundle

`update_translations.bat`

- Downloads the latest version of Cashew translations. Runs `budget\assets\translations\generate-translations.py`

### Develop Wirelessly on Android

- `adb tcpip 5555`
- `adb connect <IP>`
- Get the phone's IP by going to `About Phone` > `Status Information` > `IP Address`

### Migrate Database

1. Make any database changes to the schema and tables
2. Bump the schema version
   - Change `int schemaVersionGlobal = ...+1` in `tables.dart`
3. Make sure you are in application root directory
   - `cd .\budget\`
4. Generate database code
   - Run `dart run build_runner build`
5. Export the new schema
   - Generate schema dump for the newly created schema
   - Replace `[schemaVersion]` in the command below with the value of `schemaVersionGlobal`
   - Run `dart run drift_dev schema dump lib\database\tables.dart drift_schemas//drift_schema_v[schemaVersion].json`
   - Read more: https://drift.simonbinder.eu/docs/advanced-features/migrations/#exporting-the-schema
6. Generate step-by-step migrations
   - Run `dart run drift_dev schema steps drift_schemas/ lib\database\schema_versions.dart`
7. Implement migration strategy
   - Edit `await stepByStep(...)` function in `tables.dart` and add the migration strategy for the new version migration

### Get Platform

- Use `getPlatform()` from `functions.dart`
- Since `Platform` is not supported on web, we must create a wrapper and always use this to determine the current platform

### Push Route

- If we want to navigate to a new page, stick to `pushRoute(context, page)` function from `functions.dart`
- It handles the platform routing and `PageRouteBuilder`

### Wallets vs. Accounts

- `Wallets` have been been renamed to `Accounts` on the front-end but internally, the name `Wallet` is still used.

### Objectives vs. Goals

- `Objectives` have been been renamed to `Goals` on the front-end but internally, the name `Objectives` is still used.

### Long Term Loans

- Long term loans create a goal. However, the goals total is not used. Instead the total of the goal is calculated by totalling the proper polarity of transactions of the opposite type. For example, if it was a loan of 100$ lent out, the initial transaction would be 100$ of negative polarity (expense) and that would be the total of the goal. When a payment is made, it is made in the opposite (positive) polarity (income) and added to the total 'paid back'. We can easily find how much is remaining by taking the difference (or the addition including polarities).
