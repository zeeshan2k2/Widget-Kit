//
//  SampleWidget.swift
//  SampleWidget
//
//  Created by Zeeshan Waheed on 29/04/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Data Model

struct FocusState {
    static let all: [(String, String, String, String, Color)] = [
        ("Focus",  "Deep Work",   "Session",    "brain.head.profile",    .indigo),
        ("Break",  "Rest",        "Recharge",   "cup.and.saucer.fill",   .teal),
        ("Plan",   "Strategy",    "Next Steps", "list.bullet.clipboard", .orange),
        ("Learn",  "Reading",     "Growth",     "book.fill",             .blue),
        ("Review", "Reflection",  "End Day",    "moon.stars.fill",       .purple),
    ]
}

// MARK: - Timeline Entry

// A single snapshot of data that the widget displays at a specific point in time.
// The system reads `date` to know when to show this entry — everything else is
// custom data we defined to drive the widget's UI.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let stateIndex: Int
    let totalStates: Int
}

// MARK: - Provider

// The brain of the widget — tells the system what data to display and when.
// Conforms to AppIntentTimelineProvider so it can read the user's
// intent configuration (which session they picked from the widget editor).
struct Provider: AppIntentTimelineProvider {

    // Called when the widget loads for the first time and has no data yet.
    // The system shows a blurred/redacted version of this — so just
    // hardcode a sensible default, it doesn't need to be dynamic.
    func placeholder(in context: Context) -> SimpleEntry {
        makeEntry(from: FocusState.all[0], index: 0, date: Date())
    }

    // Called when the system needs a quick one-off preview e.g. the widget
    // gallery. Reads the user's chosen session from their intent config
    // and returns a single entry immediately.
    func snapshot(for configuration: FocusWidgetIntent, in context: Context) async -> SimpleEntry {
        let index = selectedIndex(for: configuration.session)
        return makeEntry(from: FocusState.all[index], index: index, date: Date())
    }

    // The main function — called when the widget needs to actually run.
    // Starts from the user's chosen session via intent, then builds entries
    // for all remaining sessions advancing one per hour automatically.
    // policy .atEnd means reload timeline once all entries have been shown.
    func timeline(for configuration: FocusWidgetIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Start from whatever session the user picked
        let startIndex = selectedIndex(for: configuration.session)
        
        // Build entries for remaining sessions from that point
        for hourOffset in 0..<(FocusState.all.count - startIndex) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let stateIndex = startIndex + hourOffset
            entries.append(makeEntry(from: FocusState.all[stateIndex], index: stateIndex, date: entryDate))
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }

    // Translates the user's SessionOption enum pick into an array index
    // so we can grab the correct state from FocusState.all.
    private func selectedIndex(for session: SessionOption?) -> Int {
        switch session {
        case .focus:     return 0
        case .breakTime: return 1
        case .plan:      return 2
        case .learn:     return 3
        case .review:    return 4
        case .none:      return 0  // default to Focus if nothing selected
        }
    }

    // A factory helper that constructs a SimpleEntry from a FocusState tuple.
    // Keeps placeholder(), snapshot(), and timeline() clean by avoiding
    // repeated SimpleEntry(...) boilerplate across all three functions.
    private func makeEntry(from state: (String, String, String, String, Color), index: Int, date: Date) -> SimpleEntry {
        SimpleEntry(
            date: date,
            title: state.0,
            value: state.1,
            subtitle: state.2,
            icon: state.3,
            accentColor: state.4,
            stateIndex: index,
            totalStates: FocusState.all.count
        )
    }
}

// MARK: - Shared Progress Bar

