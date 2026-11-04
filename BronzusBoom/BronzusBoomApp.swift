import Combine
import SwiftUI
import SwiftData

@main
struct BronzusBoomApp: App {
    
    
    
    var body: some Scene {
       
            WindowGroup {
                if #available(iOS 17.0, *) {
                RootView()
                        .modelContainer(for: [Find.self, BarterItem.self])

            } else {
                // Fallback on earlier versions
            }
        }
    }
}

enum Keys {
    static let onboarded = "ravezation.onboarded"
    static let appearance = "ravezation.appearance"
    static let haptics = "ravezation.haptics"
    static let name = "ravezation.profile.name"
    static let motto = "ravezation.profile.motto"
    static let emblem = "ravezation.profile.emblem"
    static let since = "ravezation.profile.since"
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    
    var title: String {
        switch self {
            case .system: "Follow System"
            case .light: "Day Paper"
            case .dark: "Night Lantern"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
            case .system: nil
            case .light: .light
            case .dark: .dark
        }
    }
}

struct RootView: View {
    @AppStorage(Keys.onboarded) private var onboarded = false
    @AppStorage(Keys.appearance) private var appearance = AppAppearance.system.rawValue
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
                }
                .transition(.opacity)
            } else if !onboarded {
                OnboardingView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { onboarded = true }
                }
                .transition(.asymmetric(insertion: .opacity,
                                        removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                MainView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(AppAppearance(rawValue: appearance)?.colorScheme)
        .tint(Palette.rust)
    }
}
import SwiftUI

struct StampLabel: View {
    let text: String
    var color: Color = Palette.rust
    var angle: Double = -4
    
    var body: some View {
        Text(text.uppercased())
            .font(Typo.label(11))
            .tracking(1.6)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(color, lineWidth: 1.5))
            .overlay(RoundedRectangle(cornerRadius: 1.5).strokeBorder(color.opacity(0.45), lineWidth: 0.6).padding(2.5))
            .rotationEffect(.degrees(angle))
            .opacity(0.88)
    }
}

struct Polaroid<Content: View>: View {
    var angle: Double = 0
    var caption: String? = nil
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                content
                RadialGradient(colors: [.clear, Color.black.opacity(0.18)],
                               center: .center, startRadius: 55, endRadius: 200)
                    .allowsHitTesting(false)
                Color(hex: 0xB8914A).opacity(0.05).allowsHitTesting(false)
            }
            .clipped()
            if let caption {
                Text(caption)
                    .font(Typo.hand(14))
                    .foregroundStyle(Palette.inkSoft)
                    .lineLimit(1)
            }
        }
        .padding(8)
        .padding(.bottom, caption == nil ? 16 : 4)
        .background(Palette.card)
        .shadow(color: .black.opacity(0.14), radius: 6, x: 0, y: 4)
        .rotationEffect(.degrees(angle))
    }
}

struct Tape: View {
    var angle: Double = -5
    var body: some View {
        Rectangle()
            .fill(Palette.ochre.opacity(0.42))
            .frame(width: 70, height: 20)
            .rotationEffect(.degrees(angle))
    }
}

struct DataImage: View {
    let data: Data?
    var contentMode: ContentMode = .fill
    var placeholderSymbol = "photo"
    
    var body: some View {
        if let data, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().aspectRatio(contentMode: contentMode)
        } else {
            ZStack {
                Palette.paperDeep
                Image(systemName: placeholderSymbol)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
    }
}

struct InkButtonStyle: ButtonStyle {
    var fill: Color = Palette.ink
    var text: Color = Palette.paper
    var shadow: Color = Palette.rust
    var wide = true
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(Typo.label(14))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(text)
            .padding(.vertical, 15)
            .padding(.horizontal, 22)
            .frame(maxWidth: wide ? .infinity : nil)
            .background(RoundedRectangle(cornerRadius: 4).fill(fill))
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(shadow)
                    .offset(x: pressed ? 0 : 4, y: pressed ? 0 : 4)
            )
            .offset(x: pressed ? 4 : 0, y: pressed ? 4 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    var color: Color = Palette.ink
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typo.label(12))
            .tracking(1)
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(color.opacity(0.7), style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
            )
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct SealButton: View {
    let symbol: String
    var fill: Color = Palette.rust
    var label = "Add"
    let action: () -> Void
    
    var body: some View {
        Button {
            Haptics.stamp()
            action()
        } label: {
            ZStack {
                WaxSeal().fill(fill)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                Circle().strokeBorder(Color.white.opacity(0.28), lineWidth: 1).padding(10)
                Image(systemName: symbol)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Palette.paperFixed)
            }
            .frame(width: 66, height: 66)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct EmblemBadge: View {
    let symbol: String
    var size: CGFloat = 64
    var color: Color = Palette.rust
    
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.1))
            Circle().strokeBorder(color, lineWidth: 2)
            Circle()
                .strokeBorder(color.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                .padding(size * 0.08)
            Image(systemName: symbol)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(-8))
        .accessibilityHidden(true)
    }
}

struct ScreenHeader<Trailing: View>: View {
    let kicker: String
    let title: String
    var subtitle: String? = nil
    var dark = false
    @ViewBuilder var trailing: Trailing
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text(kicker.uppercased())
                    .font(Typo.label(11))
                    .tracking(2)
                    .foregroundStyle(dark ? Palette.brass : Palette.rust)
                Text(title)
                    .font(Typo.title(32))
                    .foregroundStyle(dark ? Palette.paperFixed : Palette.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(Typo.hand(15))
                        .foregroundStyle(dark ? Palette.paperFixed.opacity(0.6) : Palette.inkSoft)
                }
            }
            Spacer(minLength: 12)
            trailing
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(kicker: String, title: String, subtitle: String? = nil, dark: Bool = false) {
        self.init(kicker: kicker, title: title, subtitle: subtitle, dark: dark) { EmptyView() }
    }
}

struct FieldLabel: View {
    let text: String
    var dark = false
    init(_ text: String, dark: Bool = false) {
        self.text = text
        self.dark = dark
    }
    
    var body: some View {
        Text(text.uppercased())
            .font(Typo.label(11))
            .tracking(1.8)
            .foregroundStyle(dark ? Palette.paperFixed.opacity(0.6) : Palette.inkSoft)
    }
}

struct InkField: View {
    let placeholder: String
    @Binding var text: String
    var color: Color = Palette.ink
    
    var body: some View {
        VStack(spacing: 6) {
            TextField(placeholder, text: $text)
                .font(Typo.body(20))
                .foregroundStyle(color)
                .tint(Palette.rust)
            Rectangle().fill(color.opacity(0.35)).frame(height: 1)
        }
    }
}

struct PaperEditor: View {
    @Binding var text: String
    var placeholder: String
    var dark = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(Typo.hand(16))
                    .foregroundStyle((dark ? Palette.paperFixed : Palette.inkSoft).opacity(0.55))
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
            TextEditor(text: $text)
                .font(Typo.body(16))
                .foregroundStyle(dark ? Palette.paperFixed : Palette.ink)
                .scrollContentBackground(.hidden)
        }
        .padding(10)
        .frame(minHeight: 120)
        .background(RoundedRectangle(cornerRadius: 4).fill(dark ? Color.white.opacity(0.06) : Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder((dark ? Palette.paperFixed : Palette.ink).opacity(0.15)))
    }
}

struct InkSegment<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let title: (T) -> String
    var dark = false
    @Namespace private var underline
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(options, id: \.self) { option in
                let on = option == selection
                Button {
                    guard !on else { return }
                    Haptics.tap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selection = option }
                } label: {
                    VStack(spacing: 6) {
                        Text(title(option).uppercased())
                            .font(Typo.label(13))
                            .tracking(1.6)
                            .foregroundStyle(on ? (dark ? Palette.paperFixed : Palette.ink)
                                             : (dark ? Palette.paperFixed.opacity(0.5) : Palette.inkSoft))
                        ZStack {
                            Color.clear.frame(height: 2)
                            if on {
                                Rectangle()
                                    .fill(dark ? Palette.brass : Palette.rust)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "underline", in: underline)
                            }
                        }
                    }
                    .fixedSize()
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
    }
}

struct EmptyState: View {
    let symbol: String
    let title: String
    let text: String
    var dark = false
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder((dark ? Palette.brass : Palette.inkSoft).opacity(0.6),
                                  style: StrokeStyle(lineWidth: 1.2, dash: [4, 4]))
                    .frame(width: 96, height: 96)
                Image(systemName: symbol)
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(dark ? Palette.brass : Palette.inkSoft)
            }
            Text(title)
                .font(Typo.title(22))
                .foregroundStyle(dark ? Palette.paperFixed : Palette.ink)
            Text(text)
                .font(Typo.hand(16))
                .multilineTextAlignment(.center)
                .foregroundStyle(dark ? Palette.paperFixed.opacity(0.6) : Palette.inkSoft)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

struct StampToast: ViewModifier {
    @Binding var text: String?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let text {
                    StampLabel(text: text, color: Palette.moss, angle: -3)
                        .padding(12)
                        .background(Palette.card, in: RoundedRectangle(cornerRadius: 6))
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .padding(.bottom, 28)
                        .transition(.scale(scale: 1.6).combined(with: .opacity))
                        .task {
                            try? await Task.sleep(for: .seconds(1.8))
                            withAnimation { self.text = nil }
                        }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: text)
    }
}

extension View {
    func stampToast(_ text: Binding<String?>) -> some View {
        modifier(StampToast(text: text))
    }
}
import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: alpha)
    }
}

extension Color {
    init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(uiColor: UIColor(hex: hex, alpha: alpha))
    }
    
    static func dynamic(_ light: UInt32, _ dark: UInt32, alpha: CGFloat = 1) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
            ? UIColor(hex: dark, alpha: alpha)
            : UIColor(hex: light, alpha: alpha)
        })
    }
}

enum Palette {
    static let paper = Color.dynamic(0xF3EBDD, 0x1B1815)
    static let paperDeep = Color.dynamic(0xE7DBC5, 0x27211C)
    static let card = Color.dynamic(0xFBF7EF, 0x2D2721)
    static let ink = Color.dynamic(0x2B2420, 0xEDE3D1)
    static let inkSoft = Color.dynamic(0x75685C, 0xA79A88)
    static let rule = Color.dynamic(0x2B2420, 0xEDE3D1, alpha: 0.09)
    
    static let rust = Color.dynamic(0xB5532E, 0xD9774F)
    static let moss = Color.dynamic(0x5B6B3A, 0x9AAE70)
    static let ochre = Color.dynamic(0xC99A3B, 0xE0B65A)
    static let slate = Color.dynamic(0x3E4C5E, 0x8FA3BA)
    
    static let brass = Color(hex: 0xC9A45C)
    static let brassDeep = Color(hex: 0x8A6A2F)
    static let paperFixed = Color(hex: 0xF3EBDD)
    static let inkFixed = Color(hex: 0x2B2420)
}

enum Typo {
    static func title(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func hand(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .serif).italic()
    }
    static func label(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

struct PaperBackground: View {
    var ruled = false
    
    var body: some View {
        Palette.paper
            .overlay {
                Canvas { ctx, size in
                    var rng = SeededGenerator(seed: 7)
                    let count = Int(size.width * size.height / 160)
                    for _ in 0..<count {
                        let x = CGFloat.random(in: 0...size.width, using: &rng)
                        let y = CGFloat.random(in: 0...size.height, using: &rng)
                        let r = CGFloat.random(in: 0.4...1.2, using: &rng)
                        let o = Double.random(in: 0.02...0.07, using: &rng)
                        ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                                 with: .color(Palette.ink.opacity(o)))
                    }
                    guard ruled else { return }
                    var y: CGFloat = 150
                    while y < size.height {
                        var line = Path()
                        line.move(to: CGPoint(x: 0, y: y))
                        line.addLine(to: CGPoint(x: size.width, y: y))
                        ctx.stroke(line, with: .color(Palette.rule), lineWidth: 0.7)
                        y += 34
                    }
                    var margin = Path()
                    margin.move(to: CGPoint(x: 12, y: 0))
                    margin.addLine(to: CGPoint(x: 12, y: size.height))
                    ctx.stroke(margin, with: .color(Palette.rust.opacity(0.3)), lineWidth: 1)
                }
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
    }
}

enum Haptics {
    private static var enabled: Bool {
        UserDefaults.standard.object(forKey: Keys.haptics) as? Bool ?? true
    }
    static func tap() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func stamp() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.9)
    }
    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}

