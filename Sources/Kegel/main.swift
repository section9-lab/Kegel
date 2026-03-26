import AppKit
import Combine
import Foundation
import SwiftUI

// MARK: - Constants & Helpers

enum Constants {
    static let bundleID = "com.kegeltimer.app"
    static let configKey = "com.kegeltimer.trainingConfig"
    static let githubOwner = "section9-lab"
    static let githubRepo = "Kegel"
    static let appZipName = "KegelTimer.app.zip"
    static let appName = "KegelTimer"
    static let flowerEmoji = "🌼"
}

/// Simple localization helper
func L(_ en: String, _ zh: String) -> String {
    Locale.preferredLanguages.first?.hasPrefix("zh") == true ? zh : en
}

// MARK: - Models

struct TrainingConfig: Codable, Equatable {
    var contractSeconds: Int
    var relaxSeconds: Int
    var repetitions: Int
    var reminderIntervalMinutes: Int
    
    static let `default` = TrainingConfig(
        contractSeconds: 5,
        relaxSeconds: 5,
        repetitions: 10,
        reminderIntervalMinutes: 60
    )
    
    var totalDurationSeconds: Int {
        (contractSeconds + relaxSeconds) * repetitions
    }
    
    var durationString: String {
        let mins = totalDurationSeconds / 60
        let secs = totalDurationSeconds % 60
        return mins > 0 ? String(format: "%d:%02d", mins, secs) : "\(secs)"
    }
}

enum TrainingPhase: Equatable {
    case idle
    case readyToStart
    case contracting(Int)
    case relaxing(Int)
    case completed
    case paused
    
    var title: String {
        switch self {
        case .idle:         return L("KegelTimer", "提肛计时器")
        case .readyToStart: return L("Ready?", "准备好了吗？")
        case .contracting:  return L("Contract", "收缩")
        case .relaxing:     return L("Relax", "放松")
        case .completed:    return L("Completed!", "完成！")
        case .paused:       return L("Paused", "已暂停")
        }
    }
    
    var subtitle: String {
        switch self {
        case .idle:                     return L("Click to start training", "点击开始训练")
        case .readyToStart:             return L("Get ready...", "准备...")
        case .contracting(let secs):    return String(format: L("%d sec", "%d 秒"), secs)
        case .relaxing(let secs):       return String(format: L("%d sec", "%d 秒"), secs)
        case .completed:                return L("Great job!", "做得好！")
        case .paused:                   return L("Tap to resume", "点击继续")
        }
    }
    
    var icon: String {
        switch self {
        case .idle, .readyToStart: return "hourglass"
        case .contracting:         return "arrow.up.circle.fill"
        case .relaxing:            return "arrow.down.circle.fill"
        case .completed:           return "checkmark.circle.fill"
        case .paused:              return "pause.circle.fill"
        }
    }
}

// MARK: - State Management

@MainActor
final class AppState: ObservableObject {
    @Published var phase: TrainingPhase = .idle
    @Published var currentRepetition: Int = 0
    @Published var config: TrainingConfig
    @Published var reminderCountdownMinutes: Int = 0
    @Published var phaseProgress: CGFloat = 0.0
    @Published var isContracting: Bool = false
    
    var onOverlayRequest: ((Bool) -> Void)?
    
    private var trainingTimer: Timer?
    private var reminderTimer: Timer?
    private var trainingTimerID: Int = 0
    private var reminderTimerID: Int = 0
    private var lastReminderTime: Date?
    private var phaseStartTime: Date?
    private var phaseDuration: Int = 0
    
    init() {
        // Load config
        if let data = UserDefaults.standard.data(forKey: Constants.configKey),
           let savedConfig = try? JSONDecoder().decode(TrainingConfig.self, from: data) {
            self.config = savedConfig
        } else {
            self.config = .default
        }
        
        self.reminderCountdownMinutes = config.reminderIntervalMinutes
        startReminderTimer()
    }
    
    func updateConfig(_ newConfig: TrainingConfig) {
        self.config = newConfig
        if let data = try? JSONEncoder().encode(newConfig) {
            UserDefaults.standard.set(data, forKey: Constants.configKey)
        }
        
        // Refresh reminder
        if phase == .idle {
            self.reminderCountdownMinutes = newConfig.reminderIntervalMinutes
        }
        startReminderTimer()
    }
    
