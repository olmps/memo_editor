# memo_editor

A new Flutter project.

## Getting Started

Todo Roadmap:

- [ ] Document and test all current functionality (plus README and ARCHITECTURE files);
- [ ] Dramatically improve UI;
- [ ] Allow to store/update multiple collections (locally);
- [ ] Open Source this;
- [ ] Allow the user to import a given collection from the `memo` repo, using the Github REST API:
  - https://api.github.com/repos/olmps/memo/commits?path=README.md
  - https://docs.github.com/en/rest/reference/repos#list-commits
- [ ] Improve editor usage (probably `flutter-quill` repo changes);
  - Allow using images;
  - Allow specific code highlight;
- Allow a decente experience on all platforms;
- Distribute this application in all platforms.



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