//
//  KeyboardViewController.swift
//
//  Classes for the parent keyboard view controller that language keyboards inherit and keyboard keys.
//

import UIKit

/// The parent KeyboardViewController class that is inherited by all Scribe keyboards.
class KeyboardViewController: UIInputViewController {
  var keyboardView: UIView!

  // Stack views that are populated with they keyboard rows.
  @IBOutlet weak var stackView0: UIStackView!
  @IBOutlet weak var stackView1: UIStackView!
  @IBOutlet weak var stackView2: UIStackView!
  @IBOutlet weak var stackView3: UIStackView!

  /// Changes the keyboard state such that the letters view will be shown.
  func changeKeyboardToLetterKeys() {
    keyboardState = .letters
    loadKeys()
  }

  /// Changes the keyboard state such that the numbers view will be shown.
  func changeKeyboardToNumberKeys() {
    keyboardState = .numbers
    shiftButtonState = .normal
    loadKeys()
  }

  /// Changes the keyboard state such that the symbols view will be shown.
  func changeKeyboardToSymbolKeys() {
    keyboardState = .symbols
    loadKeys()
  }

  // MARK: Display Activation Functions

  /// Function to load the keyboard interface into which keyboardView is instantiated.
  func loadInterface() {
    let keyboardNib = UINib(nibName: "Keyboard", bundle: nil)
    keyboardView = keyboardNib.instantiate(withOwner: self, options: nil)[0] as? UIView
    keyboardView.translatesAutoresizingMaskIntoConstraints = true
    view.addSubview(keyboardView)

    // Override keyboards switching to others for translation and prior Scribe commands.
    switchInput = false
    scribeKeyState = false
    commandState = false
    conjugateView = false

    // Set height for Scribe command functionality.
    annotationHeight = nounAnnotation1.frame.size.height

    loadKeys()
  }

