# Confluence-layout Extension For Quarto

This filter is designed to enable quarto syntax for establishing columns with  `quarto publish confluence` without having to explicitly use [confluence storage format](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html)


## Installing


```bash
quarto add jtlandis/confluence-layout
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

This format understands `grid/ g-col-(2,4,6,8)` or `columns / column` specifications.

Only up to 3 columns are supported by confluence, thus any additional columns will force a single column layout.

The filter tries to guess the layout based on the classes of the nested columns.

* under "grid" with 2 columns, the first column's class is inspected.
  * if `g-col-4` --> left side bar layout
  * if `g-col-8` --> right side bar layout
  * everything else: --> even layout
* under "grid" with 3 columns, the middle column is inspected.
  * if `g-col-8` --> side bar layouts
  * everything else: --> even layout

* under "columns" the even layouts are used each time as I do not have enough `.lua` experience to walk the class attributes and guess the most likely layout.


## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

