//
//  VNEGreenUIKit.swift
//  VNEGREEN UI Kit (Design System & Smart EV Mobility Component Library)
//
//  A production-ready SwiftUI Component Library for iOS & iPadOS.
//  Target: iOS 15.0+ | Swift 5.7+
//

import SwiftUI
import Combine

// MARK: - 1. DESIGN TOKENS & COLOR PALETTE

public enum VNEColor {
    // Primary Tech & Neon Greens
    public static let primary500 = Color(hex: 0x10B981)   // Emerald Tech Green
    public static let primary600 = Color(hex: 0x059669)
    public static let accentNeon = Color(hex: 0x00E599)   // Electric Neon Green
    public static let accentGlow = Color(hex: 0x17F39E)

    // Dark Mode Palette
    public static let darkBackground = Color(hex: 0x080C15)
    public static let darkCard       = Color(hex: 0x111827)
    public static let darkElevated   = Color(hex: 0x192237)
    public static let darkBorder     = Color(hex: 0x1E293B)

    // Light Mode Palette
    public static let lightBackground = Color(hex: 0xF8FAFC)
    public static let lightCard       = Color(hex: 0xFFFFFF)
    public static let lightBorder     = Color(hex: 0xE2E8F0)

    // Status Colors
    public static let statusAvailable = Color(hex: 0x10B981)
    public static let statusBusy      = Color(hex: 0xF59E0B)
    public static let statusOffline   = Color(hex: 0xEF4444)
    public static let statusFastDC    = Color(hex: 0x0284C7)
}

public enum VNEFont {
    public static func poppins(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom("Poppins-\(weightName(for: weight))", size: size)
            .bold(weight == .bold || weight == .heavy || weight == .black)
    }

    private static func weightName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold: return "Bold"
        case .semibold: return "SemiBold"
        case .medium: return "Medium"
        case .light: return "Light"
        default: return "Regular"
        }
    }
}

// MARK: - 2. HAPTIC FEEDBACK GENERATOR