func ruPlural(_ n: Int, _ one: String, _ few: String, _ many: String) -> String {
    let mod10 = n % 10, mod100 = n % 100
    if mod10 == 1 && mod100 != 11 { return one }
    if (2...4).contains(mod10) && !(12...14).contains(mod100) { return few }
    return many
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
import SwiftUI

struct GemShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height, x = rect.minX, y = rect.minY
        func pt(_ px: CGFloat, _ py: CGFloat) -> CGPoint { CGPoint(x: x + w * px, y: y + h * py) }
        
        let tl = pt(0.25, 0.10), tr = pt(0.75, 0.10)
        let r = pt(0.96, 0.36), l = pt(0.04, 0.36)
        let b = pt(0.50, 0.94)
        let m1 = pt(0.37, 0.36), m2 = pt(0.63, 0.36), top = pt(0.50, 0.10)
        
        var p = Path()
        p.move(to: tl)
        p.addLine(to: tr)
        p.addLine(to: r)
        p.addLine(to: b)
        p.addLine(to: l)
        p.closeSubpath()
        
        p.move(to: l); p.addLine(to: r)
        p.move(to: tl); p.addLine(to: m1); p.addLine(to: b)
        p.move(to: tr); p.addLine(to: m2); p.addLine(to: b)
        p.move(to: m1); p.addLine(to: top); p.addLine(to: m2)
        return p
    }
}

struct WaxSeal: Shape {
    var lobes = 14
    
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let steps = 180
        var p = Path()
        for i in 0...steps {
            let t = Double(i) / Double(steps) * 2 * .pi
            let rr = radius * CGFloat(0.93 + 0.07 * cos(Double(lobes) * t))
            let point = CGPoint(x: c.x + rr * CGFloat(cos(t)), y: c.y + rr * CGFloat(sin(t)))
            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        p.closeSubpath()
        return p
    }
}

struct TagShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cut = min(16, rect.height * 0.28)
        let r: CGFloat = 6
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: rect.maxY),
                       control: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cut))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
        p.closeSubpath()
        
        let hole: CGFloat = 9
        p.addEllipse(in: CGRect(x: rect.minX + 11, y: rect.midY - hole / 2, width: hole, height: hole))
        return p
    }
}

struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let notch: CGFloat = 9
        let r: CGFloat = 4
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - notch))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct AirmailStripe: View {
    var body: some View {
        Canvas { ctx, size in
            var x: CGFloat = -size.height
            var i = 0
            while x < size.width + size.height {
                var p = Path()
                p.move(to: CGPoint(x: x, y: size.height))
                p.addLine(to: CGPoint(x: x + size.height, y: 0))
                p.addLine(to: CGPoint(x: x + size.height + 10, y: 0))
                p.addLine(to: CGPoint(x: x + 10, y: size.height))
                p.closeSubpath()
                ctx.fill(p, with: .color(i.isMultiple(of: 2) ? Palette.rust : Palette.slate))
                x += 20
                i += 1
            }
        }
        .frame(height: 8)
    }
}

struct DashedDivider: View {
    var color: Color = Palette.ink.opacity(0.25)
    var body: some View {
        Line()
            .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .frame(height: 1)
    }
    
    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return p
        }
    }
}

struct OrnateDivider: View {
    var color: Color = Palette.ink.opacity(0.22)

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(color).frame(height: 0.6).frame(maxWidth: .infinity)
            Image(systemName: "diamond.fill")
                .font(.system(size: 5))
                .foregroundStyle(color)
                .padding(.horizontal, 10)
            Rectangle().fill(color).frame(height: 0.6).frame(maxWidth: .infinity)
        }
    }
}

struct CompassRose: View {
    var size: CGFloat = 100
    var color: Color = Palette.ink
    @State private var angle: Double = 0

    var body: some View {
        Canvas { ctx, s in
            let c = CGPoint(x: s.width / 2, y: s.height / 2)
            let r = min(s.width, s.height) / 2
            ctx.stroke(
                Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                with: .color(color), lineWidth: 0.5
            )
            for i in 0..<32 {
                let t = Double(i) / 32.0 * 2 * .pi
                let isCardinal = i % 8 == 0
                let isMajor = i % 4 == 0
                let len = r * (isCardinal ? 0.22 : (isMajor ? 0.13 : 0.07))
                var path = Path()
                path.move(to: CGPoint(x: c.x + (r - len) * cos(t), y: c.y + (r - len) * sin(t)))
                path.addLine(to: CGPoint(x: c.x + r * cos(t), y: c.y + r * sin(t)))
                ctx.stroke(path, with: .color(color),
                           lineWidth: isCardinal ? 1.0 : (isMajor ? 0.6 : 0.35))
            }
            // Cardinal arrows
            for i in 0..<4 {
                let t = Double(i) * .pi / 2
                let tip = CGPoint(x: c.x + r * 0.68 * cos(t), y: c.y + r * 0.68 * sin(t))
                let w = r * 0.065
                let b1 = CGPoint(x: c.x + w * cos(t + .pi / 2), y: c.y + w * sin(t + .pi / 2))
                let b2 = CGPoint(x: c.x + w * cos(t - .pi / 2), y: c.y + w * sin(t - .pi / 2))
                var arrow = Path()
                arrow.move(to: tip); arrow.addLine(to: b1)
                arrow.addLine(to: CGPoint(x: c.x, y: c.y)); arrow.addLine(to: b2)
                arrow.closeSubpath()
                ctx.fill(arrow, with: .color(i == 0 ? Palette.rust : color))
            }
            // Center dot
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r * 0.05, y: c.y - r * 0.05,
                                            width: r * 0.10, height: r * 0.10)), with: .color(color))
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(angle))
        .onAppear {
            withAnimation(.linear(duration: 90).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
        .accessibilityHidden(true)
    }
}
import SwiftUI
import SwiftData

struct BarterPostcard: View {
    let card: BarterCard
    
    var body: some View {
        VStack(spacing: 0) {
            AirmailStripe()
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TRADE CARD")
                        .font(Typo.label(10))
                        .tracking(2)
                        .foregroundStyle(Palette.rust)
                    Text(card.n)
                        .font(Typo.title(24))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                }
                Spacer()
                EmblemBadge(symbol: Emblem.safe(card.e), size: 54)
            }
            .padding(16)
            
            DashedDivider().padding(.horizontal, 16)
            
            HStack(alignment: .top, spacing: 0) {
                column("Offering", card.g, color: Palette.moss)
                Rectangle().fill(Palette.rule).frame(width: 1)
                column("Seeking", card.w, color: Palette.slate)
            }
            .padding(.vertical, 14)
            
            DashedDivider().padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                if let qr = QRCode.image(for: card.encoded()) {
                    Image(uiImage: qr)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 132, height: 132)
                        .padding(8)
                        .background(Color.white)
                        .accessibilityLabel("Trade card QR code")
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("RAVEZATION")
                        .font(Typo.title(18))
                        .tracking(4)
                        .foregroundStyle(Palette.ink)
                    Text("Scan in the Trade tab to see matches.")
                        .font(Typo.hand(13))
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Palette.ink.opacity(0.15)))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
    
    private func column(_ title: String, _ items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(Typo.label(10))
                .tracking(1.6)
                .foregroundStyle(color)
            if items.isEmpty {
                Text("empty for now").font(Typo.hand(14)).foregroundStyle(Palette.inkSoft)
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Text("· \(item)")
                        .font(Typo.body(14))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

struct MyBarterCardView: View {
    let card: BarterCard
    @Environment(\.dismiss) private var dismiss
    @State private var rendered: Image?
    
    private var isEmpty: Bool { card.g.isEmpty && card.w.isEmpty }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(spacing: 22) {
                        BarterPostcard(card: card)
                            .rotationEffect(.degrees(-1))
                        
                        Text(isEmpty
                             ? "Add items to the «Offering» and «Seeking» lists first — then the card becomes useful."
                             : "Show the code to a friend: they scan it in Ravezation and instantly see what you can trade.")
                        .font(Typo.hand(16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.horizontal, 10)
                        
                        if let rendered, !isEmpty {
                            ShareLink(item: rendered,
                                      preview: SharePreview("Trade Card", image: rendered)) {
                                Label("Share Card", systemImage: "square.and.arrow.up")
                            }
                                      .buttonStyle(InkButtonStyle())
                        }
                    }
                    .padding(22)
                }
            }
            .navigationTitle("My Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { render() }
        }
    }
    
    @MainActor
    private func render() {
        let content = BarterPostcard(card: card)
            .frame(width: 360)
            .padding(24)
            .background(Palette.paperFixed)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        if let ui = renderer.uiImage { rendered = Image(uiImage: ui) }
    }
}