struct ProgressBar: View {
    let progress: Double
    let accentColor: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 4)
                Capsule()
                    .fill(accentColor.gradient)
                    .frame(width: geo.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    var entry: SimpleEntry

    var progress: Double {
        Double(entry.stateIndex + 1) / Double(entry.totalStates)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label(entry.title, systemImage: entry.icon)
                    .font(.caption2.weight(.semibold))
                    .frame(width: 60)
                    .foregroundStyle(entry.accentColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(entry.accentColor.opacity(0.15), in: Capsule())

                Spacer()

                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(entry.value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(entry.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 1)

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                ProgressBar(progress: progress, accentColor: entry.accentColor)

                Text("\(entry.stateIndex + 1) of \(entry.totalStates) sessions")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 20).fill(.background)
            entry.accentColor.opacity(0.06)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    var entry: SimpleEntry

    var progress: Double {
        Double(entry.stateIndex + 1) / Double(entry.totalStates)
    }

    var body: some View {
        HStack(spacing: 16) {

            // ── Left: current session info ──────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                Label(entry.title, systemImage: entry.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(entry.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(entry.accentColor.opacity(0.15), in: Capsule())

                Spacer()

                Text(entry.value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(entry.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    ProgressBar(progress: progress, accentColor: entry.accentColor)
                    Text("\(entry.stateIndex + 1) of \(entry.totalStates) sessions")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }

            Divider()
                .overlay(entry.accentColor.opacity(0.3))

            // ── Right: all sessions list ────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(FocusState.all.enumerated()), id: \.offset) { index, state in
                    HStack(spacing: 6) {
                        Image(systemName: state.3)
                            .font(.system(size: 10))
                            .foregroundStyle(index == entry.stateIndex ? AnyShapeStyle(state.4) : AnyShapeStyle(.tertiary))
                            .frame(width: 14)

                        Text(state.1)
                            .font(.system(size: 11, weight: index == entry.stateIndex ? .semibold : .regular))
                            .foregroundStyle(index == entry.stateIndex ? .primary : .tertiary)

                        Spacer()

                        if index == entry.stateIndex {
                            Circle()
                                .fill(state.4)
                                .frame(width: 5, height: 5)
                        } else if index < entry.stateIndex {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(state.4.opacity(0.6))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 20).fill(.background)
            entry.accentColor.opacity(0.06)
        }
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    var entry: SimpleEntry

    var progress: Double {
        Double(entry.stateIndex + 1) / Double(entry.totalStates)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────
            HStack {
                Label(entry.title, systemImage: entry.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(entry.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(entry.accentColor.opacity(0.15), in: Capsule())

                Spacer()

                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // ── Hero section ────────────────────────────────────────
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.value)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(entry.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Big icon
                Image(systemName: entry.icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(entry.accentColor.opacity(0.3))
            }

            Spacer()

            // ── Progress ────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Daily Progress")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(entry.accentColor)
                }
                ProgressBar(progress: progress, accentColor: entry.accentColor)
            }

            Spacer()

            // ── All sessions ────────────────────────────────────────
            VStack(spacing: 10) {
                ForEach(Array(FocusState.all.enumerated()), id: \.offset) { index, state in
                    HStack(spacing: 12) {
                        // Icon circle
                        ZStack {
                            Circle()
                                .fill(index <= entry.stateIndex ? state.4.opacity(0.15) : Color(.systemGray6))
                                .frame(width: 32, height: 32)

                            Image(systemName: index < entry.stateIndex ? "checkmark" : state.3)
                                .font(.system(size: 13, weight: index < entry.stateIndex ? .bold : .regular))
                                .foregroundStyle(index <= entry.stateIndex ? AnyShapeStyle(state.4) : AnyShapeStyle(.tertiary))
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(state.1)
                                .font(.system(size: 13, weight: index == entry.stateIndex ? .semibold : .regular))
                                .foregroundStyle(index <= entry.stateIndex ? .primary : .tertiary)

                            Text(state.2)
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        // Active indicator
                        if index == entry.stateIndex {
                            Text("Now")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(state.4)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(state.4.opacity(0.15), in: Capsule())
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 20).fill(.background)
            entry.accentColor.opacity(0.06)
        }
    }
}

// MARK: - Entry View (routes to correct size)

struct SampleWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .systemLarge:  LargeWidgetView(entry: entry)
        default:            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct SampleWidget: Widget {
    let kind: String = "SampleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: FocusWidgetIntent.self, provider: Provider()) { entry in
            SampleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Sessions")
        .description("Tracks your daily focus, break, and review cycles.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    SampleWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Focus", value: "Deep Work", subtitle: "Session", icon: "brain.head.profile", accentColor: .indigo, stateIndex: 0, totalStates: 5)
    SimpleEntry(date: .now, title: "Break", value: "Rest",      subtitle: "Recharge", icon: "cup.and.saucer.fill", accentColor: .teal, stateIndex: 1, totalStates: 5)
    SimpleEntry(date: .now, title: "Plan",   value: "Strategy",   subtitle: "Next Steps", icon: "list.bullet.clipboard", accentColor: .orange, stateIndex: 2, totalStates: 5)
    SimpleEntry(date: .now, title: "Learn",  value: "Reading",    subtitle: "Growth",     icon: "book.fill",             accentColor: .blue,   stateIndex: 3, totalStates: 5)
    SimpleEntry(date: .now, title: "Review", value: "Reflection", subtitle: "End Day",    icon: "moon.stars.fill",       accentColor: .purple, stateIndex: 4, totalStates: 5)
}

#Preview(as: .systemMedium) {
    SampleWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Focus", value: "Deep Work", subtitle: "Session", icon: "brain.head.profile", accentColor: .indigo, stateIndex: 0, totalStates: 5)
    SimpleEntry(date: .now, title: "Plan",  value: "Strategy",  subtitle: "Next Steps", icon: "list.bullet.clipboard", accentColor: .orange, stateIndex: 2, totalStates: 5)
}

#Preview(as: .systemLarge) {
    SampleWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Focus",  value: "Deep Work",  subtitle: "Session",    icon: "brain.head.profile",    accentColor: .indigo, stateIndex: 0, totalStates: 5)
    SimpleEntry(date: .now, title: "Break",  value: "Rest",       subtitle: "Recharge",   icon: "cup.and.saucer.fill",   accentColor: .teal,   stateIndex: 1, totalStates: 5)
    SimpleEntry(date: .now, title: "Plan",   value: "Strategy",   subtitle: "Next Steps", icon: "list.bullet.clipboard", accentColor: .orange, stateIndex: 2, totalStates: 5)
    SimpleEntry(date: .now, title: "Learn",  value: "Reading",    subtitle: "Growth",     icon: "book.fill",             accentColor: .blue,   stateIndex: 3, totalStates: 5)
    SimpleEntry(date: .now, title: "Review", value: "Reflection", subtitle: "End Day",    icon: "moon.stars.fill",       accentColor: .purple, stateIndex: 4, totalStates: 5)
}
