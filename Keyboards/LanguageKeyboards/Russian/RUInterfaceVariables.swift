//
//  RUInterfaceVariables.swift
//
//  Constants and functions to load the Russian Scribe keyboard.
//

public enum RussianKeyboardConstants {

  // Keyboard key layouts.
  static let letterKeysPhone = [
    ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"],
    ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
    ["shift", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "delete"],
    ["123", "selectKeyboard", "space", "return"] // "undoArrow"
  ]

  static let numberKeysPhone = [
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
    ["-", "/", ":", ";", "(", ")", "₽", "&", "@", "\""],
    ["#+=", ".", ",", "?", "!", "'", "delete"],
    ["АБВ", "selectKeyboard", "space", "return"] // "undoArrow"
  ]

  static let symbolKeysPhone = [
    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
    ["_", "\\", "|", "~", "<", ">", "$", "€", "£", "·"],
    ["123", ".", ",", "?", "!", "'", "delete"],
    ["АБВ", "selectKeyboard", "space", "return"] // "undoArrow"
  ]

  static let letterKeysPad = [
    ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "delete"],
    ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э", "return"],
    ["shift", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", ".", "shift"],
    [".?123", "selectKeyboard", "space", ".?123", "hideKeyboard"] // "undoArrow"
  ]

  static let numberKeysPad = [
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "—", "delete"],
    ["@", "#", "№", "₽", "ʼ", "&", "*", "(", ")", "'", "\"", "return"],
    ["#+=", "%", "_", "-", "+", "=", "≠", ";", ":", ",", ".", "#+="],
    ["АБВ", "selectKeyboard", "space", "АБВ", "hideKeyboard"] // "undoArrow"
  ]

  static let symbolKeysPad = [
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "—", "delete"],
    ["$", "€", "£", "¥", "±", "·", "`", "[", "]", "{", "}", "return"],
    ["123", "§", "|", "~", "...", "^", "\\", "<", ">", "!", "?", "123"],
    ["АБВ", "selectKeyboard", "space", "АБВ", "hideKeyboard"] // "undoArrow"
  ]

  // Alternate key vars.
  static let keysWithAlternates = ["е", "ь"]
  static let keysWithAlternatesLeft = ["е"]
  static let keysWithAlternatesRight = ["ь"]

  static let еAlternateKeys = ["ë"]
  static let ьAlternateKeys = ["Ъ"]
}

/// Provides a Russian keyboard layout.
func setRUKeyboardLayout() {
  if DeviceType.isPhone {
    letterKeys = RussianKeyboardConstants.letterKeysPhone
    numberKeys = RussianKeyboardConstants.numberKeysPhone
    symbolKeys = RussianKeyboardConstants.symbolKeysPhone
  } else {
    letterKeys = RussianKeyboardConstants.letterKeysPad
    numberKeys = RussianKeyboardConstants.numberKeysPad
    symbolKeys = RussianKeyboardConstants.symbolKeysPad
  }

  keysWithAlternates = RussianKeyboardConstants.keysWithAlternates
  keysWithAlternatesLeft = RussianKeyboardConstants.keysWithAlternatesLeft
  keysWithAlternatesRight = RussianKeyboardConstants.keysWithAlternatesRight
  еAlternateKeys = RussianKeyboardConstants.еAlternateKeys
  ьAlternateKeys = RussianKeyboardConstants.ьAlternateKeys
  currencySymbol = "₽"
  currencySymbolAlternates = roubleAlternateKeys
  spaceBar = "Пробел"
  invalidCommandMsg = "Нет в каталоге"

  translateKeyLbl = "Перевести"
  translatePrompt = commandPromptSpacing + "ru -› \(getControllerLanguageAbbr()): "
  translatePromptAndCursor = translatePrompt + commandCursor

  conjugateKeyLbl = "Спрягать"
  conjugatePrompt = commandPromptSpacing + "Спрягать: "
  conjugatePromptAndCursor = conjugatePrompt + commandCursor

  pluralKeyLbl = "Множ"
  pluralPrompt = commandPromptSpacing + "Множ: "
  pluralPromptAndCursor = pluralPrompt + commandCursor
}