    // MARK: - Timer Logic
    
    func startReminderTimer() {
        reminderTimer?.invalidate()
        reminderTimerID += 1
        let currentID = reminderTimerID
        lastReminderTime = Date()
        updateReminderCountdown()
        
        reminderTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.reminderTimerID == currentID else { return }
                self.updateReminderCountdown()
            }
        }
    }
    
    private func updateReminderCountdown() {
        guard let last = lastReminderTime else { return }
        let elapsed = Int(Date().timeIntervalSince(last) / 60)
        reminderCountdownMinutes = max(0, config.reminderIntervalMinutes - elapsed)
        
        if reminderCountdownMinutes <= 0 {
            showReminderAlert()
        }
    }
    
    private func showReminderAlert() {
        lastReminderTime = Date()
        reminderCountdownMinutes = config.reminderIntervalMinutes
        NSSound.beep()
        startTraining()
    }
    
    // MARK: - Training Workflow
    
    func startTraining() {
        stopTraining() // Reset any active session
        onOverlayRequest?(true)
        currentRepetition = 1
        runNextPhase()
    }
    
    private func runNextPhase() {
        isContracting = true
        phase = .contracting(config.contractSeconds)
        startPhaseTimer(duration: config.contractSeconds) { [weak self] in
            self?.runRelaxing()
        }
    }
    
    private func runRelaxing() {
        isContracting = false
        phase = .relaxing(config.relaxSeconds)
        startPhaseTimer(duration: config.relaxSeconds) { [weak self] in
            self?.completeRepetition()
        }
    }
    
    private func completeRepetition() {
        if currentRepetition >= config.repetitions {
            phase = .completed
            trainingTimer?.invalidate()
            onOverlayRequest?(true)
            
            // Auto-close overlay after 3 seconds to avoid bothering the user
            trainingTimerID += 1
            let currentID = trainingTimerID
            trainingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    guard let self = self, self.trainingTimerID == currentID else { return }
                    self.stopTraining()
                }
            }
        } else {
            currentRepetition += 1
            runNextPhase()
        }
    }
    
    private func startPhaseTimer(duration: Int, completion: @escaping @MainActor () -> Void) {
        phaseDuration = duration
        phaseStartTime = Date()
        phaseProgress = 0.0
        
        trainingTimer?.invalidate()
        trainingTimerID += 1
        let currentID = trainingTimerID
        trainingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.trainingTimerID == currentID, let start = self.phaseStartTime else { return }
                let elapsed = Date().timeIntervalSince(start)
                self.phaseProgress = min(1.0, CGFloat(elapsed / Double(self.phaseDuration)))
                
                // Update phase with remaining seconds for UI
                let remaining = max(0, Int(ceil(Double(self.phaseDuration) - elapsed)))
                if self.isContracting {
                    self.phase = .contracting(remaining)
                } else {
                    self.phase = .relaxing(remaining)
                }
                
                if elapsed >= Double(self.phaseDuration) {
                    self.trainingTimer?.invalidate()
                    completion()
                }
            }
        }
    }
    
    func togglePause() {
        switch phase {
        case .idle, .completed: startTraining()
        case .paused:           resumeTraining()
        default:                pauseTraining()
        }
    }
    
    private func pauseTraining() {
        trainingTimer?.invalidate()
        trainingTimerID += 1 // Invalidate current timer's task
        phase = .paused
    }
    
    private func resumeTraining() {
        // Simple resume: restart the current micro-phase
        if isContracting {
            runNextPhase()
        } else {
            runRelaxing()
        }
    }
    
    func stopTraining() {
        trainingTimer?.invalidate()
        trainingTimerID += 1
        phase = .idle
        currentRepetition = 0
        phaseProgress = 0.0
        onOverlayRequest?(false)
    }
}

// MARK: - UI Components

struct FlowerView: View {
    let scale: CGFloat
    var body: some View {
        Text(Constants.flowerEmoji)
            .font(.system(size: 60))
            .scaleEffect(scale)
    }
}