struct ScannerSheet: View {
    var onCard: (BarterCard) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var available: Bool?
    @State private var message: String?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch available {
                case .some(true):
                    QRScannerView { value in
                        if let card = BarterCard.decode(value) {
                            Haptics.success()
                            onCard(card)
                            dismiss()
                        } else {
                            Haptics.warning()
                            withAnimation { message = "Not a Ravezation card" }
                        }
                    }
                    .ignoresSafeArea()
                    viewfinder
                case .some(false):
                    ZStack {
                        PaperBackground()
                        EmptyState(symbol: "camera.metering.unknown",
                                   title: "Camera Unavailable",
                                   text: "Allow camera access in Settings or ask a friend to send the card as an image.")
                    }
                case .none:
                    ProgressView().tint(.white)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(available == false ? Palette.ink : Color.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(available == false ? 0.06 : 0.4)))
                    }
                    .accessibilityLabel("Close")
                }
                .padding(20)
                Spacer()
            }
        }
        .task { available = await CameraAccess.requestScanner() }
    }
    
    private var viewfinder: some View {
        VStack(spacing: 24) {
            Spacer()
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, dash: [26, 160]))
                .frame(width: 250, height: 250)
            VStack(spacing: 6) {
                Text("Point at your friend's card")
                    .font(Typo.title(20))
                if let message {
                    Text(message).font(Typo.hand(15)).foregroundStyle(Palette.ochre)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
import SwiftUI
import SwiftData
import CoreLocation

@available(iOS 17, *)
@Model
final class Find {
    var uid: UUID = UUID()
    var title: String = ""
    var categoryRaw: String = FindCategory.other.rawValue
    var note: String = ""
    var date: Date = Date()
    var latitude: Double?
    var longitude: Double?
    var placeName: String?
    @Attribute(.externalStorage) var photo: Data?
    @Attribute(.externalStorage) var thumb: Data?
    @Attribute(.externalStorage) var cutout: Data?

    var inMuseum: Bool = false
    var hallRaw: String = MuseumHall.nature.rawValue
    var exhibitNumber: Int = 0
    var story: String = ""
    var addedToMuseum: Date?

    init(title: String, category: FindCategory, note: String = "", date: Date = .now) {
        self.title = title
        self.categoryRaw = category.rawValue
        self.note = note
        self.date = date
    }

    var category: FindCategory {
        get { FindCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var hall: MuseumHall {
        get { MuseumHall(rawValue: hallRaw) ?? .nature }
        set { hallRaw = newValue.rawValue }
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var exhibitCode: String { String(format: "№ %03d", exhibitNumber) }
}

@available(iOS 17, *)
@Model
final class BarterItem {
    var uid: UUID = UUID()
    var title: String = ""
    var kindRaw: String = BarterKind.give.rawValue
    var conditionRaw: String = ItemCondition.good.rawValue
    var note: String = ""
    var createdAt: Date = Date()
    @Attribute(.externalStorage) var photo: Data?
    var isTraded: Bool = false
    var tradedAt: Date?
    var tradedWith: String?

    init(title: String, kind: BarterKind) {
        self.title = title
        self.kindRaw = kind.rawValue
    }

    var kind: BarterKind {
        get { BarterKind(rawValue: kindRaw) ?? .give }
        set { kindRaw = newValue.rawValue }
    }

    var condition: ItemCondition {
        get { ItemCondition(rawValue: conditionRaw) ?? .good }
        set { conditionRaw = newValue.rawValue }
    }
}

enum FindCategory: String, CaseIterable, Identifiable, Codable {
    case stone, shell, plant, feather, insect, coin, artifact, other
    var id: String { rawValue }

    var title: String {
        switch self {
        case .stone: "Stone"
        case .shell: "Shell"
        case .plant: "Plant"
        case .feather: "Feather"
        case .insect: "Insect"
        case .coin: "Coin"
        case .artifact: "Artifact"
        case .other: "Other"
        }
    }

    var symbol: String {
        switch self {
        case .stone: "hexagon.fill"
        case .shell: "hurricane"
        case .plant: "leaf.fill"
        case .feather: "bird.fill"
        case .insect: "ant.fill"
        case .coin: "circle.circle.fill"
        case .artifact: "key.fill"
        case .other: "sparkle"
        }
    }

    var color: Color {
        switch self {
        case .stone: Palette.slate
        case .shell: Palette.ochre
        case .plant: Palette.moss
        case .feather: Palette.rust
        case .insect: Palette.moss
        case .coin: Palette.ochre
        case .artifact: Palette.rust
        case .other: Palette.inkSoft
        }
    }

    var defaultHall: MuseumHall {
        switch self {
        case .stone, .shell, .plant, .feather, .insect: .nature
        case .coin, .artifact: .history
        case .other: .curio
        }
    }

    static func guess(from labels: [String]) -> FindCategory? {
        let map: [(FindCategory, [String])] = [
            (.shell, ["shell", "conch", "mollusk", "snail", "clam", "oyster"]),
            (.stone, ["rock", "stone", "pebble", "mineral", "gem", "crystal", "fossil", "quartz"]),
            (.feather, ["feather", "bird"]),
            (.insect, ["insect", "beetle", "butterfly", "bug", "moth", "dragonfly", "ladybug", "bee"]),
            (.plant, ["leaf", "plant", "flower", "tree", "mushroom", "fungus", "moss", "grass", "acorn", "cone", "berry"]),
            (.coin, ["coin", "medal", "badge"]),
            (.artifact, ["key", "bottle", "glass", "pottery", "ceramic", "tool", "toy", "button", "jewelry", "watch", "camera"])
        ]
        for label in labels {
            let l = label.lowercased()
            for (category, keys) in map where keys.contains(where: { l.contains($0) }) {
                return category
            }
        }
        return nil
    }
}

enum MuseumHall: String, CaseIterable, Identifiable {
    case nature, history, curio, memory
    var id: String { rawValue }

    var title: String {
        switch self {
        case .nature: "Nature"
        case .history: "History"
        case .curio: "Curiosities"
        case .memory: "Memory"
        }
    }

    var symbol: String {
        switch self {
        case .nature: "leaf"
        case .history: "hourglass"
        case .curio: "sparkles"
        case .memory: "heart"
        }
    }

    var wall: Color {
        switch self {
        case .nature: Color(hex: 0x1F2B24)
        case .history: Color(hex: 0x2B1E1B)
        case .curio: Color(hex: 0x1C2131)
        case .memory: Color(hex: 0x29222E)
        }
    }
}

enum BarterKind: String, CaseIterable, Identifiable {
    case give, want
    var id: String { rawValue }
    var title: String { self == .give ? "Offering" : "Seeking" }
}

enum ItemCondition: String, CaseIterable, Identifiable {
    case new, good, worn, vintage
    var id: String { rawValue }

    var title: String {
        switch self {
        case .new: "New"
        case .good: "Good"
        case .worn: "Worn"
        case .vintage: "Vintage"
        }
    }
}

enum Emblem: String, CaseIterable, Identifiable {
    case binoculars = "binoculars.fill"
    case mountain = "mountain.2.fill"
    case leaf = "leaf.fill"
    case bird = "bird.fill"
    case fish = "fish.fill"
    case hare = "hare.fill"
    case moon = "moon.stars.fill"
    case flame = "flame.fill"
    var id: String { rawValue }

    static func safe(_ raw: String) -> String {
        (Emblem(rawValue: raw) ?? .binoculars).rawValue
    }
}

enum ExplorerRank: Int, CaseIterable {
    case novice, tracker, collector, keeper, curator

    var title: String {
        switch self {
        case .novice: "Novice"
        case .tracker: "Tracker"
        case .collector: "Collector"
        case .keeper: "Keeper"
        case .curator: "Curator"
        }
    }

    var threshold: Int { [0, 3, 10, 25, 50][rawValue] }
    var next: ExplorerRank? { ExplorerRank(rawValue: rawValue + 1) }

    static func forFinds(_ count: Int) -> ExplorerRank {
        allCases.last { count >= $0.threshold } ?? .novice
    }
}

struct BarterCard: Codable, Equatable, Identifiable {
    var v = 1
    var n: String
    var e: String
    var g: [String]
    var w: [String]

    var id: String { n + "|" + g.joined(separator: ",") + "|" + w.joined(separator: ",") }

    static let prefix = "RAVEZATION1:"
    static let maxItems = 10
    static let maxLength = 28

    init(name: String, emblem: String, give: [String], want: [String]) {
        n = String(name.prefix(24))
        e = emblem
        g = give.prefix(Self.maxItems).map { String($0.prefix(Self.maxLength)) }
        w = want.prefix(Self.maxItems).map { String($0.prefix(Self.maxLength)) }
    }

    func encoded() -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return Self.prefix + data.base64EncodedString()
    }

    static func decode(_ string: String) -> BarterCard? {
        guard string.hasPrefix(prefix),
              let data = Data(base64Encoded: String(string.dropFirst(prefix.count))) else { return nil }
        return try? JSONDecoder().decode(BarterCard.self, from: data)
    }

    static func matches(_ items: [String], against other: [String]) -> [String] {
        let others = other.map(normalize).filter { !$0.isEmpty }
        return items.filter { item in
            let n = normalize(item)
            guard !n.isEmpty else { return false }
            return others.contains { $0.contains(n) || n.contains($0) }
        }
    }

    private static func normalize(_ s: String) -> String {
        s.lowercased().trimmed
    }
}

@available(iOS 17.0, *)
struct FriendCardView: View {
    let card: BarterCard
    @Environment(\.dismiss) private var dismiss
    @Query private var items: [BarterItem]
    
    private var myGive: [String] { items.filter { $0.kind == .give && !$0.isTraded }.map(\.title) }
    private var myWant: [String] { items.filter { $0.kind == .want && !$0.isTraded }.map(\.title) }
    private var canGet: [String] { BarterCard.matches(card.g, against: myWant) }
    private var canGive: [String] { BarterCard.matches(card.w, against: myGive) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack(spacing: 16) {
                            EmblemBadge(symbol: Emblem.safe(card.e), size: 72, color: Palette.slate)
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel("Explorer's Card")
                                Text(card.n).font(Typo.title(28)).foregroundStyle(Palette.ink)
                            }
                        }
                        
                        matchesBlock
                        
                        list("\(card.n) offers", card.g, highlighted: Set(canGet), color: Palette.moss)
                        list("\(card.n) seeks", card.w, highlighted: Set(canGive), color: Palette.slate)
                    }
                    .padding(22)
                }
            }
            .navigationTitle("Friend's Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    @ViewBuilder
    private var matchesBlock: some View {
        let total = canGet.count + canGive.count
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(total > 0 ? "Matches found!" : "No matches yet")
                    .font(Typo.title(20))
                    .foregroundStyle(Palette.ink)
                Spacer()
                if total > 0 { StampLabel(text: "× \(total)", color: Palette.moss, angle: -8) }
            }
            if total > 0 {
                if !canGet.isEmpty {
                    Text("You can get: " + canGet.joined(separator: ", "))
                        .font(Typo.body(15)).foregroundStyle(Palette.ink)
                }
                if !canGive.isEmpty {
                    Text("You can give: " + canGive.joined(separator: ", "))
                        .font(Typo.body(15)).foregroundStyle(Palette.ink)
                }
            } else {
                Text("But you can still work something out — check the lists below.")
                    .font(Typo.hand(15)).foregroundStyle(Palette.inkSoft)
            }
        }
        .padding(16)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6)
            .strokeBorder(total > 0 ? Palette.moss : Palette.ink.opacity(0.15),
                          style: StrokeStyle(lineWidth: 1.2, dash: total > 0 ? [] : [4, 4])))
    }
    
    private func list(_ title: String, _ entries: [String], highlighted: Set<String>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            FieldLabel(title)
            if entries.isEmpty {
                Text("empty").font(Typo.hand(15)).foregroundStyle(Palette.inkSoft)
            }
            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                let hit = highlighted.contains(entry)
                HStack {
                    Text(entry).font(Typo.body(17)).foregroundStyle(Palette.ink)
                    Spacer()
                    if hit { StampLabel(text: "match", color: color, angle: -4) }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 4).fill(hit ? color.opacity(0.14) : Palette.card))
            }
        }
    }
}
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct BarterView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BarterItem.createdAt, order: .reverse) private var items: [BarterItem]
    @AppStorage(Keys.name) private var name = ""
    @AppStorage(Keys.emblem) private var emblem = Emblem.binoculars.rawValue
    
    @State private var kind: BarterKind = .give
    @State private var showAdd = false
    @State private var showCard = false
    @State private var showScanner = false
    @State private var showArchive = false
    @State private var friendCard: BarterCard?
    @State private var tradingItem: BarterItem?
    @State private var partner = ""
    
    private var active: [BarterItem] { items.filter { $0.kind == kind && !$0.isTraded } }
    private var traded: [BarterItem] { items.filter(\.isTraded) }
    
    private func titles(_ kind: BarterKind) -> [String] {
        items.filter { $0.kind == kind && !$0.isTraded }.map(\.title)
    }
    
    private var myCard: BarterCard {
        BarterCard(name: name.isEmpty ? "Explorer" : name,
                   emblem: emblem,
                   give: titles(.give),
                   want: titles(.want))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PaperBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(kicker: "no money",
                                 title: "Trade",
                                 subtitle: "item for item — with friends and neighbors")
                    .padding(.horizontal, -22)
                    
                    HStack(spacing: 12) {
                        actionCard(title: "My Card", text: "show QR to a friend",
                                   symbol: "qrcode", color: Palette.rust) { showCard = true }
                        actionCard(title: "Scan", text: "a friend's card",
                                   symbol: "qrcode.viewfinder", color: Palette.slate) { showScanner = true }
                    }
                    
                    InkSegment(options: BarterKind.allCases, selection: $kind) { option in
                        "\(option.title) · \(titles(option).count)"
                    }
                    .padding(.top, 6)
                    
                    if active.isEmpty {
                        EmptyState(symbol: kind == .give ? "shippingbox" : "sparkle.magnifyingglass",
                                   title: kind == .give ? "Nothing to offer?" : "Not looking for anything?",
                                   text: kind == .give
                                   ? "Add things you're ready to give: books, seeds, duplicate finds."
                                   : "Write down what you want to find — matches will highlight on scan.")
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(active) { item in
                                BarterTagRow(item: item) {
                                    partner = ""
                                    tradingItem = item
                                } onDelete: {
                                    withAnimation { context.delete(item) }
                                    try? context.save()
                                }
                            }
                        }
                    }
                    
                    if !traded.isEmpty { archive }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 110)
            }
            
            SealButton(symbol: "plus", fill: Palette.moss, label: "Add Item") { showAdd = true }
                .padding(.trailing, 22)
                .padding(.bottom, 14)
        }
        .sheet(isPresented: $showAdd) { AddBarterItemView(initialKind: kind) }
        .sheet(isPresented: $showCard) { MyBarterCardView(card: myCard) }
        .fullScreenCover(isPresented: $showScanner) {
            ScannerSheet { card in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { friendCard = card }
            }
        }
        .sheet(item: $friendCard) { FriendCardView(card: $0) }
        .alert("Trade completed?",
               isPresented: Binding(get: { tradingItem != nil },
                                    set: { if !$0 { tradingItem = nil } })) {
            TextField("Who did you trade with (optional)", text: $partner)
            Button("Mark") { markTraded() }
            Button("Cancel", role: .cancel) { tradingItem = nil }
        } message: {
            Text("The item will move to the trade archive.")
        }
    }
    
    private func actionCard(title: String, text: String, symbol: String, color: Color,
                            action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(Typo.title(17)).foregroundStyle(Palette.ink)
                    Text(text).font(Typo.hand(13)).foregroundStyle(Palette.inkSoft)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 6))
            .overlay(alignment: .top) {
                AirmailStripe().clipShape(UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6))
            }
            .shadow(color: .black.opacity(0.08), radius: 5, y: 3)
        }
        .buttonStyle(.plain)
    }
    
    private var archive: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Haptics.tap()
                withAnimation(.snappy) { showArchive.toggle() }
            } label: {
                HStack {
                    FieldLabel("Trade archive · \(traded.count)")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showArchive ? 180 : 0))
                        .foregroundStyle(Palette.inkSoft)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            
            if showArchive {
                ForEach(traded) { item in
                    BarterTagRow(item: item, onTraded: {}, onDelete: {
                        withAnimation { context.delete(item) }
                        try? context.save()
                    })
                    .opacity(0.75)
                }
            }
        }
    }
    
    private func markTraded() {
        guard let item = tradingItem else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            item.isTraded = true
            item.tradedAt = .now
            item.tradedWith = partner.trimmed.isEmpty ? nil : partner.trimmed
        }
        try? context.save()
        Haptics.success()
        tradingItem = nil
    }
}

