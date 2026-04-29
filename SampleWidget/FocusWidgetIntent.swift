//
//  FocusWidgetIntent.swift
//  SampleWidgetExtension
//
//  Created by Zeeshan Waheed on 30/04/2026.
//

import AppIntents

// Defines what the user can configure when they long-press the widget and tap Edit.
// Conforms to WidgetConfigurationIntent so the system knows this is a widget intent
// and shows it in the widget editor automatically.
struct FocusWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Focus Session"
    static var description = IntentDescription("Choose which session to display.")

    // The single configurable parameter — the user picks one session from the list.
    // Optional because the user might not have picked anything yet (defaults to Focus).
    @Parameter(title: "Session")
    var session: SessionOption?
}

// All the possible sessions the user can pick from in the widget editor.
// Conforms to AppEnum so the system can display them as a list of options.
// RawValue is String so each case maps to a plain text identifier.
enum SessionOption: String, AppEnum {
    case focus, breakTime, plan, learn, review

    // The name of this type shown in the widget editor e.g. "Session"
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Session"

    // Maps each case to a human-readable label shown in the picker
    // e.g. .focus → "Focus", .breakTime → "Break"
    static var caseDisplayRepresentations: [SessionOption: DisplayRepresentation] = [
        .focus:     "Focus",
        .breakTime: "Break",
        .plan:      "Plan",
        .learn:     "Learn",
        .review:    "Review"
    ]
}