struct ProgressBar: View {
    let current: Int
    let total: Int
    let progress: CGFloat
    let active: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 3) {
                ForEach(0..<total, id: \.self) { i in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.1)).frame(height: 4)
                        if i < current - 1 {
                            Capsule().fill(Color.green).frame(height: 4)
                        } else if i == current - 1 {
                            GeometryReader { g in
                                Capsule().fill(Color.green)
                                    .frame(width: g.size.width * (active ? (progress * 0.5) : (0.5 + progress * 0.5)))
                            }.frame(height: 4)
                        }
                    }
                }
            }
            Text("\(current)/\(total)").font(.system(size: 10, design: .monospaced)).opacity(0.6)
        }
    }
}

// MARK: - Main Views

struct OverlayView: View {
    @ObservedObject var state: AppState
    @State private var flowerScale: CGFloat = 0.3
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            header
            
            if isActive {
                FlowerView(scale: flowerScale)
                    .frame(height: 80)
                ProgressBar(current: state.currentRepetition, total: state.config.repetitions, progress: state.phaseProgress, active: state.isContracting)
            } else if state.phase == .completed {
                completionView
            } else {
                idleView
            }
        }
        .padding(20)
        .frame(width: 280, height: 160)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.05)))
        .onTapGesture { state.togglePause() }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) { isHovered = hovering }
        }
        .onChange(of: state.isContracting) { _, val in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { flowerScale = val ? 1.0 : 0.3 }
        }
    }
    
    private var isActive: Bool {
        if case .contracting = state.phase { return true }
        if case .relaxing = state.phase { return true }
        return false
    }
    
    private var header: some View {
        HStack {
            if state.phase == .idle {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 8))
                    Text(L("Next in: ", "下次：") + "\(state.reminderCountdownMinutes)m")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.08))
                .clipShape(Capsule())
                .transition(.opacity.combined(with: .scale))
            }
            Spacer()
            Button(action: { state.stopTraining() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .contentShape(Rectangle()) // 扩大点击热区
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1.0 : 0.2)
            .help(L("Close", "关闭"))
        }
    }
    
    private var idleView: some View {
        VStack(spacing: 8) {
            Image(systemName: "play.circle.fill").font(.largeTitle).foregroundStyle(.blue)
            Text(L("Tap to Start", "点击开始")).font(.caption).opacity(0.6)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(.green)
            Text(L("Well Done!", "棒极了！")).font(.headline)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var state: AppState
    @State private var localConfig: TrainingConfig
    
    init(state: AppState) {
        self.state = state
        self._localConfig = State(initialValue: state.config)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("Settings", "设置"))
                        .font(.system(size: 20, weight: .bold))
                    Text(L("Customize your training experience", "自定义你的训练体验"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue.gradient)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            Divider().padding(.horizontal, 24).opacity(0.5)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Reminder Group
                    SettingsGroup(title: L("Notifications", "提醒")) {
                        SettingsRow(icon: "bell.badge.fill", color: .red, title: L("Remind Every", "提醒间隔")) {
                            HStack(spacing: 12) {
                                Text("\(localConfig.reminderIntervalMinutes) min")
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.medium)
                                Stepper("", value: $localConfig.reminderIntervalMinutes, in: 5...240, step: 5)
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    // Exercise Group
                    SettingsGroup(title: L("Exercise Timing", "锻炼计时")) {
                        VStack(spacing: 16) {
                            SettingsRow(icon: "arrow.up.circle.fill", color: .orange, title: L("Contract", "收缩")) {
                                HStack(spacing: 12) {
                                    Slider(value: Binding(get: { Double(localConfig.contractSeconds) }, set: { localConfig.contractSeconds = Int($0) }), in: 1...15)
                                        .frame(width: 100)
                                    Text("\(localConfig.contractSeconds)s")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.medium)
                                        .frame(width: 35, alignment: .trailing)
                                }
                            }
                            
                            SettingsRow(icon: "arrow.down.circle.fill", color: .green, title: L("Relax", "放松")) {
                                HStack(spacing: 12) {
                                    Slider(value: Binding(get: { Double(localConfig.relaxSeconds) }, set: { localConfig.relaxSeconds = Int($0) }), in: 1...15)
                                        .frame(width: 100)
                                    Text("\(localConfig.relaxSeconds)s")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.medium)
                                        .frame(width: 35, alignment: .trailing)
                                }
                            }
                            
                            SettingsRow(icon: "repeat", color: .blue, title: L("Reps", "次数")) {
                                HStack(spacing: 12) {
                                    Text("\(localConfig.repetitions)")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.medium)
                                    Stepper("", value: $localConfig.repetitions, in: 5...50)
                                        .labelsHidden()
                                }
                            }
                        }
                    }
                    
                    // Summary Card
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.secondary)
                        Text(L("Total Session Time:", "单次训练总长："))
                            .foregroundStyle(.secondary)
                        Text(localConfig.durationString)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color.primary.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(24)
            }
            
            Divider().opacity(0.5)
            
            // Footer Actions
            HStack(spacing: 16) {
                Button(L("Reset to Default", "恢复默认")) {
                    withAnimation { localConfig = .default }
                }
                .buttonStyle(.link)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(L("Cancel", "取消")) { close() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                
                Button(L("Save Changes", "保存修改")) {
                    state.updateConfig(localConfig)
                    close()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .padding(20)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 420, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func close() {
        NSApp.windows.first(where: { $0 is SettingsWindow })?.close()
    }
}

// MARK: - Settings UI Helpers

struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct SettingsRow<Control: View>: View {
    let icon: String
    let color: Color
    let title: String
    let control: Control
    
    init(icon: String, color: Color, title: String, @ViewBuilder control: () -> Control) {
        self.icon = icon
        self.color = color
        self.title = title
        self.control = control()
    }
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Spacer()
            
            control
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Controllers

@MainActor
final class OverlayPanelController {
    private let panel: NSPanel
    init(state: AppState) {
        panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: OverlayView(state: state))
    }
    
    func show() {
        if let screen = NSScreen.main {
            let size = panel.contentView?.fittingSize ?? NSSize(width: 280, height: 160)
            let x = screen.visibleFrame.midX - size.width/2
            let y = screen.visibleFrame.minY + 100
            panel.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
        }
        panel.orderFrontRegardless()
    }
    func hide() { panel.orderOut(nil) }
}

@MainActor
final class SettingsWindow: NSWindow {
    init(state: AppState) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 380, height: 420), styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        self.title = L("Settings", "设置")
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.contentView = NSHostingView(rootView: SettingsView(state: state))
        self.center()
    }
}

