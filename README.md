<div align="center">
  <a href="https://github.com/scribe-org/Scribe-iOS"><img src="https://github.com/scribe-org/Scribe-iOS/blob/main/Resources/Scribe-iOS_logo_transparent.png" width=612 height=164></a>
</div>

---

<!--
[![license](https://img.shields.io/github/license/scribe-org/Scribe-iOS.svg)](https://github.com/scribe-org/Scribe-iOS/blob/main/LICENSE.txt)
-->

[![coc](https://img.shields.io/badge/coc-Contributor%20Covenant-ff69b4.svg)](https://github.com/scribe-org/Scribe-iOS/blob/main/.github/CODE_OF_CONDUCT.md)

[![Available on the App Store](http://cl.ly/WouG/Download_on_the_App_Store_Badge_US-UK_135x40.svg)](https://www.apple.com/app-store/)

### Scribe language keyboards for iOS

**Scribe-iOS** is a pack of iOS and iPadOS system keyboards that color nouns typed in messaging apps based on their gender. The keyboards give users the confidence that they are using words in an appropriate context, and further helps language learners remember word genders through color association. Planned functionality includes in-chat verb conjugation and other grammar query features.

Being fully open-source, Scribe prioritizes user privacy and doesn't ask for access to any user data. German and Spanish are currently the only supported languages, but the Scribe team has interest in creating keyboards for all languages of interest.

# **Contents**<a id="contents"></a>

- [Setup](#setup)
- [Features](#features)
- [To-Do](#to-do)

# Setup [`↩`](#contents) <a id="setup"></a>

Users access Scribe language keyboards through the following:

- Download Scribe from the [App Store](https://www.apple.com/app-store/)
- Settings -> General -> Keyboard -> Keyboards -> Add New Keyboard
- Select from the available Scribe keyboards
- When typing press 🌐 to select keyboards

# Features [`↩`](#contents) <a id="features"></a>

### Noun-gender coloration

Scribe colors nouns according to the following conventions:

- Feminine nouns are colored red 🟥
- Masculine nouns are colored blue 🟦
- Neutral nouns are colored green 🟩
- Plural nouns are colored orange 🟧
- Nouns with more than one gender are multicolored

Markers are also planned for color blind users (see issue).

<!--
# Grammar queries

Scribe allows users to programmatically query words based on grammar rules. Examples of this include:

- /pl(noun) provides the plural of the noun
- /fps(verb_infinitive) provides the first person singular of the verb
- /pp(verb_infinitive) provides the past participle of the verb
-->

### iOS and iPadOS system keyboard functionality

The goal is for Scribe keyboards have all the functionality of system keyboards.

<details><summary><strong>Currently implemented features</strong></summary>
<p>

- iPhone and iPad support (WIP)
- Dynamic layouts for cross-device performance
- Portrait and landscape views (WIP)
- Auto-capitalization
- The double space period shortcut
- Typing `'` returns to the alphabetic keyboard
- Dark mode compatibility (WIP)
- Hold-to-select characters (WIP)

</p>
</details>

# To-Do [`↩`](#contents) <a id="to-do"></a>

Please see the [contribution guidelines](https://github.com/scribe-org/Scribe-iOS/blob/main/.github/CONTRIBUTING.md) if you are interested in contributing to this project. Work that is in progress or could be implemented includes:

- Creating an MVP

- Expanding Scribe's support for current languages by adding words and their genders to the [language files](https://github.com/scribe-org/Scribe-iOS)

  - Pull requests are more than welcome for this!

- Localizing the Scribe app across various languages and regions

<!--

- Adding support for more languages to Scribe-iOS [(see issues)](https://github.com/scribe-org/Scribe-iOS/issues)

- Planning the potential implementation of a verb conjugation command (see issue)

  - Example 1: typing /fps chosen_infinitive could conjugate the verb to first person singular

  - Example 2: typing /pp chosen_infinitive could query the verb's past participle

- Planning the potential implementation of a plural command (see issue)

  - Example: typing /pl chosen_noun could provide the plural for the noun

- Exploring the possibility of doing in-messenger translations

    - Example: type /tr and entering a word would bring up a selectable list
-->

- Moving grammar files to a new repository in [scribe-org](https://github.com/scribe-org) and accessing them remotely to allow Android and extension access (see issue)

  - This would likely best be implemented via a Python package that allows users to access data within JSON files stored in the package

  - The creation of a repository with grammar rules for Scribe languages would be a valuable resource for Scribe and the open-source community

- Converting Scribe keyboards into downloadable packs within the app (see issue)

  - This would help keep the app size to a minimum

- Make shift key change color after being pressed (see issue)

  - Note: we want ⇧ to switch to `⬆` and ⇪ to also be filled in

- Creating a UI field where grammar queries would take place when triggered (see issue)

  - This would allow for the removal of parentheses around words that the user wants to convert

- Make the space bar read the name of the keyboard when it's switched to (see issue)

- Providing an option in the Scribe app to change the coloration into another kind of indicator that would work for color blind users (see issue)

  - Simply adding markers like (M), (F), (N) and (P) before words in the preview would work
