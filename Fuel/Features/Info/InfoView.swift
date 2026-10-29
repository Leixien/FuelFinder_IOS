import SwiftUI

struct InfoView: View {
    /// Nil before the first download: the attribution still shows, with the dataset's public page.
    let payload: StationsPayload?

    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @Environment(\.dismiss) private var dismiss

    private static let mimitURL = URL(
        string: "https://www.mimit.gov.it/it/open-data/elenco-dataset/carburanti-prezzi-praticati-e-anagrafica-degli-impianti"
    )!
    private static let repoURL = URL(string: "https://github.com/Leixien/FuelFinder_IOS")!

    var body: some View {
        NavigationStack {
            List {
                Section("Dati") {
                    // Required by the IODL 2.0 licence: whole, linked and in Italian in every language.
                    Link(destination: payload?.source.url ?? Self.mimitURL) {
                        Label {
                            Text(verbatim: "Fonte dati: MIMIT – Osservaprezzi Carburanti")
                        } icon: {
                            Image(systemName: "building.columns")
                        }
                    }
                    LabeledContent("Licenza dei dati", value: "IODL 2.0")
                    if let day = payload.flatMap({ Formatters.referenceDay($0.pricesReferenceDate) }) {
                        LabeledContent("Prezzi del", value: day)
                    }
                }
                Section("App") {
                    Link(destination: Self.repoURL) {
                        Label("Codice sorgente su GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    LabeledContent("Licenza del codice", value: "Apache 2.0")
                    LabeledContent("Versione", value: version)
                }
                Section("Aspetto") {
                    Button("Usa impostazioni di sistema") {
                        theme = .system
                        dismiss()
                    }
                    .disabled(theme == .system)
                    .accessibilityIdentifier("info.systemTheme")
                }
            }
            .navigationTitle("Informazioni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") { dismiss() }
                }
            }
        }
    }

    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }
}

#Preview {
    InfoView(payload: PreviewData.payload)
}