@available(iOS 17, *)
struct BarterTagRow: View {
    let item: BarterItem
    var onTraded: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            Group {
                if item.photo != nil {
                    DataImage(data: item.photo)
                } else {
                    ZStack {
                        Palette.paperDeep
                        Image(systemName: item.kind == .give ? "shippingbox" : "magnifyingglass")
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(Typo.title(18))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    if item.kind == .give {
                        Text(item.condition.title.uppercased())
                            .font(Typo.label(10))
                            .tracking(1)
                            .foregroundStyle(Palette.moss)
                    }
                    if let with = item.tradedWith {
                        Text("with \(with)").font(Typo.hand(13)).foregroundStyle(Palette.inkSoft)
                    } else if !item.note.isEmpty {
                        Text(item.note).font(Typo.hand(13)).foregroundStyle(Palette.inkSoft).lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            Menu {
                if !item.isTraded {
                    Button("Trade completed", systemImage: "checkmark.seal") { onTraded() }
                }
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Palette.inkSoft)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Actions")
        }
        .padding(.leading, 34)
        .padding(.trailing, 8)
        .padding(.vertical, 12)
        .background(
            TagShape()
                .fill(Palette.card, style: FillStyle(eoFill: true))
                .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
        )
        .overlay(alignment: .topTrailing) {
            if item.isTraded {
                StampLabel(text: "Traded", color: Palette.moss, angle: -8)
                    .padding(.top, -6)
                    .padding(.trailing, 44)
                    .transition(.scale(scale: 2).combined(with: .opacity))
            }
        }
    }
}

@available(iOS 17.0, *)
struct AddBarterItemView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var kind: BarterKind
    @State private var title = ""
    @State private var condition: ItemCondition = .good
    @State private var note = ""
    @State private var image: UIImage?
    
    init(initialKind: BarterKind) {
        _kind = State(initialValue: initialKind)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        InkSegment(options: BarterKind.allCases, selection: $kind) { $0.title }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("What is it")
                            InkField(placeholder: kind == .give ? "e.g. «Bird Atlas»" : "e.g. old postcards",
                                     text: $title)
                        }
                        
                        if kind == .give {
                            VStack(alignment: .leading, spacing: 10) {
                                FieldLabel("Condition")
                                HStack(spacing: 8) {
                                    ForEach(ItemCondition.allCases) { item in
                                        let on = item == condition
                                        Button {
                                            Haptics.tap()
                                            withAnimation(.snappy) { condition = item }
                                        } label: {
                                            Text(item.title.uppercased())
                                                .font(Typo.label(10))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .foregroundStyle(on ? Palette.paper : Palette.moss)
                                                .background(RoundedRectangle(cornerRadius: 4).fill(on ? Palette.moss : .clear))
                                                .overlay(RoundedRectangle(cornerRadius: 4)
                                                    .strokeBorder(Palette.moss.opacity(on ? 0 : 0.5),
                                                                  style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                FieldLabel("Photo (optional)")
                                PhotoCapture(image: $image, height: 190)
                            }
                            .transition(.opacity)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Note")
                            PaperEditor(text: $note,
                                        placeholder: kind == .give ? "Size, completeness, pickup location" : "Any version will do?")
                        }
                    }
                    .padding(22)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(kind == .give ? "Offering" : "Seeking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmed.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        let item = BarterItem(title: title.trimmed, kind: kind)
        item.note = note.trimmed
        if kind == .give {
            item.condition = condition
            if let image { item.photo = ImageTools.jpeg(image, maxSide: 700, quality: 0.75) }
        }
        context.insert(item)
        try? context.save()
        Haptics.stamp()
        dismiss()
    }
}
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct AddFindView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var location = LocationService()
    
    @State private var image: UIImage?
    @State private var title = ""
    @State private var category: FindCategory = .other
    @State private var note = ""
    @State private var date = Date()
    @State private var attachLocation = true
    @State private var suggestions: [String] = []
    @State private var analyzing = false
    
    private var canSave: Bool { !title.trimmed.isEmpty }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PhotoCapture(image: $image) { analyze($0) }
                        
                        if analyzing {
                            HStack(spacing: 10) {
                                ProgressView().tint(Palette.rust)
                                Text("Examining the find closely…")
                                    .font(Typo.hand(15))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                            .transition(.opacity)
                        }
                        
                        if !suggestions.isEmpty { suggestionRow }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Name")
                            InkField(placeholder: "e.g. striped stone", text: $title)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Category")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                                      spacing: 8) {
                                ForEach(FindCategory.allCases) { item in
                                    CategoryTile(category: item, selected: item == category) {
                                        Haptics.tap()
                                        withAnimation(.snappy) { category = item }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Field Notes")
                            PaperEditor(text: $note, placeholder: "Where you found it, the weather, what makes it special…")
                        }
                        
                        DatePicker(selection: $date, in: ...Date(), displayedComponents: [.date]) {
                            FieldLabel("Find Date")
                        }
                        .tint(Palette.rust)
                        
                        Toggle(isOn: $attachLocation) {
                            VStack(alignment: .leading, spacing: 4) {
                                FieldLabel("Mark Location")
                                Text(location.placeName ?? location.statusText)
                                    .font(Typo.hand(15))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                        }
                        .tint(Palette.moss)
                    }
                    .padding(22)
                    .padding(.bottom, 30)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .onAppear { if attachLocation { location.request() } }
            .onChange(of: attachLocation) { _, on in if on { location.request() } }
        }
    }
    
    private var suggestionRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Looks like")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { item in
                        Button {
                            Haptics.tap()
                            title = item.capitalizedFirst
                        } label: {
                            Text(item)
                                .font(Typo.hand(16))
                                .foregroundStyle(Palette.ink)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Palette.ochre.opacity(0.22), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private func analyze(_ image: UIImage) {
        withAnimation { analyzing = true; suggestions = [] }
        Task { @MainActor in
            let labels = await VisionService.classify(image)
            withAnimation(.snappy) {
                analyzing = false
                suggestions = VisionService.localized(labels)
                if category == .other, let guess = FindCategory.guess(from: labels) { category = guess }
                if title.trimmed.isEmpty, let first = suggestions.first { title = first.capitalizedFirst }
            }
        }
    }
    
    private func save() {
        let find = Find(title: title.trimmed, category: category, note: note.trimmed, date: date)
        if let image {
            find.photo = ImageTools.jpeg(image, maxSide: 1600)
            find.thumb = ImageTools.jpeg(image, maxSide: 420, quality: 0.7)
        }
        if attachLocation, let loc = location.location {
            find.latitude = loc.coordinate.latitude
            find.longitude = loc.coordinate.longitude
            find.placeName = location.placeName
        }
        context.insert(find)
        try? context.save()
        Haptics.stamp()
        dismiss()
    }
}

struct CategoryTile: View {
    let category: FindCategory
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.symbol).font(.system(size: 19))
                Text(category.title.uppercased())
                    .font(Typo.label(8.5))
                    .tracking(0.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(selected ? Palette.paper : category.color)
            .background(RoundedRectangle(cornerRadius: 4).fill(selected ? category.color : Color.clear))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(category.color.opacity(selected ? 0 : 0.55),
                                  style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
import SwiftUI
import SwiftData
import MapKit

@available(iOS 17.0, *)
struct FindDetailView: View {
    @Bindable var find: Find
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showMuseum = false
    @State private var confirmDelete = false
    @State private var toast: String?
    
    var body: some View {
        ZStack {
            PaperBackground(ruled: true)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .top) {
                        Polaroid(angle: -1.5) {
                            DataImage(data: find.photo, placeholderSymbol: find.category.symbol)
                                .frame(height: 320)
                                .frame(maxWidth: .infinity)
                        }
                        Tape().offset(y: -10)
                    }
                    .padding(.top, 8)
                    
                    HStack(spacing: 10) {
                        StampLabel(text: find.category.title, color: find.category.color, angle: -3)
                        if find.inMuseum {
                            StampLabel(text: "Exhibit \(find.exhibitCode)", color: Palette.moss, angle: 2)
                        }
                    }
                    
                    Text(find.title)
                        .font(Typo.title(30))
                        .foregroundStyle(Palette.ink)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        meta("calendar", find.date.formatted(date: .long, time: .omitted))
                        if let place = find.placeName { meta("mappin.and.ellipse", place) }
                    }
                    
                    if !find.note.isEmpty {
                        Text(find.note)
                            .font(Typo.body(17))
                            .foregroundStyle(Palette.ink)
                            .lineSpacing(9)
                    }
                    
                    if let coordinate = find.coordinate {
                        Map(initialPosition: .region(MKCoordinateRegion(center: coordinate,
                                                                        latitudinalMeters: 900,
                                                                        longitudinalMeters: 900)),
                            interactionModes: []) {
                            Marker(find.title, coordinate: coordinate).tint(Palette.rust)
                        }
                            .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
                            .frame(height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Palette.ink.opacity(0.2)))
                    }
                    
                    VStack(spacing: 14) {
                        if find.inMuseum {
                            Button("Remove from Exhibition") {
                                withAnimation { find.inMuseum = false }
                                try? context.save()
                                toast = "Returned to journal"
                            }
                            .buttonStyle(GhostButtonStyle())
                        } else {
                            Button("Add to Museum") { showMuseum = true }
                                .buttonStyle(InkButtonStyle(fill: Palette.ink, shadow: Palette.brass))
                        }
                        Button("Offer for Trade") { offerForBarter() }
                            .buttonStyle(GhostButtonStyle(color: Palette.moss))
                    }
                    .padding(.top, 8)
                }
                .padding(.leading, 30)
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Delete Entry", systemImage: "trash", role: .destructive) { confirmDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete «\(find.title)» from journal?", isPresented: $confirmDelete,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { delete() }
        }
                            .sheet(isPresented: $showMuseum) {
                                NavigationStack {
                                    MuseumAdmitSheet(find: find) { showMuseum = false }
                                }
                            }
                            .stampToast($toast)
    }
    
    private func meta(_ symbol: String, _ text: String) -> some View {
        Label(text, systemImage: symbol)
            .font(Typo.hand(16))
            .foregroundStyle(Palette.inkSoft)
    }
    
    private func offerForBarter() {
        let item = BarterItem(title: find.title, kind: .give)
        item.photo = find.thumb
        item.note = find.note
        context.insert(item)
        try? context.save()
        Haptics.success()
        toast = "Added to «Offering»"
    }
    
    private func delete() {
        let target = find
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            context.delete(target)
            try? context.save()
        }
    }
}
import SwiftUI
import SwiftData
import MapKit

@available(iOS 17.0, *)
struct JournalView: View {
    @Query(sort: \Find.date, order: .reverse) private var finds: [Find]
    @State private var mode: Mode = .pages
    @State private var filter: FindCategory?
    @State private var showAdd = false
    
    enum Mode: String, CaseIterable, Hashable {
        case pages = "Pages"
        case map = "Map"
    }
    
    private var filtered: [Find] {
        guard let filter else { return finds }
        return finds.filter { $0.category == filter }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                PaperBackground(ruled: mode == .pages)
                
                VStack(alignment: .leading, spacing: 0) {
                    ScreenHeader(kicker: "vol. I",
                                 title: "Field Journal",
                                 subtitle: entriesText(finds.count)) {
                        InkSegment(options: Mode.allCases, selection: $mode, title: { $0.rawValue })
                            .padding(.bottom, 6)
                    }
                    if !finds.isEmpty { categoryChips }
                    
                    switch mode {
                        case .pages: pages
                        case .map: FindsMapView(finds: filtered)
                    }
                }
                
                SealButton(symbol: "plus", label: "New Entry") { showAdd = true }
                    .padding(.trailing, 22)
                    .padding(.bottom, 14)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Find.self) { FindDetailView(find: $0) }
            .sheet(isPresented: $showAdd) { AddFindView() }
        }
    }
    
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", symbol: "square.grid.2x2", on: filter == nil, color: Palette.ink) {
                    filter = nil
                }
                ForEach(FindCategory.allCases) { category in
                    chip(title: category.title, symbol: category.symbol,
                         on: filter == category, color: category.color) {
                        filter = filter == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
        }
    }
    
    private func chip(title: String, symbol: String, on: Bool, color: Color,
                      action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            withAnimation(.snappy) { action() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol).font(.system(size: 11, weight: .semibold))
                Text(title.uppercased()).font(Typo.label(11)).tracking(1)
            }
            .foregroundStyle(on ? Palette.paper : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(on ? color : Color.clear))
            .overlay(Capsule().strokeBorder(color.opacity(on ? 0 : 0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var pages: some View {
        if finds.isEmpty {
            ScrollView {
                VStack(spacing: 24) {
                    Polaroid(angle: -3, caption: "first page") {
                        ZStack {
                            Palette.paperDeep
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 54, weight: .ultraLight))
                                .foregroundStyle(Palette.inkSoft)
                        }
                        .frame(width: 200, height: 190)
                    }
                    .padding(.top, 30)
                    Text("Journal is empty")
                        .font(Typo.title(24))
                        .foregroundStyle(Palette.ink)
                    Text("Go for a walk and record your first find: a strangely shaped stone, a feather, an old key — everything counts.")
                        .font(Typo.hand(16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.horizontal, 30)
                    Button("Make First Entry") { showAdd = true }
                        .buttonStyle(InkButtonStyle(wide: false))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100)
            }
        } else if filtered.isEmpty {
            EmptyState(symbol: "tray", title: "Nothing here",
                       text: "No finds in this category yet.")
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(Array(filtered.enumerated()), id: \.element.uid) { index, find in
                        NavigationLink(value: find) {
                            FindEntryRow(find: find, index: index)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 26)
                .padding(.trailing, 18)
                .padding(.top, 6)
                .padding(.bottom, 100)
            }
        }
    }
    
    private func entriesText(_ n: Int) -> String {
        "\(n) \(n == 1 ? "entry" : "entries")"
    }
}

@available(iOS 17, *)
struct FindEntryRow: View {
    let find: Find
    let index: Int
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                Polaroid(angle: index.isMultiple(of: 2) ? -3 : 3) {
                    DataImage(data: find.thumb, placeholderSymbol: find.category.symbol)
                        .frame(width: 88, height: 88)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(find.date.formatted(.dateTime.day().month(.abbreviated).year()).uppercased())
                        .font(Typo.label(10))
                        .tracking(1.4)
                        .foregroundStyle(Palette.inkSoft)
                    Text(find.title)
                        .font(Typo.title(20))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    if let place = find.placeName {
                        Label(place, systemImage: "mappin")
                            .font(Typo.hand(14))
                            .foregroundStyle(Palette.inkSoft)
                            .lineLimit(1)
                    }
                    HStack(spacing: 8) {
                        StampLabel(text: find.category.title, color: find.category.color, angle: -2)
                        if find.inMuseum {
                            StampLabel(text: "In Museum", color: Palette.moss, angle: 2)
                        }
                    }
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
            OrnateDivider()
        }
        .overlay(alignment: .topLeading) {
            Text("\(index + 1)")
                .font(Typo.hand(11))
                .foregroundStyle(Palette.inkSoft.opacity(0.38))
                .allowsHitTesting(false)
                .offset(x: -19, y: 8)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 17, *)
struct FindsMapView: View {
    let finds: [Find]
    @State private var position: MapCameraPosition = .automatic
    
    private var located: [Find] { finds.filter { $0.coordinate != nil } }
    
    var body: some View {
        if located.isEmpty {
            EmptyState(symbol: "map",
                       title: "Map is empty",
                       text: "Finds with a location mark will appear here as pins.")
            Spacer()
        } else {
            Map(position: $position) {
                ForEach(located) { find in
                    Annotation(find.title, coordinate: find.coordinate ?? CLLocationCoordinate2D()) {
                        NavigationLink(value: find) { MapPin(find: find) }
                            .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Palette.ink.opacity(0.2)))
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 8)
        }
    }
}

@available(iOS 17, *)
private struct MapPin: View {
    let find: Find
    
    var body: some View {
        VStack(spacing: 0) {
            DataImage(data: find.thumb, placeholderSymbol: find.category.symbol)
                .frame(width: 42, height: 42)
                .clipped()
                .padding(3)
                .padding(.bottom, 5)
                .background(Palette.card)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundStyle(Palette.card)
                .offset(y: -2)
        }
        .rotationEffect(.degrees(-4))
    }
}
import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case journal, museum, barter, profile
    var id: Int { rawValue }
    
    var title: String {
        switch self {
            case .journal: "Journal"
            case .museum: "Museum"
            case .barter: "Trade"
            case .profile: "Me"
        }
    }
    
    var symbol: String {
        switch self {
            case .journal: "book.closed.fill"
            case .museum: "building.columns.fill"
            case .barter: "arrow.left.arrow.right"
            case .profile: "person.text.rectangle.fill"
        }
    }
    
    var color: Color {
        switch self {
            case .journal: Color(hex: 0xB5532E)
            case .museum: Color(hex: 0x8A6A2F)
            case .barter: Color(hex: 0x5B6B3A)
            case .profile: Color(hex: 0x3E4C5E)
        }
    }
}

struct MainView: View {
    @State private var tab: AppTab = .journal
    
    var body: some View {
        ZStack {
            switch tab {
                case .journal: if #available(iOS 17.0, *) {
                    JournalView()
                } else {
                    // Fallback on earlier versions
                }
                case .museum: if #available(iOS 17.0, *) {
                    MuseumView()
                } else {
                    // Fallback on earlier versions
                }
                case .barter: if #available(iOS 17.0, *) {
                    BarterView()
                } else {
                    // Fallback on earlier versions
                }
                case .profile: if #available(iOS 17.0, *) {
                    ProfileView()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        .id(tab)
        .transition(.opacity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BookmarkBar(selection: $tab)
        }
    }
}

