import SwiftUI

struct FilterChips: View {
    @Binding var fuel: FuelType
    @Binding var mode: ServiceMode
    @Binding var sort: StationSort

    var body: some View {
        HStack(spacing: 8) {
            Menu {
                Picker(selection: $fuel) {
                    ForEach(FuelType.allCases, id: \.self) { fuel in
                        Text(fuel.localizedName).tag(fuel)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                chip {
                    Text(fuel.localizedName)
                    Image(systemName: "chevron.down").font(.caption2.weight(.bold))
                }
            }
            Button {
                mode = mode == .selfService ? .fullService : .selfService
            } label: {
                chip { Text(mode.localizedName) }
            }
            Button {
                sort = sort == .price ? .distance : .price
            } label: {
                chip { Text(sort.localizedName) }
            }
        }
        .buttonStyle(.plain)
    }

    private func chip(@ViewBuilder _ content: () -> some View) -> some View {
        HStack(spacing: 4, content: content)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 4, y: 1)
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
