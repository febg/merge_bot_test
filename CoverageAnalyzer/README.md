#  CoverageAnalyzer

## What It Does
Analyzes test coverage in the form of JSON produced from a `.xccovreport` contained in a `.xcresult` build artifact.
Prints results and writes them to a .json file for upstream consumption.

Initially, requires the user (or another script) to extract the JSON. See the "How it Works" section below for more details.

When working with a single coverage report, prints test coverage percentages for each build target in the report, and writes the results to disk as a JSON string.  For each target, includes coverage percentage and a weight percentage comparing lines of code in this target against the project as a whole.

When working with two coverage reports, produces a diff (expressed as +/-%) by comparing per-target coverage percentages from each report, prints them, and writes the results to disk as a JSON string.

## How It Works
When `xcodebuild` builds & runs tests, the output is collected in a `.xcresult` file alongside project build artifacts 

ex. `~/Library/Developer/Xcode/DerivedData/slack-bcuxvvvtdclvllgvjebneduwvxvq/Logs/Test/Test-iOS - Prod-2019.05.11_10-43-31--0700.xcresult`

This file contains coverage data that can be extracted as JSON data via `xcrun xccov`
ex.  `xcrun xccov view testResult.xcresult/1_Test/action.xccovreport --json`

Initially, this tool isn't capable of shelling out itself to extract the JSON coverage, so you'll need do that via another method. Pass the resulting JSON as arguments to this tool.

## How to Use It

**Find the build directory where code action.xccovreport file was generated**

It is usually under
```
  ~/Library/Developer/Xcode/DerivedData/slack-*/Logs/Test/BUILD.xcresult/1_Test/action.xccovreport 
 ```

 **Use Xcode command line tools to extract a JSON representation of action.xccovreport file**

 ```
 xcrun xccov view testResult.xcresult/1_Test/action.xccovreport --json > test_coverage_raw_1.json
 ```

**Edit config file**
(Examples section shows the usage of different commands )

- coverage_analyzer.json 
```
{
  "command": "",
  "reportFiles": [""],
  "pullFiles": [""]
}
```
**Run CoverageAnalyzer by passing the config file path as argument**

 `./CoverageAnalyzer coverage_analyzer.json`


## Examples
### **File-level coverage report for ALL files**

A code coverage report applied to all files in project con be computed using the following config


- Command `command`: String command to analyze all files
- Parameter `reportFiles`: Array containing path to raw JSON coverage report  
- Paramater `pullFiles`: Empty - Not needed since all files are being analyzed

Example config:

**coverage_analyzer.json**

```
{
	"command":"analyze-all",
	"reportFiles": ["test_coverage_raw_1.json"],
	"pullFiles":[]
}
```
Example run: 

`./CoverageAnalyzer coverage_analyzer.json`


Results

- **Report Summary:** report.txt

```
NotificationContent: coverage 0.0%. Weight: 0.0%
NotificationService: coverage 9.0%. Weight: 0.1%
Slack: coverage 29.5%. Weight: 74.6%
SlackAccount: coverage 66.1%. Weight: 0.4%
SlackCalendarInterop: coverage 52.7%. Weight: 0.0%
SlackCoreData: coverage 97.2%. Weight: 0.1%
SlackDataProviders: coverage 83.1%. Weight: 5.1%
SlackDevTools: coverage 20.2%. Weight: 0.4%
SlackEmailInterop: coverage 43.5%. Weight: 0.0%
SlackFoundation: coverage 88.6%. Weight: 3.9%
SlackInstrumentation: coverage 77.8%. Weight: 1.3%
SlackLogging: coverage 28.1%. Weight: 0.7%
SlackMessagesUI: coverage 45.3%. Weight: 4.1%
SlackMessagesUISample: coverage 39.8%. Weight: 0.4%
SlackNetworking: coverage 81.5%. Weight: 1.5%
SlackPlatform: coverage 80.9%. Weight: 0.8%
SlackUI: coverage 58.7%. Weight: 4.6%
SlackUISample: coverage 19.1%. Weight: 0.1%
TSFKit: coverage 86.9%. Weight: 0.8%
share: coverage 18.6%. Weight: 1.0%
```

- **JSON Report:** report_coverage.json

```
{
  "version": "tbd",
  "resultsByName": {
    "SlackInstrumentation": {
      "coverage": 0.778191118344571,
      "weight": 0.013217618984692639,
      "name": "SlackInstrumentation",
      "fileReports": [
        {
          "name": "JankyWindowsMap.swift",
          "weight": 1.8832829574517553,
          "coverage": 100
        },
        {
          "name": "MockLogSyncManager.swift",
          "weight": 0.4417577307602883,
          "coverage": 0
        },
        {
          "name": "MockLogUploaderNetworkManager.swift",
          "weight": 0.3952569169960474,
          "coverage": 94.11764705882352
        }
      ]
    },
    "SlackCoreData": {
      "coverage": 0.971875,
      "weight": 0.000983408062102219,
      "name": "SlackCoreData",
      "fileReports": [
        {
          "name": "SLKCoreDataModel.m",
          "weight": 5.625,
          "coverage": 100
        },
        {
          "name": "ManagedObjectChangeSet.swift",
          "weight": 1.875,
          "coverage": 100
        },
        {
          "name": "ManagedObjectChangeListener.swift",
          "weight": 63.125,
          "coverage": 95.54455445544554
        }
      ]
    },
    "SlackEmailInterop": {
      "coverage": 0.4351851851851852,
      "weight": 0.00033190022095949895,
      "name": "SlackEmailInterop",
      "fileReports": [
        {
          "name": "EmailInteropWebView.swift",
          "weight": 50,
          "coverage": 0
        },
        {
          "name": "EmailAttachmentPresentationObject.swift",
          "weight": 14.814814814814813,
          "coverage": 56.25
        },
        {
          "name": "EmailDetailPresentationObject.swift",
          "weight": 35.18518518518518,
          "coverage": 100
        }
      ]
    }
  }
}
```