public struct VNEHaptics {
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// MARK: - 3. BUTTON STYLES & COMPONENTS

public enum VNEButtonVariant {
    case primary
    case secondary
    case outline
    case danger
    case ghost
}

public struct VNEButtonStyle: ButtonStyle {
    public var variant: VNEButtonVariant = .primary
    public var isFullWidth: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(VNEFont.poppins(14, weight: .semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(background(for: variant, isPressed: configuration.isPressed))
            .foregroundColor(foregroundColor(for: variant))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor(for: variant), lineWidth: variant == .outline ? 1.5 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }

    private func background(for variant: VNEButtonVariant, isPressed: Bool) -> some View {
        Group {
            switch variant {
            case .primary:
                LinearGradient(
                    gradient: Gradient(colors: [VNEColor.primary600, VNEColor.accentNeon]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(isPressed ? 0.85 : 1.0)
            case .secondary:
                VNEColor.darkElevated.opacity(isPressed ? 0.7 : 1.0)
            case .outline, .ghost:
                Color.clear
            case .danger:
                Color.red.opacity(isPressed ? 0.8 : 1.0)
            }
        }
    }

    private func foregroundColor(for variant: VNEButtonVariant) -> Color {
        switch variant {
        case .primary: return Color(hex: 0x051B11)
        case .secondary, .outline: return VNEColor.accentNeon
        case .ghost: return Color.primary
        case .danger: return Color.white
        }
    }

    private func borderColor(for variant: VNEButtonVariant) -> Color {
        switch variant {
        case .outline: return VNEColor.primary500.opacity(0.8)
        default: return Color.clear
        }
    }
}

// MARK: - 4. EV LIVE CHARGING DIAL GAUGE (SWIFTUI)

public struct VNEChargingDial: View {
    @Binding public var currentBattery: Double // 0 - 100 %
    public var powerKw: Double                 // e.g. 215.4 kW
    public var rangeKm: Int                    // e.g. 485 km
    public var targetPercent: Int = 90
    public var isCharging: Bool = true
    public var size: CGFloat = 220

    public init(
        currentBattery: Binding<Double>,
        powerKw: Double,
        rangeKm: Int,
        targetPercent: Int = 90,
        isCharging: Bool = true,
        size: CGFloat = 220
    ) {
        self._currentBattery = currentBattery
        self.powerKw = powerKw
        self.rangeKm = rangeKm
        self.targetPercent = targetPercent
        self.isCharging = isCharging
        self.size = size
    }

    public var body: some View {
        ZStack {
            if isCharging {
                Circle()
                    .fill(VNEColor.accentNeon.opacity(0.12))
                    .blur(radius: 28)
                    .frame(width: size, height: size)
            }

            Circle()
                .stroke(VNEColor.darkBorder.opacity(0.7), lineWidth: 12)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(currentBattery / 100.0, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: [VNEColor.accentNeon, VNEColor.primary500],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .animation(.easeOut(duration: 0.8), value: currentBattery)

            VStack(spacing: 2) {
                if isCharging {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(VNEColor.accentNeon)
                        Text(String(format: "%.1f kW", powerKw))
                            .font(VNEFont.poppins(12, weight: .semibold))
                            .foregroundColor(VNEColor.accentNeon)
                    }
                } else {
                    Text("ĐÃ NGẮT")
                        .font(VNEFont.poppins(11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(currentBattery))")
                        .font(.system(size: 46, weight: .black, design: .monospaced))
                        .foregroundColor(.primary)
                    Text("%")
                        .font(VNEFont.poppins(18, weight: .bold))
                        .foregroundColor(VNEColor.accentNeon)
                }

                Text("\(rangeKm) km • Sẵn sàng")
                    .font(VNEFont.poppins(11, weight: .medium))
                    .foregroundColor(.secondary)

                Text("Mục tiêu: \(targetPercent)%")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(VNEColor.darkElevated)
                    .cornerRadius(8)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 5. REMOTE TELEMATICS CAR CONTROL CARD

public struct VNECarControlCard: View {
    public let vehicleName: String
    public let licensePlate: String
    public let batteryPercent: Int
    public let rangeKm: Int
    @Binding public var isLocked: Bool
    @Binding public var isAcOn: Bool
    public var onHornTapped: () -> Void
    public var onTrunkTapped: () -> Void

    public init(
        vehicleName: String,
        licensePlate: String,
        batteryPercent: Int,
        rangeKm: Int,
        isLocked: Binding<Bool>,
        isAcOn: Binding<Bool>,
        onHornTapped: @escaping () -> Void,
        onTrunkTapped: @escaping () -> Void
    ) {
        self.vehicleName = vehicleName
        self.licensePlate = licensePlate
        self.batteryPercent = batteryPercent
        self.rangeKm = rangeKm
        self._isLocked = isLocked
        self._isAcOn = isAcOn
        self.onHornTapped = onHornTapped
        self.onTrunkTapped = onTrunkTapped
    }

    public var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CHẾ ĐỘ THỂ THAO")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(VNEColor.primary500)
                        .foregroundColor(Color(hex: 0x051B11))
                        .cornerRadius(6)

                    Text(vehicleName)
                        .font(VNEFont.poppins(17, weight: .bold))
                        .foregroundColor(.white)

                    Text("Biển số: \(licensePlate)")
                        .font(VNEFont.poppins(11, weight: .regular))
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(batteryPercent)%")
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(VNEColor.accentNeon)
                    Text("Ước tính \(rangeKm) km")
                        .font(VNEFont.poppins(10, weight: .medium))
                        .foregroundColor(.gray)
                }
            }

            Divider()
                .background(Color.white.opacity(0.12))

            HStack(spacing: 10) {
                controlActionButton(
                    icon: isLocked ? "lock.fill" : "lock.open.fill",
                    label: isLocked ? "Khóa xe" : "Mở cửa",
                    activeColor: VNEColor.accentNeon
                ) {
                    VNEHaptics.impact(.heavy)
                    isLocked.toggle()
                }

                controlActionButton(
                    icon: "snowflake",
                    label: isAcOn ? "21°C Bật" : "Tắt AC",
                    activeColor: Color.cyan
                ) {
                    VNEHaptics.impact(.medium)
                    isAcOn.toggle()
                }

                controlActionButton(
                    icon: "megaphone.fill",
                    label: "Còi/Đèn",
                    activeColor: Color.yellow
                ) {
                    VNEHaptics.impact(.rigid)
                    onHornTapped()
                }

                controlActionButton(
                    icon: "car.fill",
                    label: "Mở cốp",
                    activeColor: Color.purple
                ) {
                    VNEHaptics.impact(.medium)
                    onTrunkTapped()
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x111827), Color(hex: 0x0B0F19)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
    }

    private func controlActionButton(
        icon: String,
        label: String,
        activeColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(activeColor)
                Text(label)
                    .font(VNEFont.poppins(10, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.06))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 6. EV CHARGING STATION DISCOVERY CARD

public struct VNEStationCard: View {
    public let name: String
    public let address: String
    public let distance: String
    public let speedKw: Int
    public let availablePorts: Int
    public let totalPorts: Int
    public let ratePerKwh: Int
    public let rating: Double
    public let onNavigate: () -> Void
    public let onSelectDetail: () -> Void

    public init(
        name: String,
        address: String,
        distance: String,
        speedKw: Int,
        availablePorts: Int,
        totalPorts: Int,
        ratePerKwh: Int,
        rating: Double,
        onNavigate: @escaping () -> Void,
        onSelectDetail: @escaping () -> Void
    ) {
        self.name = name
        self.address = address
        self.distance = distance
        self.speedKw = speedKw
        self.availablePorts = availablePorts
        self.totalPorts = totalPorts
        self.ratePerKwh = ratePerKwh
        self.rating = rating
        self.onNavigate = onNavigate
        self.onSelectDetail = onSelectDetail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(speedKw) kW ULTRA")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(VNEColor.primary500.opacity(0.15))
                    .foregroundColor(VNEColor.accentNeon)
                    .cornerRadius(6)

                HStack(spacing: 4) {
                    Circle()
                        .fill(VNEColor.statusAvailable)
                        .frame(width: 6, height: 6)
                    Text("Còn \(availablePorts)/\(totalPorts) cổng trống")
                        .font(VNEFont.poppins(10, weight: .semibold))
                        .foregroundColor(VNEColor.statusAvailable)
                }

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.amber)
                    Text(String(format: "%.1f", rating))
                        .font(VNEFont.poppins(11, weight: .bold))
                        .foregroundColor(.primary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(VNEFont.poppins(15, weight: .bold))
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(VNEColor.accentNeon)
                    Text("\(address) • \(distance)")
                        .font(VNEFont.poppins(11, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Đơn giá sạc")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text("\(ratePerKwh.formattedWithSeparator)đ / kWh")
                        .font(VNEFont.poppins(12, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text("Giờ hoạt động")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text("24/7 Mở cửa")
                        .font(VNEFont.poppins(12, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(VNEColor.darkElevated.opacity(0.5))
            .cornerRadius(12)

            HStack(spacing: 10) {
                Button(action: onNavigate) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Chỉ đường")
                    }
                }
                .buttonStyle(VNEButtonStyle(variant: .secondary, isFullWidth: true))

                Button(action: onSelectDetail) {
                    HStack(spacing: 6) {
                        Text("Xem chi tiết")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(VNEButtonStyle(variant: .primary, isFullWidth: true))
            }
        }
        .padding(16)
        .background(VNEColor.darkCard)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(VNEColor.darkBorder, lineWidth: 1)
        )
    }
}

// MARK: - 7. CONNECTOR PLUG SELECTION ROW

public enum VNEConnectorType: String {
    case ccs2 = "CCS 2 (DC Siêu nhanh)"
    case type2 = "Type 2 (AC Tiêu chuẩn)"
    case nacs = "NACS (Tesla Standard)"
    case gbt = "GB/T (Chuẩn Quốc tế)"
}

public struct VNEConnectorCard: View {
    public let slotCode: String       // e.g. "Trụ A-01"
    public let type: VNEConnectorType
    public let powerKw: Int           // e.g. 350
    public let ratePerKwh: Int
    public let isAvailable: Bool
    public let isSelected: Bool
    public let onSelect: () -> Void

    public init(
        slotCode: String,
        type: VNEConnectorType,
        powerKw: Int,
        ratePerKwh: Int,
        isAvailable: Bool,
        isSelected: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.slotCode = slotCode
        self.type = type
        self.powerKw = powerKw
        self.ratePerKwh = ratePerKwh
        self.isAvailable = isAvailable
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: {
            guard isAvailable else { return }
            VNEHaptics.impact(.light)
            onSelect()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? VNEColor.primary500.opacity(0.2) : VNEColor.darkElevated)
                        .frame(width: 44, height: 44)

                    Image(systemName: "cable.connector.horizontal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isSelected ? VNEColor.accentNeon : .gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(slotCode)
                            .font(VNEFont.poppins(13, weight: .bold))
                            .foregroundColor(.primary)
                        Text("\(powerKw) kW")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(powerKw >= 150 ? VNEColor.primary500 : Color.blue)
                            .foregroundColor(Color(hex: 0x051B11))
                            .cornerRadius(5)
                    }

                    Text("\(type.rawValue) • \(ratePerKwh.formattedWithSeparator)đ/kWh")
                        .font(VNEFont.poppins(11, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if isAvailable {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(VNEColor.statusAvailable)
                                .frame(width: 6, height: 6)
                            Text("Sẵn sàng")
                                .font(VNEFont.poppins(11, weight: .semibold))
                                .foregroundColor(VNEColor.statusAvailable)
                        }
                    } else {
                        Text("Đang sạc")
                            .font(VNEFont.poppins(11, weight: .medium))
                            .foregroundColor(VNEColor.statusBusy)
                    }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? VNEColor.accentNeon : .secondary.opacity(0.4))
                        .font(.system(size: 16))
                }
            }
            .padding(14)
            .background(isSelected ? VNEColor.primary500.opacity(0.06) : VNEColor.darkCard)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? VNEColor.primary500 : VNEColor.darkBorder, lineWidth: isSelected ? 2 : 1)
            )
            .opacity(isAvailable ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
    }
}

// MARK: - 8. NFC & ISO 15118 PLUG & CHARGE RADAR VIEW

public struct VNENFCScannerView: View {
    @State private var isPulsing = false
    public var onScanCompleted: () -> Void

    public init(onScanCompleted: @escaping () -> Void) {
        self.onScanCompleted = onScanCompleted
    }

    public var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(VNEColor.accentNeon.opacity(isPulsing ? 0.0 : 0.4), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(isPulsing ? 1.35 : 0.8)

                Circle()
                    .stroke(VNEColor.accentNeon.opacity(isPulsing ? 0.0 : 0.6), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(isPulsing ? 1.25 : 0.9)

                Button(action: {
                    VNEHaptics.notification(.success)
                    onScanCompleted()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [VNEColor.primary600, VNEColor.accentNeon],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: VNEColor.accentNeon.opacity(0.45), radius: 18, x: 0, y: 0)

                        Image(systemName: "wave.3.forward.circle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(Color(hex: 0x051B11))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }

            VStack(spacing: 6) {
                Text("Đưa điện thoại lại gần nắp sạc / thẻ NFC")
                    .font(VNEFont.poppins(14, weight: .bold))
                    .foregroundColor(.primary)

                Text("Hỗ trợ chuẩn ISO 15118 Plug & Charge • Tự động nhận diện xe")
                    .font(VNEFont.poppins(11, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - 9. HELPER EXTENSIONS

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }

    static var amber: Color {
        Color(hex: 0xF59E0B)
    }
}

private extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - 10. TPMS TIRE PRESSURE MONITOR VIEW

public struct VNETPMSCard: View {
    public let fl: Double
    public let fr: Double
    public let rl: Double
    public let rr: Double
    public var onDeflate: () -> Void

    private func pressureColor(_ val: Double) -> Color {
        if val < 2.0 { return VNEColor.statusBusy }
        if val < 1.8 { return VNEColor.statusOffline }
        return VNEColor.statusAvailable
    }

    public init(fl: Double, fr: Double, rl: Double, rr: Double, onDeflate: @escaping () -> Void) {
        self.fl = fl; self.fr = fr; self.rl = rl; self.rr = rr
        self.onDeflate = onDeflate
    }

    public var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Áp suất lốp (TPMS)")
                    .font(VNEFont.poppins(13, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { VNEHaptics.impact(.medium); onDeflate() }) {
                    Text("Xả khí")
                        .font(VNEFont.poppins(11, weight: .semibold))
                        .foregroundColor(VNEColor.statusBusy)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow {
                    tireCell(label: "Trước Trái", value: fl)
                    tireCell(label: "Trước Phải", value: fr)
                }
                GridRow {
                    tireCell(label: "Sau Trái", value: rl)
                    tireCell(label: "Sau Phải", value: rr)
                }
            }
        }
        .padding(16)
        .background(VNEColor.darkCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(VNEColor.darkBorder, lineWidth: 1))
    }

    @ViewBuilder
    private func tireCell(label: String, value: Double) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 9)).foregroundColor(.secondary)
            Text(String(format: "%.1f", value))
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(pressureColor(value))
            Text("Bar").font(.system(size: 9)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(VNEColor.darkElevated)
        .cornerRadius(12)
    }
}

// MARK: - 11. THERMAL WARNING BANNER

public struct VNEThermalWarningBanner: View {
    public let temperatureC: Double
    public var isVisible: Bool { temperatureC >= 42 }

    public init(temperatureC: Double) {
        self.temperatureC = temperatureC
    }

    public var body: some View {
        if isVisible {
            HStack(spacing: 10) {
                Image(systemName: "thermometer.sun.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                    .symbolEffect(.pulse)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CẢNH BÁO NHIỆT ĐỘ CAO!")
                        .font(VNEFont.poppins(12, weight: .bold))
                        .foregroundColor(.red)
                    Text("Pin đang ở \(Int(temperatureC))°C — BMS đang kích hoạt hệ thống làm mát khẩn cấp.")
                        .font(VNEFont.poppins(11, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(14)
            .background(Color.red.opacity(0.12))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.4), lineWidth: 1))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - 12. VNEGREEN WALLET CARD

public enum VNEPaymentMethod: String, CaseIterable {
    case applePay   = "Apple Pay"
    case googlePay  = "Google Pay"
    case napasQR    = "QR Napas 24/7"
}

public struct VNEWalletCard: View {
    public let balanceVND: Int
    public let ecoPoints: Int
    @Binding public var selectedMethod: VNEPaymentMethod
    public var onTopUp: () -> Void
    public var onRedeemPoints: () -> Void

    public init(
        balanceVND: Int,
        ecoPoints: Int,
        selectedMethod: Binding<VNEPaymentMethod>,
        onTopUp: @escaping () -> Void,
        onRedeemPoints: @escaping () -> Void
    ) {
        self.balanceVND = balanceVND
        self.ecoPoints = ecoPoints
        self._selectedMethod = selectedMethod
        self.onTopUp = onTopUp
        self.onRedeemPoints = onRedeemPoints
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Balance Row
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Số dư khả dụng")
                        .font(VNEFont.poppins(11, weight: .regular))
                        .foregroundColor(.secondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(balanceVND.formattedWithSeparator)
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.primary)
                        Text("VNĐ")
                            .font(VNEFont.poppins(12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button(action: { VNEHaptics.impact(.medium); onTopUp() }) {
                    Text("+ Nạp thêm")
                        .font(VNEFont.poppins(13, weight: .bold))
                        .foregroundColor(Color(hex: 0x051B11))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(VNEColor.accentNeon)
                        .cornerRadius(14)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Divider().background(Color.white.opacity(0.1))

            // Payment Method Selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Phương thức thanh toán")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                HStack(spacing: 8) {
                    ForEach(VNEPaymentMethod.allCases, id: \.self) { method in
                        Button(action: {
                            VNEHaptics.impact(.light)
                            selectedMethod = method
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: paymentIcon(for: method))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(selectedMethod == method ? VNEColor.accentNeon : .secondary)
                                Text(method.rawValue)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(selectedMethod == method ? VNEColor.accentNeon : .secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedMethod == method ? VNEColor.primary500.opacity(0.15) : VNEColor.darkElevated)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedMethod == method ? VNEColor.primary500 : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            Divider().background(Color.white.opacity(0.1))

            // Eco Points
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(VNEColor.accentNeon)
                VStack(alignment: .leading, spacing: 2) {
                    Text("VNEGREEN Eco Points")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(VNEColor.accentNeon)
                    Text("\(ecoPoints) điểm ≈ \(ecoPoints * 100) đ ưu đãi")
                        .font(VNEFont.poppins(12, weight: .semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
                Button(action: { VNEHaptics.impact(.medium); onRedeemPoints() }) {
                    Text("Đổi điểm")
                        .font(VNEFont.poppins(11, weight: .bold))
                        .foregroundColor(Color(hex: 0x051B11))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(VNEColor.primary500)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(18)
        .background(VNEColor.darkCard)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(VNEColor.darkBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }

    private func paymentIcon(for method: VNEPaymentMethod) -> String {
        switch method {
        case .applePay:  return "apple.logo"
        case .googlePay: return "g.circle.fill"
        case .napasQR:   return "qrcode"
        }
    }
}

// MARK: - 13. ECO POINTS CARBON BADGE

public struct VNEEcoPointsCard: View {
    public let totalPoints: Int
    public let co2SavedKg: Double
    public let lastSessionPoints: Int

    public init(totalPoints: Int, co2SavedKg: Double, lastSessionPoints: Int) {
        self.totalPoints = totalPoints
        self.co2SavedKg = co2SavedKg
        self.lastSessionPoints = lastSessionPoints
    }

    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(VNEColor.primary500.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(VNEColor.accentNeon)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Tín chỉ Carbon VNEGREEN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(VNEColor.accentNeon)
                    .textCase(.uppercase)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(totalPoints)")
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(.primary)
                    Text("Điểm Eco")
                        .font(VNEFont.poppins(12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Text("Giảm thiểu \(String(format: "%.1f", co2SavedKg)) kg CO₂  •  +\(lastSessionPoints) từ phiên vừa rồi")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [VNEColor.primary500.opacity(0.12), VNEColor.accentNeon.opacity(0.07)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(VNEColor.primary500.opacity(0.3), lineWidth: 1))
    }
}
