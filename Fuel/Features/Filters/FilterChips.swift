import SwiftUI

struct FilterChips: View {
    @Binding var fuel: FuelType
    @Binding var mode: ServiceMode
    @Binding var sort: StationSort

    var body: some View {
        GlassGroup(spacing: 8) {
            chips
        }
    }

    private var chips: some View {
        HStack(spacing: 8) {
            Menu {
                // Toggles, not a Picker: only Button and Toggle labels show the second Text as a subtitle.
                ForEach(FuelType.allCases, id: \.self) { option in
                    Toggle(isOn: Binding(get: { fuel == option }, set: { if $0 { fuel = option } })) {
                        Text(option.localizedName)
                        Text(option.explanation)
                    }
                }
            } label: {
                chip {
                    Text(fuel.localizedName)
                    Image(systemName: "chevron.down").font(.caption2.weight(.bold)).accessibilityHidden(true)
                }
            }
            .accessibilityLabel(Text("Carburante: \(Text(fuel.localizedName))"))
            Button {
                mode = mode == .selfService ? .fullService : .selfService
            } label: {
                chip { Text(mode.localizedName) }
            }
            .accessibilityLabel(Text("Modalità: \(Text(mode.localizedName))"))
            Button {
                sort = sort == .price ? .distance : .price
            } label: {
                chip { Text(sort.localizedName) }
            }
            .accessibilityLabel(Text("Ordine: \(Text(sort.localizedName))"))
        }
        .buttonStyle(.plain)
    }

    private func chip(@ViewBuilder _ content: () -> some View) -> some View {
        HStack(spacing: 4, content: content)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            // A full 44 pt target: these get tapped on a phone mount.
            .frame(minHeight: 44)
            .glassSurface(in: Capsule(), interactive: true)
    }
}

extension ServiceMode {
    var localizedName: LocalizedStringResource {
        switch self {
        case .selfService: "Self"
        case .fullService: "Servito"
        }
    }
}

extension StationSort {
    var localizedName: LocalizedStringResource {
        switch self {
        case .price: "Più economici"
        case .distance: "Più vicini"
        }
    }
}

#Preview {
    FilterChips(fuel: .constant(.benzina), mode: .constant(.selfService), sort: .constant(.price))
        .padding()
        .background(.gray.opacity(0.3))
}