  /// Activates a button by assigning key touch functions for their given actions.
  ///
  /// - Parameters
  ///   - btn: the button to be activated.
  func activateBtn(btn: UIButton) {
    btn.addTarget(self, action: #selector(executeKeyActions), for: .touchUpInside)
    btn.addTarget(self, action: #selector(keyTouchDown), for: .touchDown)
    btn.addTarget(self, action: #selector(keyUntouched), for: .touchDragExit)
    btn.isUserInteractionEnabled = true
  }

  /// Deactivates a button by removing key touch functions for their given actions and making it clear.
  ///
  /// - Parameters
  ///   - btn: the button to be deactivated.
  func deactivateBtn(btn: UIButton) {
    btn.setTitle("", for: .normal)
    btn.backgroundColor = UIColor.clear
    btn.removeTarget(self, action: #selector(executeKeyActions), for: .touchUpInside)
    btn.removeTarget(self, action: #selector(keyTouchDown), for: .touchDown)
    btn.removeTarget(self, action: #selector(keyUntouched), for: .touchDragExit)
    btn.isUserInteractionEnabled = false
  }

  // MARK: Override UIInputViewController Functions

  /// Includes adding custom view sizing constraints.
  override func updateViewConstraints() {
    super.updateViewConstraints()

    checkLandscapeMode()
    if DeviceType.isPhone {
      if isLandscapeView == true {
        keyboardHeight = 200
      } else {
        keyboardHeight = 270
      }
    } else if DeviceType.isPad {
      if isLandscapeView == true {
        keyboardHeight = 320
      } else {
        keyboardHeight = 340
      }
    }

    let heightConstraint = NSLayoutConstraint(
      item: view!,
      attribute: NSLayoutConstraint.Attribute.height,
      relatedBy: NSLayoutConstraint.Relation.equal,
      toItem: nil,
      attribute: NSLayoutConstraint.Attribute.notAnAttribute,
      multiplier: 1.0,
      constant: keyboardHeight
    )
    view.addConstraint(heightConstraint)

    keyboardView.frame.size = view.frame.size
  }

  // Button to be assigned as the select keyboard button if necessary.
  @IBOutlet var selectKeyboardButton: UIButton!

  /// Includes the following:
  /// - Assignment of the proxy
  /// - Loading the Scribe interface
  /// - Making keys letters
  /// - Adding the keyboard selector target
  override func viewDidLoad() {
    super.viewDidLoad()

    checkDarkModeSetColors()
    proxy = textDocumentProxy as UITextDocumentProxy
    keyboardState = .letters
    loadInterface()

    self.selectKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
  }

  /// Includes hiding the keyboard selector button if it is not needed for the current device.
  override func viewWillLayoutSubviews() {
    self.selectKeyboardButton.isHidden = !self.needsInputModeSwitchKey
    super.viewWillLayoutSubviews()
  }

  /// Includes updateViewConstraints to change the keyboard height given device type and orientation.
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateViewConstraints()
  }

  /// Includes:
  /// - updateViewConstraints to change the keyboard height
  /// - A call to loadKeys to reload the display after an orientation change
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    updateViewConstraints()
    loadKeys()
  }

  /// Overrides the previous color variables if the user switches between light and dark mode.
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    checkDarkModeSetColors()
    loadKeys()
  }

  // MARK: Scribe Command Elements

  // The background for the Scribe command elements.
  @IBOutlet var commandBackground: UILabel!
  func setCommandBackground() {
    commandBackground.backgroundColor = keyboardBackColor
    commandBackground.isUserInteractionEnabled = false
  }

  // The bar that displays language logic or is typed into for Scribe commands.
  @IBOutlet var commandBar: CommandBar!
  @IBOutlet var commandBarShadow: UIButton!
  @IBOutlet var commandBarBlend: UILabel!

  /// Clears the text found in the command bar.
  func clearCommandBar() {
    if commandState == false {
      commandBar.textColor = keyCharColor
      commandBar.text = " "
    }

    // Trigger the removal of the noun or preposition annotations.
    hideAnnotations(annotationDisplay: getAnnotationLabels())
  }

  /// Deletes in the proxy or command bar given the current constraints.
  func handleDeleteButtonPressed() {
    if commandState != true {
      proxy.deleteBackward()
    } else if !(commandState == true && allPrompts.contains(commandBar.text!)) {
      guard
        let inputText = commandBar.text,
        !inputText.isEmpty
      else {
        return
      }
      commandBar.text = commandBar.text!.deletePriorToCursor()
    } else {
      backspaceTimer?.invalidate()
      backspaceTimer = nil
    }
  }

  // The button used to display Scribe commands and its shadow.
  @IBOutlet var scribeKey: ScribeKey!
  @IBOutlet var scribeKeyShadow: UIButton!

  /// Links various UI elements that interact concurrently.
  func linkElements() {
    scribeKey.shadow = scribeKeyShadow
    commandBar.shadow = commandBarShadow
    commandBar.blend = commandBarBlend
  }

  // Buttons used to trigger Scribe command functionality.
  @IBOutlet var translateKey: UIButton!
  @IBOutlet var conjugateKey: UIButton!
  @IBOutlet var pluralKey: UIButton!

  /// Sets up all buttons that are associated with Scribe commands.
  func setCommandBtns() {
    setBtn(btn: translateKey, color: commandKeyColor, name: "Translate", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKey, color: commandKeyColor, name: "Conjugate", canCapitalize: false, isSpecial: false)
    setBtn(btn: pluralKey, color: commandKeyColor, name: "Plural", canCapitalize: false, isSpecial: false)

    activateBtn(btn: translateKey)
    activateBtn(btn: conjugateKey)
    activateBtn(btn: pluralKey)
  }

  @IBOutlet var conjugateShiftLeftBtn: UIButton!
  @IBOutlet var conjugateShiftRightBtn: UIButton!

  // Buttons for the conjugation view.
  @IBOutlet var conjugateKeyFPS: UIButton!
  @IBOutlet var conjugateKeySPS: UIButton!
  @IBOutlet var conjugateKeyTPS: UIButton!
  @IBOutlet var conjugateKeyFPP: UIButton!
  @IBOutlet var conjugateKeySPP: UIButton!
  @IBOutlet var conjugateKeyTPP: UIButton!

  /// Returns all buttons for the 3x2 conjugation display.
  func get3x2ConjButtons() -> [UIButton] {
    let conjugationButtons: [UIButton] = [
      conjugateKeyFPS, conjugateKeySPS, conjugateKeyTPS, conjugateKeyFPP, conjugateKeySPP, conjugateKeyTPP
    ]

    return conjugationButtons
  }

  @IBOutlet var conjugateKeyTL: UIButton!
  @IBOutlet var conjugateKeyTR: UIButton!
  @IBOutlet var conjugateKeyBL: UIButton!
  @IBOutlet var conjugateKeyBR: UIButton!

  /// Returns all buttons for the 2x2 conjugation display
  func get2x2ConjButtons() -> [UIButton] {
    let conjugationButtons: [UIButton] = [
      conjugateKeyTL, conjugateKeyTR, conjugateKeyBL, conjugateKeyBR
    ]

    return conjugationButtons
  }

  // Labels for the conjugation view buttons.
  // Note that we're using buttons as labels weren't allowing for certain constraints to be set.
  @IBOutlet var conjugateLblFPS: UIButton!
  @IBOutlet var conjugateLblSPS: UIButton!
  @IBOutlet var conjugateLblTPS: UIButton!
  @IBOutlet var conjugateLblFPP: UIButton!
  @IBOutlet var conjugateLblSPP: UIButton!
  @IBOutlet var conjugateLblTPP: UIButton!

  /// Returns all labels for the 3x2 conjugation display.
  func get3x2ConjLabels() -> [UIButton] {
    let conjugationLabels: [UIButton] = [
      conjugateLblFPS, conjugateLblSPS, conjugateLblTPS, conjugateLblFPP, conjugateLblSPP, conjugateLblTPP
    ]

    return conjugationLabels
  }

  @IBOutlet var conjugateLblTL: UIButton!
  @IBOutlet var conjugateLblTR: UIButton!
  @IBOutlet var conjugateLblBL: UIButton!
  @IBOutlet var conjugateLblBR: UIButton!

  /// Returns all labels for the 2x2 conjugation display.
  func get2x2ConjLabels() -> [UIButton] {
    let conjugationLabels: [UIButton] = [
      conjugateLblTL, conjugateLblTR, conjugateLblBL, conjugateLblBR
    ]

    return conjugationLabels
  }

  /// Sets up all buttons and labels that are associated with the 3x2 conjugation display.
  func setConj3x2View() {
    setBtn(btn: conjugateKeyFPS, color: keyColor, name: "firstPersonSingular", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeySPS, color: keyColor, name: "secondPersonSingular", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeyTPS, color: keyColor, name: "thirdPersonSingular", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeyFPP, color: keyColor, name: "firstPersonPlural", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeySPP, color: keyColor, name: "secondPersonPlural", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeyTPP, color: keyColor, name: "thirdPersonPlural", canCapitalize: false, isSpecial: false)

    for btn in get3x2ConjButtons() {
      activateBtn(btn: btn)
    }

    if DeviceType.isPad {
      var conjugationFontDivisor = 3.5
      if isLandscapeView {
        conjugationFontDivisor = 4
      }
      for btn in get3x2ConjButtons() {
        btn.titleLabel?.font =  .systemFont(ofSize: letterButtonWidth / conjugationFontDivisor)
      }
    }
  }

  /// Sets up all buttons and labels that are associated with the 2x2 conjugation display.
  func setConj2x2View() {
    setBtn(btn: conjugateKeyTL, color: keyColor, name: "conjugateTopLeft", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeyTR, color: keyColor, name: "conjugateTopRight", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeyBL, color: keyColor, name: "conjugateBottomLeft", canCapitalize: false, isSpecial: false)
    setBtn(btn: conjugateKeyBR, color: keyColor, name: "conjugateBottomRight", canCapitalize: false, isSpecial: false)

    for btn in get2x2ConjButtons() {
      activateBtn(btn: btn)
    }

    if DeviceType.isPad {
      var conjugationFontDivisor = 3.5
      if isLandscapeView {
        conjugationFontDivisor = 4
      }
      for btn in get2x2ConjButtons() {
        btn.titleLabel?.font =  .systemFont(ofSize: letterButtonWidth / conjugationFontDivisor)
      }
    }
  }

  /// Sets up all buttons and labels for the conjugation view given constraints to determine the dimensions.
  func setConjugationBtns() {
    // Set the conjugation view to 2x2 for Swedish and Russian past tense.
    if controllerLanguage == "Swedish" {
      conjugateAlternateView = true
    } else if controllerLanguage == "Russian" && ruConjugationState == .past {
      conjugateAlternateView = true
    } else {
      conjugateAlternateView = false
    }

    // The base conjugation view is 3x2 for first, second, and third person in singular and plural.
    if conjugateAlternateView == false {
      setConj3x2View()
    } else {
      setConj2x2View()
    }

    // Setup the view shift buttons.
    setBtn(
      btn: conjugateShiftLeftBtn,
      color: keyColor,
      name: "shiftConjugateLeft",
      canCapitalize: false,
      isSpecial: false
    )
    setBtn(
      btn: conjugateShiftRightBtn,
      color: keyColor,
      name: "shiftConjugateRight",
      canCapitalize: false,
      isSpecial: false
    )

    activateBtn(btn: conjugateShiftLeftBtn)
    activateBtn(btn: conjugateShiftRightBtn)

    // Make all labels clear and set their font for if they will be used.
    let allConjLabels: [UIButton] = get3x2ConjLabels() + get2x2ConjLabels()
    for lbl in allConjLabels {
      lbl.backgroundColor = UIColor.clear
      lbl.setTitleColor(specialKeyColor, for: .normal)
      lbl.isUserInteractionEnabled = false
      if DeviceType.isPad {
        lbl.titleLabel?.font =  .systemFont(ofSize: letterButtonWidth / 4)
      }
    }
  }

  /// Activates all buttons that are associated with the conjugation display.
  func activateConjugationDisplay() {
    activateBtn(btn: conjugateShiftLeftBtn)
    activateBtn(btn: conjugateShiftRightBtn)

    if conjugateAlternateView == false {
      for elem in get3x2ConjButtons() {
        activateBtn(btn: elem)
      }

      for elem in get2x2ConjButtons() {
        deactivateBtn(btn: elem)
      }
    }

    if conjugateAlternateView == true {
      for elem in get3x2ConjButtons() {
        deactivateBtn(btn: elem)
      }

      for elem in get2x2ConjButtons() {
        activateBtn(btn: elem)
      }
    }
  }

  /// Deactivates all buttons that are associated with the conjugation display.
  func deactivateConjugationDisplay() {
    deactivateBtn(btn: conjugateShiftLeftBtn)
    conjugateShiftLeftBtn.tintColor = UIColor.clear
    deactivateBtn(btn: conjugateShiftRightBtn)
    conjugateShiftRightBtn.tintColor = UIColor.clear

    let allConjLabels: [UIButton] = get3x2ConjLabels() + get2x2ConjLabels()
    let allConjElements: [UIButton] = get3x2ConjButtons() + get2x2ConjButtons() + allConjLabels

    for elem in allConjElements {
      deactivateBtn(btn: elem)
    }

    for lbl in allConjLabels {
      lbl.setTitle("", for: .normal)
    }
  }

  /// Assign the conjugations that will be selectable in the conjugation display.
  func assignConjStates() {
    var conjugationStateFxn: () -> String = deGetConjugationState
    if controllerLanguage != "Swedish" {
      conjugationStateFxn = keyboardConjStateDict[controllerLanguage] as! () -> String
    }

    if !["Russian", "Swedish"].contains(controllerLanguage) {
      tenseFPS = conjugationStateFxn() + "FPS"
      tenseSPS = conjugationStateFxn() + "SPS"
      tenseTPS = conjugationStateFxn() + "TPS"
      tenseFPP = conjugationStateFxn() + "FPP"
      tenseSPP = conjugationStateFxn() + "SPP"
      tenseTPP = conjugationStateFxn() + "TPP"

    } else if controllerLanguage == "Russian" {
      if conjugateAlternateView == false {
        tenseFPS = ruGetConjugationState() + "FPS"
        tenseSPS = ruGetConjugationState() + "SPS"
        tenseTPS = ruGetConjugationState() + "TPS"
        tenseFPP = ruGetConjugationState() + "FPP"
        tenseSPP = ruGetConjugationState() + "SPP"
        tenseTPP = ruGetConjugationState() + "TPP"
      } else {
        tenseTopLeft = "pastMasculine"
        tenseTopRight = "pastFeminine"
        tenseBottomLeft = "pastNeutral"
        tenseBottomRight = "pastPlural"
      }

    } else if controllerLanguage == "Swedish" {
      let swedishTenses = svGetConjugationState()

      tenseTopLeft = swedishTenses[0]
      tenseTopRight = swedishTenses[1]
      tenseBottomLeft = swedishTenses[2]
      tenseBottomRight = swedishTenses[3]
    }
  }

  /// Sets the label of the conjugation state and assigns the current tenses that are accessed to label the buttons.
  func setConjugationState() {
    // Assign the conjugations that will be selectable.
    assignConjStates()

    // Set the view title and its labels.
    var conjugationTitleFxn: () -> String = deGetConjugationTitle
    var conjugationLabelsFxn: () -> Void = deSetConjugationLabels
    if controllerLanguage != "Swedish" {
      conjugationTitleFxn = keyboardConjTitleDict[controllerLanguage] as! () -> String
      conjugationLabelsFxn = keyboardConjLabelDict[controllerLanguage] as! () -> Void
    }

    if !["Russian", "Swedish"].contains(controllerLanguage) {
      commandBar.text = conjugationTitleFxn()
      conjugationLabelsFxn()
    } else if controllerLanguage == "Russian" {
      commandBar.text = ruGetConjugationTitle()
      ruSetConjugationLabels()
    } else if controllerLanguage == "Swedish" {
      commandBar.text = svGetConjugationTitle()
      svSetConjugationLabels()
    }

    // Assign labels that have been set by SetConjugationLabels functions.
    conjugateLblFPS.setTitle("  " + labelFPS, for: .normal)
    conjugateLblSPS.setTitle("  " + labelSPS, for: .normal)
    conjugateLblTPS.setTitle("  " + labelTPS, for: .normal)
    conjugateLblFPP.setTitle("  " + labelFPP, for: .normal)
    conjugateLblSPP.setTitle("  " + labelSPP, for: .normal)
    conjugateLblTPP.setTitle("  " + labelTPP, for: .normal)

    conjugateLblTL.setTitle("  " + labelTopLeft, for: .normal)
    conjugateLblTR.setTitle("  " + labelTopRight, for: .normal)
    conjugateLblBL.setTitle("  " + labelBottomLeft, for: .normal)
    conjugateLblBR.setTitle("  " + labelBottomRight, for: .normal)

    if conjugateAlternateView == false {
      allTenses = [tenseFPS, tenseSPS, tenseTPS, tenseFPP, tenseSPP, tenseTPP]
      allConjugationBtns = get3x2ConjButtons()
    } else {
      allTenses = [tenseTopLeft, tenseTopRight, tenseBottomLeft, tenseBottomRight]
      allConjugationBtns = get2x2ConjButtons()
    }

    // Populate conjugation view buttons.
    for index in 0..<allTenses.count {
      if verbs?[verbToConjugate]![allTenses[index]] as? String == "" {
        // Assign the invalid message if the conjugation isn't present in the directory.
        styleBtn(btn: allConjugationBtns[index], title: invalidCommandMsg, radius: keyCornerRadius)
      } else {
        conjugationToDisplay = verbs?[verbToConjugate]![allTenses[index]] as! String
        if inputWordIsCapitalized && deConjugationState != .indicativePerfect {
          conjugationToDisplay = conjugationToDisplay.capitalized
        }
        styleBtn(btn: allConjugationBtns[index], title: conjugationToDisplay, radius: keyCornerRadius)
      }
    }
  }

  // Labels to annotate noun genders.
  @IBOutlet var nounAnnotation1: UILabel!
  @IBOutlet var nounAnnotation2: UILabel!
  @IBOutlet var nounAnnotation3: UILabel!
  @IBOutlet var nounAnnotation4: UILabel!
  @IBOutlet var nounAnnotation5: UILabel!

  // Labels to annotate preposition cases.
  // There are multiple versions to account for when a word is both a noun and a preposition.
  // In this case a shifted set is used - the noun annotations precede those of prepositions.
  @IBOutlet var prepAnnotation11: UILabel!
  @IBOutlet var prepAnnotation12: UILabel!
  @IBOutlet var prepAnnotation13: UILabel!
  @IBOutlet var prepAnnotation14: UILabel!
  @IBOutlet var prepAnnotation21: UILabel!
  @IBOutlet var prepAnnotation22: UILabel!
  @IBOutlet var prepAnnotation23: UILabel!
  @IBOutlet var prepAnnotation24: UILabel!
  @IBOutlet var prepAnnotation31: UILabel!
  @IBOutlet var prepAnnotation32: UILabel!
  @IBOutlet var prepAnnotation33: UILabel!
  @IBOutlet var prepAnnotation34: UILabel!

  /// Returns all available annotation labels.
  func getAnnotationLabels() -> [UILabel] {
    let nounAnnotationDisplay: [UILabel] = [
      nounAnnotation1, nounAnnotation2, nounAnnotation3, nounAnnotation4, nounAnnotation5
    ]

    let prepAnnotationDisplay: [UILabel] = [
      prepAnnotation11, prepAnnotation12, prepAnnotation13, prepAnnotation14,
      prepAnnotation21, prepAnnotation22, prepAnnotation23, prepAnnotation24,
      prepAnnotation31, prepAnnotation32, prepAnnotation33, prepAnnotation34
    ]

    return nounAnnotationDisplay + prepAnnotationDisplay
  }

  /// Returns the noun annotation labels.
  func getNounAnnotationLabels() -> [UILabel] {
    let nounAnnotationDisplay: [UILabel] = [
      nounAnnotation1, nounAnnotation2, nounAnnotation3, nounAnnotation4, nounAnnotation5
    ]

    return nounAnnotationDisplay
  }

  /// Returns the preposition annotation labels given the current number of noun annotations displayed.
  func getPrepAnnotationLabels() -> [UILabel] {
    // Initialize an array of display elements and count how many will be changed.
    // This is initialized based on how many noun annotations have already been assigned (max 2).
    var prepAnnotationDisplay: [UILabel] = [UILabel]()
    if nounAnnotationsToDisplay == 0 {
      prepAnnotationDisplay = [prepAnnotation11, prepAnnotation12, prepAnnotation13, prepAnnotation14]
    } else if nounAnnotationsToDisplay == 1 {
      prepAnnotationDisplay = [prepAnnotation21, prepAnnotation22, prepAnnotation23, prepAnnotation24]
    } else if nounAnnotationsToDisplay == 2 {
      prepAnnotationDisplay = [prepAnnotation31, prepAnnotation32, prepAnnotation33, prepAnnotation34]
    }
    return prepAnnotationDisplay
  }

  /// Styles the labels within the annotation display and removes user interactions.
  func styleAnnotations() {
    let nounAnnotationDisplay = getNounAnnotationLabels()

    let prepAnnotationDisplay: [UILabel] = [
      prepAnnotation11, prepAnnotation12, prepAnnotation13, prepAnnotation14,
      prepAnnotation21, prepAnnotation22, prepAnnotation23, prepAnnotation24,
      prepAnnotation31, prepAnnotation32, prepAnnotation33, prepAnnotation34
    ]

    for annotationDisplay in nounAnnotationDisplay {
      annotationDisplay.clipsToBounds = true
      annotationDisplay.layer.cornerRadius = keyCornerRadius / 2
      annotationDisplay.textAlignment = NSTextAlignment.center
      annotationDisplay.isUserInteractionEnabled = false
      annotationDisplay.font = .systemFont(ofSize: annotationHeight * 0.70)
      annotationDisplay.textColor = commandBarColor
    }

    for annotationDisplay in prepAnnotationDisplay {
      annotationDisplay.clipsToBounds = true
      annotationDisplay.layer.cornerRadius = keyCornerRadius / 2
      annotationDisplay.textAlignment = NSTextAlignment.center
      annotationDisplay.isUserInteractionEnabled = false
      annotationDisplay.font = .systemFont(ofSize: annotationHeight * 0.65)
      annotationDisplay.textColor = commandBarColor
    }
  }

  // MARK: Load keys

  /// Loads the keys given the current constraints.
  func loadKeys() {
    // The name of the language keyboard that's referencing KeyboardViewController.
    controllerLanguage = classForCoder.description().components(separatedBy: ".KeyboardViewController")[0]

    setCommandBackground()
    setKeyboard()
    linkElements()
    setCommandBtns()
    setConjugationBtns()
    invalidState = false

    // Clear interface from the last state.
    keyboardKeys.forEach {$0.removeFromSuperview()}
    paddingViews.forEach {$0.removeFromSuperview()}

    keyboardView.backgroundColor? = keyboardBackColor

    // buttonWidth determined per keyboard by the top row.
    if isLandscapeView == true {
      if DeviceType.isPhone {
        letterButtonWidth = (UIScreen.main.bounds.height - 5) / CGFloat(letterKeys[0].count) * 1.5
        numSymButtonWidth = (UIScreen.main.bounds.height - 5) / CGFloat(numberKeys[0].count) * 1.5
      } else if DeviceType.isPad {
        letterButtonWidth = (UIScreen.main.bounds.height - 5) / CGFloat(letterKeys[0].count) * 1.2
        numSymButtonWidth = (UIScreen.main.bounds.height - 5) / CGFloat(numberKeys[0].count) * 1.2
      }
    } else {
      letterButtonWidth = (UIScreen.main.bounds.width - 6) / CGFloat(letterKeys[0].count) * 0.9
      numSymButtonWidth = (UIScreen.main.bounds.width - 6) / CGFloat(numberKeys[0].count) * 0.9
    }

    // Derive keyboard given current states and set widths.
    switch keyboardState {
    case .letters:
      keyboard = letterKeys
      buttonWidth = letterButtonWidth
      // Auto-capitalization if the cursor is at the start of the proxy.
      if proxy.documentContextBeforeInput?.count == 0 {
        shiftButtonState = .shift
      }
    case .numbers:
      keyboard = numberKeys
      buttonWidth = numSymButtonWidth
    case .symbols:
      keyboard = symbolKeys
      buttonWidth = numSymButtonWidth
    }

    // Derive corner radii.
    if DeviceType.isPhone {
      if isLandscapeView == true {
        keyCornerRadius = buttonWidth / 9
        commandKeyCornerRadius = buttonWidth / 5
      } else {
        keyCornerRadius = buttonWidth / 6
        commandKeyCornerRadius = buttonWidth / 3
      }
    } else if DeviceType.isPad {
      if isLandscapeView == true {
        keyCornerRadius = buttonWidth / 12
        commandKeyCornerRadius = buttonWidth / 7.5
      } else {
        keyCornerRadius = buttonWidth / 9
        commandKeyCornerRadius = buttonWidth / 5
      }
    }

    styleAnnotations()
    if annotationState == false {
      hideAnnotations(annotationDisplay: getAnnotationLabels())
    }

    if !conjugateView { // normal keyboard view
      for view in [stackView0, stackView1, stackView2, stackView3] {
        view?.isUserInteractionEnabled = true
        view?.isLayoutMarginsRelativeArrangement = true

        // Set edge insets for stack views to provide vertical key spacing.
        if view == stackView0 {
          view?.layoutMargins = UIEdgeInsets(top: 3, left: 0, bottom: 8, right: 0)
        } else if view == stackView1 {
          view?.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 6, right: 0)
        } else if view == stackView2 {
          view?.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 6, right: 0)
        } else if view == stackView3 {
          view?.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 5, right: 0)
        }
      }

      // Set up and activate Scribe key and other command elements.
      scribeKey.set()
      activateBtn(btn: scribeKey)
      styleBtn(btn: scribeKey, title: "Scribe", radius: commandKeyCornerRadius)
      scribeKey.setLeftCornerRadius()
      scribeKey.setShadow()
      commandBar.set()
      deactivateConjugationDisplay()

      if scribeKeyState {
        scribeKey.toEscape()
        scribeKey.setFullCornerRadius()
        scribeKey.setEscShadow()

        commandBar.hide()

        styleBtn(btn: translateKey, title: translateKeyLbl, radius: commandKeyCornerRadius)
        styleBtn(btn: conjugateKey, title: conjugateKeyLbl, radius: commandKeyCornerRadius)
        styleBtn(btn: pluralKey, title: pluralKeyLbl, radius: commandKeyCornerRadius)

        if DeviceType.isPhone {
          translateKey.titleLabel?.font = .systemFont(ofSize: annotationHeight * 0.65)
          conjugateKey.titleLabel?.font = .systemFont(ofSize: annotationHeight * 0.65)
          pluralKey.titleLabel?.font = .systemFont(ofSize: annotationHeight * 0.65)
        } else if DeviceType.isPad {
          translateKey.titleLabel?.font = .systemFont(ofSize: annotationHeight * 0.9)
          conjugateKey.titleLabel?.font = .systemFont(ofSize: annotationHeight * 0.9)
          pluralKey.titleLabel?.font = .systemFont(ofSize: annotationHeight * 0.9)
        }

      } else {
        if commandState == true {
          scribeKey.toEscape()
        }
        deactivateBtn(btn: conjugateKey)
        deactivateBtn(btn: translateKey)
        deactivateBtn(btn: pluralKey)

        commandBar.setCornerRadiusAndShadow()

        if commandState == false {
          commandBar.text = ""
        }
        commandBar.sizeToFit()
      }

      let numRows = keyboard.count
      for row in 0...numRows - 1 {
        for idx in 0...keyboard[row].count - 1 {
          // Set up button as a key with its values and properties.
          let btn = KeyboardKey(type: .custom)
          btn.row = row
          btn.idx = idx
          btn.style()
          btn.setChar()
          btn.setCharSize()

          let key: String = btn.key

          // Pad before key is added.
          var leftPadding = CGFloat(0)
          if DeviceType.isPhone
            && key == "y"
            && ["German", "Swedish"].contains(controllerLanguage)
            && switchInput != true {
            leftPadding = buttonWidth / 3
            addPadding(to: stackView2, width: leftPadding, key: "y")
          }
          if DeviceType.isPhone
            && key == "a"
            && (controllerLanguage == "Portuguese" || switchInput == true) {
            leftPadding = buttonWidth / 4
            addPadding(to: stackView1, width: leftPadding, key: "a")
          }
          if DeviceType.isPad
            && key == "a"
            && (controllerLanguage == "Portuguese" || switchInput == true) {
            leftPadding = buttonWidth / 3
            addPadding(to: stackView1, width: leftPadding, key: "a")
          }
          if DeviceType.isPad
            && key == "@"
            && (controllerLanguage == "Portuguese" || switchInput == true) {
            leftPadding = buttonWidth / 3
            addPadding(to: stackView1, width: leftPadding, key: "@")
          }
          if DeviceType.isPad
            && key == "€"
            && (controllerLanguage == "Portuguese" || switchInput == true) {
            leftPadding = buttonWidth / 3
            addPadding(to: stackView1, width: leftPadding, key: "€")
          }

          keyboardKeys.append(btn)
          switch row {
          case 0: stackView0.addArrangedSubview(btn)
          case 1: stackView1.addArrangedSubview(btn)
          case 2: stackView2.addArrangedSubview(btn)
          case 3: stackView3.addArrangedSubview(btn)
          default:
            break
          }

          // Special key styling.
          if key == "delete" {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(keyLongPressed(_:)))
            btn.addGestureRecognizer(longPressRecognizer)
          }

          if key == "selectKeyboard" {
            selectKeyboardButton = btn
            self.selectKeyboardButton.addTarget(
              self,
              action: #selector(handleInputModeList(from:with:)),
              for: .allTouchEvents
            )
            styleIconBtn(btn: btn, color: keyCharColor, iconName: "globe")
          }

          if key == "hideKeyboard" {
            styleIconBtn(btn: btn, color: keyCharColor, iconName: "keyboard.chevron.compact.down")
          }

          if key == "shift" {
            styleIconBtn(btn: btn, color: keyCharColor, iconName: "shift")
          }

          if key == "return" {
            styleIconBtn(btn: btn, color: keyCharColor, iconName: "arrow.turn.down.left")
          }

          if key == "delete" {
            styleIconBtn(btn: btn, color: keyCharColor, iconName: "delete.left")
          }

          // Setting hold-to-select functionality.
          let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(setAlternatesView(sender:))
          )
          longPressGesture.minimumPressDuration = 1.2

          if keysWithAlternates.contains(key) {
            btn.addGestureRecognizer(longPressGesture)
          }

          // Pad after key is added.
          var rightPadding = CGFloat(0)
          if DeviceType.isPhone
            && key == "m"
            && ["German", "Swedish"].contains(controllerLanguage)
            && switchInput != true {
            rightPadding = buttonWidth / 3
            addPadding(to: stackView2, width: rightPadding, key: "m")
          }
          if DeviceType.isPhone
            && key == "l"
            && (controllerLanguage == "Portuguese" || switchInput == true) {
            rightPadding = buttonWidth / 4
            addPadding(to: stackView1, width: rightPadding, key: "l")
          }

          // Set the width of the key given device and the given key.
          btn.adjustKeyWidth()

          // Extend button touch areas.
          var widthOfSpacing = CGFloat(0)
          if keyboardState == .letters {
            widthOfSpacing = (
              (UIScreen.main.bounds.width - 6.0)
              - (CGFloat(letterKeys[0].count) * buttonWidth)
              ) / (CGFloat(letterKeys[0].count)
              - 1.0
            )
          } else {
            widthOfSpacing = (
              (UIScreen.main.bounds.width - 6.0)
              - (CGFloat(numberKeys[0].count) * numSymButtonWidth)
              ) / (CGFloat(letterKeys[0].count)
              - 1.0
            )
          }

          switch row {
          case 0:
            btn.topShift = -5
            btn.bottomShift = -6
          case 1:
            btn.topShift = -6
            btn.bottomShift = -6
          case 2:
            btn.topShift = -6
            btn.bottomShift = -6
          case 3:
            btn.topShift = -6
            btn.bottomShift = -5
          default:
            break
          }

          // Pad left and right based on if the button has been shifted.
          if leftPadding == CGFloat(0) {
            btn.leftShift = -(widthOfSpacing / 2)
          } else {
            btn.leftShift = -(leftPadding)
          }
          if rightPadding == CGFloat(0) {
            btn.rightShift = -(widthOfSpacing / 2)
          } else {
            btn.rightShift = -(rightPadding)
          }

          // Activate keyboard interface buttons.
          activateBtn(btn: btn)
          if key == "shift" || key == spaceBar {
            btn.addTarget(self, action: #selector(keyMultiPress(_:event:)), for: .touchDownRepeat)
          }
        }
      }

      // End padding.
      switch keyboardState {
      case .letters:
        break
      case .numbers:
        break
      case .symbols:
        break
      }

    } else {
      // Load conjugation view.
      for view in [stackView0, stackView1, stackView2, stackView3] {
        view?.isUserInteractionEnabled = false
      }

      scribeKey.toEscape()
      scribeKey.setLeftCornerRadius()

      commandBar.backgroundColor = commandBarColor
      commandBarBlend.backgroundColor = commandBarColor
      commandBar.textColor = keyCharColor

      deactivateBtn(btn: conjugateKey)
      deactivateBtn(btn: translateKey)
      deactivateBtn(btn: pluralKey)

      activateConjugationDisplay()
      setConjugationState()

      styleBtn(btn: conjugateShiftLeftBtn, title: "", radius: keyCornerRadius)
      styleIconBtn(btn: conjugateShiftLeftBtn, color: keyCharColor, iconName: "chevron.left")
      styleBtn(btn: conjugateShiftRightBtn, title: "", radius: keyCornerRadius)
      styleIconBtn(btn: conjugateShiftRightBtn, color: keyCharColor, iconName: "chevron.right")
    }
  }

  // MARK: Button Actions

  /// Triggers actions based on the press of a key.
  ///
  /// - Parameters
  ///   - sender: the button pressed as sender.
  @IBAction func executeKeyActions(_ sender: UIButton) {
    guard let originalKey = sender.layer.value(
      forKey: "original"
    ) as? String,
      let keyToDisplay = sender.layer.value(forKey: "keyToDisplay") as? String else {
        return
      }

    guard let isSpecial = sender.layer.value(forKey: "isSpecial") as? Bool else { return }
    sender.backgroundColor = isSpecial ? specialKeyColor : keyColor

    // Disable the possibility of a double shift call.
    if originalKey != "shift" {
      capsLockPossible = false
    }
    // Disable the possibility of a double space period call.
    if originalKey != spaceBar {
      doubleSpacePeriodPossible = false
    }

    // Reset the Russian verbs view after a selection.
    ruConjugationState = .present

    switch originalKey {
    case "Scribe":
      if proxy.selectedText != nil && commandState != true { // annotate word
        if scribeKeyState {
          scribeKeyState = false
        }
        loadKeys()
        selectedNounAnnotation(
          commandBar: commandBar,
          nounAnnotationDisplay: getNounAnnotationLabels(),
          annotationDisplay: getAnnotationLabels()
        )
        selectedPrepAnnotation(
          commandBar: commandBar,
          prepAnnotationDisplay: getPrepAnnotationLabels()
        )
      } else {
        if commandState == true { // escape
          scribeKeyState = false
          commandState = false
          getTranslation = false
          getConjugation = false
          getPlural = false
          switchInput = false
        } else if scribeKeyState == false && conjugateView != true { // ScribeKey
          scribeKeyState = true
          activateBtn(btn: translateKey)
          activateBtn(btn: conjugateKey)
          activateBtn(btn: pluralKey)
        } else { // escape
          conjugateView = false
          scribeKeyState = false
          commandState = false
          getTranslation = false
          getConjugation = false
          getPlural = false
          switchInput = false
        }
        loadKeys()
      }

    // Switch to translate state.
    case "Translate":
      scribeKeyState = false
      commandState = true
      getTranslation = true
      switchInput = true
      // Always start in letters with a new keyboard.
      keyboardState = .letters
      loadKeys()
      commandBar.text = translatePromptAndCursor

    // Switch to conjugate state.
    case "Conjugate":
      scribeKeyState = false
      commandState = true
      getConjugation = true
      loadKeys()
      commandBar.text = conjugatePromptAndCursor

    // Switch to plural state.
    case "Plural":
      scribeKeyState = false
      if controllerLanguage == "German" { // capitalize for nouns
        if shiftButtonState == .normal {
          shiftButtonState = .shift
        }
      }
      commandState = true
      getPlural = true
      loadKeys()
      commandBar.text = pluralPromptAndCursor

    // Move displayed conjugations to the left in order if able.
    case "shiftConjugateLeft":
      if controllerLanguage == "French" {
        frConjugationStateLeft()
      } else if controllerLanguage == "German" {
        deConjugationStateLeft()
      } else if controllerLanguage == "Portuguese" {
        ptConjugationStateLeft()
      } else if controllerLanguage == "Russian" {
        ruConjugationStateLeft()
      } else if controllerLanguage == "Spanish" {
        esConjugationStateLeft()
      } else if controllerLanguage == "Swedish" {
        svConjugationStateLeft()
      }
      loadKeys()

    // Move displayed conjugations to the right in order if able.
    case "shiftConjugateRight":
      if controllerLanguage == "French" {
        frConjugationStateRight()
      } else if controllerLanguage == "German" {
        deConjugationStateRight()
      } else if controllerLanguage == "Portuguese" {
        ptConjugationStateRight()
      } else if controllerLanguage == "Russian" {
        ruConjugationStateRight()
      } else if controllerLanguage == "Spanish" {
        esConjugationStateRight()
      } else if controllerLanguage == "Swedish" {
        svConjugationStateRight()
      }
      loadKeys()

    case "firstPersonSingular":
      returnConjugation(keyPressed: sender, requestedTense: tenseFPS)
      loadKeys()

    case "secondPersonSingular":
      returnConjugation(keyPressed: sender, requestedTense: tenseSPS)
      loadKeys()

    case "thirdPersonSingular":
      returnConjugation(keyPressed: sender, requestedTense: tenseTPS)
      loadKeys()

    case "firstPersonPlural":
      returnConjugation(keyPressed: sender, requestedTense: tenseFPP)
      loadKeys()

    case "secondPersonPlural":
      returnConjugation(keyPressed: sender, requestedTense: tenseSPP)
      loadKeys()

    case "thirdPersonPlural":
      returnConjugation(keyPressed: sender, requestedTense: tenseTPP)
      loadKeys()

    case "conjugateTopLeft":
      returnConjugation(keyPressed: sender, requestedTense: tenseTopLeft)
      loadKeys()

    case "conjugateTopRight":
      returnConjugation(keyPressed: sender, requestedTense: tenseTopRight)
      loadKeys()

    case "conjugateBottomLeft":
      returnConjugation(keyPressed: sender, requestedTense: tenseBottomLeft)
      loadKeys()

    case "conjugateBottomRight":
      returnConjugation(keyPressed: sender, requestedTense: tenseBottomRight)
      loadKeys()

    case "delete":
      if shiftButtonState == .shift {
        shiftButtonState = .normal
        loadKeys()
      }
      // Prevent the command state prompt from being deleted.
      if commandState == true && allPrompts.contains((commandBar?.text!)!) {
        shiftButtonState = .shift // Auto-capitalization
        loadKeys()
        return
      }
      handleDeleteButtonPressed()
      // Auto-capitalization if delete goes to the start of the proxy.
      if proxy.documentContextBeforeInput == nil && commandState != true {
        if keyboardState == .letters && shiftButtonState == .normal {
          shiftButtonState = .shift
          loadKeys()
        }
      }
      clearCommandBar()

    case spaceBar:
      if commandState != true {
        proxy.insertText(" ")
        if [". ", "? ", "! "].contains(proxy.documentContextBeforeInput?.suffix(2)) {
          shiftButtonState = .shift
        }
        if keyboardState != .letters {
          changeKeyboardToLetterKeys()
        }
      } else {
        commandBar.text! = (commandBar?.text!.insertPriorToCursor(char: " "))!
        if [
          ". " + commandCursor,
          "? " + commandCursor,
          "! " + commandCursor
        ].contains(String(commandBar.text!.suffix(3))) {
          shiftButtonState = .shift
        }
        if keyboardState != .letters {
          changeKeyboardToLetterKeys()
        }
      }
      // Prevent annotations from being triggered during commands.
      if getConjugation == false && getTranslation == false {
        typedNounAnnotation(
          commandBar: commandBar,
          nounAnnotationDisplay: getNounAnnotationLabels(),
          annotationDisplay: getAnnotationLabels()
        )
        typedPrepAnnotation(
          commandBar: commandBar,
          prepAnnotationDisplay: getPrepAnnotationLabels()
        )
        annotationState = false
        prepAnnotationState = false
        nounAnnotationsToDisplay = 0
      }

      if proxy.documentContextBeforeInput?.suffix("  ".count) == "  " {
        clearCommandBar()
      }
      doubleSpacePeriodPossible = true

    case "selectKeyboard":
      self.advanceToNextInputMode()

    case "hideKeyboard":
      self.dismissKeyboard()

    case "return":
      if getTranslation && commandState == true { // translate state
        queryTranslation(commandBar: commandBar)
        getTranslation = false
        switchInput = false
      }
      if getConjugation && commandState == true { // conjugate state
        // Reset to the most basic conjugations.
        deConjugationState = .indicativePresent
        let triggerConjugationState = triggerConjugation(commandBar: commandBar)
        if triggerConjugationState == true {
          conjugateView = true
          loadKeys()
        } else {
          invalidState = true
        }
        getConjugation = false
      }
      if getPlural && commandState == true { // plural state
        queryPlural(commandBar: commandBar)
        getPlural = false
      }
      if commandState == false { // normal return button
        proxy.insertText("\n")
        clearCommandBar()
      } else if invalidState == true { // invalid state
        commandState = false

        // Return to the original input method if it has been switched away from.
        if switchInput == true {
          switchInput = false
          loadKeys()
        }

        autoCapAtStartOfProxy()
        if isAlreadyPluralState != true {
          commandBar.text = commandPromptSpacing + invalidCommandMsg
        }
        commandBar.textColor = keyCharColor

        invalidState = false
        isAlreadyPluralState = false
      } else {
        commandState = false
        clearCommandBar()
        autoCapAtStartOfProxy()
        loadKeys()
        // Avoid showing noun annotation instead of conjugation state header.
        if conjugateView == false {
          typedNounAnnotation(
            commandBar: commandBar,
            nounAnnotationDisplay: getNounAnnotationLabels(),
            annotationDisplay: getAnnotationLabels()
          )
          typedPrepAnnotation(
            commandBar: commandBar,
            prepAnnotationDisplay: getPrepAnnotationLabels()
          )
          annotationState = false
          prepAnnotationState = false
          nounAnnotationsToDisplay = 0
        }
      }

    case "123":
      changeKeyboardToNumberKeys()
      clearCommandBar()

    case ".?123":
      changeKeyboardToNumberKeys()
      clearCommandBar()

    case "#+=":
      changeKeyboardToSymbolKeys()
      clearCommandBar()

    case "ABC":
      changeKeyboardToLetterKeys()
      clearCommandBar()
      autoCapAtStartOfProxy()

    case "АБВ":
      changeKeyboardToLetterKeys()
      clearCommandBar()
      autoCapAtStartOfProxy()

    case "'":
      // Change back to letter keys.
      if commandState != true {
        proxy.insertText("'")
      } else {
        commandBar.text! = (commandBar.text!.insertPriorToCursor(char: "'"))
      }
      changeKeyboardToLetterKeys()
      clearCommandBar()

    case "shift":
      shiftButtonState = shiftButtonState == .normal ? .shift : .normal
      loadKeys()
      clearCommandBar()
      capsLockPossible = true

    default:
      if shiftButtonState == .shift {
        shiftButtonState = .normal
        loadKeys()
      }
      if commandState == false {
        proxy.insertText(keyToDisplay)
        clearCommandBar()
      } else {
        commandBar.text = commandBar.text!.insertPriorToCursor(char: keyToDisplay)
      }
    }
    // Remove alternates view if it's present.
    if self.view.viewWithTag(1001) != nil {
      let viewWithTag = self.view.viewWithTag(1001)
      viewWithTag?.removeFromSuperview()
    }
  }

  // MARK: Key press functions

  /// Auto-capitalization if the cursor is at the start of the proxy.
  func autoCapAtStartOfProxy() {
    proxy.insertText(" ")
    if proxy.documentContextBeforeInput == " " {
      if shiftButtonState == .normal {
        shiftButtonState = .shift
        loadKeys()
      }
    }
    proxy.deleteBackward()
  }

  /// Colors keys to show they have been pressed.
  ///
  /// - Parameters
  ///   - sender: the key that was pressed.
  @objc func keyTouchDown(_ sender: UIButton) {
    sender.backgroundColor = keyPressedColor
  }

  /// Defines events that occur given multiple presses of a single key.
  ///
  /// - Parameters
  ///  - sender: the key that was pressed multiple times.
  ///  - event: event to derive tap counts.
  @objc func keyMultiPress(_ sender: UIButton, event: UIEvent) {
    guard var originalKey = sender.layer.value(forKey: "original") as? String else { return }

    let touch: UITouch = event.allTouches!.first!

    // Caps lock given two taps of shift.
    if touch.tapCount == 2 && originalKey == "shift" && capsLockPossible == true {
      shiftButtonState = .caps
      loadKeys()
      clearCommandBar()
    }

    // To make sure that the user can still use the double space period shortcut after numbers and symbols.
    let punctuationThatCancelsShortcut = ["?", "!", ",", ".", ":", ";", "-"]
    if originalKey != "shift" && proxy.documentContextBeforeInput?.count != 1 && commandState == false {
      let charBeforeSpace = String(Array(proxy.documentContextBeforeInput!).secondToLast()!)
      if punctuationThatCancelsShortcut.contains(charBeforeSpace) {
        originalKey = "Cancel shortcut"
      }
    } else if commandState == true {
      let charBeforeSpace = String(Array((commandBar?.text!)!).secondToLast()!)
      if punctuationThatCancelsShortcut.contains(charBeforeSpace) {
        originalKey = "Cancel shortcut"
      }
    }
    // Double space period shortcut.
    if touch.tapCount == 2
      && originalKey == spaceBar
      && proxy.documentContextBeforeInput?.count != 1
      && doubleSpacePeriodPossible == true {
      // The fist condition prevents a period if the prior characters are spaces as the user wants a series of spaces.
      if proxy.documentContextBeforeInput?.suffix(2) != "  " && commandState == false {
        proxy.deleteBackward()
        proxy.insertText(". ")
        keyboardState = .letters
        shiftButtonState = .shift
        loadKeys()
      // The fist condition prevents a period if the prior characters are spaces as the user wants a series of spaces.
      } else if commandBar.text!.suffix(2) != "  " && commandState == true {
        commandBar.text! = (commandBar?.text!.deletePriorToCursor())!
        commandBar.text! = (commandBar?.text!.insertPriorToCursor(char: ". "))!
        keyboardState = .letters
        shiftButtonState = .shift
        loadKeys()
      }
      clearCommandBar()
    }
  }

  /// Defines the criteria under which a key is long pressed.
  ///
  /// - Parameters
  ///   - gesture: the gesture that was received.
  @objc func keyLongPressed(_ gesture: UIGestureRecognizer) {
    // Prevent the command state prompt from being deleted.
    if commandState == true && allPrompts.contains((commandBar?.text!)!) {
      gesture.state = .cancelled
    }
    if gesture.state == .began {
      backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
        self.handleDeleteButtonPressed()
      }
    } else if gesture.state == .ended || gesture.state == .cancelled {
      backspaceTimer?.invalidate()
      backspaceTimer = nil
      (gesture.view as! UIButton).backgroundColor = specialKeyColor
    }
  }

  /// Resets key coloration after they have been annotated to by keyPressedColor.
  ///
  /// - Parameters
  ///   - sender: the key that was pressed.
  @objc func keyUntouched(_ sender: UIButton) {
    guard let isSpecial = sender.layer.value(forKey: "isSpecial") as? Bool else { return }
    sender.backgroundColor = isSpecial ? specialKeyColor : keyColor
  }

  /// Generates an alternates view to select other characters related to a long held key.
  ///
  /// - Parameters
  ///   - sender: the long press of the given key.
  func genAlternatesView(sender: UILongPressGestureRecognizer) {
    let tapLocation = sender.location(in: self.view)

    // Derive which button was pressed and get its alternates.
    guard let button: UIButton = sender.view as? UIButton else { return }
    let btnPressed: String = button.layer.value(forKey: "original") as? String ?? ""
    alternateKeys = keyAlternatesDict[btnPressed ] ?? [""]
    let numAlternates: CGFloat = CGFloat(alternateKeys.count)

    alternateButtonWidth = buttonWidth * 0.9
    if keysWithAlternatesLeft.contains(btnPressed ) {
      alternatesViewX = tapLocation.x - 10.0
    } else if keysWithAlternatesRight.contains(btnPressed ) {
      alternatesViewX = tapLocation.x - CGFloat(alternateButtonWidth * numAlternates + (3.0 * numAlternates) - 5.0)
    }

    if numAlternates > 0 {
      alternatesViewWidth = CGFloat(alternateButtonWidth * numAlternates + (3.0 * numAlternates) + 5.0)
    }

    if DeviceType.isPhone {
      alternatesViewY = tapLocation.y - 50.0
      alternatesBtnHeight = buttonWidth * 1.4
      alternatesCharHeight = buttonWidth / 2
    } else if DeviceType.isPad {
      alternatesViewY = tapLocation.y - 100.0
      alternatesBtnHeight = buttonWidth
      alternatesCharHeight = buttonWidth / 3
    }

    alternatesKeyView = UIView(
      frame: CGRect(
        x: alternatesViewX,
        y: alternatesViewY,
        width: alternatesViewWidth,
        height: alternatesBtnHeight
      )
    )

    alternatesKeyView.backgroundColor = keyColor
    alternatesKeyView.layer.cornerRadius = 5
    alternatesKeyView.layer.borderWidth = 1
    alternatesKeyView.tag = 1001
    alternatesKeyView.layer.borderColor = keyShadowColor
    button.backgroundColor = keyColor
  }

  /// Sets the characters that can be selected on an alternates view that is generated.
  ///
  /// - Parameters
  ///   - sender: the long press of the given key.
  @objc func setAlternatesView(sender: UILongPressGestureRecognizer) {
    // Only run this code when the state begins.
    if sender.state != UIGestureRecognizer.State.began {
      return
    }

    // If alternateKeysView is already added than remove and then add again.
    if self.view.viewWithTag(1001) != nil {
      let viewWithTag = self.view.viewWithTag(1001)
      viewWithTag?.removeFromSuperview()
    }

    genAlternatesView(sender: sender)

    alternateBtnStartX = 5.0
    for char in alternateKeys {
      let btn: UIButton = UIButton(
        frame: CGRect(
          x: alternateBtnStartX,
          y: 0,
          width: alternateButtonWidth,
          height: alternatesBtnHeight
        )
      )
      if shiftButtonState == .normal || char == "ß" {
        btn.setTitle(char, for: .normal)
      } else {
        btn.setTitle(char.capitalized, for: .normal)
      }
      btn.titleLabel?.font = .systemFont(ofSize: alternatesCharHeight)
      btn.setTitleColor(keyCharColor, for: .normal)

      alternatesKeyView.addSubview(btn)
      setBtn(btn: btn, color: keyColor, name: char, canCapitalize: true, isSpecial: false)
      activateBtn(btn: btn)

      alternateBtnStartX += (alternateButtonWidth + 3.0)
    }
    self.view.addSubview(alternatesKeyView)
  }
}