### **File-level coverage report for a SET of files**

A code coverage report applied to specific files in project 

**Config:**

- Command `command`: String command to analyze a set of files
- Parameter `reportFiles`: Array containing path to raw JSON coverage report  
- Paramater `pullFiles`: String array representing names of files to be analyzed

Example config:

**coverage_analyzer.json**

```
{
	"command":"analyze-files",
	"reportFiles": ["test_coverage_raw_1.json"],
	"pullFiles":["ContextBlockPresentable.swift", "FileTombstoneView.swift", "Channel.swift"]
}
```
Example run: 

`./CoverageAnalyzer coverage_analyzer.json`

Results

- **Report Summary:** report.txt
```
SlackDataProviders: coverage 83.1%. Weight: 5.1%
SlackMessagesUI: coverage 45.3%. Weight: 4.1%
```

- **JSON Report:** report_coverage.json

```
{
  "version": "tbd",
  "resultsByName": {
    "SlackMessagesUI": {
      "coverage": 0.4527433365505977,
      "weight": 0.041392259963921214,
      "name": "SlackMessagesUI",
      "fileReports": [
        {
          "name": "ContextBlockPresentable.swift",
          "weight": 0.2672804217091098,
          "coverage": 44.44444444444444
        },
        {
          "name": "FileTombstoneView.swift",
          "weight": 0.4677407379909421,
          "coverage": 0
        }
      ]
    },
    "SlackDataProviders": {
      "coverage": 0.8313613003465997,
      "weight": 0.05142609534755792,
      "name": "SlackDataProviders",
      "fileReports": [
        {
          "name": "Channel.swift",
          "weight": 0.5019720329867335,
          "coverage": 94.04761904761905
        }
      ]
    }
  }
}
```

### **Difference between two code coverage reports**

Differenece between any two code coverage reports con be computed using the following config

- Command `command`: String command to analyze a set of files
- Parameter `reportFiles`: Array containing **two** raw JSON coverage report paths (paths to files being analyzed) 
- Paramater `pullFiles`: Empty - Not needed since all files are being analyzed

Example config:

**coverage_analyzer.json**

```
{
	"command":"analyze-diff",
	"reportFiles": ["test_coverage_raw_1.json", "test_coverage_raw_2.json"],
	"pullFiles":[]
}
```
Example run: 

`./CoverageAnalyzer coverage_analyzer.json`

Results
- **Report Summary:** report.txt
```
NotificationContent delta: 0.0%
NotificationService delta: 0.0%
Slack delta: +2.9%
SlackAccount delta: +5.6%
SlackCalendarInterop delta: -4.7%
SlackCoreData delta: +0.0%
SlackDataProviders delta: +0.0%
SlackDevTools delta: +10.3%
SlackEmailInterop delta: 0.0%
SlackFoundation delta: +0.1%
SlackInstrumentation delta: -9.3%
SlackLogging delta: +12.5%
SlackMessagesUI delta: +37.8%
SlackNetworking delta: +2.5%
SlackPlatform delta: +0.7%
SlackUI delta: +43.2%
TSFKit delta: +24.9%
share delta: +15.5%
```
- **JSON Report:** report_coverage.json
```
{
  "deltasByTargetName": {
    "NotificationService": 0,
    "SlackCoreData": 0.00008816614420070756,
    "SlackLogging": 0.12495181538782099,
    "SlackDevTools": 0.1034098708429525,
    "NotificationContent": 0,
    "SlackAccount": 0.055625350015341635,
    "SlackDataProviders": 0.00046843104196170327,
    "SlackFoundation": 0.0009723116040958324,
    "SlackEmailInterop": 0,
    "SlackInstrumentation": -0.09260902020755923,
    "TSFKit": 0.24863443977595667,
    "SlackNetworking": 0.025405872601322543,
    "Slack": 0.029126392323748695,
    "SlackMessagesUI": 0.3780786946877781,
    "SlackPlatform": 0.006995179263756368,
    "share": 0.15530137605474503,
    "SlackCalendarInterop": -0.04737570531246671,
    "SlackUI": 0.4315518793857981
  },
  "firstReportVersion": "tbd",
  "secondReportVersion": "tbd"
}
```

## Testing

**Testing can be done in two ways**
- Using Xcode 
```
Product -> Test (or using ⌘U shortcut)
```

- Using Xcode command line
From root directory
```
xcodebuild -project CoverageAnalyzer.xcodeproj/ -scheme CoverageAnalyzer test
```

## TODO

- Add line coverage functionality
- Add file / line coverage results to summary 
- Re-factor Analyzer.analyze() method to encode JSON from a string 
- Add tests to re-factored version of Analyzer.analyze()
