# Kirkja "README.md" Template
## How to markdown like a game designer: a cheat-sheet and style-guide with examples.
This "README.md" is a markdown file that describes the folder within which it resides. If a "README.md" file is located in a repo folder, GitHub.com will use it to display **formatted text** on the folder's main page in any modern web browser.

## GitHub Syntax
![GitHub Logo Tooltip](https://github.githubassets.com/favicons/favicon-dark.png)

[Official Markdown Documentation](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

### Headings
- We use headings to describe the hierarchy or structure of the subject. Headings on GitHub.com range from biggest `#` to smallest `######`.

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

### Text Formatting

#### `_italic_`
- We use _italic formatting_ for new _vocabulary_, dev industry _jargon_, and trailing _(Note: meta comments.)_

#### `**bold**`
- We use **bold formatting** when drawing the user's attention to the **important parts** so the user can **skim the documents quickly**.

#### `_**italic + bold**_`
- We use _**italic + bold formatting**_ when the two previous formats overlap.

#### `Inline Code`
- We use `inline code` with single backticks surrounding the word to designate key, or mouse buttons, and in-editor menu and button navigation. And for `code` `variables` and `classes`.

#### `~~Strikethru~~`
- We use ~~strikethru formatting~~ when we want to preserve a previous statement or idea, but is no longer relevant. _(Should probably leave a note as to why it's important to keep.)_

### Images
Are there any ways to make this image smaller? Not with pure Markdown.
![Kirkja Logo](http://kirkja.org/favicon.png)

### URL Links
Use `[link_name](url_address)` to add links.
- [Kirkja Official Website](https://kirkja.org/)

### Blockquotes
We are able to quote source material with the `>` + `Space` characters.

 **PAGE ONE**
> :sun_with_face: Far out in the uncharted backwaters of the unfashionable end of the western spiral arm of the Galaxy lies a small unregarded yellow sun.
>
>  :earth_asia: Orbiting this at a distance of roughly ninety-two million miles is an utterly insignificant little blue green planet whose ape-descended *life forms are so amazingly primitive that they still think digital watches are a pretty neat idea*.
>
> :money_with_wings: This planet has - or rather had - a problem, which was this: most of the people on it were unhappy for pretty much of the time. Many solutions were suggested for this problem, but most of these were largely concerned with the movements of *small green pieces of paper*, which is odd because ***on the whole it wasn't the small green pieces of paper that were unhappy***.
>
> :watch: And so the problem remained; lots of the people were mean, and most of them were miserable, even the ones with digital watches.
>
> :evergreen_tree: Many were increasingly of the opinion that they'd all made a big mistake in coming down from the trees in the first place. And some said that even the trees had been a bad move, and that no one should ever have left the oceans.
>
> :coffee: And then, one Thursday, nearly two thousand years after one man had been nailed to a tree for saying how great it would be to be nice to people for a change, one girl sitting on her own in a small café in Rickmansworth suddenly realized what it was that had been going wrong all this time, and she finally knew how the world could be made a good and happy place. This time it was right, it would work, and no one would have to get nailed to anything.
>
> :sob: Sadly, however, before she could get to a phone to tell anyone-about it, a terribly stupid catastrophe occurred, and the idea was lost forever.
>
> :no_entry_sign: This is not her story.
>
> :whale: But it is the story of that terrible stupid catastrophe and some of its consequences.

### Lists
#### Unordered Lists
We are able to create bulleted lists by adding `-` + `Space` before each line item.
- bool = true: **`🗹`**
- bool = false: **`🞎`**
- We use quotes around paths ""

#### Ordered lists
Add `1.` + `Space` before each new line.
1. exist.
1. behave true.
1. make mistakes.
1. atone + grow.

or we may skip ahead by starting the list with a number of our choice.

38. life
1. the
1. universe
1. and
1. everything

#### Indented Lists
`Tab` once before using the `-` character to indent a line.
- exist.
  - behave true.
    - make mistakes.
      - atone + grow.

#### Task Lists
Task lists are more useful within GitHub.com Issues and Projects. The Github.com web UI tracks the tasks as a part of their project management
Add `- [ ]` before each new line.
- [x] exist.
- [x] behave true.
- [ ] make mistakes.
- [ ] atone + grow.

#### Code Block
```gdscript
var dog_legs: int = 4

func _ready():
  print("Our dog has ", dog_legs, " legs.")
```

### Tables
#### Table Syntax
- Use vertical pipes **`|`** to separate table columns.
- The first row of text is displayed as table headers.
- The second row contains the column data justification syntax `---`.
- Rows 3+ are all table data cells.

| Occasion             | Unicode Glyphs              | ASCII Style             |
| :------------------- | :------------------------:  | ----------------------: |
| Justify Left: `:---` | Justify Center: `:---:`     | Justify Right: `---:`   |
| Alphanumeric Keys    | `W` `S` `A` `D`             | [W] [S] [A] [D]         |
| Modifier Keys        | `Shift` `Ctrl` `Alt`        | [Shift] [Ctrl] [Alt]    |
| Arrow Keys           | `🠉` `🠋` `🠈` `🠊` | [Up] [Down] [Left] [Right] |

#### Tested emojis and glyphs.
| Occasion | Glyph / Emoji | Reason |
| --- | --- | --- |
| UI Instructions      | Within Atom, click `Edit` > `Bookmark` > `View All`. |
| Boolean UI           | **`🞎`** **`🗹`** | [false] [true] |
| There is no real way... | to merge cells together. | Það er rist eða ekkert. |

### Hard Rule
---

# Discord Markdown

## Discord Syntax
Discord is made for ease of communication, so its support for Markdown is built around messaging instead of formatting like a web page. *(No lists; no tables)*

[Discord Cheatsheet](https://gist.github.com/matthewzring/9f7bbfd102003963f9be7dbcf7d40e51)

### New Line
- We use `Shift` + `Enter` to start a **new line in the same message**.
- Only press `Enter` when we are ready to send.

### Text Formatting
#### `*Italic*`
- We use *italic* formatting for new *vocabulary*, dev industry *jargon*, and trailing *(Note: GitHub.com seems to also supports the single asterisk formatting.)*

#### `**bold**`
- pass

#### `***italic + bold***`
- pass

#### `~~strikethru~~`
- We use ~~strikethru formatting~~ when we want to preserve a previous statement, but is no longer relevant.

#### `__underline__`
- We use underlines Not sure why the underline isn't supported in GitHub.

#### Spoiler
 - [[Mark as spoiler]]

#### URL Links
As a security measure

### Lists
Making lists in Discord requires manual work:
1. `•` | `‣` | `▪` : Copy a bullet character to use in our list.
1. Paste it to the front of each new line item.
1. Press `Shift` + `Enter` to start a new line item.