struct BookmarkBar: View {
    @Binding var selection: AppTab
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(AppTab.allCases) { tab in
                let on = tab == selection
                Button {
                    guard !on else { return }
                    Haptics.tap()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { selection = tab }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .semibold))
                        Text(tab.title.uppercased())
                            .font(Typo.label(9))
                            .tracking(1.2)
                    }
                    .foregroundStyle(on ? Palette.paperFixed : Palette.inkSoft)
                    .frame(maxWidth: .infinity)
                    .padding(.top, on ? 16 : 10)
                    .padding(.bottom, 16)
                    .background(
                        BookmarkShape()
                            .fill(on ? tab.color : Palette.paperDeep)
                            .shadow(color: .black.opacity(on ? 0.18 : 0), radius: 4, y: -1)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .background(alignment: .top) {
            Palette.paper
                .overlay(alignment: .top) {
                    Rectangle().fill(Palette.ink.opacity(0.12)).frame(height: 1)
                }
                .padding(.top, 18)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct ExhibitView: View {
    @Bindable var find: Find
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var drag: CGSize = .zero
    @State private var appeared = false
    @State private var shareImage: Image?
    @State private var confirmRemove = false
    
    private var tilt: CGSize {
        CGSize(width: max(-140, min(140, drag.width)),
               height: max(-140, min(140, drag.height)))
    }
    
    var body: some View {
        ZStack {
            MuseumWall(hall: find.hall)
            
            VStack(spacing: 16) {
                topBar
                Spacer(minLength: 0)
                
                ExhibitImage(find: find, large: true)
                    .frame(maxHeight: 320)
                    .rotation3DEffect(.degrees(Double(tilt.width) / 5), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                    .rotation3DEffect(.degrees(Double(-tilt.height) / 7), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                    .shadow(color: .black.opacity(0.55), radius: 18,
                            x: -tilt.width / 8, y: 20 - tilt.height / 10)
                    .scaleEffect(appeared ? 1 : 0.82)
                    .opacity(appeared ? 1 : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { drag = $0.translation }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.45)) { drag = .zero }
                            }
                    )
                    .accessibilityLabel(find.title)
                
                Text("rotate exhibit with your finger")
                    .font(Typo.hand(14))
                    .foregroundStyle(Palette.paperFixed.opacity(0.45))
                
                Spacer(minLength: 0)
                plaque
                    .offset(y: appeared ? 0 : 60)
                    .opacity(appeared ? 1 : 0)
            }
            .padding(20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) { appeared = true }
            renderShareCard()
        }
        .confirmationDialog("Remove exhibit from display? The journal entry will remain.",
                            isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                find.inMuseum = false
                try? context.save()
                dismiss()
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.paperFixed)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            .accessibilityLabel("Close")

            Spacer()

            Text(find.hall.title.uppercased())
                .font(Typo.label(11))
                .tracking(2)
                .foregroundStyle(Palette.brass)
            
            Spacer()
            
            Menu {
                if let shareImage {
                    ShareLink(item: shareImage,
                              preview: SharePreview(find.title, image: shareImage)) {
                        Label("Share Card", systemImage: "square.and.arrow.up")
                    }
                }
                Button("Remove from Exhibition", systemImage: "archivebox", role: .destructive) {
                    confirmRemove = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.paperFixed)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            .accessibilityLabel("Actions")
        }
    }

    private var plaque: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(find.exhibitCode)
                    .font(Typo.label(12))
                    .tracking(1.5)
                Spacer()
                Text(find.category.title.uppercased())
                    .font(Typo.label(11))
                    .tracking(1.5)
            }
            Text(find.title)
                .font(Typo.title(26))
            Text([find.date.formatted(date: .abbreviated, time: .omitted), find.placeName]
                .compactMap { $0 }
                .joined(separator: " · "))
            .font(Typo.hand(15))
            .opacity(0.75)
            if !find.story.isEmpty {
                Rectangle().fill(Palette.inkFixed.opacity(0.25)).frame(height: 1)
                Text(find.story)
                    .font(Typo.body(16))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(Palette.inkFixed)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: [Color(hex: 0xE2C07A), Palette.brass, Palette.brassDeep],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(alignment: .topLeading) { screw.padding(6) }
        .overlay(alignment: .topTrailing) { screw.padding(6) }
        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
    }
    
    private var screw: some View {
        Circle()
            .fill(Palette.brassDeep)
            .frame(width: 6, height: 6)
            .overlay(Rectangle().fill(Palette.inkFixed.opacity(0.4)).frame(width: 5, height: 1))
    }
    
    @MainActor
    private func renderShareCard() {
        let renderer = ImageRenderer(content: ExhibitShareCard(find: find).environment(\.colorScheme, .dark))
        renderer.scale = 3
        if let ui = renderer.uiImage { shareImage = Image(uiImage: ui) }
    }
}

@available(iOS 17, *)
private struct ExhibitShareCard: View {
    let find: Find
    
    var body: some View {
        ZStack {
            MuseumWall(hall: find.hall)
            VStack(spacing: 22) {
                Text("RAVEZATION · POCKET MUSEUM")
                    .font(Typo.label(10))
                    .tracking(2.5)
                    .foregroundStyle(Palette.brass)
                ExhibitImage(find: find, large: true)
                    .frame(height: 230)
                    .shadow(color: .black.opacity(0.5), radius: 14, y: 14)
                VStack(spacing: 4) {
                    Text(find.exhibitCode).font(Typo.label(11)).tracking(1.5)
                    Text(find.title).font(Typo.title(22)).lineLimit(2).multilineTextAlignment(.center)
                    Text("Hall «\(find.hall.title)»").font(Typo.hand(13))
                }
                .foregroundStyle(Palette.inkFixed)
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Palette.brass, Palette.brassDeep],
                                           startPoint: .top, endPoint: .bottom),
                            in: RoundedRectangle(cornerRadius: 3))
            }
            .padding(28)
        }
        .frame(width: 360, height: 480)
    }
}
import SwiftUI
import SwiftData

struct MuseumWall: View {
    let hall: MuseumHall
    
