# memo_editor

A tool to help manage your own [memo](https://github.com/olmps/memo) collections.

This tool wraps a rich-text editor that allows you to (locally) manage and store custom collections, with import/export
features to make a seamless experience when dealing with the core project's collection format.

## Few things to consider

Before using this tool, be aware that it's in a state that we consider pre-alpha, meaning that it should have a
plethora of bugs and visual inconsistencies - really, we didn't put almost any effort while thinking about the layout.
The current version is only meant as a PoC of a editor that should make things easier for anyone that wants to create
its own collection of memos, or even import one from the core [memo](https://github.com/olmps/memo) project and update
with your own personal preferences.

Nonetheless, we are looking into where this tool stands today and where we can go from here to improve the `memo`
ecosystem, you can take a look at this project's issues to get to know what are the next steps.

This pre-alpha version is available at [https://memo-editor.netlify.app/](https://memo-editor.netlify.app/).

## Setup

If you have no idea how to install Flutter and run it locally, check this
[_Get started_](https://flutter.dev/docs/get-started/install).

If you have Flutter setup locally, on the project's root folder, install pubspec dependencies by running
`flutter pub get` and make sure that, if you're not using vscode, to also generate the files through
`flutter pub run build_runner build`. If you're using vscode, it should be all setup, described in details in the
[section](#running-tasks) below.

### Running Tasks

Because this project's uses `build_runner`, it's important to know when to use its tasks.

When you open this project, the `Generate build_runner files` should automatically run but if for some reason the vscode
do not, open the vscode `Run Build Task` (`CMD + SHIFT + B` shortcut) and run `Generate build_runner files`.

If you're planning to develop and change any file that auto-generates, open the vscode `Run Build Task`
(`CMD + SHIFT + B` shortcut) and run `Watch build_runner files`, or simply launch using the `DEV - Tool + Watch`
configuration of `launch.json`.

## Example Collection Format

Minimal example of a collection, appropriately called `my_example_collection.json`, holding a single memo:

```json
{
  "id": "my_example_collection",
  "name": "My Example Collection",
  "description": "My description",
  "category": "My category",
  "tags": ["My single tag"],
  "memos": [
    {
      "question": [],
      "answer": []
    },
  ]
}
```