// MARK: - Core App Logic

final class UpdateService {
    func checkForUpdate() async -> String? { nil } // Placeholder for brevity
}

@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let state: AppState
    private var settingsWindow: SettingsWindow?
    
    init(state: AppState) {
        self.state = state
        super.init()
        statusItem.button?.title = Constants.flowerEmoji
        buildMenu()
    }
    
    private func buildMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "\(Constants.appName) v1.0.0", action: nil, keyEquivalent: "").isEnabled = false
        menu.addItem(.separator())
        menu.addItem(withTitle: L("Start/Pause", "开始/暂停"), action: #selector(toggle), keyEquivalent: "p").target = self
        menu.addItem(withTitle: L("Settings...", "设置..."), action: #selector(openSettings), keyEquivalent: ",").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: L("Quit", "退出"), action: #selector(quit), keyEquivalent: "q").target = self
        statusItem.menu = menu
    }
    
    @objc private func toggle() { state.togglePause() }
    @objc private func openSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindow(state: state)
            settingsWindow?.isReleasedWhenClosed = false
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    @objc private func quit() { NSApp.terminate(nil) }
}

// MARK: - AppDelegate & Entry

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let state = AppState()
    private var statusItem: StatusItemController?
    private var overlay: OverlayPanelController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = StatusItemController(state: state)
        overlay = OverlayPanelController(state: state)
        
        state.onOverlayRequest = { [weak self] show in
            show ? self?.overlay?.show() : self?.overlay?.hide()
        }
    }
}

let delegate = AppDelegate()
let app = NSApplication.shared
app.delegate = delegate
app.run()