    var body: some View {
        ZStack {
            hall.wall
            Canvas { ctx, size in
                var x: CGFloat = 0
                while x < size.width {
                    ctx.fill(Path(CGRect(x: x, y: 0, width: 1, height: size.height)),
                             with: .color(.white.opacity(0.035)))
                    x += 14
                }
            }
            RadialGradient(colors: [Color.white.opacity(0.17), .clear],
                           center: .top, startRadius: 10, endRadius: 540)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: hall)
    }
}

@available(iOS 17.0, *)
struct MuseumView: View {
    @Query(filter: #Predicate<Find> { $0.inMuseum == true }, sort: \Find.exhibitNumber)
    private var exhibits: [Find]
    
    @State private var hall: MuseumHall?
    @State private var showPicker = false
    @State private var selected: Find?
    
    private var shown: [Find] {
        guard let hall else { return exhibits }
        return exhibits.filter { $0.hall == hall }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MuseumWall(hall: hall ?? .nature)
            
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(kicker: "pocket",
                             title: "Museum",
                             subtitle: "\(exhibits.count) on display",
                             dark: true)
                hallPlaques
                
                if shown.isEmpty {
                    EmptyState(symbol: "building.columns",
                               title: exhibits.isEmpty ? "Halls await exhibits" : "This hall is empty",
                               text: "Choose a find from the journal — the background removes automatically and it takes its place on the pedestal.",
                               dark: true)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 18),
                                            GridItem(.flexible(), spacing: 18)],
                                  spacing: 30) {
                            ForEach(shown) { exhibit in
                                Button {
                                    Haptics.tap()
                                    selected = exhibit
                                } label: {
                                    ExhibitPedestal(find: exhibit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                                  .padding(.horizontal, 20)
                                  .padding(.top, 16)
                                  .padding(.bottom, 100)
                    }
                }
            }
            
            SealButton(symbol: "plus", fill: Palette.brassDeep, label: "Add Exhibit") {
                showPicker = true
            }
            .padding(.trailing, 22)
            .padding(.bottom, 14)
        }
        .sheet(isPresented: $showPicker) { ExhibitCandidatePicker() }
        .fullScreenCover(item: $selected) { ExhibitView(find: $0) }
    }
    
    private var hallPlaques: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                plaque("All halls", symbol: "square.grid.2x2", on: hall == nil) { hall = nil }
                ForEach(MuseumHall.allCases) { item in
                    plaque(item.title, symbol: item.symbol, on: hall == item) {
                        hall = hall == item ? nil : item
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
        }
    }
    
    private func plaque(_ title: String, symbol: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            withAnimation(.snappy) { action() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol).font(.system(size: 11, weight: .semibold))
                Text(title.uppercased()).font(Typo.label(11)).tracking(1)
            }
            .foregroundStyle(on ? Palette.inkFixed : Palette.brass)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if on {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [Palette.brass, Palette.brassDeep],
                                             startPoint: .top, endPoint: .bottom))
                } else {
                    RoundedRectangle(cornerRadius: 3).strokeBorder(Palette.brass.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 17, *)
struct ExhibitImage: View {
    let find: Find
    var large = false
    
    var body: some View {
        if let data = find.cutout, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFit()
        } else if let data = (large ? find.photo : find.thumb) ?? find.photo, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(width: large ? 260 : 110, height: large ? 260 : 110)
                .clipped()
                .padding(large ? 10 : 6)
                .padding(.bottom, large ? 22 : 12)
                .background(Palette.paperFixed)
        } else {
            Image(systemName: find.category.symbol)
                .font(.system(size: large ? 120 : 54, weight: .light))
                .foregroundStyle(Palette.brass)
        }
    }
}

@available(iOS 17, *)
struct ExhibitPedestal: View {
    let find: Find
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Ellipse()
                    .fill(RadialGradient(colors: [Color.white.opacity(0.22), .clear],
                                         center: .center, startRadius: 2, endRadius: 80))
                    .frame(width: 150, height: 40)
                    .offset(y: 62)
                ExhibitImage(find: find)
                    .frame(maxHeight: 130)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 12)
                    .phaseAnimator([false, true]) { content, up in
                        content.offset(y: up ? -4 : 2)
                    } animation: { _ in .easeInOut(duration: 2.4) }
            }
            .frame(height: 160)
            
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: 0xD9D2C4), Color(hex: 0xA9A090)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(height: 8)
                .padding(.horizontal, 10)
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: 0x8E8676), Color(hex: 0x5E574B)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 22)
                .padding(.horizontal, 18)
            
            VStack(spacing: 2) {
                Text(find.exhibitCode)
                    .font(Typo.label(10))
                    .tracking(1.2)
                Text(find.title)
                    .font(Typo.body(13))
                    .lineLimit(1)
            }
            .foregroundStyle(Palette.inkFixed)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [Palette.brass, Palette.brassDeep],
                                       startPoint: .top, endPoint: .bottom),
                        in: RoundedRectangle(cornerRadius: 2))
            .padding(.top, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(find.exhibitCode), \(find.title)")
    }
}

@available(iOS 17.0, *)
struct ExhibitCandidatePicker: View {
    @Query(filter: #Predicate<Find> { $0.inMuseum == false }, sort: \Find.date, order: .reverse)
    private var candidates: [Find]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                if candidates.isEmpty {
                    EmptyState(symbol: "book.closed",
                               title: "Nothing to exhibit",
                               text: "Every exhibit starts with a journal entry. Add a find — then come back.")
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 18),
                                            GridItem(.flexible(), spacing: 18)],
                                  spacing: 22) {
                            ForEach(Array(candidates.enumerated()), id: \.element.uid) { index, find in
                                NavigationLink(value: find) {
                                    Polaroid(angle: index.isMultiple(of: 2) ? -2 : 2, caption: find.title) {
                                        DataImage(data: find.thumb, placeholderSymbol: find.category.symbol)
                                            .frame(height: 130)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                                  .padding(22)
                    }
                }
            }
            .navigationTitle("Choose a Find")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .navigationDestination(for: Find.self) { find in
                MuseumAdmitSheet(find: find) { dismiss() }
            }
        }
    }
}

@available(iOS 17.0, *)
struct MuseumAdmitSheet: View {
    @Bindable var find: Find
    var onDone: () -> Void
    
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Find> { $0.inMuseum == true }) private var exhibits: [Find]
    
    @State private var hall: MuseumHall = .nature
    @State private var story = ""
    @State private var restoring = false
    @State private var preview: UIImage?
    
    var body: some View {
        ZStack {
            MuseumWall(hall: hall)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ZStack {
                        if let preview {
                            Image(uiImage: preview).resizable().scaledToFit()
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        } else {
                            ExhibitImage(find: find, large: true)
                                .opacity(restoring ? 0.5 : 1)
                        }
                        if restoring {
                            VStack(spacing: 10) {
                                ProgressView().tint(Palette.brass)
                                Text("Restoration: removing background…")
                                    .font(Typo.hand(15))
                                    .foregroundStyle(Palette.paperFixed)
                            }
                        }
                    }
                    .frame(height: 280)
                    .frame(maxWidth: .infinity)
                    .shadow(color: .black.opacity(0.5), radius: 14, y: 14)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        FieldLabel("Hall", dark: true)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                                  spacing: 10) {
                            ForEach(MuseumHall.allCases) { item in
                                let on = item == hall
                                Button {
                                    Haptics.tap()
                                    withAnimation(.snappy) { hall = item }
                                } label: {
                                    Label(item.title, systemImage: item.symbol)
                                        .font(Typo.label(12))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(on ? Palette.inkFixed : Palette.brass)
                                        .background {
                                            if on {
                                                RoundedRectangle(cornerRadius: 3).fill(Palette.brass)
                                            } else {
                                                RoundedRectangle(cornerRadius: 3).strokeBorder(Palette.brass.opacity(0.5))
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        FieldLabel("Exhibit Story", dark: true)
                        PaperEditor(text: $story,
                                    placeholder: "Why does this object deserve a place on display?",
                                    dark: true)
                    }
                    
                    Button(restoring ? "Restoring…" : "Put on Display") { admit() }
                        .buttonStyle(InkButtonStyle(fill: Palette.brass, text: Palette.inkFixed,
                                                    shadow: Palette.brassDeep))
                        .disabled(restoring)
                }
                .padding(22)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle(find.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            hall = find.category.defaultHall
            story = find.story.isEmpty ? find.note : find.story
        }
    }
            
    private func admit() {
        hideKeyboard()
        restoring = true
        Task { @MainActor in
            if find.cutout == nil, let data = find.photo, let ui = UIImage(data: data),
               let lifted = await VisionService.liftSubject(ui) {
                find.cutout = ImageTools.png(lifted, maxSide: 1000)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { preview = lifted }
                try? await Task.sleep(for: .milliseconds(700))
            }
            find.hall = hall
            find.story = story.trimmed
            find.exhibitNumber = (exhibits.map(\.exhibitNumber).max() ?? 0) + 1
            find.addedToMuseum = .now
            find.inMuseum = true
            try? context.save()
            Haptics.success()
            restoring = false
            onDone()
        }
    }
}
import SwiftUI

struct OnboardingView: View {
    var onDone: () -> Void
    
    @AppStorage(Keys.name) private var name = ""
    @AppStorage(Keys.emblem) private var emblem = Emblem.binoculars.rawValue
    @AppStorage(Keys.since) private var since: Double = 0
    @State private var page = 0
    
    private let total = 4
    
    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: 0) {
                header
                TabView(selection: $page) {
                    OnboardingPage(kicker: "Chapter I · Find",
                                   title: "Every walk is an expedition",
                                   text: "Photograph stones, shells, feathers and curious things. Ravezation will identify them and mark the spot on the map.") {
                        OnbFindArt()
                    }
                                   .tag(0)
                    
                    OnboardingPage(kicker: "Chapter II · Keep",
                                   title: "Your pocket museum",
                                   text: "Your best finds become exhibits: the background removes itself, and each object gets a plaque and a story.") {
                        OnbMuseumArt()
                    }
                                   .tag(1)
                    
                    OnboardingPage(kicker: "Chapter III · Trade",
                                   title: "Item for item, no money",
                                   text: "Make «offering» and «seeking» lists, show a friend your card — and see your matches right away.") {
                        OnbBarterArt()
                    }
                                   .tag(2)
                    
                    OnbIdentityPage(name: $name, emblem: $emblem)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                footer
            }
        }
        .onTapGesture { hideKeyboard() }
    }
    
    private var header: some View {
        HStack {
            Text("\(roman(page + 1)) / \(roman(total))")
                .font(Typo.label(13))
                .tracking(2)
                .foregroundStyle(Palette.inkSoft)
                .contentTransition(.numericText())
            Spacer()
            if page < total - 1 {
                Button("Skip") {
                    Haptics.tap()
                    withAnimation(.easeInOut) { page = total - 1 }
                }
                .font(Typo.label(13))
                .foregroundStyle(Palette.inkSoft)
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 48)
    }
    
    private var footer: some View {
        VStack(spacing: 18) {
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Palette.rust : Palette.ink.opacity(0.18))
                        .frame(width: i == page ? 28 : 10, height: 4)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: page)
            .accessibilityHidden(true)
            
            Button(page == total - 1 ? "Open Journal" : "Next") {
                next()
            }
            .buttonStyle(InkButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    private func next() {
        hideKeyboard()
        if page < total - 1 {
            Haptics.tap()
            withAnimation(.easeInOut) { page += 1 }
        } else {
            if name.trimmed.isEmpty { name = "Explorer" }
            if since == 0 { since = Date().timeIntervalSince1970 }
            Haptics.success()
            onDone()
        }
    }
    
    private func roman(_ n: Int) -> String {
        ["I", "II", "III", "IV", "V"][max(0, min(4, n - 1))]
    }
}

private struct OnboardingPage<Art: View>: View {
    let kicker: String
    let title: String
    let text: String
    @ViewBuilder var art: Art
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer(minLength: 0)
            art
                .frame(maxWidth: .infinity)
                .frame(height: 330)
            Spacer(minLength: 0)
            Text(kicker.uppercased())
                .font(Typo.label(12))
                .tracking(2)
                .foregroundStyle(Palette.rust)
            Text(title)
                .font(Typo.title(32))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(text)
                .font(Typo.body(17))
                .foregroundStyle(Palette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 12)
        }
        .padding(.horizontal, 28)
    }
}

private struct OnbFindArt: View {
    @State private var stamped = false
    
    var body: some View {
        ZStack {
            Tape(angle: 4).offset(y: -128).zIndex(1)
            Polaroid(angle: -4, caption: "shell · coast") {
                ZStack {
                    Palette.paperDeep
                    Image(systemName: "hurricane")
                        .font(.system(size: 76, weight: .light))
                        .foregroundStyle(Palette.ochre)
                }
                .frame(width: 210, height: 210)
            }
            StampLabel(text: "Found", angle: -14)
                .scaleEffect(stamped ? 1.35 : 3)
                .opacity(stamped ? 1 : 0)
                .offset(x: 78, y: 100)
            if !stamped {
                Text("tap to stamp")
                    .font(Typo.hand(15))
                    .foregroundStyle(Palette.inkSoft)
                    .offset(y: 158)
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !stamped else { return }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { stamped = true }
            Haptics.stamp()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

private struct OnbMuseumArt: View {
    @State private var fanned = false
    private let items: [(String, Color)] = [
        ("leaf.fill", Palette.moss),
        ("hexagon.fill", Palette.brass),
        ("bird.fill", Palette.rust)
    ]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(MuseumHall.nature.wall)
                .overlay(
                    RadialGradient(colors: [Color.white.opacity(0.18), .clear],
                                   center: .top, startRadius: 4, endRadius: 260)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            ForEach(0..<items.count, id: \.self) { i in
                let offset = CGFloat(i - 1)
                Polaroid(angle: fanned ? Double(i - 1) * 11 : 0) {
                    ZStack {
                        Palette.paperDeep
                        Image(systemName: items[i].0)
                            .font(.system(size: 40, weight: .light))
                            .foregroundStyle(items[i].1)
                    }
                    .frame(width: 100, height: 110)
                }
                .offset(x: fanned ? offset * 78 : 0, y: fanned ? abs(offset) * 14 - 14 : 0)
                .zIndex(i == 1 ? 1 : 0)
            }
            
            Text("HALL «NATURE»")
                .font(Typo.label(11))
                .tracking(2)
                .foregroundStyle(Palette.inkFixed)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(LinearGradient(colors: [Palette.brass, Palette.brassDeep],
                                           startPoint: .top, endPoint: .bottom),
                            in: RoundedRectangle(cornerRadius: 3))
                .offset(y: 120)
        }
        .padding(.horizontal, 4)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) { fanned = true }
        }
        .accessibilityHidden(true)
    }
}

private struct OnbBarterArt: View {
    @State private var swapped = false
    
    var body: some View {
        ZStack {
            tag("Bird Atlas", symbol: "book.closed.fill", color: Palette.rust)
                .offset(x: swapped ? 60 : -60, y: swapped ? 50 : -50)
                .rotationEffect(.degrees(swapped ? 6 : -6))
            tag("Tomato Seeds", symbol: "leaf.fill", color: Palette.moss)
                .offset(x: swapped ? -60 : 60, y: swapped ? -50 : 50)
                .rotationEffect(.degrees(swapped ? -5 : 5))
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(Palette.inkSoft)
                .rotationEffect(.degrees(swapped ? 180 : 0))
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) { swapped.toggle() }
            }
        }
        .accessibilityHidden(true)
    }
    
    private func tag(_ title: String, symbol: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(color)
            Text(title).font(Typo.body(17)).foregroundStyle(Palette.ink)
        }
        .padding(.leading, 34)
        .padding(.trailing, 18)
        .padding(.vertical, 16)
        .background(
            TagShape()
                .fill(Palette.card, style: FillStyle(eoFill: true))
                .shadow(color: .black.opacity(0.14), radius: 6, y: 3)
        )
    }
}

private struct OnbIdentityPage: View {
    @Binding var name: String
    @Binding var emblem: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Spacer()
                    EmblemBadge(symbol: emblem, size: 116)
                        .id(emblem)
                        .transition(.scale(scale: 1.4).combined(with: .opacity))
                    Spacer()
                }
                .padding(.vertical, 12)
                
                Text("FINAL TOUCH")
                    .font(Typo.label(12))
                    .tracking(2)
                    .foregroundStyle(Palette.rust)
                Text("How to sign the journal?")
                    .font(Typo.title(32))
                    .foregroundStyle(Palette.ink)
                
                InkField(placeholder: "Name or nickname", text: $name)
                    .submitLabel(.done)

                FieldLabel("Expedition Emblem")
                    .padding(.top, 6)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(Emblem.allCases) { item in
                        let on = item.rawValue == emblem
                        Button {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { emblem = item.rawValue }
                        } label: {
                            Image(systemName: item.rawValue)
                                .font(.system(size: 22))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .foregroundStyle(on ? Palette.paperFixed : Palette.ink)
                                .background(RoundedRectangle(cornerRadius: 4).fill(on ? Palette.rust : Color.clear))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(Palette.ink.opacity(on ? 0 : 0.3),
                                                      style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                
                Text("Your name is stored only on this device and never published.")
                    .font(Typo.hand(14))
                    .foregroundStyle(Palette.inkSoft)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query private var finds: [Find]
    @Query private var items: [BarterItem]
    
    @AppStorage(Keys.name) private var name = ""
    @AppStorage(Keys.motto) private var motto = ""
    @AppStorage(Keys.emblem) private var emblem = Emblem.binoculars.rawValue
    @AppStorage(Keys.since) private var since: Double = 0
    @AppStorage(Keys.haptics) private var haptics = true
    @AppStorage(Keys.appearance) private var appearance = AppAppearance.system.rawValue
    @AppStorage(Keys.onboarded) private var onboarded = true
    
    @State private var editing = false
    @State private var confirmWipe = false
    
    private var exhibits: Int { finds.filter(\.inMuseum).count }
    private var trades: Int { items.filter(\.isTraded).count }
    private var places: Int { Set(finds.compactMap(\.placeName)).count }
    private var rank: ExplorerRank { .forFinds(finds.count) }
    private var collected: Set<FindCategory> { Set(finds.map(\.category)) }
    
    private var sinceDate: Date {
        since > 0 ? Date(timeIntervalSince1970: since) : .now
    }
    
    private var idNumber: String {
        String(format: "%06d", Int(since) % 1_000_000)
    }
    
    var body: some View {
        ZStack {
            PaperBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ScreenHeader(kicker: "ID card", title: "Explorer") {
                        Button {
                            Haptics.tap()
                            editing = true
                        } label: {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                                .frame(width: 42, height: 42)
                                .overlay(Circle().strokeBorder(Palette.ink.opacity(0.3),
                                                               style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
                        }
                        .accessibilityLabel("Edit Profile")
                        .padding(.bottom, 6)
                    }
                    .padding(.horizontal, -22)
                    
                    idCard
                    statsGrid
                    rankProgress
                    stampCollection
                    settings
                    dangerZone
                    
                    Text("Ravezation · \(appVersion)")
                        .font(Typo.label(10))
                        .tracking(1.5)
                        .foregroundStyle(Palette.inkSoft)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $editing) { EditProfileView() }
        .confirmationDialog("Delete all finds, exhibits, trade lists and profile? This action cannot be undone.",
                            isPresented: $confirmWipe, titleVisibility: .visible) {
            Button("Delete Everything", role: .destructive) { wipe() }
        }
    }
    
    private var idCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("RAVEZATION · FIELD ID")
                    .font(Typo.label(9.5))
                    .tracking(1.6)
                Spacer()
                Text("№ \(idNumber)")
                    .font(Typo.label(10))
            }
            .foregroundStyle(Palette.paper)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Palette.ink)
            
            HStack(alignment: .top, spacing: 16) {
                EmblemBadge(symbol: Emblem.safe(emblem), size: 84)
                    .padding(.top, 4)
                VStack(alignment: .leading, spacing: 10) {
                    idField("name", name.isEmpty ? "Explorer" : name)
                    idField("rank", rank.title)
                    idField("in expedition since", sinceDate.formatted(date: .long, time: .omitted))
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            
            if !motto.isEmpty {
                Text("«\(motto)»")
                    .font(Typo.hand(16))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background {
            ZStack(alignment: .bottomTrailing) {
                Palette.card
                CompassRose(size: 130, color: Palette.ink)
                    .opacity(0.055)
                    .offset(x: 18, y: 18)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Palette.ink.opacity(0.18)))
        .overlay(alignment: .bottomTrailing) {
            StampLabel(text: rank.title, color: Palette.moss, angle: -12)
                .padding(14)
        }
        .shadow(color: .black.opacity(0.1), radius: 8, y: 5)
        .rotationEffect(.degrees(-0.8))
    }
    
    private func idField(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(Typo.label(9))
                .tracking(1.4)
                .foregroundStyle(Palette.inkSoft)
            Text(value)
                .font(Typo.title(18))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                  spacing: 12) {
            statTile(finds.count, "finds", "book.closed", Palette.rust)
            statTile(exhibits, "exhibits", "building.columns", Palette.brassDeep)
            statTile(trades, "trades", "arrow.left.arrow.right", Palette.moss)
            statTile(places, "places", "mappin.and.ellipse", Palette.slate)
        }
    }
    
    private func statTile(_ value: Int, _ label: String, _ symbol: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
            Text("\(value)")
                .font(Typo.title(32))
                .foregroundStyle(Palette.ink)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(Typo.label(10))
                .tracking(1.4)
                .foregroundStyle(Palette.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: 5)
            .strokeBorder(Palette.ink.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [4, 4])))
        .accessibilityElement(children: .combine)
    }
    
    @ViewBuilder
    private var rankProgress: some View {
        if let next = rank.next {
            let span = Double(next.threshold - rank.threshold)
            let done = Double(finds.count - rank.threshold)
            let left = next.threshold - finds.count
            VStack(alignment: .leading, spacing: 10) {
                FieldLabel("Next Rank")
                Text("\(left) more \(left == 1 ? "find" : "finds") until «\(next.title)»")
                    .font(Typo.hand(16))
                    .foregroundStyle(Palette.ink)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Palette.ink.opacity(0.1))
                        Rectangle().fill(Palette.rust)
                            .frame(width: geo.size.width * CGFloat(max(0, min(1, done / span))))
                        HStack(spacing: 0) {
                            ForEach(0..<10, id: \.self) { _ in
                                Spacer()
                                Rectangle().fill(Palette.paper.opacity(0.6)).frame(width: 1)
                            }
                        }
                    }
                }
                .frame(height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 1))
            }
        } else {
            StampLabel(text: "Top rank achieved", color: Palette.moss, angle: -2)
        }
    }
    
    private var stampCollection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FieldLabel("Stamp Collection · \(collected.count)/\(FindCategory.allCases.count)")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 14) {
                ForEach(FindCategory.allCases) { category in
                    let has = collected.contains(category)
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .strokeBorder(has ? category.color : Palette.ink.opacity(0.2),
                                              style: StrokeStyle(lineWidth: has ? 2 : 1, dash: has ? [] : [3, 3]))
                            Image(systemName: category.symbol)
                                .font(.system(size: 20))
                                .foregroundStyle(has ? category.color : Palette.ink.opacity(0.18))
                        }
                        .frame(width: 58, height: 58)
                        .rotationEffect(.degrees(has ? -10 : 0))
                        Text(category.title)
                            .font(Typo.label(9))
                            .foregroundStyle(has ? Palette.ink : Palette.inkSoft)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityValue(has ? "earned" : "not earned")
                }
            }
        }
    }
    
    private var settings: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldLabel("Gear").padding(.bottom, 10)
            
            Toggle(isOn: $haptics) {
                settingLabel("Haptic Feedback", "hand.tap")
            }
            .tint(Palette.moss)
            .padding(.vertical, 12)
            
            OrnateDivider()

            HStack {
                settingLabel("Appearance", "circle.lefthalf.filled")
                Spacer()
                Menu {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppAppearance.allCases) { item in
                            Text(item.title).tag(item.rawValue)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text((AppAppearance(rawValue: appearance) ?? .system).title)
                            .font(Typo.hand(15))
                        Image(systemName: "chevron.up.chevron.down").font(.system(size: 11))
                    }
                    .foregroundStyle(Palette.rust)
                }
            }
            .padding(.vertical, 12)
            
            OrnateDivider()

            Button {
                Haptics.tap()
                onboarded = false
            } label: {
                HStack {
                    settingLabel("Redo Onboarding", "book.pages")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(Palette.inkSoft)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 12)
            
            OrnateDivider()

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(Palette.moss)
                Text("All entries, photos and lists are stored only on this device. No registration, ads, or analytics.")
                    .font(Typo.hand(14))
                    .foregroundStyle(Palette.inkSoft)
            }
            .padding(.vertical, 14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 6))
    }
    
    private func settingLabel(_ title: String, _ symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .frame(width: 22)
                .foregroundStyle(Palette.ink)
            Text(title)
                .font(Typo.body(16))
                .foregroundStyle(Palette.ink)
        }
    }
    
    private var dangerZone: some View {
        Button {
            confirmWipe = true
        } label: {
            Label("Delete All Data", systemImage: "trash")
        }
        .buttonStyle(GhostButtonStyle(color: Palette.rust))
    }
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    private func wipe() {
        try? context.delete(model: Find.self)
        try? context.delete(model: BarterItem.self)
        try? context.save()
        let defaults = UserDefaults.standard
        for key in [Keys.name, Keys.motto, Keys.emblem, Keys.since, Keys.haptics, Keys.appearance] {
            defaults.removeObject(forKey: key)
        }
        Haptics.success()
        withAnimation { onboarded = false }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Keys.name) private var storedName = ""
    @AppStorage(Keys.motto) private var storedMotto = ""
    @AppStorage(Keys.emblem) private var storedEmblem = Emblem.binoculars.rawValue
    
    @State private var name = ""
    @State private var motto = ""
    @State private var emblem = Emblem.binoculars.rawValue
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Spacer()
                            EmblemBadge(symbol: emblem, size: 100)
                                .id(emblem)
                                .transition(.scale(scale: 1.3).combined(with: .opacity))
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Name")
                            InkField(placeholder: "Name or nickname", text: $name)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Expedition Motto")
                            InkField(placeholder: "e.g. «Look down as you walk»", text: $motto)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            FieldLabel("Emblem")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                                      spacing: 12) {
                                ForEach(Emblem.allCases) { item in
                                    let on = item.rawValue == emblem
                                    Button {
                                        Haptics.tap()
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                            emblem = item.rawValue
                                        }
                                    } label: {
                                        Image(systemName: item.rawValue)
                                            .font(.system(size: 22))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 54)
                                            .foregroundStyle(on ? Palette.paperFixed : Palette.ink)
                                            .background(RoundedRectangle(cornerRadius: 4).fill(on ? Palette.rust : .clear))
                                            .overlay(RoundedRectangle(cornerRadius: 4)
                                                .strokeBorder(Palette.ink.opacity(on ? 0 : 0.3),
                                                              style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(22)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("ID Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        storedName = name.trimmed.isEmpty ? "Explorer" : name.trimmed
                        storedMotto = motto.trimmed
                        storedEmblem = emblem
                        Haptics.stamp()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                name = storedName
                motto = storedMotto
                emblem = Emblem.safe(storedEmblem)
            }
        }
    }
}
import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void
    
    @State private var ring: CGFloat = 0
    @State private var gem: CGFloat = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var stamped = false
    @State private var compassSpin: Double = 0

    var body: some View {
        ZStack {
            PaperBackground()

            VStack(spacing: 28) {
                ZStack {
                    // Slowly rotating outer compass tick ring
                    Canvas { ctx, s in
                        let c = CGPoint(x: s.width / 2, y: s.height / 2)
                        let r = min(s.width, s.height) / 2
                        for i in 0..<64 {
                            let t = Double(i) / 64.0 * 2 * .pi
                            let isCard = i % 16 == 0
                            let isMaj = i % 4 == 0
                            let len = r * (isCard ? 0.16 : (isMaj ? 0.09 : 0.05))
                            var path = Path()
                            path.move(to: CGPoint(x: c.x + (r - len) * cos(t),
                                                  y: c.y + (r - len) * sin(t)))
                            path.addLine(to: CGPoint(x: c.x + r * cos(t), y: c.y + r * sin(t)))
                            ctx.stroke(path,
                                       with: .color(Palette.ink.opacity(isCard ? 0.35 : (isMaj ? 0.2 : 0.1))),
                                       lineWidth: isCard ? 1.2 : (isMaj ? 0.7 : 0.4))
                        }
                    }
                    .frame(width: 196, height: 196)
                    .rotationEffect(.degrees(compassSpin))
                    .opacity(ring > 0 ? min(1, ring * 2) : 0)

                    Circle()
                        .trim(from: 0, to: ring)
                        .stroke(Palette.ink.opacity(0.5), style: StrokeStyle(lineWidth: 1.4, dash: [2, 5]))
                        .frame(width: 156, height: 156)
                        .rotationEffect(.degrees(-90))
                    Circle()
                        .trim(from: 0, to: ring)
                        .stroke(Palette.ink, lineWidth: 2)
                        .frame(width: 132, height: 132)
                        .rotationEffect(.degrees(-90))
                    GemShape()
                        .trim(from: 0, to: gem)
                        .stroke(Palette.rust, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                        .frame(width: 76, height: 64)
                }
                
                VStack(spacing: 10) {
                    Text("RAVEZATION")
                        .font(Typo.title(44))
                        .tracking(showTitle ? 8 : 26)
                        .foregroundStyle(Palette.ink)
                        .opacity(showTitle ? 1 : 0)
                    Text("journal · museum · trade")
                        .font(Typo.label(12))
                        .tracking(1.8)
                        .foregroundStyle(Palette.inkSoft)
                        .opacity(showSubtitle ? 1 : 0)
                }
            }
            
            StampLabel(text: "Expedition open", angle: -12)
                .scaleEffect(stamped ? 1.15 : 2.6)
                .opacity(stamped ? 1 : 0)
                .offset(x: 64, y: 170)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ravezation")
        .task {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) { compassSpin = 360 }
            withAnimation(.easeInOut(duration: 0.7)) { ring = 1 }
            withAnimation(.easeInOut(duration: 0.85).delay(0.2)) { gem = 1 }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.55)) { showTitle = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.85)) { showSubtitle = true }
            try? await Task.sleep(for: .milliseconds(1150))
            withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) { stamped = true }
            Haptics.stamp()
            try? await Task.sleep(for: .milliseconds(650))
            onFinish()
        }
    }
}
import SwiftUI
import PhotosUI
import VisionKit
import AVFoundation

struct CameraPicker: UIViewControllerRepresentable {
    var onPick: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.onPick(image) }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PhotoCapture: View {
    @Binding var image: UIImage?
    var height: CGFloat = 260
    var onNewImage: (UIImage) -> Void = { _ in }

    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false

    private var cameraAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    var body: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 14) {
                Polaroid(angle: -1.5) {
                    ZStack {
                        if let image {
                            Image(uiImage: image).resizable().scaledToFill()
                        } else {
                            Palette.paperDeep
                            VStack(spacing: 8) {
                                Image(systemName: "camera.macro")
                                    .font(.system(size: 34, weight: .light))
                                Text("photo spot")
                                    .font(Typo.hand(15))
                            }
                            .foregroundStyle(Palette.inkSoft)
                        }
                    }
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                
                HStack(spacing: 12) {
                    if cameraAvailable {
                        Button { showCamera = true } label: {
                            Label("Take Photo", systemImage: "camera")
                        }
                        .buttonStyle(GhostButtonStyle())
                    }
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("From Gallery", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(GhostButtonStyle())
                }
            }
            .onChange(of: pickerItem) { _, item in
                guard let item else { return }
                Task { @MainActor in
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let ui = UIImage(data: data) {
                        set(ui)
                    }
                    pickerItem = nil
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { set($0) }.ignoresSafeArea()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private func set(_ ui: UIImage) {
        let normalized = ImageTools.normalized(ui, maxSide: 1600)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { image = normalized }
        Haptics.tap()
        onNewImage(normalized)
    }
}

struct QRScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: DataScannerViewController, context: Context) {
        if !controller.isScanning { try? controller.startScanning() }
    }

    static func dismantleUIViewController(_ controller: DataScannerViewController, coordinator: Coordinator) {
        controller.stopScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        private var last: String?
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            for item in addedItems {
                if case .barcode(let code) = item, let value = code.payloadStringValue, value != last {
                    last = value
                    onScan(value)
                    return
                }
            }
        }
    }
}

enum CameraAccess {
    @MainActor
    static func requestScanner() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted && DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }
}
import SwiftUI
import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreLocation

enum ImageTools {
    static func normalized(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        let scale = longest > 0 ? min(1, maxSide / longest) : 1
        let size = CGSize(width: (image.size.width * scale).rounded(),
                          height: (image.size.height * scale).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    static func jpeg(_ image: UIImage, maxSide: CGFloat, quality: CGFloat = 0.82) -> Data? {
        normalized(image, maxSide: maxSide).jpegData(compressionQuality: quality)
    }

    static func png(_ image: UIImage, maxSide: CGFloat) -> Data? {
        normalized(image, maxSide: maxSide).pngData()
    }
}

enum VisionService {
    private static let dictionary: [String: String] = [
        "rock": "rock", "stone": "stone", "pebble": "pebble", "crystal": "crystal",
        "fossil": "fossil", "mineral": "mineral", "gemstone": "gemstone",
        "seashell": "seashell", "shell": "shell", "conch": "conch", "snail": "snail",
        "leaf": "leaf", "flower": "flower", "tree": "branch", "plant": "plant",
        "mushroom": "mushroom", "moss": "moss", "acorn": "acorn", "pinecone": "pinecone",
        "conifer_cone": "pine cone", "berry": "berry", "feather": "feather", "bird": "bird",
        "insect": "insect", "butterfly": "butterfly", "beetle": "beetle", "ladybug": "ladybug",
        "dragonfly": "dragonfly", "moth": "moth", "bee": "bee",
        "coin": "coin", "medal": "medal", "badge": "badge",
        "key": "key", "bottle": "bottle", "glass": "glass", "pottery": "pottery",
        "ceramic": "ceramic", "button": "button", "jewelry": "jewelry", "toy": "toy",
        "watch": "watch", "book": "book", "postcard": "postcard", "stamp": "stamp"
    ]

    static func classify(_ image: UIImage) async -> [String] {
        guard let cg = image.cgImage else { return [] }
        return await Task.detached(priority: .userInitiated) { () -> [String] in
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
            do { try handler.perform([request]) } catch { return [] }
            let results = (request.results ?? [])
                .filter { $0.confidence > 0.12 }
                .sorted { $0.confidence > $1.confidence }
            return Array(results.prefix(8).map(\.identifier))
        }.value
    }

    static func localized(_ labels: [String]) -> [String] {
        labels.compactMap { dictionary[$0.lowercased()] }.uniqued()
    }

    static func liftSubject(_ image: UIImage) async -> UIImage? {
        guard let cg = image.cgImage else { return nil }
        return await Task.detached(priority: .userInitiated) { () -> UIImage? in
            if #available(iOS 17.0, *) {
                let request = VNGenerateForegroundInstanceMaskRequest()
                let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
                do {
                    try handler.perform([request])
                    guard let result = request.results?.first, !result.allInstances.isEmpty else { return nil }
                    let buffer = try result.generateMaskedImage(ofInstances: result.allInstances,
                                                                from: handler,
                                                                croppedToInstancesExtent: true)
                    let ci = CIImage(cvPixelBuffer: buffer)
                    guard let out = CIContext().createCGImage(ci, from: ci.extent) else { return nil }
                    return UIImage(cgImage: out)
                } catch {
                    return nil
                }

            } else {
                return nil
            }
        }.value
    }
}

enum QRCode {
    static func image(for string: String, scale: CGFloat = 10) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale)) else { return nil }
        guard let cg = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var placeName: String?
    @Published var status: CLAuthorizationStatus

    private let manager: CLLocationManager

    override init() {
        let m = CLLocationManager()
        manager = m
        status = m.authorizationStatus
        super.init()
        m.delegate = self
        m.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    var statusText: String {
        switch status {
        case .denied, .restricted: "Location access disabled in Settings"
        case .notDetermined: "Location permission required"
        default: location == nil ? "Determining location…" : "Coordinates saved"
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        Task { @MainActor in
            self.status = newStatus
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                self.manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        Task { @MainActor in
            self.location = last
            await self.reverseGeocode(last)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    private func reverseGeocode(_ location: CLLocation) async {
        guard let mark = try? await CLGeocoder().reverseGeocodeLocation(location).first else { return }
        let parts = [mark.locality ?? mark.subAdministrativeArea ?? mark.name, mark.country]
        placeName = parts.compactMap { $0 }.joined(separator: ", ")
    }
}
